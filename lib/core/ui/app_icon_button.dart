import 'package:flutter/material.dart';
import 'package:hubx/core/theme/app_dimensions.dart';

/// An icon-only button that cannot be built without saying what it does.
///
/// A bare [IconButton] takes its label through an optional `tooltip`, so the
/// easiest thing to write is the one a screen reader announces as just
/// "button". Here the label is required, which makes the accessible version
/// the default rather than the diligent one.
///
/// `accessibility_test.dart` fails the build when a tappable has no label, so
/// this is the convenience; that test is the guarantee.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background,
    this.foreground,
    this.size,
    super.key,
  });

  final IconData icon;

  /// Painted as a circle behind the icon. Transparent when null.
  ///
  /// Here rather than at the call site because the alternative is a bare
  /// [IconButton], which is exactly the thing this class exists to keep out of
  /// the codebase: styling a button should never cost you its label.
  final Color? background;

  /// The icon's own colour. Falls back to the theme's.
  final Color? foreground;

  /// Diameter of the visible button, Material's 40 by default.
  ///
  /// Only the paint shrinks. The area that answers a finger stays 48pt however
  /// small this is, because [IconButton] pads the tap target out beyond what it
  /// draws — so a button can be as discreet as the design wants without
  /// becoming harder to hit.
  final double? size;

  /// How much of the button the icon takes up. Chosen so the default diameter
  /// yields Material's own 24pt icon.
  static const _iconRatio = 0.6;

  /// Read aloud by a screen reader, and shown as the tooltip on a long press.
  /// Write what the button *does*, not what it looks like: "Open settings",
  /// not "Gear".
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? AppSize.icon24 / _iconRatio;

    return IconButton(
      icon: Icon(icon, size: diameter * _iconRatio),
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: EdgeInsets.zero,
        // Both: Material's own minimum is 40, and fixedSize alone is clamped
        // by it.
        minimumSize: Size.square(diameter),
        fixedSize: Size.square(diameter),
      ),
    );
  }
}
