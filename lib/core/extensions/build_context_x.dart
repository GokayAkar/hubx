import 'package:flutter/material.dart';
import 'package:hubx/l10n/generated/app_localizations.dart';

/// Shorthands for the objects that are read from the widget tree constantly.
extension BuildContextX on BuildContext {
  /// Localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
