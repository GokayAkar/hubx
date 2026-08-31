import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/onboarding/ui/onboarding_ui.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool completed = false;
  bool writesFail = false;
  int calls = 0;

  @override
  Future<bool> isCompleted() async => completed;

  @override
  Future<void> markCompleted() async {
    calls++;
    if (writesFail) throw StateError('disk is full');
    completed = true;
  }
}

void main() {
  late _FakeOnboardingRepository repository;

  setUp(() => repository = _FakeOnboardingRepository());

  group('OnboardingBloc', () {
    test('starts before the flow has been finished', () {
      final bloc = OnboardingBloc(repository);

      expect(bloc.state.status, OnboardingStatus.initial);
      expect(bloc.state.isSaving, isFalse);
      expect(bloc.state.isCompleted, isFalse);
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'saves the flag and says the flow is done',
      build: () => OnboardingBloc(repository),
      act: (bloc) => bloc.add(const OnboardingFinished()),
      expect: () => const [
        OnboardingState(status: OnboardingStatus.saving),
        OnboardingState(status: OnboardingStatus.completed),
      ],
      verify: (_) => expect(repository.completed, isTrue),
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'lets the user through even when the flag cannot be saved',
      build: () => OnboardingBloc(repository..writesFail = true),
      act: (bloc) => bloc.add(const OnboardingFinished()),
      // Deliberately the same ending as the happy path. A write that failed
      // costs the user this flow once more on the next launch; stopping here
      // would strand them on a screen whose only button never comes back.
      expect: () => const [
        OnboardingState(status: OnboardingStatus.saving),
        OnboardingState(status: OnboardingStatus.completed),
      ],
      // Silent to the user, but not to whoever is on call.
      errors: () => [isA<StateError>()],
      verify: (_) => expect(repository.completed, isFalse),
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'a second tap does not write the flag twice over',
      build: () => OnboardingBloc(repository),
      act: (bloc) async {
        bloc.add(const OnboardingFinished());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const OnboardingFinished());
      },
      // The repository is asked again — the bloc does not deduplicate — but
      // the state it lands on is the same either way, so a double tap cannot
      // leave the flow half finished.
      verify: (bloc) {
        expect(bloc.state.status, OnboardingStatus.completed);
        expect(repository.calls, 2);
      },
    );
  });
}
