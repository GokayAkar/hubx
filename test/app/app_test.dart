import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/fake_home_repository.dart';

void main() {
  /// Mirrors `main()`: seed the store, register, load the startup snapshot and
  /// build the app from it.
  Future<App> bootstrap([
    Map<String, Object> storedPreferences = const {},
  ]) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(storedPreferences);
    AppDependencies.register();
    // The home page is the first tab and starts fetching the moment the app
    // appears. Stubbed so no suite here needs a network connection to pass.
    DependencyProvider.override<HomeRepository>(FakeHomeRepository());

    return App(startup: await AppStartupLoader.load());
  }

  const onboarded = {'onboarding.completed': true};

  /// Walks the welcome screen and the two steps behind it.
  Future<void> finishOnboarding(WidgetTester tester) async {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    for (var page = 0; page < 2; page++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
  }

  setUp(DependencyProvider.reset);

  /// Widget tests default to an 800x600 surface, which is no phone. Rendering
  /// at the reference frame keeps the scale at 1 and lets an overflow that a
  /// real device would show fail the test here.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..devicePixelRatio = 1
          ..physicalSize = kDesignSize;
    addTearDown(view.reset);
  });

  testWidgets('opens onboarding on a fresh install', (tester) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to PlantApp'), findsOneWidget);
  });

  testWidgets('opens home once onboarding is done', (tester) async {
    await tester.pumpWidget(await bootstrap(onboarded));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('leaves nothing under onboarding to walk back to', (
    tester,
  ) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    final router = AutoRouter.of(tester.element(find.byType(Scaffold)));
    expect(
      router.stack.map((route) => route.name),
      ['OnboardingWelcomeRoute'],
    );
    expect(router.canPop(), isFalse);
  });

  testWidgets('finishing onboarding hands over to the paywall', (
    tester,
  ) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    await finishOnboarding(tester);

    // Marked done before the handover, so killing the app on the paywall does
    // not send the user back through onboarding.
    expect(
      await DependencyProvider.get<OnboardingRepository>().isCompleted(),
      isTrue,
    );

    // Onboarding is gone for good: back from the paywall exits the app.
    final router = AutoRouter.of(tester.element(find.byType(Scaffold)));
    expect(router.stack.map((route) => route.name), ['PaywallRoute']);
    expect(router.canPop(), isFalse);
  });

  testWidgets('honours links that arrive after launch', (tester) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    await finishOnboarding(tester);

    // Only the entry point is redirected; the startup snapshot has no say
    // over a link that arrives later.
    await tester.binding.handlePushRoute(SettingsRoutes.root);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('paints the very first frame with the persisted settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      await bootstrap({
        ...onboarded,
        'settings.theme_mode': 'dark',
        'settings.locale': 'tr',
      }),
    );

    // No pumpAndSettle: the first frame must already be correct.
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.locale, const Locale('tr'));

    await tester.pumpAndSettle();
    expect(find.text('Ana Sayfa'), findsOneWidget);
  });

  testWidgets('navigates to settings and switches to dark theme', (
    tester,
  ) async {
    await tester.pumpWidget(await bootstrap(onboarded));
    await tester.pumpAndSettle();

    // Settings is the Profile tab now, not a button in an app bar.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      await DependencyProvider.get<SettingsRepository>().readThemeMode(),
      ThemeMode.dark,
    );
  });
}
