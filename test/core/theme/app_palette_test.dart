import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_palette.dart';
import 'package:hubx/core/theme/app_theme.dart';

void main() {
  /// Reads the palette a widget would see under [mode].
  Future<AppPalette> paletteUnder(WidgetTester tester, ThemeMode mode) async {
    late AppPalette palette;

    // The theme's text styles are screen-scaled, so ScreenUtil has to be up
    // before ThemeData is built.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: kDesignSize,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: Builder(
            builder: (context) {
              palette = context.palette;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return palette;
  }

  group('AppPalette', () {
    testWidgets('both themes carry one', (tester) async {
      // A missing extension would throw on the `!` in `context.palette`.
      expect(await paletteUnder(tester, ThemeMode.light), AppPalette.light);
      expect(await paletteUnder(tester, ThemeMode.dark), AppPalette.dark);
    });

    testWidgets('dark inverts the page, not the brand', (tester) async {
      final light = await paletteUnder(tester, ThemeMode.light);
      final dark = await paletteUnder(tester, ThemeMode.dark);

      // The surface and the text swap ends of the scale…
      expect(dark.surface.computeLuminance(), lessThan(0.2));
      expect(light.surface.computeLuminance(), greaterThan(0.8));
      expect(dark.textPrimary.computeLuminance(), greaterThan(0.8));
      expect(light.textPrimary.computeLuminance(), lessThan(0.2));

      // …while the brand colour stays what the brand is.
      expect(dark.primary, light.primary);
    });

    test('lerps every colour, so a theme change fades', () {
      final middle = AppPalette.light.lerp(AppPalette.dark, 0.5);

      expect(middle.surface, isNot(AppPalette.light.surface));
      expect(middle.surface, isNot(AppPalette.dark.surface));
      expect(middle.welcomeGradient, hasLength(2));
      expect(
        middle.welcomeGradient.first,
        isNot(AppPalette.light.welcomeGradient.first),
      );
    });
  });
}
