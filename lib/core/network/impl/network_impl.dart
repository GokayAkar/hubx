/// Network setup.
///
/// Dio itself stays inside `RemoteService`; what lives here is the configured
/// instance the app shares and the interceptors installed on it.
library;

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';

part 'src/logging_interceptor.dart';
part 'src/retry_policy.dart';

/// The source network traces are logged under.
const _logSource = LogSource('network');

/// Registers the app's [Dio], tracing every attempt and retrying the ones that
/// are safe to repeat.
///
/// Requires a [Logger] to be registered first.
///
/// Order matters: tracing is installed before retrying, so each attempt is
/// logged rather than only the last. Interceptors added later — the auth one
/// will do exactly this from its own module — run after both:
///
/// ```dart
/// DependencyProvider.get<Dio>().interceptors.add(_AuthInterceptor(...));
/// ```
///
/// Failed requests are *reported* by `RemoteService`, not from here: only it
/// can tell a request that failed from one a later interceptor recovered.
void registerNetwork(BaseOptions options) {
  DependencyProvider.registerLazySingleton<Dio>(() {
    final dio = Dio(options);

    return dio
      ..interceptors.add(
        _LoggingInterceptor(
          DependencyProvider.get<Logger>().withSource(_logSource),
          includeBodies: kDebugMode,
        ),
      )
      ..interceptors.add(
        RetryInterceptor(
          dio: dio,
          retries: 2,
          retryDelays: const [
            Duration(milliseconds: 200),
            Duration(milliseconds: 500),
          ],
          retryEvaluator: _shouldRetry,
        ),
      );
  });
}
