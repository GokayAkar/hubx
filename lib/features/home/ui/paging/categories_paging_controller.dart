import 'package:hubx/features/home/api/home_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Feeds the category grid one page at a time.
///
/// It is where the repository meets the list, so the widget never holds one:
/// the screen asks the container for a controller and shows whatever it emits.
class CategoriesPagingController extends PagingController<int, PlantCategory> {
  factory CategoriesPagingController(HomeRepository repository) {
    // Closed over rather than stored on the object, because the superclass
    // constructor takes the callbacks and there is no `this` to read yet.
    var hasMore = true;

    return CategoriesPagingController._(
      getNextPageKey: (state) {
        if (state.pages == null) return _firstPage;

        return hasMore ? state.pages!.length + _firstPage : null;
      },
      fetchPage: (page) async {
        final result = await repository.fetchCategories(
          page: page,
          pageSize: pageSize,
        );
        hasMore = result.hasMore;

        return result.items;
      },
    );
  }

  CategoriesPagingController._({
    required super.getNextPageKey,
    required super.fetchPage,
  });

  /// The server counts pages from one, not from zero.
  static const _firstPage = 1;

  /// Two columns, so an even number keeps the last row full.
  static const pageSize = 20;
}
