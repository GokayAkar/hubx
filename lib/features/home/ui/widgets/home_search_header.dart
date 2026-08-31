import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/gen/assets.gen.dart';

/// The greeting and the search field, as a header that collapses as the page
/// scrolls under it.
///
/// The field is pinned to the bottom of the header and the greeting sits above
/// it, so shrinking the box carries the greeting up and off while the field
/// stays exactly where the thumb left it. The greeting fades on the way out:
/// text that slid under the status bar at full strength would look like a bug.
class HomeSearchHeader extends SliverPersistentHeaderDelegate {
  const HomeSearchHeader({
    required this.topInset,
    required this.greetingHeight,
  });

  /// The status bar, which the header paints under and lays out below.
  final double topInset;

  /// The room the greeting needs, from [greetingHeightFor].
  final double greetingHeight;

  static double get _fieldHeight => math.max(AppSize.minTouchTarget, 48.w);

  /// Between the status bar and the greeting. The page's own side margin, so
  /// the corner reads as one deliberate margin rather than two measurements
  /// that happen not to match.
  static double get _topGap => AppSpacing.s32;

  /// The height the greeting takes at the user's text size.
  ///
  /// Measured rather than fixed: the two lines grow — and, once they are wide
  /// enough, wrap — with the text size, and a box that stayed at the design's
  /// height would carry them up past the top of the header and clip them away
  /// entirely.
  static double greetingHeightFor(BuildContext context) {
    final inherited = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final width = MediaQuery.sizeOf(context).width - AppSpacing.s24 * 2;

    double lineHeight(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: inherited.merge(style)),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout(maxWidth: math.max(0, width));
      final height = painter.height;
      painter.dispose();

      return height;
    }

    return lineHeight(context.l10n.homeGreetingHi, AppTextStyles.regular16) +
        lineHeight(
          greetingFor(TimeOfDay.now(), context),
          AppTextStyles.medium24,
        );
  }

  /// Morning until noon, afternoon until six, evening after that.
  @visibleForTesting
  static String greetingFor(TimeOfDay time, BuildContext context) {
    if (time.hour < 12) return context.l10n.homeGreetingMorning;
    if (time.hour < 18) return context.l10n.homeGreetingAfternoon;

    return context.l10n.homeGreetingEvening;
  }

  @override
  double get maxExtent =>
      topInset + _topGap + greetingHeight + _fieldHeight + AppSpacing.s16;

  // The field is pinned [AppSpacing.s16] off the bottom, so the collapsed box
  // has to budget that same 16 below it — anything less presses the field
  // against the status bar and leaves the slack underneath.
  @override
  double get minExtent =>
      topInset + AppSpacing.s12 + _fieldHeight + AppSpacing.s16;

  @override
  bool shouldRebuild(HomeSearchHeader oldDelegate) =>
      oldDelegate.topInset != topInset ||
      oldDelegate.greetingHeight != greetingHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final palette = context.palette;
    // 1 fully open, 0 fully collapsed.
    final open = maxExtent == minExtent
        ? 1.0
        : (1 - shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Painted, not just placed: the page scrolls underneath, and a header
        // you can see through is a header you cannot read.
        ColoredBox(color: palette.surface),
        // Filled, not just pinned to the top: given only a width, the image
        // takes whatever height its proportions ask for, and on a wide phone
        // that is taller than this header. Nothing clips a sliver's child, so
        // the surplus paints straight over the page below — which is why the
        // content looked missing until a scroll faded the picture out.
        Positioned.fill(
          child: Opacity(opacity: open, child: const _Leaves()),
        ),
        Positioned(
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          bottom: AppSpacing.s16 + _fieldHeight + AppSpacing.s16,
          child: Opacity(
            opacity: open,
            child: const _Greeting(),
          ),
        ),
        Positioned(
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          bottom: AppSpacing.s16,
          child: const _SearchField(),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.homeGreetingHi,
          style: AppTextStyles.regular16.copyWith(color: palette.textPrimary),
        ),
        Text(
          HomeSearchHeader.greetingFor(TimeOfDay.now(), context),
          style: AppTextStyles.medium24.copyWith(color: palette.textPrimary),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: HomeSearchHeader._fieldHeight,
      child: TextField(
        // Nothing to search yet; the field is the design's, and typing in it
        // simply does nothing until there is an index behind it.
        readOnly: true,
        decoration: InputDecoration(
          hintText: context.l10n.homeSearchHint,
          hintStyle: AppTextStyles.regular16.copyWith(
            color: palette.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppSize.icon24,
            color: palette.textTertiary,
          ),
          filled: true,
          fillColor: palette.surfaceRaised,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
            borderSide: BorderSide(color: palette.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
            borderSide: BorderSide(color: palette.divider),
          ),
        ),
      ),
    );
  }
}

/// The illustration behind the greeting.
///
/// It is drawn on white and there is no dark version of it, so on a dark theme
/// it is multiplied through the page's own background: white becomes the page,
/// and the leaves become a shade of it. Left as it is, it paints a white band
/// across the top of a dark page.
class _Leaves extends StatelessWidget {
  const _Leaves();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Assets.images.home.searchBackground.image(
      // Cover, and the box it covers is the header exactly.
      fit: BoxFit.cover,
      // Blended by the image itself rather than by a ColorFiltered around it.
      // That widget opens a layer of its own, and the multiply then reaches
      // past the picture and darkens the page underneath — which on a dark
      // theme means the whole screen below the header goes to the background
      // colour and the content looks like it never arrived.
      color: isDark ? context.palette.surface : null,
      colorBlendMode: isDark ? BlendMode.multiply : null,
      // Excluded from semantics: it is scenery, and naming it would put a noise
      // between the greeting and the search field.
      excludeFromSemantics: true,
    );
  }
}
