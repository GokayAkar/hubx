import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/ui/emphasised_text.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/paywall/ui/widgets/paywall_feature_cards.dart';
import 'package:hubx/features/paywall/ui/widgets/paywall_plan_tile.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  Future<void> openPaywall(WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'onboarding.completed': true,
        });
    AppDependencies.register();

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
    await tester.binding.handlePushRoute(PaywallRoutes.root);
    await tester.pumpAndSettle();
  }

  /// Opens the paywall with [repository] standing in for the real one.
  ///
  /// Pumps a fixed span rather than settling: a skeleton pulses for as long as
  /// it is on screen, so `pumpAndSettle` would wait for an animation that never
  /// ends.
  Future<void> openPaywallWith(
    WidgetTester tester,
    PaywallRepository repository,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'onboarding.completed': true});
    AppDependencies.register();
    DependencyProvider.override<PaywallRepository>(repository);

    await tester.pumpWidget(App(startup: await AppStartupLoader.load()));
    await tester.pumpAndSettle();
    await tester.binding.handlePushRoute(PaywallRoutes.root);
    // Two frames: one for the route to build, one to lay it out. Enough for
    // the page to be on screen, short enough that nothing in flight resolves.
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
  }

  final skeleton = find.byWidgetPredicate((widget) => widget is Skeletonizer);

  group('paywall', () {
    testWidgets('draws the page in outline while the plans load', (
      tester,
    ) async {
      final repository = _PendingRepository();
      await openPaywallWith(tester, repository);

      // Only the plans are waiting on the server. Everything written into
      // the app — the title, the cards, the links — is readable at once;
      // bones over static copy would make the page look slower than it is.
      expect(find.text('Unlimited'), findsWidgets);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // By predicate, not by type: Skeletonizer is abstract and its
      // constructor hands back a private subclass, which byType would miss.
      expect(skeleton, findsOneWidget);
      expect(
        find.descendant(of: skeleton, matching: find.byType(PaywallPlanTile)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: skeleton,
          matching: find.byType(PaywallFeatureCards),
        ),
        findsNothing,
      );

      // And it is one thing to a screen reader, not a handful of nameless
      // boxes.
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);

      repository.complete();
      await tester.pumpAndSettle();

      expect(skeleton, findsNothing);
      expect(find.text('1 Month'), findsOneWidget);
    });

    testWidgets('the plans land exactly where their placeholders stood', (
      tester,
    ) async {
      final repository = _PendingRepository();
      await openPaywallWith(tester, repository);
      final placeholder = tester.getRect(find.byType(PaywallPlanTile).first);

      repository.complete();
      await tester.pumpAndSettle();

      final landed = tester.getRect(find.byType(PaywallPlanTile).first);

      // To the pixel, because it is the same widget tree either way: the
      // skeleton is the page with its words hidden, not a drawing of it. This
      // is what a hand-built placeholder could not promise.
      //
      // Height and vertical position only: the placeholder is measured while
      // the route is still sliding in, so its horizontal offset is the
      // transition's, not the layout's.
      expect(landed.top, placeholder.top);
      expect(landed.size, placeholder.size);
    });

    testWidgets('offers a way back when the plans cannot be fetched', (
      tester,
    ) async {
      final repository = _FlakyRepository();
      await openPaywallWith(tester, repository);

      expect(find.text("We couldn't load the plans"), findsOneWidget);
      expect(find.text('1 Month'), findsNothing);

      // The second attempt succeeds, and the page is the page again.
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.calls, 2);
      expect(find.text("We couldn't load the plans"), findsNothing);
      expect(find.text('1 Month'), findsOneWidget);
    });

    testWidgets('opens on the plan that carries the trial', (tester) async {
      await openPaywall(tester);

      // The yearly plan is pre-selected, so the button offers the trial.
      expect(find.text('Try free for 3 days'), findsOneWidget);
      expect(find.text('Save 48%'), findsOneWidget);
    });

    testWidgets('a plan without a trial does not offer one', (tester) async {
      await openPaywall(tester);

      await tester.tap(find.text('1 Month'));
      await tester.pumpAndSettle();

      // Neither the button nor the small print may promise free days that the
      // monthly plan does not include.
      expect(find.text('Try free for 3 days'), findsNothing);
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.textContaining('free trial'), findsNothing);
    });

    testWidgets('shows the ongoing price, and the first charge below', (
      tester,
    ) async {
      await openPaywall(tester);

      // The plan line quotes what it renews at…
      expect(find.textContaining(r'then $529.99/year'), findsOneWidget);
      // …and the small print what it charges first.
      expect(find.textContaining(r'charged $274.99 per year'), findsOneWidget);
    });

    testWidgets('a tenth of the third feature card peeks past the edge', (
      tester,
    ) async {
      await openPaywall(tester);

      final screen = tester.getSize(find.byType(MaterialApp)).width;
      final titles = find.text('Unlimited');
      final second = tester.getRect(find.text('Faster'));
      final third = tester.getRect(titles.last);

      // Card edges, from the titles inside them: the padding is the same on
      // every card, so the distance between two titles is the card pitch.
      final pitch = third.left - second.left;
      final cardWidth = pitch - 12; // the gap between cards
      final thirdCardLeft = third.left - 16; // the card's own padding

      // Partly on the screen and partly off it — that sliver is what says the
      // row can be pushed.
      expect(thirdCardLeft, lessThan(screen));
      expect(thirdCardLeft + cardWidth, greaterThan(screen));
      expect((screen - thirdCardLeft) / cardWidth, closeTo(0.1, 0.02));
    });

    testWidgets('the close button stays easy to hit however small it looks', (
      tester,
    ) async {
      await openPaywall(tester);

      // The disc is drawn at the design's smaller size, but the area that
      // answers a finger is not. Worth pinning here: this screen is exempt
      // from the route-wide tap-target check, so nothing else would catch it.
      final close = find.byTooltip(
        MaterialLocalizations.of(
          tester.element(find.byType(Scaffold).last),
        ).closeButtonTooltip,
      );

      // What is painted, then what answers a finger.
      expect(tester.getSize(close).shortestSide, lessThan(40));
      final button = find.ancestor(
        of: close,
        matching: find.byType(IconButton),
      );
      expect(tester.getSize(button).shortestSide, greaterThanOrEqualTo(48));
    });

    testWidgets('sits at the bottom, leaving the photograph on show', (
      tester,
    ) async {
      await openPaywall(tester);

      final screen = tester.view.physicalSize.height;
      final top = tester.getRect(find.byType(EmphasisedText)).top;
      final bottom = tester.getRect(find.text('Terms')).bottom;

      // The room to spare goes above the text, not below it: that is what
      // leaves the plant in view.
      expect(top, greaterThan(screen - bottom));
      expect(top / screen, greaterThan(0.15));
    });
  });
}

/// Hangs until the test says otherwise.
///
/// A `Future.delayed` would not do: `pumpAndSettle` advances the test clock, so
/// any delay short enough to be convenient is one the pumping runs past.
class _PendingRepository implements PaywallRepository {
  final _completer = Completer<List<Product>>();

  void complete() => _completer.complete(_products);

  @override
  Future<List<Product>> fetchProducts() => _completer.future;
}

/// Fails once, then works: the shape of a connection that has come back.
class _FlakyRepository implements PaywallRepository {
  int calls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    calls++;
    if (calls == 1) throw const SocketException('offline');

    return _products;
  }
}

const _products = [
  Product(
    id: 'monthly',
    period: SubscriptionPeriod.month,
    initialPrice: Price(amount: 2.99, currencyCode: 'USD'),
    renewalPrice: Price(amount: 2.99, currencyCode: 'USD'),
  ),
  Product(
    id: 'yearly',
    period: SubscriptionPeriod.year,
    freeTrial: Duration(days: 3),
    initialPrice: Price(amount: 274.99, currencyCode: 'USD'),
    renewalPrice: Price(amount: 529.99, currencyCode: 'USD'),
  ),
];
