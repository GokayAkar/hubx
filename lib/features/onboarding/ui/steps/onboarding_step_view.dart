import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/core/ui/emphasised_text.dart';
import 'package:hubx/gen/assets.gen.dart';

/// One illustrated step: a heading and a picture.
///
/// The button and the page indicator are deliberately not here — they belong
/// to the screen around the `PageView`, so they hold still while the pages
/// slide under them.
class OnboardingStepView extends StatelessWidget {
  const OnboardingStepView({
    required this.title,
    required this.image,
    super.key,
  });

  final String title;
  final AssetGenImage image;

  /// How much of the screen the artwork takes, measured from the layout this
  /// replaced.
  static const _artworkShare = 0.698;

  @override
  Widget build(BuildContext context) {
    // Fills the device and does not scroll at any ordinary text size: the
    // minimum height makes the column as tall as the viewport, so there is
    // nothing to scroll to. At the accessibility sizes, where the title alone
    // can be taller than the screen, it becomes a scroll rather than clipping
    // the artwork away.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: AppSpacing.s24),
                  _Title(title: title),
                ],
              ),
              // A share of the screen rather than whatever is left over:
              // leftovers need a bounded height, which a scroll view does not
              // give. The figure is what the old layout measured at, so the
              // artwork is the size it always was.
              SizedBox(
                height: constraints.maxHeight * _artworkShare,
                child: image.image(
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: EmphasisedText(
        title,
        style: AppTextStyles.medium28.copyWith(
          color: context.palette.textPrimary,
        ),
        emphasisStyle: AppTextStyles.extraBold28.copyWith(
          color: context.palette.textPrimary,
        ),
        // Stretched to the measured width of the emphasised words, so the
        // stroke fits whatever they turn out to be.
        underlineBuilder: (width) => Assets.images.onboarding.titleBrush.image(
          width: width,
          fit: BoxFit.fill,
          height: 8.h,
          // The stroke is one colour over transparency, so it works as a mask:
          // `srcIn` keeps its shape and takes the heading's colour, which is
          // what stops it disappearing on a dark background.
          color: context.palette.textPrimary,
          colorBlendMode: BlendMode.srcIn,
        ),
        underlineOvershoot: 0.2,
      ),
    );
  }
}
