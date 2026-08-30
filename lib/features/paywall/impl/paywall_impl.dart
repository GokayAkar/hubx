/// Paywall domain implementation.
///
/// The classes live in `part` files and are named with a leading underscore, so
/// nothing outside this library can import or reference them.
library;

import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';

part 'src/paywall_repository_impl.dart';

/// Binds [PaywallRepository] to its implementation.
void registerPaywallDomain() {
  DependencyProvider.registerLazySingleton<PaywallRepository>(
    _PaywallRepositoryImpl.new,
  );
}
