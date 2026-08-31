import 'package:flutter/material.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_palette.dart';
import 'package:hubx/core/theme/app_text_styles.dart';

/// Single source of truth for the light and dark [ThemeData] of the app.
abstract final class AppTheme {
  /// Brand seed colour both schemes are generated from.
  ///
  /// Read off the palette rather than written out again: Material generates
  /// the tones it fills its own widgets with from this, so a seed that drifts
  /// from the brand shows up as the wrong colour on everything the design
  /// never drew — a radio, a text button, a text field's cursor.
  static Color get seedColor => AppPalette.light.primary;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = brightness == Brightness.light
        ? AppPalette.light
        : AppPalette.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      // Reached with `context.palette`; the design's colours live here rather
      // than as constants so they follow the theme.
      extensions: [palette],
      scaffoldBackgroundColor: palette.surface,
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      // Material's own widgets read from here, so the design's styles reach an
      // AppBar or a button without every screen restating them.
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.extraBold28,
        headlineMedium: AppTextStyles.medium28,
        headlineSmall: AppTextStyles.regular28,
        titleLarge: AppTextStyles.medium20,
        titleMedium: AppTextStyles.semiBold16,
        bodyLarge: AppTextStyles.regular16,
        bodyMedium: AppTextStyles.regular13,
        bodySmall: AppTextStyles.regular12,
        labelLarge: AppTextStyles.semiBold16,
        labelMedium: AppTextStyles.regular12,
        labelSmall: AppTextStyles.regular11,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          textStyle: AppTextStyles.semiBold16,
          minimumSize: Size.fromHeight(AppSize.controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      ),
    );
  }
}
