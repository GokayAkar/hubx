import 'dart:async';

import 'package:hubx/app/startup/app_startup.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

/// Reads everything the app needs before `runApp`.
///
/// Only feature `api` contracts are touched here, and every read runs in
/// parallel, so adding a flag costs one entry rather than one more round trip.
abstract final class AppStartupLoader {
  static Future<AppStartup> load() async {
    final settings = DependencyProvider.get<SettingsRepository>();
    final onboarding = DependencyProvider.get<OnboardingRepository>();

    final (themeMode, locale, isOnboardingCompleted) = await (
      settings.readThemeMode(),
      settings.readLocale(),
      onboarding.isCompleted(),
    ).wait;

    return AppStartup(
      preferences: UserPreferences(themeMode: themeMode, locale: locale),
      status: UserStatus(isOnboardingCompleted: isOnboardingCompleted),
    );
  }
}
