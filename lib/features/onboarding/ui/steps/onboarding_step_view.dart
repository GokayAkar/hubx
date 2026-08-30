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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.s24),
        _Title(title: title),
        SizedBox(height: AppSpacing.s32),
        Expanded(
          child: image.image(fit: BoxFit.contain, excludeFromSemantics: true),
        ),
      ],
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
          letterSpacing: -1,
        ),
        emphasisStyle: AppTextStyles.extraBold28.copyWith(
          color: context.palette.textPrimary,
          letterSpacing: -1,
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
