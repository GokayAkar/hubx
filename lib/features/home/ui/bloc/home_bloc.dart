import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hubx/features/home/api/home_api.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads the promoted articles.
///
/// The categories below them are not here: they arrive a page at a time and
/// their state machine lives in a `PagingController`, which is a bloc of its
/// own in all but name. Two independent loads, two independent failures — the
/// articles failing must not empty the grid.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  final HomeRepository _repository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      emit(
        HomeState(
          status: HomeStatus.ready,
          questions: await _repository.fetchQuestions(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: HomeStatus.failed));
    }
  }
}
