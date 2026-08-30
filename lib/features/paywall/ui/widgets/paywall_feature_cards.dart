import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/gen/assets.gen.dart';

/// What the subscription buys, as a row the user can push sideways.
class PaywallFeatureCards extends StatelessWidget {
  const PaywallFeatureCards({required this.features, super.key});

  final List<PaywallFeature> features;

  /// How much of the third card shows.
  static const _peek = 0.1;

  /// The design's card height, at the design's own width.
  static const _cardHeight = 124.0;

  /// The width of one card on a screen [maxWidth] wide.
  static double _cardWidth(double maxWidth) {
    // Only the left edge is padded; the right one bleeds so the third card can
    // run past it.
    final visible = maxWidth - AppSpacing.s24;

    return (visible - AppSpacing.s8 * 2) / (2 + _peek);
  }

  @override
  Widget build(BuildContext context) {
    final gap = AppSpacing.s8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = PaywallFeatureCards._cardWidth(constraints.maxWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: AppSpacing.s24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, feature) in features.indexed) ...[
                if (index > 0) SizedBox(width: gap),
                _Card(feature: feature, width: cardWidth),
              ],
              SizedBox(width: AppSpacing.s24),
            ],
          ),
        );
      },
    );
  }
}

/// One selling point.
class PaywallFeature {
  const PaywallFeature({
    required this.icon,
    required this.title,
    required this.body,
  });

  final SvgGenImage icon;
  final String title;
  final String body;
}

class _Card extends StatelessWidget {
  const _Card({required this.feature, required this.width});

  final PaywallFeature feature;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ConstrainedBox(
        // A minimum rather than a fixed height: the design's 124 at the
        // system's own text size, taller when the user asks for larger text.
        constraints: BoxConstraints(
          minHeight: PaywallFeatureCards._cardHeight.w,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.palette.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.r14),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Icon(feature.icon),
                // No Spacer: the card lives in a vertical scroll, so its
                // height is what its content makes it. This gap is what takes
                // the content to the design's 124.
                SizedBox(height: AppSpacing.s8),
                Text(
                  feature.title,
                  style: AppTextStyles.medium20.copyWith(
                    color: context.palette.textPrimary,
                  ),
                ),
                Text(
                  feature.body,
                  style: AppTextStyles.regular13.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon(this.icon);

  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      // Tinted here rather than in the file, so one asset serves every state.
      child: icon.svg(
        width: AppSize.icon20,
        height: AppSize.icon20,
        colorFilter: ColorFilter.mode(
          context.palette.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
