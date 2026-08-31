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
import 'package:hubx/features/home/ui/widgets/premium_banner.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  Future<void> openHome(WidgetTester tester, FakeHomeRepository fake) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(fake);

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
  }

  /// Stops before the load resolves, so the first frame can be inspected.
  ///
  /// Fixed pumps rather than settling: a skeleton shimmers for as long as it is
  /// on screen, so `pumpAndSettle` would wait for an animation that never ends.
  Future<void> openHomePending(
    WidgetTester tester,
    FakeHomeRepository fake,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<HomeRepository>(fake);

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
  }

  final skeleton = find.byWidgetPredicate((widget) => widget is Skeletonizer);

  group('home', () {
    testWidgets('draws both rows in outline while they load', (tester) async {
      final fake = FakeHomeRepository(pending: true);
      await openHomePending(tester, fake);

      // Placeholders, not spinners: the shape of the page is on screen before
      // its contents are. Two of them — the articles and the grid load
      // separately, and each says so for itself.
      expect(skeleton, findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // What the app already knows is readable straight away.
      // The body rather than the title: the title is two weights in one line,
      // so it is rich text and carries no plain string to match.
      expect(find.text('Tap to upgrade your account!'), findsOneWidget);
      expect(find.text('Hi, plant lover!'), findsOneWidget);

      // And the bones are one thing to a screen reader, not a page of nameless
      // boxes.
      expect(find.bySemanticsLabel('Loading'), findsNWidgets(2));

      fake.release();
      await tester.pumpAndSettle();

      expect(skeleton, findsNothing);
      expect(find.text('Category 0'), findsOneWidget);
    });

    testWidgets('the header picture stays inside the header on a wide phone', (
      tester,
    ) async {
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        ..physicalSize = const Size(440, 956)
        ..padding = const FakeViewPadding(top: 59, bottom: 34)
        ..viewPadding = const FakeViewPadding(top: 59, bottom: 34);

      await openHome(tester, FakeHomeRepository());

      // Given only a width, the illustration takes the height its proportions
      // ask for — taller than this header on a wide phone — and nothing clips
      // a sliver's child, so the surplus painted straight over the page below.
      // The page then looked empty until a scroll faded the picture away.
      expect(
        tester.getRect(find.byType(Image).first).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(PremiumBanner)).top),
      );
    });

    testWidgets('shows the articles and the first page of categories', (
      tester,
    ) async {
      await openHome(tester, FakeHomeRepository());

      expect(find.text('How to identify plants?'), findsOneWidget);
      expect(find.text('Category 0'), findsOneWidget);
    });

    testWidgets('asks for the next page only while the server has one', (
      tester,
    ) async {
      // Two full pages and a bit: the grid should stop after the third.
      final fake = FakeHomeRepository(categoryCount: 41);
      await openHome(tester, fake);

      for (var i = 0; i < 6; i++) {
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
      }

      // Three pages of 20 covers 41 items, and the server said so on the
      // third — a fourth request would be the client guessing.
      expect(fake.requestedPages, [1, 2, 3]);
    });

    testWidgets('says so when there is nothing to show', (tester) async {
      await openHome(tester, FakeHomeRepository(categoryCount: 0));

      expect(find.text('No categories yet'), findsOneWidget);
    });

    testWidgets('a failed first page can be tried again', (tester) async {
      await openHome(tester, FakeHomeRepository(failCategoryPage: 1));

      expect(find.text('We couldn’t load this'), findsOneWidget);
      expect(find.text('Category 0'), findsNothing);

      // The fake fails page 1 every time, so what is checked here is that the
      // button asks again rather than that the second attempt succeeds.
      final fake =
          DependencyProvider.get<HomeRepository>() as FakeHomeRepository;
      final retry = find.widgetWithText(TextButton, 'Try again');
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(fake.requestedPages.length, greaterThan(1));
    });

    testWidgets('a failed article load leaves the categories alone', (
      tester,
    ) async {
      // Two independent loads: one falling over must not take the other with
      // it.
      await openHome(tester, FakeHomeRepository(failQuestions: true));

      expect(find.text('How to identify plants?'), findsNothing);
      expect(find.text('Category 0'), findsOneWidget);
    });

    testWidgets('the header collapses and the greeting goes with it', (
      tester,
    ) async {
      // Enough categories that the page has somewhere to scroll to.
      await openHome(tester, FakeHomeRepository(categoryCount: 20));

      final greeting = find.text('Hi, plant lover!');
      final field = find.byType(TextField);

      final fieldBefore = tester.getRect(field);
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: greeting, matching: find.byType(Opacity)).first,
            )
            .opacity,
        1,
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final fieldAfter = tester.getRect(field);

      // The greeting has gone and the field has risen with the shrinking box,
      // but it is still on screen and unchanged in size: that is what
      // "collapses upward" has to mean for the one control up here.
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: greeting, matching: find.byType(Opacity)).first,
            )
            .opacity,
        0,
      );
      expect(fieldAfter.top, lessThan(fieldBefore.top));
      expect(fieldAfter.top, greaterThanOrEqualTo(0));
      expect(fieldAfter.size, fieldBefore.size);
    });
  });
}
