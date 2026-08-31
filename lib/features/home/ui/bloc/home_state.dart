part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, failed }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.questions = const [],
  });

  final HomeStatus status;
  final List<Question> questions;

  bool get isLoading =>
      status == HomeStatus.initial || status == HomeStatus.loading;

  HomeState copyWith({HomeStatus? status, List<Question>? questions}) {
    return HomeState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [status, questions];
}
