/// Onboarding domain implementation.
///
/// The classes live in `part` files and are named with a leading underscore, so
/// nothing outside this library can import or reference them.
library;

import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/api/storage_api.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';

part 'src/onboarding_repository_impl.dart';

/// Namespace this feature owns inside the key/value storage.
const _storageNamespace = 'onboarding';

/// Binds [OnboardingRepository] to its implementation.
void registerOnboardingDomain() {
  DependencyProvider.registerLazySingleton<OnboardingRepository>(
    () => _OnboardingRepositoryImpl(
      DependencyProvider.get<KeyValueStorageFactory>().storageFor(
        _storageNamespace,
      ),
    ),
  );
}
