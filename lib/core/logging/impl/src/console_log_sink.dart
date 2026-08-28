part of '../logging_impl.dart';

/// Writes to the developer console. Always on locally, harmless in release.
class _ConsoleLogSink implements LogSink {
  const _ConsoleLogSink({required this.minimumLevel});

  final LogLevel minimumLevel;

  static const Map<LogLevel, int> _levelValues = {
    LogLevel.debug: 500,
    LogLevel.info: 800,
    LogLevel.warning: 900,
    LogLevel.error: 1000,
  };

  @override
  void write(LogEntry entry) {
    // Events carry no level of their own; they count as informational.
    final level = switch (entry) {
      LogMessage() => entry.level,
      LogEvent() => LogLevel.info,
    };
    if (level.index < minimumLevel.index) return;

    // Formatted only once the entry is known to be printed.
    final context = entry.context.isEmpty ? '' : ' ${entry.context}';

    switch (entry) {
      case LogMessage():
        developer.log(
          '${entry.message}$context',
          name: entry.source.name,
          time: entry.time,
          level: _levelValues[level] ?? 0,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
      case LogEvent():
        developer.log(
          'event: ${entry.name}$context',
          name: entry.source.name,
          time: entry.time,
          level: _levelValues[level] ?? 0,
        );
    }
  }
}
