import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Owns the app-wide appearance and language state.
///
/// The bloc is constructed with the settings already read from disk, so the
/// very first frame is painted in the user's theme and language — there is no
/// default-then-correct flash.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._repository, {
    SettingsState initialState = const SettingsState(),
  }) : super(initialState) {
    on<SettingsThemeModeChanged>(_onThemeModeChanged);
    on<SettingsLocaleChanged>(_onLocaleChanged);
  }

  final SettingsRepository _repository;

  Future<void> _onThemeModeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    // Applied first so the UI reacts immediately, rolled back if the write
    // fails — showing a preference that was never stored is worse than a
    // moment of the old one.
    final previous = state.themeMode;
    emit(state.copyWith(themeMode: event.themeMode));

    try {
      await _repository.writeThemeMode(event.themeMode);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(themeMode: previous));
    }
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final previous = state.locale;
    emit(
      state.copyWith(
        locale: event.locale,
        resetLocale: event.locale == null,
      ),
    );

    try {
      await _repository.writeLocale(event.locale);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(locale: previous, resetLocale: previous == null));
    }
  }
}
