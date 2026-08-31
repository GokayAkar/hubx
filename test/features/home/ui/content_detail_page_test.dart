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

import '../../../support/fake_home_repository.dart';

/// The detail screen is the one page the route-driven accessibility sweep
/// cannot reach: it takes arguments, so there is no path to push. It gets the
/// same checks here, where there is something to pass it.
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

  Future<void> openDetail(WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(FakeHomeRepository());

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('How to identify plants?'));
    await tester.pumpAndSettle();
  }

  group('content detail', () {
    testWidgets('a card opens it, carrying its picture across', (tester) async {
      await openDetail(tester);

      // The same tag on both ends is what makes the picture travel rather than
      // one screen simply replacing another.
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'question-1');

      expect(find.text('Life Style'), findsOneWidget);
      expect(find.textContaining('Lorem ipsum'), findsOneWidget);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('survives the largest text the system offers', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openDetail(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
