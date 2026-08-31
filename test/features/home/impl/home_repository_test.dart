import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/impl/logging_impl.dart';
import 'package:hubx/core/network/api/network_api.dart';
import 'package:hubx/core/network/impl/network_impl.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/impl/home_impl.dart';

/// Exercises the generated parsing through the contract.
///
/// The service and its DTOs are private to `home_impl`, so there is nothing to
/// construct here: the test registers the feature and asks the container for
/// the repository, which is all the app can do either.
void main() {
  late HttpServer server;
  late Uri requested;

  HomeRepository repository() => DependencyProvider.get<HomeRepository>();

  /// Serves [body] as the real API does — labelled `text/html` even though it
  /// is JSON, which is the case `RemoteService` has to undo before a parser
  /// ever sees it.
  Future<void> serve(String body) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(
      server.forEach((request) async {
        requested = request.uri;
        request.response
          ..headers.contentType = ContentType.html
          ..write(body);
        await request.response.close();
      }),
    );

    await DependencyProvider.reset();
    registerLogging();
    registerNetwork(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'));
    registerHomeDomain();
  }

  tearDown(() => server.close(force: true));

  group('fetchQuestions', () {
    test(
      'parses the payload and honours the order the server asks for',
      () async {
        // Deliberately out of order: the list arrives second-first.
        await serve(
          jsonEncode([
            {
              'id': 2,
              'title': 'Differences Between Species and Varieties?',
              'subtitle': 'Plant Identify',
              'image_uri': 'https://example.test/card2.png',
              'uri': 'https://example.test/differences',
              'order': 2,
            },
            {
              'id': 1,
              'title': 'How to identify plants?',
              'subtitle': 'Life Style',
              'image_uri': 'https://example.test/card.png',
              'uri': 'https://example.test/identify',
              'order': 1,
            },
          ]),
        );

        final questions = await repository().fetchQuestions();

        expect(questions.map((question) => question.id), [1, 2]);
        // `image_uri` and `uri` are the wire's names; the app sees neither.
        expect(questions.first.imageUrl, 'https://example.test/card.png');
        expect(questions.first.articleUrl, 'https://example.test/identify');
        expect(questions.first.subtitle, 'Life Style');
      },
    );

    test(
      'a missing field fails loudly rather than arriving half-built',
      () async {
        await serve(
          jsonEncode([
            {
              'id': 1,
              'title': 'How to identify plants?',
              'subtitle': 'Life Style',
              // No `image_uri`: a card with no picture is not a card.
              'uri': 'https://example.test/identify',
              'order': 1,
            },
          ]),
        );

        await expectLater(
          repository().fetchQuestions(),
          throwsA(isA<ApiParsingException>()),
        );
      },
    );
  });

  group('fetchCategories', () {
    /// The endpoint's envelope: a slice under `data`, its place under `meta`.
    String page({required int page, required int pageCount}) => jsonEncode({
      'data': [
        {
          'id': 11,
          'name': 'fern',
          'title': 'Ferns',
          'rank': 0,
          // The real image object carries a dozen more fields; the DTO names
          // the one the app uses and the generator drops the rest.
          'image': {
            'id': 23,
            'mime': 'image/png',
            'url': 'https://example.test/ferns.png',
          },
        },
      ],
      'meta': {
        'pagination': {
          'page': page,
          'pageSize': 20,
          'pageCount': pageCount,
          'total': 9,
        },
      },
    });

    test('parses the slice and asks for the page it was told to', () async {
      await serve(page(page: 1, pageCount: 3));

      final result = await repository().fetchCategories(page: 1, pageSize: 20);

      expect(result.items.single.id, 11);
      expect(result.items.single.title, 'Ferns');
      expect(result.items.single.imageUrl, 'https://example.test/ferns.png');
      expect(requested.queryParameters, {'page': '1', 'pageSize': '20'});
    });

    test(
      'takes hasMore from the server count, not from what arrived',
      () async {
        // One item on page 1 of 3 — a client counting items would call it the
        // last page and stop.
        await serve(page(page: 1, pageCount: 3));

        expect(
          (await repository().fetchCategories(page: 1, pageSize: 20)).hasMore,
          isTrue,
        );
      },
    );

    test('stops when the last page says so', () async {
      await serve(page(page: 3, pageCount: 3));

      expect(
        (await repository().fetchCategories(page: 3, pageSize: 20)).hasMore,
        isFalse,
      );
    });
  });
}
