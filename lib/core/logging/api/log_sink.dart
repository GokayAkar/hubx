import 'package:hubx/core/logging/api/log_entry.dart';

/// A destination for log entries.
///
/// Implement one per backend (console, Crashlytics, Datadog, …) and hand it to
/// [LogSinkRegistry]. Sinks decide for themselves which entries they care
/// about, so a crash reporter can ignore debug noise.
abstract interface class LogSink {
  void write(LogEntry entry);
}

/// Where sinks are plugged in and out at runtime.
///
/// A new backend never touches the logging implementation: it registers its own
/// sink here, from its own module.
abstract interface class LogSinkRegistry {
  void addSink(LogSink sink);

  void removeSink(LogSink sink);
}
