import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../support/fake_home_repository.dart';

void main() {
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

  setUp(() async {
    await DependencyProvider.reset();
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..devicePixelRatio = 1
          ..physicalSize = kDesignSize;
    addTearDown(view.reset);
  });

  Future<void> openSettings(WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(FakeHomeRepository());

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
    await tester.binding.handlePushRoute(SettingsRoutes.root);
    await tester.pumpAndSettle();
  }

  group('settings', () {
    testWidgets('picking a language changes the app it is shown in', (
      tester,
    ) async {
      await openSettings(tester);

      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();

      // The screen retitles itself: the choice reaches MaterialApp, not just
      // the row that was tapped.
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('the choice outlives the screen it was made on', (
      tester,
    ) async {
      await openSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Written through the repository, so the next launch starts dark
      // without the user asking again.
      expect(
        await DependencyProvider.get<SettingsRepository>().readThemeMode(),
        ThemeMode.dark,
      );
    });

    testWidgets('system is the default for both, and stays selectable', (
      tester,
    ) async {
      await openSettings(tester);

      final theme = tester.widget<RadioListTile<ThemeMode>>(
        find.widgetWithText(RadioListTile<ThemeMode>, 'System'),
      );
      final language = tester.widget<RadioListTile<Locale?>>(
        find.widgetWithText(RadioListTile<Locale?>, 'System language'),
      );

      // Both offer "whatever the phone is set to" — a preference the app must
      // let the user return to, not only leave.
      expect(theme.value, ThemeMode.system);
      expect(language.value, isNull);
    });
  });
}
