part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({this.count = 0});

  final int count;

  @override
  List<Object?> get props => [count];
}
