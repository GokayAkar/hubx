/// Whether the user has been through the onboarding flow.
///
/// Read at startup to decide which screen the app opens on.
abstract interface class OnboardingRepository {
  Future<bool> isCompleted();

  Future<void> markCompleted();
}
