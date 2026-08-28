part of '../settings_impl.dart';

class _SettingsRepositoryImpl implements SettingsRepository {
  const _SettingsRepositoryImpl(this._storage);

  static const _themeMode = StorageKey<String>('theme_mode');
  static const _locale = StorageKey<String>('locale');

  final KeyValueStorage _storage;

  @override
  Future<ThemeMode> readThemeMode() async {
    final stored = await _storage.read(_themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) =>
      _storage.write(_themeMode, mode.name);

  @override
  Future<Locale?> readLocale() async {
    final stored = await _storage.read(_locale);
    if (stored == null || stored.isEmpty) return null;
    return Locale(stored);
  }

  @override
  Future<void> writeLocale(Locale? locale) {
    if (locale == null) return _storage.delete(_locale);
    return _storage.write(_locale, locale.languageCode);
  }
}
