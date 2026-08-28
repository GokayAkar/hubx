/// Implementation of the key/value storage contract.
///
/// Everything below is private to this library: the classes live in `part`
/// files, which Dart refuses to let anyone import. The only thing the app can
/// reach is [registerKeyValueStorage].
library;

import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/api/storage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'src/shared_prefs_key_value_storage.dart';
part 'src/shared_prefs_key_value_storage_factory.dart';

/// Binds the storage contracts to their shared_preferences implementation.
void registerKeyValueStorage() {
  DependencyProvider.registerLazySingleton<KeyValueStorageFactory>(
    () => _SharedPrefsKeyValueStorageFactory(SharedPreferencesAsync()),
  );
}
