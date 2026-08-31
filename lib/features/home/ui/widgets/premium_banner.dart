import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/core/ui/emphasised_text.dart';
import 'package:hubx/gen/assets.gen.dart';

/// The offer at the top of the page, in the design's gold on near-black.
///
/// Its colours are the banner's own rather than the theme's: it is meant to
/// look like something else on the page, and it looks the same whichever theme
/// the app is in.
class PremiumBanner extends StatelessWidget {
  const PremiumBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  static const _background = Color(0xFF24201A);
  static const _gold = Color(0xFFE5C990);
  static const _goldMuted = Color(0xFFBBA588);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _background,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Assets.icons.premiumMail.svg(width: 40.w, height: 40.w),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmphasisedText(
                      context.l10n.homePremiumTitle,
                      style: AppTextStyles.semiBold16.copyWith(color: _gold),
                      emphasisStyle: AppTextStyles.bold16.copyWith(
                        color: _gold,
                      ),
                    ),
                    Text(
                      context.l10n.homePremiumBody,
                      style: AppTextStyles.regular13.copyWith(
                        color: _goldMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppSize.icon24,
                color: _goldMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
