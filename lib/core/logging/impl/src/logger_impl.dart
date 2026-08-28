part of '../logging_impl.dart';

/// Turns calls into [LogEntry] objects and hands them to the distributor.
///
/// Holds nothing but its source, so [withSource] is free.
class _LoggerImpl implements Logger {
  const _LoggerImpl({
    required LogSource source,
    required _LogEntryDistributor distributor,
  }) : _source = source,
       _distributor = distributor;

  final LogSource _source;
  final _LogEntryDistributor _distributor;

  @override
  Logger withSource(LogSource source) =>
      _LoggerImpl(source: source, distributor: _distributor);

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) =>
      _message(LogLevel.debug, message, context);

  @override
  void info(String message, {Map<String, Object?> context = const {}}) =>
      _message(LogLevel.info, message, context);

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => _message(
    LogLevel.warning,
    message,
    context,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => _message(
    LogLevel.error,
    message,
    context,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void event(String name, {Map<String, Object?> properties = const {}}) =>
      _distributor.distribute(
        LogEvent(name: name, source: _source, context: properties),
      );

  void _message(
    LogLevel level,
    String message,
    Map<String, Object?> context, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _distributor.distribute(
      LogMessage(
        level: level,
        message: message,
        source: _source,
        error: error,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }
}
