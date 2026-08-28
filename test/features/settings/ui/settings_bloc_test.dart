import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:hubx/features/settings/ui/settings_ui.dart';

/// A hand-written stand-in for the private implementation — possible only
/// because the bloc depends on the [SettingsRepository] contract.
class _FakeSettingsRepository implements SettingsRepository {
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;

  @override
  Future<ThemeMode> readThemeMode() async => themeMode;

  @override
  Future<void> writeThemeMode(ThemeMode mode) async => themeMode = mode;

  @override
  Future<Locale?> readLocale() async => locale;

  @override
  Future<void> writeLocale(Locale? value) async => locale = value;
}

void main() {
  late _FakeSettingsRepository repository;

  setUp(() => repository = _FakeSettingsRepository());

  group('SettingsBloc', () {
    test('defaults to system theme and system locale', () {
      expect(SettingsBloc(repository).state, const SettingsState());
    });

    test('starts from the state it was seeded with', () {
      const seeded = SettingsState(
        themeMode: ThemeMode.light,
        locale: Locale('tr'),
      );

      expect(SettingsBloc(repository, initialState: seeded).state, seeded);
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits dark theme and persists it',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc.add(const SettingsThemeModeChanged(ThemeMode.dark)),
      expect: () => const [SettingsState(themeMode: ThemeMode.dark)],
      verify: (_) => expect(repository.themeMode, ThemeMode.dark),
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits the selected locale and clears it again',
      build: () => SettingsBloc(repository),
      act: (bloc) => bloc
        ..add(const SettingsLocaleChanged(Locale('tr')))
        ..add(const SettingsLocaleChanged(null)),
      expect: () => const [
        SettingsState(locale: Locale('tr')),
        SettingsState(),
      ],
      verify: (_) => expect(repository.locale, isNull),
    );
  });
}
