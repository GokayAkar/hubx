import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/paywall/impl/paywall_impl.dart';

void main() {
  late PaywallRepository repository;

  setUp(() async {
    await DependencyProvider.reset();
    registerPaywallDomain();
    repository = DependencyProvider.get<PaywallRepository>();
  });

  group('PaywallRepository', () {
    test('offers a monthly and a yearly plan', () async {
      final products = await repository.fetchProducts();

      expect(
        products.map((product) => product.period),
        [SubscriptionPeriod.month, SubscriptionPeriod.year],
      );
    });

    test('only the yearly plan carries the trial', () async {
      final products = await repository.fetchProducts();
      final monthly = products.first;
      final yearly = products.last;

      expect(monthly.hasFreeTrial, isFalse);
      expect(yearly.freeTrial, const Duration(days: 3));
    });

    test('the yearly plan renews above its first year', () async {
      final yearly = (await repository.fetchProducts()).last;

      // The first year is discounted; later years are not.
      expect(yearly.initialPrice.amount, lessThan(yearly.renewalPrice.amount));
    });
  });

  group('Product', () {
    test('derives the saving from the two prices', () {
      const product = Product(
        id: 'y',
        period: SubscriptionPeriod.year,
        initialPrice: Price(amount: 274.99, currencyCode: 'USD'),
        renewalPrice: Price(amount: 529.99, currencyCode: 'USD'),
      );

      expect(product.savingPercent, 48);
    });

    test('claims no saving when both prices match', () {
      const product = Product(
        id: 'm',
        period: SubscriptionPeriod.month,
        initialPrice: Price(amount: 2.99, currencyCode: 'USD'),
        renewalPrice: Price(amount: 2.99, currencyCode: 'USD'),
      );

      expect(product.savingPercent, isNull);
    });
  });

  group('Price', () {
    test('formats for the locale it is shown in', () {
      const price = Price(amount: 2.99, currencyCode: 'USD');

      expect(price.format('en_US'), r'$2.99');
      expect(price.format('tr_TR'), contains('2,99'));
    });
  });
}
