/// Paths other features navigate to, without seeing this feature's widgets.
abstract final class OnboardingRoutes {
  /// The welcome screen, and the app's entry point for a new user.
  static const root = '/onboarding';

  /// The illustrated steps. Its own route so the page indicator and the call
  /// to action can stay put while only the pages slide.
  static const steps = '/onboarding/steps';
}
