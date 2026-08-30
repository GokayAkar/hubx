import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// An amount of money, kept as a number rather than a formatted string.
///
/// Formatting belongs to the screen, which knows the locale; a string here
/// could not be compared, discounted, or shown correctly in another language.
class Price extends Equatable {
  const Price({required this.amount, required this.currencyCode});

  final double amount;

  /// ISO 4217, e.g. `USD`.
  final String currencyCode;

  /// Rendered for [locale] — `$2.99`, `2,99 $`, depending on where the user is.
  String format(String locale) => NumberFormat.simpleCurrency(
    locale: locale,
    name: currencyCode,
  ).format(amount);

  @override
  List<Object?> get props => [amount, currencyCode];
}
