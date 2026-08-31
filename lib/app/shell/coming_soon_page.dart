import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_text_styles.dart';

/// The tabs that have no feature behind them yet.
///
/// Real routes rather than dead buttons: the bar switches to them, the back
/// stack behaves, and the day one of them grows a feature it replaces a page
/// instead of teaching the bar something new.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
      ),
      body: Center(
        child: Text(
          context.l10n.comingSoon,
          style: AppTextStyles.regular15.copyWith(color: palette.textSecondary),
        ),
      ),
    );
  }
}

@RoutePage()
class DiagnosePage extends StatelessWidget {
  const DiagnosePage({super.key});

  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: context.l10n.navDiagnose);
}

@RoutePage()
class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: context.l10n.navGarden);
}
