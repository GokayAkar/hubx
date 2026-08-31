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
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  Future<void> openSteps(WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(const <String, Object>{});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(FakeHomeRepository());

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
    await tester.binding.handlePushRoute(OnboardingRoutes.steps);
    await tester.pumpAndSettle();
  }

  int litDot(WidgetTester tester) => tester
      .widget<AnimatedSmoothIndicator>(
        find.byType(AnimatedSmoothIndicator),
      )
      .activeIndex;

  group('onboarding steps', () {
    testWidgets('the button carries the user from one step to the next', (
      tester,
    ) async {
      await openSteps(tester);

      expect(find.textContaining('Take a photo'), findsOneWidget);
      expect(litDot(tester), 0);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.textContaining('Get plant'), findsOneWidget);
      expect(litDot(tester), 1);
    });

    testWidgets('a swipe moves the dots with the pages', (tester) async {
      await openSteps(tester);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(litDot(tester), 1);
    });

    testWidgets('only the pages move; the button and dots hold still', (
      tester,
    ) async {
      await openSteps(tester);

      final button = tester.getRect(find.byType(FilledButton));
      final dots = tester.getRect(find.byType(AnimatedSmoothIndicator));

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // The whole reason the indicator lives outside the PageView: dragged
      // along with the pages it would slide off with them.
      expect(tester.getRect(find.byType(FilledButton)), button);
      expect(tester.getRect(find.byType(AnimatedSmoothIndicator)), dots);
    });

    testWidgets('the last step finishes the flow and hands over', (
      tester,
    ) async {
      await openSteps(tester);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // The flag is written and the paywall has taken over.
      expect(
        await DependencyProvider.get<OnboardingRepository>().isCompleted(),
        isTrue,
      );
      expect(find.text('Terms'), findsOneWidget);
    });
  });
}
