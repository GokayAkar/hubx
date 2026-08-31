import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/ui/home_ui.dart';

import '../../../support/fake_home_repository.dart';

void main() {
  group('HomeBloc', () {
    test('starts with nothing, and knows it is not done', () {
      final bloc = HomeBloc(FakeHomeRepository());

      expect(bloc.state.status, HomeStatus.initial);
      expect(bloc.state.questions, isEmpty);
      // `initial` counts as loading: the screen is put together before the
      // first event is handled, and a frame that called that state "ready"
      // would show an empty row rather than a skeleton.
      expect(bloc.state.isLoading, isTrue);
    });

    blocTest<HomeBloc, HomeState>(
      'passes through loading on its way to the articles',
      build: () => HomeBloc(FakeHomeRepository()),
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.ready,
          questions: FakeHomeRepository.questions,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'reports a failure rather than swallowing it',
      build: () => HomeBloc(FakeHomeRepository(failQuestions: true)),
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.failed),
      ],
      // Handed to the observer as well as the state: the user sees a retry,
      // and whoever is on call sees the reason.
      errors: () => [isA<Exception>()],
    );

    blocTest<HomeBloc, HomeState>(
      'the same event is the retry, and it can succeed the second time',
      build: () => HomeBloc(_FlakyRepository()),
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HomeStarted());
      },
      skip: 2,
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.ready,
          questions: FakeHomeRepository.questions,
        ),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<HomeBloc, HomeState>(
      'a retry after a success keeps what is already on screen',
      build: () => HomeBloc(FakeHomeRepository()),
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HomeStarted());
      },
      skip: 2,
      // The articles survive the loading state, so a refresh does not blank
      // the row it is refreshing.
      expect: () => [
        const HomeState(
          status: HomeStatus.loading,
          questions: FakeHomeRepository.questions,
        ),
        const HomeState(
          status: HomeStatus.ready,
          questions: FakeHomeRepository.questions,
        ),
      ],
    );
  });
}

/// Fails once, then works: the shape of a connection that has come back.
class _FlakyRepository extends FakeHomeRepository {
  var _asked = false;

  @override
  Future<List<Question>> fetchQuestions() async {
    if (!_asked) {
      _asked = true;
      throw Exception('offline');
    }

    return FakeHomeRepository.questions;
  }
}
