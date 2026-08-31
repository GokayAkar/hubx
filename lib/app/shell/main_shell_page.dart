import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/app/router/app_router.gr.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/gen/assets.gen.dart';

/// The bar along the bottom, and the four screens it switches between.
///
/// A shell route rather than a bar drawn inside the home page: each tab keeps
/// its own scroll position and its own back stack, and anything pushed on top
/// of the shell — a detail screen, the paywall — covers the bar rather than
/// floating above it.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        DiagnoseRoute(),
        GardenRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabs = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          extendBody: true,
          floatingActionButton: const _ScanButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _Bar(
            index: tabs.activeIndex,
            onSelected: tabs.setActiveIndex,
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  /// The design's 64, and as much more as the labels need.
  ///
  /// Measured rather than assumed: the labels grow with the user's text size,
  /// and a bar held at 64 clips them off at the larger accessibility sizes.
  static double _heightFor(BuildContext context) {
    final label = TextPainter(
      // Ascender and descender, so the line box is the tallest one a label
      // can occupy rather than the height of whichever word is in it. Merged
      // onto the inherited style, as [Text] does it: the line spacing comes
      // from there, not from the token.
      text: TextSpan(
        text: 'Hg',
        style: DefaultTextStyle.of(context).style.merge(
          AppTextStyles.regular11,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final labelHeight = label.height;
    label.dispose();

    return math.max(
      64.w,
      AppSpacing.s8 +
          AppSize.icon24 +
          AppSpacing.s4 +
          labelHeight +
          AppSpacing.s8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const icons = Assets.icons;
    // The app raises the bottom inset so no content sits against the screen
    // edge. A bar pinned to that edge is the exception — it *is* the edge — so
    // it takes the real system inset and nothing more. Left inherited, the
    // extra is padded inside the bar and leaves a strip of nothing under it.
    final systemInset = MediaQuery.viewPaddingOf(context).bottom;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.divider)),
        ),
        child: BottomAppBar(
          // The page's own background, not a fixed white: the bar sits flush
          // against the content above it in either theme.
          color: palette.surface,
          // No notch: the design has a straight top edge with the scan button
          // sitting on it, not cut into it.
          elevation: 0,
          padding: EdgeInsets.only(bottom: systemInset),
          height: _heightFor(context) + systemInset,
          child: Row(
            children: [
              _Tab(
                icon: icons.home,
                label: context.l10n.homeTitle,
                isSelected: index == 0,
                onTap: () => onSelected(0),
              ),
              _Tab(
                icon: icons.healthcare,
                label: context.l10n.navDiagnose,
                isSelected: index == 1,
                onTap: () => onSelected(1),
              ),
              // The gap the scan button occupies.
              SizedBox(width: _ScanButton.diameter + AppSpacing.s16),
              _Tab(
                icon: icons.garden,
                label: context.l10n.navGarden,
                isSelected: index == 2,
                onTap: () => onSelected(2),
              ),
              _Tab(
                icon: icons.profile,
                label: context.l10n.navProfile,
                isSelected: index == 3,
                onTap: () => onSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colour = isSelected ? palette.primary : palette.textTertiary;

    return Expanded(
      // Announced as the tab it is, and as selected or not: a screen reader
      // user needs to know which of the four they are on.
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        container: true,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon.svg(
                  width: AppSize.icon24,
                  height: AppSize.icon24,
                  colorFilter: ColorFilter.mode(colour, BlendMode.srcIn),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  label,
                  style: AppTextStyles.regular11.copyWith(color: colour),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton();

  /// The design's, which is between Material's regular 56 and its large 96.
  static double get diameter => 64.w;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        shape: const CircleBorder(),
        elevation: 0,
        tooltip: context.l10n.navScan,
        child: Assets.icons.identify.svg(
          width: AppSize.icon24,
          height: AppSize.icon24,
          colorFilter: ColorFilter.mode(palette.onPrimary, BlendMode.srcIn),
        ),
      ),
    );
  }
}
