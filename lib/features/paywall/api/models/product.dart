import 'package:equatable/equatable.dart';
import 'package:hubx/features/paywall/api/models/price.dart';

/// How often a subscription renews.
enum SubscriptionPeriod { month, year }

/// One thing the paywall can sell.
///
/// Two prices rather than one, because a subscription rarely charges the same
/// amount twice: an introductory year can cost less than the years after it,
/// and the difference is what the "save" badge is made of.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.period,
    required this.initialPrice,
    required this.renewalPrice,
    this.freeTrial,
    this.isAutoRenewable = true,
  });

  /// The identifier the store knows it by.
  final String id;

  final SubscriptionPeriod period;

  /// The first charge, once any [freeTrial] is over.
  final Price initialPrice;

  /// Every charge after the first period.
  final Price renewalPrice;

  /// Free time before the first charge, if the product offers any.
  final Duration? freeTrial;

  final bool isAutoRenewable;

  bool get hasFreeTrial => freeTrial != null;

  /// How much less the first period costs than a later one, as a percentage.
  ///
  /// Derived rather than stored: a badge that can disagree with the prices
  /// beside it is worse than no badge.
  int? get savingPercent {
    if (renewalPrice.amount <= initialPrice.amount) return null;

    final saved = 1 - initialPrice.amount / renewalPrice.amount;

    return (saved * 100).round();
  }

  @override
  List<Object?> get props => [
    id,
    period,
    initialPrice,
    renewalPrice,
    freeTrial,
    isAutoRenewable,
  ];
}
