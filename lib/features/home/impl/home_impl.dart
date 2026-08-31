/// Home domain implementation.
///
/// The classes live in `part` files and are named with a leading underscore, so
/// nothing outside this library can import or reference them.
library;

import 'package:dio/dio.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/logging/api/logging_api.dart';
import 'package:hubx/core/network/api/network_api.dart';
import 'package:hubx/features/home/api/home_api.dart';

part 'src/home_repository_impl.dart';
part 'src/home_service.dart';

/// Binds [HomeRepository] to its implementation.
void registerHomeDomain() {
  DependencyProvider.registerLazySingleton<HomeRepository>(
    () => _HomeRepositoryImpl(
      _HomeService(
        DependencyProvider.get<Dio>(),
        DependencyProvider.get<Logger>().withSource(_source),
      ),
    ),
  );
}

const _source = LogSource('home');
