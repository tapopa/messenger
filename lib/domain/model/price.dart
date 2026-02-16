// Copyright © 2025-2026 Ideas Networks Solutions S.A.,
//                       <https://github.com/tapopa>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import '/util/new_type.dart';
import 'promo_share.dart';

/// Price of something.
class Price {
  const Price({required this.sum, required this.currency});

  /// [Price] with value of zero with a `G` currency.
  static const zero = Price(sum: Sum(0), currency: Currency('XXX'));

  /// Constructs a [Price] with `XXX` currency of the provided [amount].
  Price.xxx(double amount) : sum = Sum(amount), currency = Currency('XXX');

  /// Constructs a [Price] with `USDT` currency of the provided [amount].
  Price.usdt(double amount) : sum = Sum(amount), currency = Currency('USDT');

  /// Constructs a [Price] with `USD` currency of the provided [amount].
  Price.usd(double amount) : sum = Sum(amount), currency = Currency('USD');

  /// Constructs a [Price] with `EUR` currency of the provided [amount].
  Price.eur(double amount) : sum = Sum(amount), currency = Currency('EUR');

  /// [Sum] of this [Price].
  final Sum sum;

  /// [Currency] of this [Price].
  final Currency currency;

  @override
  String toString() => 'Price(${currency.val} -> ${sum.val})';

  /// Multiplies this [Price] to the [other].
  Price operator *(Price other) {
    return Price(currency: other.currency, sum: Sum(sum.val * other.sum.val));
  }
}

/// Sum of money.
class Sum extends NewType<double> implements Comparable<Sum> {
  const Sum(super.val);

  /// Parses the provided [val] as a [Sum].
  static Sum parse(String val) => Sum(double.parse(val));

  /// Constructs a [Sum] from the provided [val].
  factory Sum.fromJson(String val) => Sum.parse(val);

  @override
  int compareTo(Sum other) => val.compareTo(other.val);

  @override
  bool operator ==(Object other) {
    return other is Sum && other.val == val;
  }

  @override
  int get hashCode => val.hashCode;

  /// Returns a [String] representing this [Sum].
  String toJson() => val.toString();
}

/// Currency as alphabetic code in [ISO 4217] format.
///
/// [ISO 4217]: https://iso.org/iso-4217-currency-codes.html
class Currency extends NewType<String> {
  const Currency(super.val);
}

/// Modifier of a [Price].
class PriceModifier {
  PriceModifier({required this.percentage, required this.amount});

  /// [Percentage] to apply to the [Price].
  ///
  /// `null` means this [PriceModifier] modifies the [Price] by a fixed [Sum].
  final Percentage? percentage;

  /// Concrete [Sum] amount to apply to the [Price].
  ///
  /// If the [percentage] is not `null`, then it represents the already
  /// calculated [Sum] of the percentage.
  final Price amount;
}
