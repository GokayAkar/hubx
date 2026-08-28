import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Screen-scoped state for the home page.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeTapped>(_onTapped);
  }

  void _onTapped(HomeTapped event, Emitter<HomeState> emit) {
    emit(HomeState(count: state.count + 1));
  }
}
