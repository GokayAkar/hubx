part of '../key_value_storage_impl.dart';

class _SharedPrefsKeyValueStorageFactory implements KeyValueStorageFactory {
  const _SharedPrefsKeyValueStorageFactory(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  KeyValueStorage storageFor(String namespace) {
    assert(namespace.isNotEmpty, 'namespace must not be empty');
    return _SharedPrefsKeyValueStorage(
      preferences: _preferences,
      namespace: namespace,
    );
  }
}
