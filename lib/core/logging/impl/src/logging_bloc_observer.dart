part of '../logging_impl.dart';

/// Turns bloc activity into log entries: every dispatched event becomes a
/// [LogEvent] — that is the user-action trail — and every bloc failure becomes
/// an error.
class _LoggingBlocObserver extends BlocObserver {
  const _LoggingBlocObserver(this._logger);

  final Logger _logger;

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.event(
      event.runtimeType.toString(),
      properties: {'bloc': bloc.runtimeType.toString()},
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      '${bloc.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
