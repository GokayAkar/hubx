import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/features/onboarding/ui/steps/bloc/onboarding_bloc.dart';
import 'package:hubx/features/onboarding/ui/steps/onboarding_step_view.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/gen/assets.gen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


@RoutePage()
class OnboardingStepsPage extends StatelessWidget {
  const OnboardingStepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyProvider.get<OnboardingBloc>(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) => current.isCompleted,
        listener: (context, state) =>
            unawaited(context.router.replacePath(PaywallRoutes.root)),
        builder: (context, state) {
          return _OnboardingStepsScreen(
            isSaving: state.isSaving,
            onFinish: () =>
                context.read<OnboardingBloc>().add(const OnboardingFinished()),
          );
        },
      ),
    );
  }
}

/// Pure presentation: no DI, no bloc — takes values, returns callbacks.
class _OnboardingStepsScreen extends StatefulWidget {
  const _OnboardingStepsScreen({
    required this.isSaving,
    required this.onFinish,
  });

  final bool isSaving;
  final VoidCallback onFinish;

  @override
  State<_OnboardingStepsScreen> createState() => _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState extends State<_OnboardingStepsScreen> {
  final _controller = PageController();

  /// Which dot is lit. Tracked here rather than handed to the indicator's
  /// controller because the dots and the pages are offset by one.
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if ((_controller.page ?? 0).round() == 1) {
      widget.onFinish();
      return;
    }
    unawaited(
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Only the pages move; everything below holds still.
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  OnboardingStepView(
                    title: context.l10n.onboardingScanTitle,
                    image: Assets.images.onboarding.scan,
                  ),
                  OnboardingStepView(
                    title: context.l10n.onboardingCareTitle,
                    image: Assets.images.onboarding.detail,
                  ),
                ],
              ),
            ),
            _Cta(onPressed: widget.isSaving ? null : _next),
            SizedBox(height: AppSpacing.s24),
            _Indicator(page: _page),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required int page,
  }) : _page = page;

  final int _page;

  @override
  Widget build(BuildContext context) {
    return Center(
      // Decorative, and the package marks each dot tappable: a 6dp
      // dot is far under the 48dp a finger needs, and "dot, dot,
      // dot" tells a screen reader nothing the page has not said.
      child: ExcludeSemantics(
        child: AnimatedSmoothIndicator(
          // The welcome screen owns the first dot, so the pages
          // here start at the second.
          activeIndex: _page,
          count: 2,
          effect: ScaleEffect(
            dotWidth: 6.w,
            dotHeight: 6.w,
            spacing: 4.w,
            scale: 10 / 6,
            radius: 6.w,
            dotColor: context.palette.indicatorInactive,
            activeDotColor: context.palette.indicatorActive,
          ),
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: FilledButton(
        onPressed: onPressed,
        child: Text(context.l10n.onboardingContinue),
      ),
    );
  }
}
