import 'dart:async';

import 'package:hubx/app/startup/app_startup.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

/// Reads everything the app needs before `runApp`.
///
/// Only feature `api` contracts are touched here, and every read runs in
/// parallel, so adding a flag costs one entry rather than one more round trip.
abstract final class AppStartupLoader {
  static const _source = LogSource('startup');

  /// [load], falling back to [AppStartup.fallback] if anything goes wrong.
  ///
  /// Losing stored preferences is bad; refusing to start is worse.
  static Future<AppStartup> loadOrFallback() async {
    try {
      return await load();
    } on Object catch (error, stackTrace) {
      DependencyProvider.getOrNull<Logger>()
          ?.withSource(_source)
          .error(
            'Startup could not be loaded, falling back to defaults',
            error: error,
            stackTrace: stackTrace,
          );
      return AppStartup.fallback;
    }
  }

  static Future<AppStartup> load() async {
    final settings = DependencyProvider.get<SettingsRepository>();
    final onboarding = DependencyProvider.get<OnboardingRepository>();

    final (themeMode, locale, isOnboardingCompleted) = await (
      settings.readThemeMode(),
      settings.readLocale(),
      onboarding.isCompleted(),
    ).wait;

    final startup = AppStartup(
      preferences: UserPreferences(themeMode: themeMode, locale: locale),
      status: UserStatus(isOnboardingCompleted: isOnboardingCompleted),
    );

    DependencyProvider.getOrNull<Logger>()?.withSource(_source).debug(
      'Startup loaded',
      context: {
        'themeMode': themeMode.name,
        'locale': locale?.languageCode,
        'onboardingCompleted': isOnboardingCompleted,
      },
    );

    return startup;
  }
}
