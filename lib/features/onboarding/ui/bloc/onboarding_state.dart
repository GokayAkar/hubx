part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, saving, completed }

class OnboardingState extends Equatable {
  const OnboardingState({this.status = OnboardingStatus.initial});

  final OnboardingStatus status;

  bool get isSaving => status == OnboardingStatus.saving;

  bool get isCompleted => status == OnboardingStatus.completed;

  OnboardingState copyWith({OnboardingStatus? status}) =>
      OnboardingState(status: status ?? this.status);

  @override
  List<Object?> get props => [status];
}
