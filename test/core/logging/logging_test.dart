import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';
import 'package:hubx/core/logging/impl/logging_impl.dart';

/// Stands in for a real backend sink (Crashlytics, Datadog, …).
class _RecordingSink implements LogSink {
  final entries = <LogEntry>[];

  @override
  void write(LogEntry entry) => entries.add(entry);
}

class _CounterBloc extends Bloc<String, int> {
  _CounterBloc() : super(0) {
    on<String>((event, emit) => emit(state + 1));
  }
}

class _FailingSink implements LogSink {
  @override
  void write(LogEntry entry) => throw StateError('backend is down');
}

void main() {
  late Logger logger;
  late LogSinkRegistry registry;
  late _RecordingSink sink;

  setUp(() async {
    await DependencyProvider.reset();
    registerLogging();
    logger = DependencyProvider.get<Logger>();
    registry = DependencyProvider.get<LogSinkRegistry>();
    sink = _RecordingSink();
    registry.addSink(sink);
  });

  group('Logger', () {
    test('sends diagnostics to every registered sink', () {
      final second = _RecordingSink();
      registry.addSink(second);

      logger.info('hello');

      expect(sink.entries, hasLength(1));
      expect(second.entries, hasLength(1));
    });

    test('carries level, message, error and stack trace', () {
      final stackTrace = StackTrace.current;

      logger.error('request failed', error: 'boom', stackTrace: stackTrace);

      final entry = sink.entries.single as LogMessage;
      expect(entry.level, LogLevel.error);
      expect(entry.message, 'request failed');
      expect(entry.error, 'boom');
      expect(entry.stackTrace, stackTrace);
    });

    test('records user actions as events, not messages', () {
      logger.event('settings_opened', properties: {'from': 'home'});

      final entry = sink.entries.single as LogEvent;
      expect(entry.name, 'settings_opened');
      expect(entry.context, {'from': 'home'});
    });

    test('tags entries with their source', () {
      logger.withSource(const LogSource('network')).warning('slow response');

      expect(sink.entries.single.source, const LogSource('network'));
    });

    test('a sink added later also receives from derived loggers', () {
      final network = logger.withSource(const LogSource('network'));
      final late_ = _RecordingSink();

      registry.addSink(late_);
      network.info('after');

      expect(late_.entries, hasLength(1));
    });

    test('removed sinks stop receiving', () {
      registry.removeSink(sink);

      logger.info('ignored');

      expect(sink.entries, isEmpty);
    });

    test('bloc events become the user-action trail', () {
      final originalObserver = Bloc.observer;
      final originalFlutterOnError = FlutterError.onError;
      final originalPlatformOnError = PlatformDispatcher.instance.onError;
      addTearDown(() {
        Bloc.observer = originalObserver;
        FlutterError.onError = originalFlutterOnError;
        PlatformDispatcher.instance.onError = originalPlatformOnError;
      });

      attachLoggingHandlers();
      _CounterBloc().add('tapped');

      final entry = sink.entries.whereType<LogEvent>().single;
      expect(entry.name, 'String');
      expect(entry.source, LogSource.bloc);
      expect(entry.context['bloc'], '_CounterBloc');
    });

    test('copies the context, so later mutation cannot rewrite an entry', () {
      final context = <String, Object?>{'status': 500};

      logger.error('request failed', context: context);
      context['status'] = 200;

      expect(sink.entries.single.context, {'status': 500});
    });

    test('chains the previous FlutterError handler, not replaces it', () {
      final originalObserver = Bloc.observer;
      final originalFlutterOnError = FlutterError.onError;
      final originalPlatformOnError = PlatformDispatcher.instance.onError;
      addTearDown(() {
        Bloc.observer = originalObserver;
        FlutterError.onError = originalFlutterOnError;
        PlatformDispatcher.instance.onError = originalPlatformOnError;
      });

      var previousHandlerRan = false;
      FlutterError.onError = (_) => previousHandlerRan = true;

      attachLoggingHandlers();
      FlutterError.reportError(const FlutterErrorDetails(exception: 'boom'));

      expect(previousHandlerRan, isTrue);
      expect(
        sink.entries.whereType<LogMessage>().single.source,
        LogSource.flutter,
      );
    });

    test('one failing sink does not stop the others', () {
      registry.addSink(_FailingSink());
      final other = _RecordingSink();
      registry.addSink(other);

      expect(() => logger.info('still delivered'), returnsNormally);
      expect(other.entries, hasLength(1));
    });
  });
}
