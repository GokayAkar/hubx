part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => const [];
}

/// Asks for the promoted articles. Sent again to retry a failed load.
final class HomeStarted extends HomeEvent {
  const HomeStarted();
}
