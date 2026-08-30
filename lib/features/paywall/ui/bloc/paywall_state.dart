part of 'paywall_bloc.dart';

enum PaywallStatus { initial, loading, ready, failed }

class PaywallState extends Equatable {
  const PaywallState({
    this.status = PaywallStatus.initial,
    this.products = const [],
    this.selectedId,
  });

  final PaywallStatus status;
  final List<Product> products;
  final String? selectedId;

  bool get isLoading =>
      status == PaywallStatus.initial || status == PaywallStatus.loading;

  /// The plan the call to action would buy.
  Product? get selected {
    for (final product in products) {
      if (product.id == selectedId) return product;
    }

    return null;
  }

  PaywallState copyWith({
    PaywallStatus? status,
    List<Product>? products,
    String? selectedId,
  }) {
    return PaywallState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [status, products, selectedId];
}
