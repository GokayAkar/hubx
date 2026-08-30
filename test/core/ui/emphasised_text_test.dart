import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/ui/emphasised_text.dart';

/// Stands in for the design's hand-drawn stroke.
class _Underline extends StatelessWidget {
  const _Underline(this.width);

  final double width;

  @override
  Widget build(BuildContext context) => const SizedBox(height: 4);
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    String text, {
    double textScale = 1,
    double width = 360,
    double overshoot = 0,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width,
              child: EmphasisedText(
                text,
                style: const TextStyle(fontSize: 28),
                emphasisStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                underlineOvershoot: overshoot,
                underlineBuilder: _Underline.new,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('EmphasisedText', () {
    testWidgets('reads to a screen reader without the markers', (tester) async {
      await pump(tester, 'Get plant **care guides**');

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.semanticsLabel, 'Get plant care guides');
    });

    testWidgets('draws no underline when none was asked for', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: EmphasisedText(
            'Get plant **care guides**',
            style: TextStyle(fontSize: 28),
            emphasisStyle: TextStyle(fontSize: 28),
          ),
        ),
      );

      expect(find.byType(_Underline), findsNothing);
    });

    testWidgets('sizes the underline to the emphasised words', (tester) async {
      await pump(tester, 'Get plant **care guides**');

      final underline = tester.widget<_Underline>(find.byType(_Underline));
      // Wide enough to be the two emphasised words and no more.
      expect(underline.width, greaterThan(100));
      expect(underline.width, lessThan(360));
    });

    testWidgets('follows the words when the system text grows', (
      tester,
    ) async {
      await pump(tester, 'Take a photo to **identify** the plant!');
      final normal = tester.widget<_Underline>(find.byType(_Underline)).width;

      await pump(
        tester,
        'Take a photo to **identify** the plant!',
        textScale: 1.5,
      );
      final larger = tester.widget<_Underline>(find.byType(_Underline)).width;

      // The stroke is measured, not padded, so it grows with the word.
      expect(larger, greaterThan(normal));
    });

    testWidgets('runs the stroke past the words when asked', (tester) async {
      await pump(tester, 'Get plant **care guides**');
      final flush = tester.widget<_Underline>(find.byType(_Underline)).width;

      await pump(tester, 'Get plant **care guides**', overshoot: 0.1);
      final overhung = tester.widget<_Underline>(find.byType(_Underline)).width;

      // A tenth past the words at each end is a fifth wider overall.
      expect(overhung, closeTo(flush * 1.2, 0.5));
    });

    testWidgets('does not clip a stroke under the last line', (tester) async {
      // The stroke is painted below the text, so it falls outside the stack's
      // own bounds whenever the emphasis lands on the final line.
      await pump(tester, 'Get plant **care guides**');

      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.clipBehavior, Clip.none);
    });

    testWidgets('places one stroke per line when the words wrap', (
      tester,
    ) async {
      // Narrow enough to break the emphasised run across two lines.
      await pump(tester, 'A **very long emphasised phrase here**', width: 200);

      expect(find.byType(_Underline), findsAtLeast(2));
    });
  });
}
