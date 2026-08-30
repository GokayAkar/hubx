import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/core/ui/emphasised_text.dart';
import 'package:hubx/features/onboarding/api/onboarding_routes.dart';
import 'package:hubx/gen/assets.gen.dart';

/// The first screen: what the app is, and one way in.
///
/// No step indicator here — the design starts counting from the screen after
/// this one.
class OnboardingWelcomeView extends StatelessWidget {
  const OnboardingWelcomeView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: context.palette.welcomeGradient,
      ),
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: decoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.s24),
              const _Title(),
              const _Subtitle(),
              SizedBox(height: AppSpacing.s24),
              Expanded(
                child: Assets.images.onboarding.welcome.image(
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              const _Cta(),
              SizedBox(height: AppSpacing.s12),
              _Legal(onOpenTerms: () {}, onOpenPrivacy: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: FilledButton(
        onPressed: () => unawaited(
          context.router.replacePath(OnboardingRoutes.steps),
        ),
        child: Text(
          context.l10n.onboardingWelcomeAction,
          style: AppTextStyles.semiBold16,
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Text(
        context.l10n.onboardingWelcomeBody,
        style: AppTextStyles.regular16.copyWith(
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: EmphasisedText(
        context.l10n.onboardingWelcomeTitle,
        style: AppTextStyles.light28.copyWith(
          color: context.palette.textPrimary,
        ),
        emphasisStyle: AppTextStyles.semiBold28.copyWith(
          color: context.palette.textPrimary,
        ),
      ),
    );
  }
}

class _Legal extends StatefulWidget {
  const _Legal({required this.onOpenTerms, required this.onOpenPrivacy});

  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  State<_Legal> createState() => _LegalState();
}

class _LegalState extends State<_Legal> {
  /// Recognisers hold gesture state, so they are created once and disposed.
  late final _terms = TapGestureRecognizer()..onTap = widget.onOpenTerms;
  late final _privacy = TapGestureRecognizer()..onTap = widget.onOpenPrivacy;

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.regular11.copyWith(
      color: context.palette.textTertiary,
    );
    final link = AppTextStyles.underlined(base);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${context.l10n.onboardingLegal}\n'),
          TextSpan(
            text: context.l10n.onboardingTermsOfUse,
            style: link,
            recognizer: _terms,
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: context.l10n.onboardingPrivacyPolicy,
            style: link,
            recognizer: _privacy,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      style: base,
      textAlign: TextAlign.center,
    );
  }
}
