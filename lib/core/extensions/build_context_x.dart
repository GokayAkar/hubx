import 'package:flutter/material.dart';
import 'package:hubx/core/theme/app_palette.dart';
import 'package:hubx/l10n/generated/app_localizations.dart';

/// Shorthands for the objects that are read from the widget tree constantly.
extension BuildContextX on BuildContext {
  /// Localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The design's own colours, which follow the theme.
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
