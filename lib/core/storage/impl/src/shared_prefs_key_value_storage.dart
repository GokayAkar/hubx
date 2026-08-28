part of '../key_value_storage_impl.dart';

class _SharedPrefsKeyValueStorage implements KeyValueStorage {
  const _SharedPrefsKeyValueStorage({
    required SharedPreferencesAsync preferences,
    required String namespace,
  }) : _preferences = preferences,
       _namespace = namespace;

  final SharedPreferencesAsync _preferences;
  final String _namespace;

  String _qualify(StorageKey<Object> key) => '$_namespace.${key.name}';

  @override
  Future<T?> read<T extends Object>(StorageKey<T> key) async {
    final name = _qualify(key);
    final stored = (await _preferences.getAll(allowList: {name}))[name];

    return switch (stored) {
      null => null,
      final T value => value,
      // A string list can come back as List<Object?> and needs re-typing.
      final List<Object?> value => value.cast<String>() as T,
      _ => throw StateError('$key is stored as ${stored.runtimeType}'),
    };
  }

  @override
  Future<void> write<T extends Object>(StorageKey<T> key, T value) async {
    final name = _qualify(key);
    switch (value) {
      case final String value:
        await _preferences.setString(name, value);
      case final int value:
        await _preferences.setInt(name, value);
      case final double value:
        await _preferences.setDouble(name, value);
      case final bool value:
        await _preferences.setBool(name, value);
      case final List<String> value:
        await _preferences.setStringList(name, value);
      default:
        throw UnsupportedError('$key holds an unsupported type');
    }
  }

  @override
  Future<void> delete<T extends Object>(StorageKey<T> key) =>
      _preferences.remove(_qualify(key));

  @override
  Future<void> clear() async {
    final keys = await _preferences.getKeys();
    final owned = keys.where((key) => key.startsWith('$_namespace.')).toSet();
    if (owned.isEmpty) return;
    await _preferences.clear(allowList: owned);
  }
}
