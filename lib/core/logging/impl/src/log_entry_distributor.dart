part of '../logging_impl.dart';

/// Owns the sinks and hands every entry to all of them.
///
/// This is the shared piece: all loggers point at the same distributor, so a
/// sink added at any time is seen by every logger, derived ones included.
class _LogEntryDistributor implements LogSinkRegistry {
  final _sinks = <LogSink>[];

  @override
  void addSink(LogSink sink) => _sinks.add(sink);

  @override
  void removeSink(LogSink sink) => _sinks.remove(sink);

  /// One failing sink must never take the others — or the app — down with it.
  void distribute(LogEntry entry) {
    for (final sink in List<LogSink>.of(_sinks)) {
      try {
        sink.write(entry);
      } on Object catch (error, stackTrace) {
        developer.log(
          'Log sink ${sink.runtimeType} failed',
          name: LogSource.logging.name,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
