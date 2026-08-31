import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/features/home/ui/widgets/remote_image.dart';

/// What a card on the home page opens into.
///
/// One screen for both articles and categories: they arrive from different
/// endpoints but they are the same thing here — a picture, a name, and a body
/// of text. The body is placeholder copy until there is something real behind
/// it.
@RoutePage()
class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({
    required this.title,
    required this.imageUrl,
    required this.heroTag,
    this.subtitle,
    super.key,
  });

  final String title;
  final String imageUrl;

  /// Shared with the card that opened this screen, which is what lets the
  /// picture travel between the two instead of being replaced.
  final String heroTag;

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.w,
            pinned: true,
            backgroundColor: palette.surface,
            foregroundColor: palette.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: heroTag,
                child: RemoteImage(url: imageUrl),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.s24),
            sliver: SliverList.list(
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: AppTextStyles.medium15.copyWith(
                      color: palette.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s8),
                ],
                Text(
                  title,
                  style: AppTextStyles.medium24.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.s16),
                Text(
                  _body,
                  style: AppTextStyles.regular15.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Deliberately not localised: it is filler standing in for an article, and
  /// translating Lorem Ipsum would only make it look like real copy.
  static const _body = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.''';
}
