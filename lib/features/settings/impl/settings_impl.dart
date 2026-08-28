/// Settings domain implementation.
///
/// The classes live in `part` files and are named with a leading underscore,
/// so nothing outside this library can import or reference them. The app wires
/// the feature up through [registerSettingsDomain] alone.
library;

import 'package:flutter/material.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/api/storage_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

part 'src/settings_repository_impl.dart';

/// Namespace this feature owns inside the key/value storage.
const _storageNamespace = 'settings';

/// Binds [SettingsRepository] to its implementation.
void registerSettingsDomain() {
  DependencyProvider.registerLazySingleton<SettingsRepository>(
    () => _SettingsRepositoryImpl(
      DependencyProvider.get<KeyValueStorageFactory>().storageFor(
        _storageNamespace,
      ),
    ),
  );
}
