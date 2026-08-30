part of '../paywall_impl.dart';

/// Answers with the two products the design shows.
///
/// A stand-in until there is a store to ask: the shape of what it returns is
/// what the screen is written against, so replacing it means changing this
/// file and nothing else.
class _PaywallRepositoryImpl implements PaywallRepository {
  const _PaywallRepositoryImpl();

  static const _currency = 'USD';

  @override
  Future<List<Product>> fetchProducts() async => Future.delayed(
    const Duration(milliseconds: 2000),
    () => const [
      Product(
        id: 'plantapp.premium.monthly',
        period: SubscriptionPeriod.month,
        initialPrice: Price(amount: 2.99, currencyCode: _currency),
        renewalPrice: Price(amount: 2.99, currencyCode: _currency),
      ),
      Product(
        id: 'plantapp.premium.yearly',
        period: SubscriptionPeriod.year,
        // Three days free, then a discounted first year, then the full price.
        freeTrial: Duration(days: 3),
        initialPrice: Price(amount: 274.99, currencyCode: _currency),
        renewalPrice: Price(amount: 529.99, currencyCode: _currency),
      ),
    ],
  );
}
