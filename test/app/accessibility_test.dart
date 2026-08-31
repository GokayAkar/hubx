import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/router/app_router.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../support/fake_home_repository.dart';

void main() {
  // Widget tests default to a font whose every glyph is a square, so text
  // measures far wider than Roboto does and lines wrap that never would on a
  // device. These checks are about how a layout copes with growing text, so
  // they have to measure the real thing.
  setUpAll(() async {
    for (final weight in const [
      'Light',
      'Regular',
      'Medium',
      'SemiBold',
      'ExtraBold',
    ]) {
      final bytes = await File('assets/fonts/Roboto-$weight.ttf').readAsBytes();
      await (FontLoader(
        'Roboto',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
  });

  const onboarded = {'onboarding.completed': true};

  Future<App> boot([Map<String, Object> stored = const {}]) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(stored);
    AppDependencies.register();
    // The home page is the first tab and starts fetching the moment the app
    // appears. Stubbed so no suite here needs a network connection to pass.
    DependencyProvider.override<HomeRepository>(FakeHomeRepository());

    return App(startup: await AppStartupLoader.load());
  }

  setUp(() async {
    await DependencyProvider.reset();
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
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
    // Through the dispatcher rather than a MediaQuery above the app: wrapping
    // one here would hand the app a whole fresh MediaQueryData, wiping the
    // view's padding, and every check below would run on a phone with no notch
    // and no home indicator.
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(await boot(stored));
    await tester.pumpAndSettle();

    await tester.binding.handlePushRoute(path);
    await tester.pumpAndSettle();
  }

  // Driven by the router rather than a hand-kept list: a screen has to be
  // registered there to be reachable at all, so a new one cannot quietly skip
  // these checks.
  testWidgets('leaves room at the bottom on a phone with no home indicator', (
    tester,
  ) async {
    // An iPhone SE has a status bar but no bottom inset, so a layout that
    // leans on the system spacing puts its last row against the edge.
    tester.view
      ..padding = const FakeViewPadding(top: 20)
      ..viewPadding = const FakeViewPadding(top: 20);

    await open(tester, path: OnboardingRoutes.steps);

    final screen = tester.getSize(find.byType(MaterialApp)).height;
    final indicator = tester.getRect(find.byType(AnimatedSmoothIndicator));

    expect(screen - indicator.bottom, greaterThanOrEqualTo(20));
  });

  testWidgets('every screen inherits that room, not just the ones that ask', (
    tester,
  ) async {
    tester.view
      ..padding = const FakeViewPadding(top: 20)
      ..viewPadding = const FakeViewPadding(top: 20);

    // A screen that says nothing about safe areas still gets the gap, because
    // the app raises the inset once for everything below it.
    await open(tester, stored: onboarded, path: SettingsRoutes.root);

    final inset = MediaQuery.paddingOf(
      tester.element(find.byType(Scaffold).last),
    );

    expect(inset.bottom, greaterThanOrEqualTo(20));
  });

  testWidgets('the tab bar reaches the edge on a phone with no indicator', (
    tester,
  ) async {
    tester.view
      ..padding = const FakeViewPadding(top: 20)
      ..viewPadding = const FakeViewPadding(top: 20);

    await open(tester, stored: onboarded, path: HomeRoutes.root);

    final screen = tester.getSize(find.byType(MaterialApp)).height;

    // The app's minimum bottom inset is for content. A bar pinned to the
    // bottom is the edge itself, and inheriting that minimum leaves a strip of
    // nothing beneath it.
    expect(tester.getRect(find.byType(BottomAppBar)).bottom, screen);
  });

  testWidgets('and stops short of a home indicator where there is one', (
    tester,
  ) async {
    tester.view
      ..padding = const FakeViewPadding(top: 47, bottom: 34)
      ..viewPadding = const FakeViewPadding(top: 47, bottom: 34);

    await open(tester, stored: onboarded, path: HomeRoutes.root);

    final screen = tester.getSize(find.byType(MaterialApp)).height;

    // The bar still reaches the edge; its labels do not.
    expect(tester.getRect(find.byType(BottomAppBar)).bottom, screen);
    expect(
      screen - tester.getRect(find.text('Home')).bottom,
      greaterThanOrEqualTo(34),
    );
  });

  // The paywall's legal links are sized to the design's type instead of to a
  // 48pt target — a deliberate product call, made with the cost known. Only the
  // size check is lifted, and only there: the rest of that screen, and every
  // other screen, is still held to it.
  const undersizedTapTargets = {PaywallRoutes.root};

  for (final path in screenPaths(AppRouter(startOnOnboarding: false).routes)) {
    group(path, () {
      testWidgets('meets the accessibility guidelines', (tester) async {
        // A phone with both a notch and a home indicator: the insets a layout
        // is most likely to have forgotten.
        const inset = EdgeInsets.only(top: 47, bottom: 34);
        tester.view
          ..padding = const FakeViewPadding(top: 47, bottom: 34)
          ..viewPadding = const FakeViewPadding(top: 47, bottom: 34);

        final handle = tester.ensureSemantics();
        await open(tester, stored: onboarded, path: path);

        // Nothing tappable hides under the notch or the home indicator.
        final screen = tester.getSize(find.byType(MaterialApp));
        for (final tappable in [
          ...find.byType(IconButton).evaluate(),
          ...find.byType(TextButton).evaluate(),
          ...find.byType(FilledButton).evaluate(),
        ]) {
          final rect = tester.getRect(find.byWidget(tappable.widget));
          expect(
            rect.top,
            greaterThanOrEqualTo(inset.top),
            reason: 'a control on $path sits under the status bar',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(screen.height - inset.bottom),
            reason: 'a control on $path sits under the home indicator',
          );
        }

        // Every tappable is big enough to hit, and says what it does.
        if (!undersizedTapTargets.contains(path)) {
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        }
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        handle.dispose();
      });

      testWidgets('survives the largest text the system offers', (
        tester,
      ) async {
        // The real ceiling, not a round number: iOS's largest accessibility
        // size lands near 3.1x and Android's goes past it. Testing at 2 passes
        // screens that fall apart on a device someone is actually using.
        await open(
          tester,
          stored: onboarded,
          path: path,
          textScale: 3.1,
        );

        expect(tester.takeException(), isNull);
      });
    });
  }
}

/// Every screen the router can open by path, tabs included.
///
/// Walking the tree rather than the top level: the four tabs live under a
/// shell route, and a list that stopped at the top would have checked the
/// shell once and none of the screens inside it.
Iterable<String> screenPaths(
  List<AutoRoute> routes, [
  String prefix = '',
]) sync* {
  for (final route in routes) {
    // Routes that carry arguments cannot be reached by path at all. The detail
    // screen is checked in the home feature's own suite, where there is
    // something to pass it.
    if (route.path == HomeRoutes.detail) continue;

    final path = route.path.startsWith('/')
        ? route.path
        : [prefix, route.path].where((part) => part.isNotEmpty).join('/');
    final children = route.children;

    if (children == null || children.isEmpty) {
      yield path;
    } else {
      // The parent is a container; its children are the screens.
      yield* screenPaths(children, path);
    }
  }
}
