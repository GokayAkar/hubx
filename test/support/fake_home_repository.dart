import 'dart:async';

import 'package:hubx/features/home/api/home_api.dart';

/// Stands in for the server in widget tests.
///
/// Registered by every suite that mounts the app, because the home page is the
/// first tab and starts fetching the moment it appears: without this, tests
/// reach the network, and a suite that needs a connection to pass is a suite
/// that fails for reasons that have nothing to do with the code.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.categoryCount = 3,
    this.failQuestions = false,
    this.failCategoryPage = 0,
    this.pending = false,
  });

  /// How many categories the server has in total, across every page.
  final int categoryCount;

  final bool failQuestions;

  /// The page number to fail on; 0 to answer every page.
  final int failCategoryPage;

  /// Holds every answer back until [release], so a test can look at the frame
  /// where nothing has arrived yet.
  ///
  /// A delay would not do: `pumpAndSettle` advances the test clock, so any
  /// delay short enough to be convenient is one the pumping runs past.
  final bool pending;

  final _gate = Completer<void>();

  void release() => _gate.complete();

  /// Pages actually asked for, in order.
  final requestedPages = <int>[];

  static const questions = [
    Question(
      id: 1,
      title: 'How to identify plants?',
      subtitle: 'Life Style',
      imageUrl: 'https://example.test/card.png',
      articleUrl: 'https://example.test/article',
    ),
    Question(
      id: 2,
      title: 'Differences Between Species and Varieties?',
      subtitle: 'Plant Identify',
      imageUrl: 'https://example.test/card2.png',
      articleUrl: 'https://example.test/article2',
    ),
  ];

  @override
  Future<List<Question>> fetchQuestions() async {
    if (pending) await _gate.future;
    if (failQuestions) throw Exception('offline');

    return questions;
  }

  @override
  Future<ResultPage<PlantCategory>> fetchCategories({
    required int page,
    required int pageSize,
  }) async {
    requestedPages.add(page);
    if (pending) await _gate.future;
    if (page == failCategoryPage) throw Exception('offline');

    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, categoryCount);

    return ResultPage(
      items: [
        for (var i = start; i < end; i++)
          PlantCategory(
            id: i,
            title: 'Category $i',
            imageUrl: 'https://example.test/$i.png',
          ),
      ],
      hasMore: end < categoryCount,
    );
  }
}
