part of '../network_impl.dart';

/// Statuses worth trying again.
///
/// 500 is deliberately absent: a server that threw will throw again, and
/// retrying only doubles the load on something already struggling. These are
/// the ones that say "busy, come back".
const _retryableStatuses = {
  408, // request timeout
  429, // too many requests
  502, // bad gateway
  503, // service unavailable
  504, // gateway timeout
};

/// Methods that can be repeated without changing the outcome.
///
/// POST and PATCH are missing on purpose: a timed-out POST may well have
/// reached the server, and sending it again would place a second order.
const _idempotentMethods = {'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'};

/// Decides whether a failed attempt may be repeated.
///
/// Replaces `dio_smart_retry`'s [DefaultRetryEvaluator], which decides on the
/// status code alone: it never looks at the method, so it would replay a POST,
/// and its retryable set includes 500.
bool _shouldRetry(DioException error, int attempt) {
  if (!_idempotentMethods.contains(error.requestOptions.method.toUpperCase())) {
    return false;
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError => true,
    DioExceptionType.badResponse => _retryableStatuses.contains(
      error.response?.statusCode,
    ),
    // Cancelling was the app's own doing; a bad certificate will not heal.
    DioExceptionType.cancel ||
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => false,
  };
}
