import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/features/home/ui/paging/categories_paging_controller.dart';

import '../../../../support/fake_home_repository.dart';

/// The grid's state machine. Not a bloc, but it holds exactly what one would:
/// which page comes next, what has arrived, and what went wrong.
void main() {
  late FakeHomeRepository repository;
  late CategoriesPagingController controller;

  void build({int categoryCount = 3, int failCategoryPage = 0}) {
    repository = FakeHomeRepository(
      categoryCount: categoryCount,
      failCategoryPage: failCategoryPage,
    );
    controller = CategoriesPagingController(repository);
    addTearDown(controller.dispose);
  }

  /// Everything that has arrived, across every page held.
  int loaded(CategoriesPagingController controller) =>
      controller.value.pages?.expand((page) => page).length ?? 0;

  /// Asks for pages until the controller says there are none left, or until
  /// [limit] — so a controller that never stops fails the test instead of
  /// hanging it.
  Future<void> exhaust({int limit = 10}) async {
    for (var i = 0; i < limit && controller.value.hasNextPage; i++) {
      controller.fetchNextPage();
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('CategoriesPagingController', () {
    test('counts from one, because the server does', () async {
      build();
      controller.fetchNextPage();
      await Future<void>.delayed(Duration.zero);

      expect(repository.requestedPages, [1]);
    });

    test('stops the moment the server says there is no more', () async {
      // Two full pages and a short third.
      build(categoryCount: CategoriesPagingController.pageSize * 2 + 1);
      await exhaust();

      // Three requests, not four: `hasMore` comes from the server's own count,
      // so the last page is known to be the last. A client that inferred it
      // from a short page would still ask once more and get nothing.
      expect(repository.requestedPages, [1, 2, 3]);
      expect(loaded(controller), CategoriesPagingController.pageSize * 2 + 1);
      expect(controller.value.hasNextPage, isFalse);
    });

    test('a single short page is the whole list', () async {
      build();
      await exhaust();

      expect(repository.requestedPages, [1]);
      expect(loaded(controller), 3);
    });

    test('an empty catalogue is an answer, not a failure', () async {
      build(categoryCount: 0);
      await exhaust();

      expect(loaded(controller), 0);
      expect(controller.value.error, isNull);
      expect(controller.value.hasNextPage, isFalse);
    });

    test('keeps the failure so the grid can offer a retry', () async {
      build(failCategoryPage: 1);
      controller.fetchNextPage();
      await Future<void>.delayed(Duration.zero);

      expect(controller.value.error, isA<Exception>());
      expect(loaded(controller), 0);
    });

    test(
      'a page that fails part way keeps the pages already in hand',
      () async {
        build(categoryCount: 100, failCategoryPage: 2);
        controller.fetchNextPage();
        await Future<void>.delayed(Duration.zero);
        controller.fetchNextPage();
        await Future<void>.delayed(Duration.zero);

        // The first page stays on screen; only the addition failed.
        expect(loaded(controller), CategoriesPagingController.pageSize);
        expect(controller.value.error, isA<Exception>());
      },
    );

    test('refresh starts the whole list over from the first page', () async {
      build(categoryCount: 100);
      controller.fetchNextPage();
      await Future<void>.delayed(Duration.zero);
      controller.fetchNextPage();
      await Future<void>.delayed(Duration.zero);
      expect(repository.requestedPages, [1, 2]);

      controller
        ..refresh()
        ..fetchNextPage();
      await Future<void>.delayed(Duration.zero);

      expect(repository.requestedPages, [1, 2, 1]);
      expect(loaded(controller), CategoriesPagingController.pageSize);
    });
  });
}
