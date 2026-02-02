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

import 'price.dart';

/// Balance of some [BalanceOrigin].
class Balance {
  const Balance({required this.sum, required this.currency});

  /// [Price] with value of zero with a `G` currency.
  static const zero = Balance(sum: Sum(0), currency: Currency('XXX'));

  /// [Sum] of this [Price].
  final Sum sum;

  /// [Currency] of this [Price].
  final Currency currency;

  @override
  String toString() => 'Balance(${currency.val} -> ${sum.val})';
}
