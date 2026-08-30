part of 'paywall_bloc.dart';

sealed class PaywallEvent extends Equatable {
  const PaywallEvent();

  @override
  List<Object?> get props => const [];
}

/// Asks for what is on offer.
final class PaywallStarted extends PaywallEvent {
  const PaywallStarted();
}

/// The user picked a plan.
final class PaywallProductSelected extends PaywallEvent {
  const PaywallProductSelected(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
