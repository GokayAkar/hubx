/// Logging implementation.
///
/// The classes live in `part` files and are named with a leading underscore, so
/// nothing outside this library can import or reference them.
library;

import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';

part 'src/console_log_sink.dart';
part 'src/log_entry_distributor.dart';
part 'src/logger_impl.dart';
part 'src/logging_bloc_observer.dart';

/// Binds [Logger] and [LogSinkRegistry], with the console as the only sink.
///
/// Adding a backend later means writing a `LogSink` and registering it — this
/// function does not change:
///
/// ```dart
/// DependencyProvider.get<LogSinkRegistry>().addSink(DatadogLogSink(...));
/// ```
void registerLogging({
  LogLevel minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info,
}) {
  final distributor = _LogEntryDistributor()
    ..addSink(_ConsoleLogSink(minimumLevel: minimumLevel));

  DependencyProvider.registerLazySingleton<LogSinkRegistry>(() => distributor);
  DependencyProvider.registerLazySingleton<Logger>(
    () => _LoggerImpl(source: LogSource.app, distributor: distributor),
  );
}

/// Routes the error streams the app does not own into [Logger]: framework
/// errors, uncaught async errors and every bloc transition.
///
/// Call once, after [registerLogging].
void attachLoggingHandlers() {
  final logger = DependencyProvider.get<Logger>();
  final flutterLogger = logger.withSource(LogSource.flutter);

  // Chained, not replaced: Flutter's own handler still dumps to the console,
  // deduplicates and reports to DevTools — and flutter_test still fails tests
  // on framework errors.
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    flutterLogger.error(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
      context: {if (details.library != null) 'library': details.library},
    );
    previousFlutterOnError?.call(details);
  };

  final platformLogger = logger.withSource(LogSource.platform);
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    platformLogger.error(
      'Uncaught error',
      error: error,
      stackTrace: stackTrace,
    );
    // False hands the error back to the platform, so the crash still surfaces
    // in the native report instead of being silently swallowed.
    return false;
  };

  Bloc.observer = _LoggingBlocObserver(logger.withSource(LogSource.bloc));
}
