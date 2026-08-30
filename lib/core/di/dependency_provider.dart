import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

/// The only door to the service locator.
///
/// Features never import `get_it` directly: they register through their own
/// `register*` function and resolve through [get]. That keeps the container
/// swappable and keeps `get_it` out of every pubspec in the app.
abstract final class DependencyProvider {
  static final GetIt _di = GetIt.instance;

  static T get<T extends Object>({String? instanceName}) =>
      _di.get<T>(instanceName: instanceName);

  static T? getOrNull<T extends Object>({String? instanceName}) =>
      isRegistered<T>(instanceName: instanceName)
      ? get<T>(instanceName: instanceName)
      : null;

  static bool isRegistered<T extends Object>({String? instanceName}) =>
      _di.isRegistered<T>(instanceName: instanceName);

  /// Registers a single instance created on first use.
  ///
  /// [T] must always be the *interface*, never the implementation type —
  /// that is what keeps implementations invisible to the rest of the app.
  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) {
    _di.registerLazySingleton<T>(
      factory,
      instanceName: instanceName,
      dispose: dispose,
    );
  }

  /// Registers a new instance per resolution. Use it for blocs and cubits.
  static void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _di.registerFactory<T>(factory, instanceName: instanceName);
  }

  /// Puts [instance] in place of whatever is registered for [T].
  ///
  /// For tests: it is how a fake stands in for the real thing after the app
  /// has already wired itself up, which is the only way to reach a path — a
  /// failing request, an empty response — that the real implementation never
  /// takes.
  @visibleForTesting
  static void override<T extends Object>(T instance, {String? instanceName}) {
    _di.allowReassignment = true;
    try {
      _di.registerSingleton<T>(instance, instanceName: instanceName);
    } finally {
      // Back off immediately: a duplicate registration in the app itself is a
      // mistake, and this must not be what hides it.
      _di.allowReassignment = false;
    }
  }

  @visibleForTesting
  static Future<void> reset() => _di.reset();
}
