import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/gen/assets.gen.dart';

/// The icons are drawn in the colours Figma exported them with — grey, green,
/// white. Nothing may depend on that: they are tinted where they are used, so
/// one file serves both the resting and the active state, and both themes.
void main() {
  testWidgets('every icon renders, and takes the colour it is given', (
    tester,
  ) async {
    final icons = {
      'home': Assets.icons.home,
      'garden': Assets.icons.garden,
      'healthcare': Assets.icons.healthcare,
      'profile': Assets.icons.profile,
      'identify': Assets.icons.identify,
      'speedometer': Assets.icons.speedometer,
    };

    for (final entry in icons.entries) {
      await tester.pumpWidget(
        Center(
          child: entry.value.svg(
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF13231B),
              BlendMode.srcIn,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(SvgPicture),
        findsOneWidget,
        reason: '${entry.key} failed to build',
      );
      expect(tester.takeException(), isNull, reason: entry.key);
    }
  });
}
