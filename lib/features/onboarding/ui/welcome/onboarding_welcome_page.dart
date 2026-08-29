import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hubx/features/onboarding/ui/welcome/onboarding_welcome_view.dart';

/// The screen a new user lands on. Its own route: it has no page indicator and
/// its own call to action, and there is no going back to it.
@RoutePage()
class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingWelcomeView();
  }
}
