import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  Future<void> seed([Map<String, Object> stored = const {}]) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(stored);
    await DependencyProvider.reset();
    AppDependencies.register();
  }

  group('AppStartupLoader', () {
    test('falls back to system defaults on a fresh install', () async {
      await seed();

      final startup = await AppStartupLoader.load();

      expect(startup.preferences.themeMode, ThemeMode.system);
      expect(startup.preferences.locale, isNull);
      expect(startup.status.isOnboardingCompleted, isFalse);
    });

    test('falls back instead of failing when storage throws', () async {
      await seed();
      // Nothing registered under KeyValueStorageFactory any more, so every
      // read below fails.
      await DependencyProvider.reset();

      expect(await AppStartupLoader.loadOrFallback(), AppStartup.fallback);
    });

    test('reads preferences and status that were written before', () async {
      await seed({
        'settings.theme_mode': 'dark',
        'settings.locale': 'tr',
        'onboarding.completed': true,
      });

      final startup = await AppStartupLoader.load();

      expect(startup.preferences.themeMode, ThemeMode.dark);
      expect(startup.preferences.locale, const Locale('tr'));
      expect(startup.status.isOnboardingCompleted, isTrue);
    });
  });
}
