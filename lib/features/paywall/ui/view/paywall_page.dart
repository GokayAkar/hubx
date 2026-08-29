import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hubx/core/theme/app_colors.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/ui/app_icon_button.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/gen/assets.gen.dart';

/// Scaffold for the paywall: the background and the way out are real, the
/// offer is not built yet.
@RoutePage()
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paywallSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.paywall.background.image(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            excludeFromSemantics: true,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s8),
                child: AppIconButton(
                  icon: Icons.close,
                  label: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () =>
                      unawaited(context.router.replacePath(HomeRoutes.root)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
