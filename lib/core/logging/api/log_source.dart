import 'package:equatable/equatable.dart';

/// Who produced a log entry.
///
/// A typed constant rather than an enum: core owns the infrastructure sources
/// below, and every feature declares its own next to its other contracts. That
/// way adding a feature never means editing a list inside core.
///
/// ```dart
/// // features/cards/api/cards_api.dart
/// abstract final class CardsLog {
///   static const source = LogSource('cards');
/// }
/// ```
class LogSource extends Equatable {
  const LogSource(this.name);

  /// The app itself: the root logger everything else is derived from.
  static const app = LogSource('app');

  /// Bloc activity, reported by the observer.
  static const bloc = LogSource('bloc');

  /// Errors raised by the Flutter framework.
  static const flutter = LogSource('flutter');

  /// Uncaught asynchronous errors.
  static const platform = LogSource('platform');

  /// The logging pipeline reporting on itself.
  static const logging = LogSource('logging');

  final String name;

  @override
  List<Object?> get props => [name];

  @override
  String toString() => name;
}
