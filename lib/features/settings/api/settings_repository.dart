import 'package:flutter/material.dart';

/// Persisted appearance and language choices.
///
/// The implementation is private to `features/settings/impl`; the app only
/// ever sees this contract.
abstract interface class SettingsRepository {
  /// Saved theme mode, or [ThemeMode.system] when the user never chose one.
  Future<ThemeMode> readThemeMode();

  Future<void> writeThemeMode(ThemeMode mode);

  /// Saved locale, or `null` when the app should follow the system language.
  Future<Locale?> readLocale();

  Future<void> writeLocale(Locale? locale);
}
