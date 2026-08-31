import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Text Styles are the design's typographic tokens,
/// with the font family and weight
abstract final class AppTextStyles {
  static const fontFamily = 'Roboto';

  // ---------------------------------------------------------------- 28 / 27

  /// 28 · Regular · 100%
  static TextStyle get regular28 => _style(400, 28);

  /// 28 · Light · 100%
  static TextStyle get light28 => _style(300, 28);

  /// 28 · Medium · 100% · -1
  static TextStyle get medium28 => _style(500, 28, letterSpacing: -1);

  static TextStyle get semiBold28 => _style(600, 28);

  /// 28 · ExtraBold · 100% · -1
  static TextStyle get extraBold28 => _style(800, 28, letterSpacing: -1);

  /// 27 · Light · 100%
  static TextStyle get light27 => _style(300, 27);

  // -------------------------------------------------------------- 24 / 20 / 17

  /// 24 · Medium · 28
  static TextStyle get medium24 => _style(500, 24);

  /// 20 · Medium · 24 · 0.38
  static TextStyle get medium20 => _style(500, 20, letterSpacing: 0.38);

  /// 17 · Light · 24 · 0.38
  static TextStyle get light17 => _style(300, 17, letterSpacing: 0.38);

  // ------------------------------------------------------------------- 16

  /// 16 · Regular
  static TextStyle get regular16 => _style(400, 16);

  /// 16 · Medium · 100%
  static TextStyle get medium16 => _style(500, 16);

  /// 16 · SemiBold
  static TextStyle get semiBold16 => _style(600, 16);

  /// 16 · Bold · 21
  static TextStyle get bold16 => _style(700, 16);

  // ---------------------------------------------------------------- 15 / 13

  /// 15 · Regular · 20
  static TextStyle get regular15 => _style(400, 15);

  /// 15 · Medium · 20
  static TextStyle get medium15 => _style(500, 15);

  /// 13 · Regular
  static TextStyle get regular13 => _style(400, 13);

  // ------------------------------------------------------------- 12 / 11 / 9

  /// 12 · Light · 100%
  static TextStyle get light12 => _style(300, 12);

  /// 12 · Regular · 100%
  static TextStyle get regular12 => _style(400, 12);

  /// 11 · Regular
  static TextStyle get regular11 => _style(400, 11);

  /// 9 · Light · 132%
  static TextStyle get light9 => _style(300, 9);

  /// Underlined variant of any token, for links.
  static TextStyle underlined(TextStyle style) =>
      style.copyWith(decoration: TextDecoration.underline);

  /// [letterSpacing] is the design's own tracking, in design units, so it
  /// scales with the text rather than staying put as the type grows.
  static TextStyle _style(
    int weight,
    double size, {
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.values[weight ~/ 100 - 1],
      fontSize: size.sp,
      letterSpacing: letterSpacing?.sp,
    );
  }
}
