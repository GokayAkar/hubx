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
    super.key,
  });

  final IconData icon;

  /// Read aloud by a screen reader, and shown as the tooltip on a long press.
  /// Write what the button *does*, not what it looks like: "Open settings",
  /// not "Gear".
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: AppSize.icon24),
      tooltip: label,
      onPressed: onPressed,
    );
  }
}
