part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => const [];
}

/// The user reached the end of the flow.
final class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}
