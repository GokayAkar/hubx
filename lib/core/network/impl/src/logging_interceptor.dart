part of '../network_impl.dart';

/// Traces every attempt: what went out, what came back, how long it took.
///
/// This is a trace, not a report. Whether a request ultimately *failed* is
/// decided in `RemoteService` — an interceptor cannot tell a failure from one a
/// later interceptor recovers from, and never sees a parse failure at all. So
/// everything here is logged at [LogLevel.debug]: visible while developing,
/// below the release threshold, and never an alert.
class _LoggingInterceptor extends Interceptor {
  const _LoggingInterceptor(this._logger, {required this.includeBodies});

  final Logger _logger;

  /// Bodies are only ever logged in debug builds. A request body carries
  /// whatever the user typed — passwords, card numbers, an IBAN — and these
  /// entries are meant to reach a remote sink one day.
  final bool includeBodies;

  static const _startedAtKey = 'hubx.startedAt';
  static const _redacted = '***';

  /// Header names whose values are secrets, whatever the build.
  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'proxy-authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();

    _logger.debug(
      '-> ${options.method} ${options.path}',
      context: {
        if (options.queryParameters.isNotEmpty)
          'query': options.queryParameters,
        'headers': _safeHeaders(options.headers),
        if (includeBodies && options.data != null) 'body': options.data,
      },
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '<- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}',
      context: {
        ..._timing(response.requestOptions),
        if (includeBodies) 'body': response.data,
      },
    );

    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    _logger.debug(
      '<- ${error.type.name} ${error.requestOptions.method} '
      '${error.requestOptions.path}',
      context: {
        ..._timing(error.requestOptions),
        if (error.response?.statusCode != null)
          'status': error.response!.statusCode,
      },
    );

    handler.next(error);
  }

  Map<String, Object?> _timing(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return const {};

    return {'ms': DateTime.now().difference(startedAt).inMilliseconds};
  }

  Map<String, Object?> _safeHeaders(Map<String, Object?> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _sensitiveHeaders.contains(entry.key.toLowerCase())
            ? _redacted
            : entry.value,
    };
  }
}
