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
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/fake_home_repository.dart';

/// The tab shell. Its whole reason for existing is that each tab keeps its own
/// state and that anything pushed on top of it covers the bar — neither of
/// which a bar drawn inside the home page would give.
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

  Future<void> boot(WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(
      FakeHomeRepository(categoryCount: 40),
    );

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  group('tab shell', () {
    testWidgets('each tab is its own screen, reached from the bar', (
      tester,
    ) async {
      await boot(tester);
      expect(find.text('Get Started'), findsOneWidget);

      await tapTab(tester, 'Diagnose');
      expect(find.text('Coming soon'), findsOneWidget);

      await tapTab(tester, 'Profile');
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('a tab comes back where it was left', (tester) async {
      await boot(tester);

      double offset() => tester
          .state<ScrollableState>(
            // First: the page's own scroll view, not the article row nested
            // inside it.
            find
                .descendant(
                  of: find.byType(CustomScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position
          .pixels;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      final scrolled = offset();
      expect(scrolled, greaterThan(0));

      await tapTab(tester, 'Profile');
      await tapTab(tester, 'Home');

      // The point of a shell route: leaving a tab and coming back is not the
      // same as opening it again. A bar drawn inside the home page would have
      // rebuilt this from the top.
      expect(offset(), scrolled);
    });

    testWidgets('a screen pushed on top of the shell covers the bar', (
      tester,
    ) async {
      await boot(tester);
      expect(find.byType(BottomAppBar), findsOneWidget);

      await tester.tap(find.text('How to identify plants?'));
      await tester.pumpAndSettle();

      // Pushed at the root rather than inside a tab, so the detail screen has
      // the device to itself.
      expect(find.textContaining('Lorem ipsum'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(BottomAppBar), findsOneWidget);
    });
  });
}
