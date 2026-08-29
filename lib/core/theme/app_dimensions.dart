import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The frame the design was drawn on.
///
/// Every token below is expressed in these units, so a value read off the
/// design can be typed in as-is and will land proportionally on any phone.
const kDesignSize = Size(360, 800);

/// Gaps and padding, in design units.
///
/// Named for the value on the design, so "24 gap" in a review becomes
/// `AppSpacing.s24` with nothing to look up. Only the steps of the scale exist,
/// so a stray 13 or 17 cannot be typed in — that is what keeps screens looking
/// like one app.
///
/// Everything in this file scales by width (`.w`), vertical gaps included.
/// Scaling those by height instead would stretch a square into a rectangle and
/// make the rhythm differ between a short and a tall phone; mixing the two
/// scalers would make a button's height and its padding drift apart.
abstract final class AppSpacing {
  static double get s4 => 4.w;

  static double get s8 => 8.w;

  static double get s12 => 12.w;

  static double get s16 => 16.w;

  static double get s24 => 24.w;

  static double get s32 => 32.w;

  static double get s48 => 48.w;

  /// The standard horizontal padding of a screen. Named for what it is, not
  /// what it measures, because it is a decision rather than a number.
  static double get page => s16;
}

/// Corner radii, in design units.
abstract final class AppRadius {
  static double get r8 => 8.w;

  static double get r12 => 12.w;

  static double get r16 => 16.w;

  static double get r24 => 24.w;
}

/// Fixed sizes that are not spacing: control heights, icon sizes.
abstract final class AppSize {
  /// Inline icon, next to text.
  static double get icon20 => 20.w;

  /// Standard icon.
  static double get icon24 => 24.w;

  /// Button height, and the minimum comfortable touch target.
  ///
  /// Scales up like everything else, but never down: a finger is the same size
  /// on a narrow phone, so 48 is a floor rather than a proportion.
  static double get controlHeight => math.max(48, 48.w);
}
