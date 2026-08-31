import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/ui/widgets/remote_image.dart';

/// One tile of the category grid: a name, and the plant sitting in the corner
/// under it.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.onTap,
    this.heroTag,
    super.key,
  });

  final PlantCategory category;
  final VoidCallback onTap;

  /// Ties this picture to the one on the screen it opens, so the two are the
  /// same object moving rather than one screen replacing another.
  ///
  /// Null for a card that stands in for a real one: a skeleton draws the same
  /// placeholder several times over, and several heroes answering to one tag
  /// is an error the moment any route transition begins.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surfaceRaised,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Bottom-right and allowed to run past the tile's edge, as the
            // design has it: the plant reads as sitting behind the card rather
            // than being pasted onto it.
            PositionedDirectional(
              end: -AppSpacing.s8,
              bottom: 0,
              width: 132.w,
              height: 132.w,
              child: _MaybeHero(
                tag: heroTag,
                child: RemoteImage(url: category.imageUrl, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.s16),
              child: SizedBox(
                width: 96.w,
                child: Text(
                  category.title,
                  style: AppTextStyles.semiBold16.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A [Hero] when there is a tag to fly under, and the child alone when there
/// is not.
class _MaybeHero extends StatelessWidget {
  const _MaybeHero({required this.tag, required this.child});

  final Object? tag;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      tag == null ? child : Hero(tag: tag!, child: child);
}
