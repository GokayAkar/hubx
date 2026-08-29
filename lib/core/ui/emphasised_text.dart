import 'package:flutter/material.dart';

/// Renders a localized string whose emphasised half is marked with `**`.
///
/// [underlineBuilder] draws something under the emphasised words — the design's
/// hand-drawn stroke. It is given the measured width of each run, so it fits
/// whatever the words turn out to be: a longer translation, a larger system
/// text size, or a word that wrapped onto a second line all measure correctly,
/// which is why the stroke is placed from a measurement rather than guessed at
/// with padding.
class EmphasisedText extends StatelessWidget {
  const EmphasisedText(
    this.text, {
    required this.style,
    required this.emphasisStyle,
    this.underlineBuilder,
    this.underlineOvershoot = 0,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle style;
  final TextStyle emphasisStyle;
  final Widget Function(double width)? underlineBuilder;

  /// How far the stroke runs past the words at each end, as a fraction of
  /// their measured width. A hand-drawn stroke is drawn through a word rather
  /// than stopping at its letters, and a fraction keeps that overhang in
  /// proportion as the word or the system text size changes.
  final double underlineOvershoot;

  final TextAlign? textAlign;

  static final _marker = RegExp(r'\*\*(.+?)\*\*');

  @override
  Widget build(BuildContext context) {
    final spans = _spans().toList();
    final content = Text.rich(
      TextSpan(children: spans.map((s) => s.span).toList()),
      style: style,
      textAlign: textAlign,
      // The markers are punctuation, not content: a screen reader should hear
      // the sentence, not the asterisks.
      semanticsLabel: text.replaceAll('**', ''),
    );

    if (underlineBuilder == null) return content;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          // The stroke sits below the last line of text, which is the edge of
          // this stack: the default hard clip would erase it whenever the
          // emphasised words land on the final line.
          clipBehavior: Clip.none,
          children: [
            content,
            for (final box in _emphasisBoxes(context, spans, constraints))
              () {
                final overhang = box.width * underlineOvershoot;
                final width = box.width + overhang * 2;

                return Positioned(
                  left: box.left - overhang,
                  top: box.bottom,
                  width: width,
                  child: underlineBuilder!(width),
                );
              }(),
          ],
        );
      },
    );
  }

  /// Where the emphasised words actually landed, wrapping included.
  List<Rect> _emphasisBoxes(
    BuildContext context,
    List<_Run> runs,
    BoxConstraints constraints,
  ) {
    final start = runs
        .takeWhile((run) => !run.isEmphasis)
        .fold(
          0,
          (length, run) => length + run.text.length,
        );
    final emphasis = runs.where((run) => run.isEmphasis).firstOrNull;
    if (emphasis == null) return const [];

    final painter = TextPainter(
      text: TextSpan(
        style: style,
        children: runs.map((run) => run.span).toList(),
      ),
      textDirection: Directionality.of(context),
      textAlign: textAlign ?? TextAlign.start,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: constraints.maxWidth);

    final boxes = painter.getBoxesForSelection(
      TextSelection(
        baseOffset: start,
        extentOffset: start + emphasis.text.length,
      ),
    );
    painter.dispose();

    return boxes.map((box) => box.toRect()).toList();
  }

  Iterable<_Run> _spans() sync* {
    var index = 0;
    for (final match in _marker.allMatches(text)) {
      if (match.start > index) {
        yield _Run(
          text.substring(index, match.start),
          style,
          isEmphasis: false,
        );
      }
      yield _Run(match.group(1)!, emphasisStyle, isEmphasis: true);
      index = match.end;
    }
    if (index < text.length) {
      yield _Run(text.substring(index), style, isEmphasis: false);
    }
  }
}

class _Run {
  const _Run(this.text, this.style, {required this.isEmphasis});

  final String text;
  final TextStyle style;
  final bool isEmphasis;

  TextSpan get span => TextSpan(text: text, style: style);
}
