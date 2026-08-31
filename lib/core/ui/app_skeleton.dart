import 'package:flutter/material.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Draws [child] as bones while [enabled], with the app's own colours.
///
/// [Skeletonizer] takes the real tree and paints every piece of it as a
/// placeholder, so a skeleton cannot drift out of step with the thing it stands
/// in for: change the layout and both change. What it needs is something to lay
/// out, which is what stand-in data is for — shapes, not values.
///
/// The two accessibility decisions live here rather than at each call site,
/// because they are the same decision every time:
///
///  - one announcement for the whole group, since a screen reader reading out a
///    page of nameless bones tells the user nothing;
///  - no shimmer under "reduce motion", which is on for people whom movement
///    makes ill. The pulse is decoration and the first thing to go; the shapes
///    still read as placeholders sitting still.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final palette = context.palette;

    return Semantics(
      label: context.l10n.loading,
      container: true,
      child: ExcludeSemantics(
        child: Skeletonizer(
          effect: MediaQuery.disableAnimationsOf(context)
              ? SolidColorEffect(color: palette.surfaceRaised)
              : ShimmerEffect(
                  baseColor: palette.surfaceRaised,
                  highlightColor: palette.divider,
                ),
          child: child,
        ),
      ),
    );
  }
}
