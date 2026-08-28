import 'package:hubx/core/logging/api/log_source.dart';

/// What the app logs through.
///
/// The implementation fans entries out to every registered `LogSink`, so code
/// that logs never knows whether the destination is the console, Crashlytics or
/// Datadog.
abstract interface class Logger {
  /// Returns a logger that tags its entries with [source].
  ///
  /// Sinks are shared, so a sink added later reaches derived loggers too.
  Logger withSource(LogSource source);

  void debug(String message, {Map<String, Object?> context});

  void info(String message, {Map<String, Object?> context});

  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context,
  });

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context,
  });

  /// Records a user action or business event.
  void event(String name, {Map<String, Object?> properties});
}
