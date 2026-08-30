import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';

/// One plan the user can choose.
class PaywallPlanTile extends StatelessWidget {
  const PaywallPlanTile({
    required this.title,
    required this.detail,
    required this.isSelected,
    required this.onSelected,
    this.badge,
    super.key,
  });

  final String title;
  final String detail;
  final bool isSelected;
  final VoidCallback onSelected;

  /// The "save" flag, when the plan has something to boast about.
  final String? badge;

  static const _height = 63.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              // The design's 63 as a floor, so the tile keeps its proportions
              // at the system's own text size and grows rather than clips when
              // the user asks for larger.
              constraints: BoxConstraints(minHeight: _height.w),
              decoration: BoxDecoration(
                color: palette.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.r14),
                border: Border.all(
                  color: isSelected ? palette.primary : palette.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                children: [
                  _Radio(isSelected: isSelected),
                  SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.medium16.copyWith(
                            color: palette.textPrimary,
                          ),
                        ),
                        Text(
                          detail,
                          style: AppTextStyles.regular12.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(top: 0, right: 0, child: _Badge(badge!)),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return RadioGroup(
      groupValue: isSelected,
      onChanged: (_) {},
      child: Radio.adaptive(
        value: true,
        activeColor: palette.primary,
        enabled: isSelected,
        innerRadius: WidgetStateProperty.all(12.w),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.primary,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.r14),
          bottomLeft: Radius.circular(AppRadius.r12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        child: Text(
          label,
          style: AppTextStyles.regular12.copyWith(
            color: context.palette.onPrimary,
          ),
        ),
      ),
    );
  }
}
