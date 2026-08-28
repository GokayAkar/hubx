import 'package:hubx/core/logging/api/log_source.dart';

/// Severity of a diagnostic message.
enum LogLevel { debug, info, warning, error }

/// One thing worth reporting.
///
/// Sealed so a sink can decide per kind what to do with it — a crash reporter
/// only cares about [LogMessage] errors, an analytics backend only about
/// [LogEvent].
sealed class LogEntry {
  LogEntry({
    required this.source,
    DateTime? time,
    Map<String, Object?> context = const {},
  }) : time = time ?? DateTime.now(),
       // Copied: a caller that reuses and mutates its map must not be able to
       // change what a buffering sink uploads later.
       context = context.isEmpty
           ? const {}
           : Map<String, Object?>.unmodifiable(context);

  /// Who produced the entry.
  final LogSource source;

  final DateTime time;

  /// Extra key/values attached to the entry.
  final Map<String, Object?> context;
}

/// A diagnostic message, optionally carrying the error it describes.
final class LogMessage extends LogEntry {
  LogMessage({
    required this.level,
    required this.message,
    required super.source,
    this.error,
    this.stackTrace,
    super.time,
    super.context,
  });

  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}

/// Something the user did, or a business event worth counting.
final class LogEvent extends LogEntry {
  LogEvent({
    required this.name,
    required super.source,
    super.time,
    super.context,
  });

  final String name;
}
