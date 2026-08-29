import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Screen-scoped state for the onboarding flow.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._repository) : super(const OnboardingState()) {
    on<OnboardingFinished>(_onFinished);
  }

  final OnboardingRepository _repository;

  Future<void> _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.saving));
    await _repository.markCompleted();
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
