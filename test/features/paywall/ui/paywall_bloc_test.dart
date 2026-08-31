import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/paywall/ui/paywall_ui.dart';

/// A stand-in for the private implementation — possible only because the bloc
/// depends on the [PaywallRepository] contract rather than on a class.
class _FakePaywallRepository implements PaywallRepository {
  _FakePaywallRepository({this.products = _products, this.failures = 0});

  final List<Product> products;

  /// How many of the first calls throw before one succeeds.
  int failures;

  int calls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    calls++;
    if (failures-- > 0) throw Exception('offline');

    return products;
  }
}

const _monthly = Product(
  id: 'monthly',
  period: SubscriptionPeriod.month,
  initialPrice: Price(amount: 2.99, currencyCode: 'USD'),
  renewalPrice: Price(amount: 2.99, currencyCode: 'USD'),
);

const _yearly = Product(
  id: 'yearly',
  period: SubscriptionPeriod.year,
  freeTrial: Duration(days: 3),
  initialPrice: Price(amount: 274.99, currencyCode: 'USD'),
  renewalPrice: Price(amount: 529.99, currencyCode: 'USD'),
);

const List<Product> _products = [_monthly, _yearly];

void main() {
  group('PaywallBloc', () {
    test('starts empty, with nothing selected and nothing to buy', () {
      final bloc = PaywallBloc(_FakePaywallRepository());

      expect(bloc.state.status, PaywallStatus.initial);
      expect(bloc.state.products, isEmpty);
      expect(bloc.state.selected, isNull);
      expect(bloc.state.isLoading, isTrue);
    });

    blocTest<PaywallBloc, PaywallState>(
      'opens on the last plan, which is the one carrying the trial',
      build: () => PaywallBloc(_FakePaywallRepository()),
      act: (bloc) => bloc.add(const PaywallStarted()),
      expect: () => [
        const PaywallState(status: PaywallStatus.loading),
        const PaywallState(
          status: PaywallStatus.ready,
          products: _products,
          selectedId: 'yearly',
        ),
      ],
    );

    blocTest<PaywallBloc, PaywallState>(
      'selects nothing when the server offers nothing',
      build: () => PaywallBloc(_FakePaywallRepository(products: const [])),
      act: (bloc) => bloc.add(const PaywallStarted()),
      // The guard that matters: `products.last` on an empty list would throw
      // inside the handler and turn an empty catalogue into a crash.
      verify: (bloc) {
        expect(bloc.state.status, PaywallStatus.ready);
        expect(bloc.state.selectedId, isNull);
        expect(bloc.state.selected, isNull);
      },
    );

    blocTest<PaywallBloc, PaywallState>(
      'fails loudly enough to be seen and to be logged',
      build: () => PaywallBloc(_FakePaywallRepository(failures: 1)),
      act: (bloc) => bloc.add(const PaywallStarted()),
      expect: () => [
        const PaywallState(status: PaywallStatus.loading),
        const PaywallState(status: PaywallStatus.failed),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<PaywallBloc, PaywallState>(
      'the retry is the same event, and it asks the server again',
      build: () => PaywallBloc(_FakePaywallRepository(failures: 1)),
      act: (bloc) async {
        bloc.add(const PaywallStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaywallStarted());
      },
      skip: 2,
      expect: () => [
        const PaywallState(status: PaywallStatus.loading),
        const PaywallState(
          status: PaywallStatus.ready,
          products: _products,
          selectedId: 'yearly',
        ),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<PaywallBloc, PaywallState>(
      'choosing a plan changes only the choice',
      build: () => PaywallBloc(_FakePaywallRepository()),
      act: (bloc) async {
        bloc.add(const PaywallStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaywallProductSelected('monthly'));
      },
      skip: 2,
      expect: () => [
        const PaywallState(
          status: PaywallStatus.ready,
          products: _products,
          selectedId: 'monthly',
        ),
      ],
      verify: (bloc) => expect(bloc.state.selected, _monthly),
    );
  });
}
