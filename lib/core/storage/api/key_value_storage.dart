/// A typed name for a stored value.
///
/// Carrying the type on the key is what makes [KeyValueStorage] safe at
/// compile time: `storage.read(_themeMode)` can only ever produce a `String?`.
class StorageKey<T extends Object> {
  const StorageKey(this.name);

  final String name;

  @override
  String toString() => 'StorageKey<$T>($name)';
}

/// Namespaced key/value persistence.
///
/// Obtain an instance from [KeyValueStorageFactory] — never construct one.
/// Supported value types are `String`, `int`, `double`, `bool` and
/// `List<String>`; anything else throws [UnsupportedError].
abstract interface class KeyValueStorage {
  Future<T?> read<T extends Object>(StorageKey<T> key);

  Future<void> write<T extends Object>(StorageKey<T> key, T value);

  Future<void> delete<T extends Object>(StorageKey<T> key);

  /// Removes every value in this storage's namespace only.
  Future<void> clear();
}

/// Hands out one [KeyValueStorage] per namespace.
///
/// Each feature asks for its own namespace, so keys can never collide and
/// `clear()` can never wipe another feature's data.
abstract interface class KeyValueStorageFactory {
  KeyValueStorage storageFor(String namespace);
}
