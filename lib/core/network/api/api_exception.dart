import 'package:flutter/foundation.dart';

/// Everything a request can fail with.
///
/// Sealed, so a caller can handle each case exhaustively and the compiler
/// points at the gap when a new one appears. `RemoteService` maps Dio's error
/// taxonomy onto these, so call sites reason about what went wrong rather than
/// about `DioExceptionType`.
sealed class ApiException implements Exception {
  const ApiException({
    required this.method,
    required this.path,
    this.cause,
    this.stackTrace,
  });

  final String method;
  final String path;

  /// The underlying error, kept for logs — never for control flow.
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ApiException')}($method $path)';
}

/// The server answered, but not with success.
final class ApiStatusException extends ApiException {
  const ApiStatusException({
    required super.method,
    required super.path,
    required this.statusCode,
    this.body,
    super.cause,
    super.stackTrace,
  });

  final int statusCode;

  /// The decoded error body, when there was one.
  final Object? body;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isClientError => statusCode >= 400 && statusCode < 500;

  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'ApiStatusException($statusCode, $method $path)';
}

/// The server could not be reached at all.
final class ApiConnectionException extends ApiException {
  const ApiConnectionException({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });
}

/// The request outlived one of the configured timeouts.
final class ApiTimeoutException extends ApiException {
  const ApiTimeoutException({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });
}

/// The app cancelled the request itself.
///
/// Its own case because this is not a failure: a search screen that cancels the
/// previous keystroke's request expects it, and it must not be reported like
/// something broke.
final class ApiCancelledException extends ApiException {
  const ApiCancelledException({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });
}

/// The response arrived but did not fit the model.
final class ApiParsingException extends ApiException {
  const ApiParsingException({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });
}

/// Anything that could not be classified — including a response the transport
/// could not attach a status code to.
final class ApiUnknownException extends ApiException {
  const ApiUnknownException({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });
}
