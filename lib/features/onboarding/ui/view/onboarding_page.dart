import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/onboarding/ui/bloc/onboarding_bloc.dart';

/// Placeholder for the real onboarding flow.
///
/// What matters here is the wiring: finishing marks the flow complete through
/// `OnboardingRepository`, so the next launch opens on home instead.
@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyProvider.get<OnboardingBloc>(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) => current.isCompleted,
        // Replace, not push: onboarding leaves the stack for good, so back
        // exits the app instead of returning to the flow.
        listener: (context, state) =>
            unawaited(context.router.replacePath(HomeRoutes.root)),
        builder: (context, state) {
          return _OnboardingScreen(
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
class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({required this.isSaving, required this.onFinish});

  final bool isSaving;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.onboardingTitle,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.onboardingBody,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: isSaving ? null : onFinish,
                child: Text(context.l10n.onboardingContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
