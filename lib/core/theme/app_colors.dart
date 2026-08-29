import 'package:flutter/material.dart';

/// The palette of the design.
abstract final class AppColors {
  /// Primary action: the green of every call-to-action button.

  static const primary = Color(0xFF28AF6E);

  /// Headings and body copy on light backgrounds.
  static const textPrimary = Color(0xFF13231B);

  /// Subtitles and supporting copy — the welcome screen's "Identify more…".
  static const textSecondary = Color(0xB213231B);

  /// The fine print under the call to action — the "By tapping…" line.

  static const textTertiary = Color(0xB2597165);

  static const surface = Color(0xFFFFFFFF);

  /// The paywall is dark; its own background rather than the app's surface.
  static const paywallSurface = Color(0xFF101E17);

  /// The welcome screen fades from a pale blue into white.
  static const welcomeGradient = [Color(0xFFFAFAFA), Color(0xFFEAF7F1)];

  /// Page indicator: the active dot is the text colour, the rest a wash of it.
  static const Color indicatorActive = textPrimary;
  static const indicatorInactive = Color(0x2613231B);
}
