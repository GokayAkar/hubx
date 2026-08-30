import 'package:hubx/features/paywall/api/models/product.dart';

/// What the paywall can offer.
///
/// Asynchronous even though today's implementation answers from memory: the
/// real one asks the store, and a contract that promised otherwise would have
/// to change every call site the day it does.
abstract interface class PaywallRepository {
  Future<List<Product>> fetchProducts();
}
