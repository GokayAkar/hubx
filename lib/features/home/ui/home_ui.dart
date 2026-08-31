import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/ui/bloc/home_bloc.dart';
import 'package:hubx/features/home/ui/paging/categories_paging_controller.dart';

export 'bloc/home_bloc.dart';
export 'detail/content_detail_page.dart';
export 'view/home_page.dart';

/// Registers this feature's presentation dependencies.
///
/// Screen-scoped blocs are registered as factories: one instance per screen,
/// owned and closed by the `BlocProvider` that creates it. The paging
/// controller is the same bargain — one per screen, disposed with it.
void registerHomeUi() {
  DependencyProvider.registerFactory<HomeBloc>(
    () => HomeBloc(DependencyProvider.get<HomeRepository>()),
  );
  DependencyProvider.registerFactory<CategoriesPagingController>(
    () => CategoriesPagingController(DependencyProvider.get<HomeRepository>()),
  );
}
