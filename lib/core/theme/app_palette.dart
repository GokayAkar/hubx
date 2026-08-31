import 'package:flutter/material.dart';

/// The design's colours, one set per brightness.
///
/// A `ThemeExtension` rather than plain constants, because constants cannot
/// change with the theme — and rather than Material's `ColorScheme`, because
/// several of these have no slot there: a two-stop gradient, three tiers of
/// text, an indicator wash.
///
/// Read it through `context.palette`. Values reach a widget from `Theme`, so a
/// theme switch crossfades them instead of snapping, and a test can override
/// the whole set without touching the widgets.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceRaised,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.indicatorActive,
    required this.indicatorInactive,
    required this.welcomeGradient,
  });

  /// From the design, which only specifies the light appearance.
  static const light = AppPalette(
    primary: Color(0xFF28AF6E),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF4F6F6),
    divider: Color(0x1A13231B),
    textPrimary: Color(0xFF13231B),
    textSecondary: Color(0xB213231B),
    textTertiary: Color(0xB2597165),
    indicatorActive: Color(0xFF13231B),
    indicatorInactive: Color(0x2613231B),
    welcomeGradient: [Color(0xFFFAFAFA), Color(0xFFEAF7F1)],
  );

  /// PROVISIONAL: derived from the light set and the paywall's #101E17, not
  /// given by the design. Every value here needs sign-off.
  static const dark = AppPalette(
    primary: Color(0xFF28AF6E),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFF101E17),
    surfaceRaised: Color(0xFF1C2B23),
    divider: Color(0x33F2F7F4),
    textPrimary: Color(0xFFF2F7F4),
    textSecondary: Color(0xB2F2F7F4),
    textTertiary: Color(0xB2A8BDB1),
    indicatorActive: Color(0xFFF2F7F4),
    indicatorInactive: Color(0x33F2F7F4),
    welcomeGradient: [Color(0xFF0B1611), Color(0xFF16281F)],
  );

  final Color primary;

  /// What sits on [primary] — the button label.
  final Color onPrimary;

  final Color surface;

  /// A panel sitting on [surface] — the feature cards, the plan tiles.
  final Color surfaceRaised;

  /// Hairlines and the resting state of a control's outline.
  final Color divider;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color indicatorActive;
  final Color indicatorInactive;

  /// Bottom to top, behind the welcome screen.
  final List<Color> welcomeGradient;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? surfaceRaised,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? indicatorActive,
    Color? indicatorInactive,
    List<Color>? welcomeGradient,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      indicatorActive: indicatorActive ?? this.indicatorActive,
      indicatorInactive: indicatorInactive ?? this.indicatorInactive,
      welcomeGradient: welcomeGradient ?? this.welcomeGradient,
    );
  }

  /// What makes a theme change fade rather than jump.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;

    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      indicatorActive: Color.lerp(indicatorActive, other.indicatorActive, t)!,
      indicatorInactive: Color.lerp(
        indicatorInactive,
        other.indicatorInactive,
        t,
      )!,
      welcomeGradient: [
        for (var i = 0; i < welcomeGradient.length; i++)
          Color.lerp(welcomeGradient[i], other.welcomeGradient[i], t)!,
      ],
    );
  }
}
