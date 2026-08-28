import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/api/storage_api.dart';
import 'package:hubx/core/storage/impl/key_value_storage_impl.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late KeyValueStorageFactory factory;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await DependencyProvider.reset();
    registerKeyValueStorage();
    factory = DependencyProvider.get<KeyValueStorageFactory>();
  });

  group('KeyValueStorage', () {
    const key = StorageKey<String>('token');

    test('reads back what it wrote', () async {
      final storage = factory.storageFor('alpha');

      await storage.write(key, 'abc');

      expect(await storage.read(key), 'abc');
    });

    test('returns null for a key that was never written', () async {
      expect(await factory.storageFor('alpha').read(key), isNull);
    });

    test('keeps namespaces isolated', () async {
      await factory.storageFor('alpha').write(key, 'from-alpha');
      await factory.storageFor('beta').write(key, 'from-beta');

      expect(await factory.storageFor('alpha').read(key), 'from-alpha');
      expect(await factory.storageFor('beta').read(key), 'from-beta');
    });

    test('clear only wipes its own namespace', () async {
      final alpha = factory.storageFor('alpha');
      final beta = factory.storageFor('beta');
      await alpha.write(key, 'from-alpha');
      await beta.write(key, 'from-beta');

      await alpha.clear();

      expect(await alpha.read(key), isNull);
      expect(await beta.read(key), 'from-beta');
    });

    test('delete removes a single key', () async {
      final storage = factory.storageFor('alpha');
      await storage.write(key, 'abc');

      await storage.delete(key);

      expect(await storage.read(key), isNull);
    });

    test('stores every supported type', () async {
      final storage = factory.storageFor('types');

      await storage.write(const StorageKey<int>('i'), 42);
      await storage.write(const StorageKey<double>('d'), 1.5);
      await storage.write(const StorageKey<bool>('b'), true);
      await storage.write(const StorageKey<List<String>>('l'), ['a', 'b']);

      expect(await storage.read(const StorageKey<int>('i')), 42);
      expect(await storage.read(const StorageKey<double>('d')), 1.5);
      expect(await storage.read(const StorageKey<bool>('b')), true);
      expect(await storage.read(const StorageKey<List<String>>('l')), [
        'a',
        'b',
      ]);
    });

    test('rejects an unsupported type', () async {
      final storage = factory.storageFor('types');

      expect(
        () => storage.write(const StorageKey<Duration>('x'), Duration.zero),
        throwsUnsupportedError,
      );
    });
  });
}
