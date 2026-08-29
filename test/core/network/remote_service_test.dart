import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';
import 'package:hubx/core/logging/impl/logging_impl.dart';
import 'package:hubx/core/network/api/network_api.dart';
import 'package:hubx/core/network/impl/network_impl.dart';

class _RecordingSink implements LogSink {
  final entries = <LogEntry>[];

  Iterable<LogMessage> get messages => entries.whereType<LogMessage>();

  /// What the service decided about a call's outcome.
  Iterable<LogMessage> get reports =>
      messages.where((entry) => entry.source == const LogSource('cards'));

  /// What the interceptor traced about each attempt.
  Iterable<LogMessage> get traces =>
      messages.where((entry) => entry.source == const LogSource('network'));

  @override
  void write(LogEntry entry) => entries.add(entry);
}

class _UserService extends RemoteService {
  const _UserService(super.dio, super.logger);

  Future<String> fetchName({
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) => get(
    '/user',
    (json) => (json! as Map<String, Object?>)['name']! as String,
    cancelToken: cancelToken,
    headers: headers,
  );

  Future<void> rename(String name) =>
      post('/user', (_) {}, body: {'name': name});
}

/// The shape the real auth interceptor will take: attach the token, and on a
/// 401 refresh it and replay. Queued, so concurrent failures refresh once.
class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;

  String token = 'stale';
  int refreshes = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['authorization'] = token;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode != 401) return handler.next(error);

    // Queuing serialises the failures, but each one still arrives holding its
    // own 401. Refresh only if nobody refreshed while this one waited.
    if (error.requestOptions.headers['authorization'] == token) {
      refreshes++;
      token = 'fresh';
    }

    try {
      handler.resolve(
        await _dio.fetch<Object?>(
          error.requestOptions..headers['authorization'] = token,
        ),
      );
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}

void main() {
  late HttpServer server;
  late Dio dio;
  late Logger logger;
  late _RecordingSink sink;
  late List<HttpHeaders> received;

  _UserService service() => _UserService(dio, logger);

  /// Serves whatever [handle] decides, so each test shapes its own backend.
  Future<void> serve(
    Future<void> Function(HttpRequest request) handle,
  ) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(
      server.forEach((request) async {
        received.add(request.headers);
        await handle(request);
      }),
    );

    await DependencyProvider.reset();
    registerLogging();
    registerNetwork(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'));
    dio = DependencyProvider.get<Dio>();
    sink = _RecordingSink();
    DependencyProvider.get<LogSinkRegistry>().addSink(sink);
    logger = DependencyProvider.get<Logger>().withSource(
      const LogSource('cards'),
    );
  }

  setUp(() => received = []);
  tearDown(() => server.close(force: true));

  test('returns the parsed model', () async {
    await serve((request) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'name': 'Gokay'}));
      await request.response.close();
    });

    expect(await service().fetchName(), 'Gokay');
  });

  test('turns a failing status into ApiStatusException', () async {
    await serve((request) async {
      request.response.statusCode = 503;
      await request.response.close();
    });

    await expectLater(
      service().fetchName(),
      throwsA(
        isA<ApiStatusException>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.isServerError, 'isServerError', isTrue)
            .having((e) => e.path, 'path', '/user'),
      ),
    );
  });

  test('turns an unreachable host into ApiConnectionException', () async {
    await serve((request) async => request.response.close());
    await server.close(force: true);

    await expectLater(
      service().fetchName(),
      throwsA(isA<ApiConnectionException>()),
    );
  });

  test('a parser that chokes becomes ApiParsingException', () async {
    await serve((request) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'unexpected': true}));
      await request.response.close();
    });

    await expectLater(
      service().fetchName(),
      throwsA(isA<ApiParsingException>()),
    );
  });

  test('reports a broken body, which no interceptor could see', () async {
    await serve((request) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'unexpected': true}));
      await request.response.close();
    });

    await expectLater(
      service().fetchName(),
      throwsA(isA<ApiParsingException>()),
    );

    expect(sink.reports.single.level, LogLevel.error);
    expect(sink.reports.single.source, const LogSource('cards'));
  });

  test('a cancelled request is not reported as a failure', () async {
    await serve((request) async {
      await Future<void>.delayed(const Duration(seconds: 5));
      await request.response.close();
    });

    final token = CancelToken();
    final result = service().fetchName(cancelToken: token);
    token.cancel();

    await expectLater(result, throwsA(isA<ApiCancelledException>()));
    expect(sink.reports.single.level, LogLevel.debug);
  });

  test('a response without a status code is not mistaken for a 4xx', () async {
    await serve((request) async => request.response.close());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
          ),
        ),
      ),
    );

    await expectLater(
      service().fetchName(),
      throwsA(isA<ApiUnknownException>()),
    );
    expect(sink.reports.single.level, LogLevel.error);
  });

  test('retries an idempotent request the server says is busy', () async {
    var calls = 0;
    await serve((request) async {
      calls++;
      request.response.statusCode = calls < 3 ? 503 : 200;
      if (calls >= 3) {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'name': 'Gokay'}));
      }
      await request.response.close();
    });

    expect(await service().fetchName(), 'Gokay');
    expect(calls, 3);
    // It succeeded in the end, so nothing is reported as a failure.
    expect(sink.reports, isEmpty);
  });

  test('never retries a POST, however transient the failure looks', () async {
    var calls = 0;
    await serve((request) async {
      calls++;
      request.response.statusCode = 503;
      await request.response.close();
    });

    await expectLater(
      service().rename('Gokay'),
      throwsA(isA<ApiStatusException>()),
    );
    // Replaying it could place the same order twice.
    expect(calls, 1);
  });

  test('does not retry a failure that will not heal', () async {
    var calls = 0;
    await serve((request) async {
      calls++;
      request.response.statusCode = 404;
      await request.response.close();
    });

    await expectLater(
      service().fetchName(),
      throwsA(isA<ApiStatusException>()),
    );
    expect(calls, 1);
  });

  test('traces what went out and what came back', () async {
    await serve((request) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'name': 'Gokay'}));
      await request.response.close();
    });

    await service().fetchName();

    final traces = sink.traces.toList();
    expect(traces, hasLength(2));
    expect(traces.first.level, LogLevel.debug);
    expect(traces.first.message, '-> GET /user');
    expect(traces.last.message, startsWith('<- 200 GET /user'));
    expect(traces.last.context['ms'], isA<int>());
  });

  test('never traces a secret, even in a header', () async {
    await serve((request) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'name': 'Gokay'}));
      await request.response.close();
    });

    await service().fetchName(headers: {'authorization': 'super-secret'});

    final headers =
        sink.traces.first.context['headers']! as Map<String, Object?>;
    expect(headers['authorization'], '***');
    expect(sink.traces.first.toString(), isNot(contains('super-secret')));
  });

  test('an interceptor can refresh a token and replay the request', () async {
    await serve((request) async {
      final authorized = request.headers.value('authorization') == 'fresh';
      request.response.statusCode = authorized ? 200 : 401;
      if (authorized) {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'name': 'Gokay'}));
      }
      await request.response.close();
    });

    final auth = _AuthInterceptor(dio);
    dio.interceptors.add(auth);

    expect(await service().fetchName(), 'Gokay');
    expect(auth.refreshes, 1);
    // The 401 was recovered from, so nothing failed as far as the app is
    // concerned and nothing is reported.
    expect(sink.reports, isEmpty);
    expect(received.first.value('authorization'), 'stale');
    expect(received.last.value('authorization'), 'fresh');
  });

  test('concurrent 401s refresh the token only once', () async {
    await serve((request) async {
      final authorized = request.headers.value('authorization') == 'fresh';
      request.response.statusCode = authorized ? 200 : 401;
      if (authorized) {
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'name': 'Gokay'}));
      }
      await request.response.close();
    });

    final auth = _AuthInterceptor(dio);
    dio.interceptors.add(auth);
    final user = service();

    await Future.wait([
      user.fetchName(),
      user.fetchName(),
      user.fetchName(),
    ]);

    expect(auth.refreshes, 1);
  });
}
