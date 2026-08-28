part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({this.themeMode = ThemeMode.system, this.locale});

  /// `system` follows the OS setting.
  final ThemeMode themeMode;

  /// `null` follows the OS language.
  final Locale? locale;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool resetLocale = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: resetLocale ? null : locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
