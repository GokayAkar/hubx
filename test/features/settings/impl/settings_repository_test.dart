import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/impl/key_value_storage_impl.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:hubx/features/settings/impl/settings_impl.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// The implementation is private, so the test resolves it the same way the app
/// does: through the contract registered by [registerSettingsDomain].
void main() {
  late SettingsRepository repository;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await DependencyProvider.reset();
    registerKeyValueStorage();
    registerSettingsDomain();
    repository = DependencyProvider.get<SettingsRepository>();
  });

  group('SettingsRepository', () {
    test('falls back to system defaults when nothing was saved', () async {
      expect(await repository.readThemeMode(), ThemeMode.system);
      expect(await repository.readLocale(), isNull);
    });

    test('round-trips the theme mode', () async {
      await repository.writeThemeMode(ThemeMode.dark);

      expect(await repository.readThemeMode(), ThemeMode.dark);
    });

    test('round-trips the locale and clears it again', () async {
      await repository.writeLocale(const Locale('tr'));
      expect(await repository.readLocale(), const Locale('tr'));

      await repository.writeLocale(null);
      expect(await repository.readLocale(), isNull);
    });
  });
}
