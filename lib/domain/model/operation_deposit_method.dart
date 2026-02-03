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

import '/api/backend/schema.dart' show OperationDepositKind;
import '/util/new_type.dart';
import 'country.dart';
import 'price.dart';

/// Description of some method for performing an [OperationDeposit].
class OperationDepositMethod {
  const OperationDepositMethod({
    required this.id,
    required this.kind,
    this.countries,
    this.nominals,
    this.pricing,
  });

  /// Unique ID of this [OperationDepositMethod].
  final OperationDepositMethodId id;

  /// [OperationDepositKind] of this [OperationDepositMethod].
  final OperationDepositKind kind;

  /// Criteria filtering this [OperationDepositMethod] availability for specific
  /// [CountryCode]s.
  final CriteriaCountry? countries;

  /// List of available nominal [Price]s this [OperationDepositMethod] accepts.
  final List<Price>? nominals;

  /// [OperationDepositPricing] of this [OperationDepositMethod].
  ///
  /// `null` in case this [OperationDepositMethod] is unavailable for the
  /// provided [CountryCode].
  final OperationDepositPricing? pricing;
}

/// Entities' criteria matching [CountryCode]s.
abstract class CriteriaCountry {
  const CriteriaCountry();
}

/// [CountryCode]s being excluded from entities' match.
class CriteriaCountryExcept extends CriteriaCountry {
  const CriteriaCountryExcept(this.except);

  /// [CountryCode]s excluded from the match.
  final List<CountryCode> except;
}

/// [CountryCode]s being included into entities' match.
class CriteriaCountryOnly extends CriteriaCountry {
  const CriteriaCountryOnly(this.only);

  /// [CountryCode]s included into the match.
  final List<CountryCode> only;
}

/// ID of an [OperationDepositMethod].
class OperationDepositMethodId extends NewType<String> {
  const OperationDepositMethodId(super.val);
}

/// Pricing of an [OperationDeposit].
class OperationDepositPricing {
  OperationDepositPricing({
    required this.nominal,
    this.bonus,
    this.withoutTax,
    this.tax,
    this.total,
  });

  /// Nominal [Price] of the [OperationDeposit].
  final Price nominal;

  /// Bonus of the nominal [Price] to be granted as a separate
  /// [OperationDepositBonus] once the original [OperationDeposit] is completed
  /// successfully.
  ///
  /// `null` if no bonus is granted.
  final PriceModifier? bonus;

  /// Calculated [Price] of the [OperationDeposit] to be paid, before the tax
  /// being applied, in the provided [Currency].
  ///
  /// `null` if the provided [Currency] is not supported by the [OperationDeposit].
  ///
  /// Doesn't include [bonus].
  final Price? withoutTax;

  /// Tax applied to the [withoutTax] [Price], according to the billing
  /// [CountryCode] of the [OperationDeposit], in the provided [Currency].
  ///
  /// `null` if the provided [Currency] is not supported by the
  /// [OperationDeposit].
  final PriceModifier? tax;

  /// Calculated total [Price] of the [OperationDeposit] to be paid, after the
  /// tax being applied, in the provided [Currency].
  ///
  /// It's calculated as: `total = withoutTax + tax`.
  ///
  /// `null` if the provided [Currency] is not supported by the
  /// [OperationDeposit].
  ///
  /// Doesn't include [bonus].
  final Price? total;
}
