import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/theme/app_dimensions.dart';

void main() {
  /// Renders at [width] logical pixels and reports what the tokens become.
  Future<({double md, double radius, double control})> measure(
    WidgetTester tester,
    double width,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(width, kDesignSize.height);
    addTearDown(tester.view.reset);

    late double md;
    late double radius;
    late double control;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: kDesignSize,
        minTextAdapt: true,
        builder: (context, _) {
          md = AppSpacing.s16;
          radius = AppRadius.r12;
          control = AppSize.controlHeight;
          return const SizedBox.shrink();
        },
      ),
    );

    return (md: md, radius: radius, control: control);
  }

  group('AppSpacing', () {
    testWidgets('matches the design one to one at the reference width', (
      tester,
    ) async {
      final measured = await measure(tester, kDesignSize.width);

      expect(measured.md, 16);
      expect(measured.radius, 12);
    });

    testWidgets('grows on a wider phone', (tester) async {
      final measured = await measure(tester, 430);

      // 430 / 360 ≈ 1.19
      expect(measured.md, closeTo(19.1, 0.2));
    });

    testWidgets('tightens on a narrower phone', (tester) async {
      final measured = await measure(tester, 320);

      // 320 / 360 ≈ 0.89
      expect(measured.md, closeTo(14.2, 0.2));
    });

    testWidgets('keeps the touch target at 48 however narrow the phone', (
      tester,
    ) async {
      final measured = await measure(tester, 320);

      // A finger does not shrink with the screen.
      expect(measured.control, greaterThanOrEqualTo(48));
    });

    testWidgets('the scale is proportional, so the rhythm holds', (
      tester,
    ) async {
      final narrow = await measure(tester, 320);
      final wide = await measure(tester, 430);

      expect(wide.md / narrow.md, closeTo(430 / 320, 0.01));
    });
  });
}
