import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/router/app_router.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Guards the four things a screen reader user, a large-text user and a user
/// with low vision depend on.
///
/// The screen list is the router's, so adding a screen adds its checks: there
/// is nothing here to remember to update.
void main() {
  const onboarded = {'onboarding.completed': true};

  Future<App> boot([Map<String, Object> stored = const {}]) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(stored);
    AppDependencies.register();

    return App(startup: await AppStartupLoader.load());
  }

  setUp(() async {
    await DependencyProvider.reset();
    final view = TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .views
        .first
      ..devicePixelRatio = 1
      ..physicalSize = kDesignSize;
    addTearDown(view.reset);
  });

  /// Boots the app and navigates to [path].
  Future<void> open(
    WidgetTester tester, {
    required String path,
    Map<String, Object> stored = const {},
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: await boot(stored),
      ),
    );
    await tester.pumpAndSettle();

    await tester.binding.handlePushRoute(path);
    await tester.pumpAndSettle();
  }

  // Driven by the router rather than a hand-kept list: a screen has to be
  // registered there to be reachable at all, so a new one cannot quietly skip
  // these checks.
  for (final route in AppRouter(startOnOnboarding: false).routes) {
    group(route.path, () {
      testWidgets('meets the accessibility guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await open(tester, stored: onboarded, path: route.path);

        // Every tappable is big enough to hit, and says what it does.
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Text stands out enough from what is behind it.
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      });

      testWidgets('survives the largest text the system offers', (
        tester,
      ) async {
        // iOS and Android both go past 2x with accessibility sizes on.
        await open(
          tester,
          stored: onboarded,
          path: route.path,
          textScale: 2,
        );

        expect(tester.takeException(), isNull);
      });
    });
  }
}
