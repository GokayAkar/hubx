import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/home/ui/bloc/home_bloc.dart';

export 'bloc/home_bloc.dart';
export 'view/home_page.dart';

/// Registers this feature's presentation dependencies.
///
/// Screen-scoped blocs are registered as factories: one instance per screen,
/// owned and closed by the `BlocProvider` that creates it.
void registerHomeUi() {
  DependencyProvider.registerFactory<HomeBloc>(HomeBloc.new);
}
