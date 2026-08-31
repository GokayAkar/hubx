import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hubx/core/logging/api/logging_api.dart';
import 'package:hubx/core/network/api/api_exception.dart';
import 'package:meta/meta.dart';

/// A decoded response body, before it is turned into a model.
///
/// Deliberately as wide as JSON itself: a map, a list, a string, a number, a
/// bool or null. Naming it says "this has been decoded but not yet
/// understood", which `Object?` on its own does not.
typedef Json = Object?;

/// Turns a decoded body into a model.
typedef JsonParser<T> = T Function(Json json);

/// Base class for a feature's remote data source.
///
/// A service lives in the feature's `impl`, is private to it, and turns
/// endpoints into models. Dio stays inside this class, so a service reads as
/// endpoints and parsers and nothing else:
///
/// ```dart
/// class _CardsService extends RemoteService {
///   const _CardsService(super.dio, super.logger);
///
///   Future<List<CardDto>> fetchCards() => get(
///     '/cards',
///     (json) => [for (final item in json! as List) CardDto.fromJson(item)],
///   );
///
///   Future<void> order(String type) =>
///       post('/cards', (_) {}, body: {'type': type});
/// }
/// ```
///
/// Dio features these verbs do not cover — cancellation, upload progress,
/// multipart — are added here as they are needed, rather than by reaching
/// around the class.
abstract class RemoteService {
  const RemoteService(Dio dio, Logger logger) : _dio = dio, _logger = logger;

  /// Private on purpose: every call goes through the verbs below, so no
  /// service can skip the error translation by awaiting Dio itself.
  final Dio _dio;

  /// Pass a logger already tagged with the feature's source, so a failure
  /// names the feature whose call failed.
  final Logger _logger;

  @protected
  Future<T> get<T>(
    String path,
    JsonParser<T> parse, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _fetch(
    _dio.get<Json>(
      path,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    ),
    parse,
  );

  @protected
  Future<T> post<T>(
    String path,
    JsonParser<T> parse, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _fetch(
    _dio.post<Json>(
      path,
      data: body,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    ),
    parse,
  );

  @protected
  Future<T> put<T>(
    String path,
    JsonParser<T> parse, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _fetch(
    _dio.put<Json>(
      path,
      data: body,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    ),
    parse,
  );

  @protected
  Future<T> patch<T>(
    String path,
    JsonParser<T> parse, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _fetch(
    _dio.patch<Json>(
      path,
      data: body,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    ),
    parse,
  );

  @protected
  Future<T> delete<T>(
    String path,
    JsonParser<T> parse, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _fetch(
    _dio.delete<Json>(
      path,
      data: body,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    ),
    parse,
  );

  /// Awaits [request] and turns its body into [T].
  ///
  /// The single place a request's outcome is judged. That is deliberately here
  /// and not in a Dio interceptor: an interceptor sees every failure, including
  /// the ones a later interceptor recovers from, and never sees a parse
  /// failure at all — so it can neither log the truth nor stay quiet about a
  /// request that ended up succeeding.
  Future<T> _fetch<T>(
    Future<Response<Json>> request,
    JsonParser<T> parse,
  ) async {
    final Response<Json> response;
    try {
      response = await request;
    } on DioException catch (error, stackTrace) {
      throw _report(error.toApiException(stackTrace));
    }

    try {
      return parse(_decoded(response.data));
    } on Object catch (error, stackTrace) {
      throw _report(
        ApiParsingException(
          method: response.requestOptions.method,
          path: response.requestOptions.path,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// The body, decoded.
  ///
  /// Dio decides whether to decode from the response's content type, and not
  /// every server labels its JSON correctly — this one calls it text/html,
  /// so what arrives is a string containing JSON rather than a map. Undoing
  /// that here keeps the workaround in one place instead of in every parser,
  /// and a correctly labelled response arrives decoded already and passes
  /// straight through.
  ///
  /// A body that really is text stays text: only something that parses as
  /// JSON is replaced.
  Json _decoded(Json data) {
    if (data is! String || data.isEmpty) return data;

    try {
      return jsonDecode(data);
    } on FormatException {
      return data;
    }
  }

  /// Logs [failure] at the severity it deserves and hands it back to be thrown.
  ///
  /// A 4xx is the app's normal life — not logged in, not found, bad input — and
  /// drowning the crash reporter in those buries the real outages. A cancelled
  /// request is not a failure at all. What is broken (5xx, no connection,
  /// timeouts, a response that did not fit the model) is what gets logged as an
  /// error.
  ApiException _report(ApiException failure) {
    final context = <String, Object?>{
      'method': failure.method,
      'path': failure.path,
      if (failure is ApiStatusException) 'status': failure.statusCode,
    };

    switch (failure) {
      case ApiCancelledException():
        _logger.debug('Request cancelled', context: context);
      case ApiStatusException(isServerError: false):
        _logger.warning(
          'Request failed',
          error: failure,
          stackTrace: failure.stackTrace,
          context: context,
        );
      case _:
        _logger.error(
          'Request failed',
          error: failure,
          stackTrace: failure.stackTrace,
          context: context,
        );
    }

    return failure;
  }
}

/// Maps Dio's error taxonomy onto [ApiException].
extension DioExceptionX on DioException {
  ApiException toApiException([StackTrace? stackTrace]) {
    final method = requestOptions.method;
    final path = requestOptions.path;
    final statusCode = response?.statusCode;

    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiTimeoutException(
        method: method,
        path: path,
        cause: this,
        stackTrace: stackTrace,
      ),
      DioExceptionType.connectionError => ApiConnectionException(
        method: method,
        path: path,
        cause: this,
        stackTrace: stackTrace,
      ),
      DioExceptionType.cancel => ApiCancelledException(
        method: method,
        path: path,
        cause: this,
        stackTrace: stackTrace,
      ),
      // Without a status code there is nothing to classify: calling it a 0
      // would make `isClientError` and `isServerError` both false and let it
      // pass for an expected failure.
      DioExceptionType.badResponse when statusCode != null =>
        ApiStatusException(
          method: method,
          path: path,
          statusCode: statusCode,
          body: response?.data,
          cause: this,
          stackTrace: stackTrace,
        ),
      DioExceptionType.badResponse ||
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown => ApiUnknownException(
        method: method,
        path: path,
        cause: this,
        stackTrace: stackTrace,
      ),
    };
  }
}
