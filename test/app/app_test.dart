import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/app/view/app.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  /// Mirrors `main()`: seed the store, register, load the startup snapshot and
  /// build the app from it.
  Future<App> bootstrap([
    Map<String, Object> storedPreferences = const {},
  ]) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(storedPreferences);
    AppDependencies.register();

    return App(startup: await AppStartupLoader.load());
  }

  const onboarded = {'onboarding.completed': true};

  setUp(DependencyProvider.reset);

  testWidgets('opens onboarding on a fresh install', (tester) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to HubX'), findsOneWidget);
  });

  testWidgets('opens home once onboarding is done', (tester) async {
    await tester.pumpWidget(await bootstrap(onboarded));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('finishing onboarding lands on home and is remembered', (
    tester,
  ) async {
    await tester.pumpWidget(await bootstrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(
      await DependencyProvider.get<OnboardingRepository>().isCompleted(),
      isTrue,
    );
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

    await tester.tap(find.byIcon(Icons.settings_outlined));
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
