import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/paywall/ui/bloc/paywall_bloc.dart';

export 'bloc/paywall_bloc.dart';
export 'paywall_page.dart';

/// Registers this feature's presentation dependencies.
void registerPaywallUi() {
  DependencyProvider.registerFactory<PaywallBloc>(
    () => PaywallBloc(DependencyProvider.get<PaywallRepository>()),
  );
}
