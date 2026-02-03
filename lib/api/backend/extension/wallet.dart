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

import '/api/backend/schema.dart';
import '/domain/model/balance.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/store/model/operation.dart';

/// Extension adding models construction from an [PriceMixin].
extension PriceConversion on PriceMixin {
  /// Constructs a new [Price] from this [PriceMixin].
  Price toModel() => Price(sum: sum, currency: currency);
}

/// Extension adding models construction from an [OperationDepositMixin].
extension OperationDepositConversion on OperationDepositMixin {
  /// Constructs a new [OperationDeposit] from this [OperationDepositMixin].
  OperationDeposit toModel() => OperationDeposit(
    id: id,
    num: this.num,
    status: status,
    amount: amount.toModel(),
    createdAt: createdAt,
    kind: kind,
    billingCountry: billingCountry,
    invoice: invoice,
  );

  /// Constructs a new [DtoOperation] from this [OperationDepositMixin].
  DtoOperation toDto(OperationsCursor? cursor) =>
      DtoOperation(toModel(), ver, cursor: cursor);
}

/// Extension adding models construction from an [OperationDepositBonusMixin].
extension OperationDepositBonusConversion on OperationDepositBonusMixin {
  /// Constructs a new [OperationDepositBonus] from this
  /// [OperationDepositBonusMixin].
  OperationDepositBonus toModel() => OperationDepositBonus(
    id: id,
    num: this.num,
    status: status,
    amount: amount.toModel(),
    createdAt: createdAt,
    depositId: deposit.node.id,
  );

  /// Constructs a new [DtoOperation] from this [OperationDepositBonusMixin].
  DtoOperation toDto(OperationsCursor? cursor) =>
      DtoOperation(toModel(), ver, cursor: cursor);
}

/// Extension adding models construction from an [PriceModifierMixin].
extension PriceModifierConversion on PriceModifierMixin {
  /// Constructs a new [PriceModifier] from this [PriceModifierMixin].
  PriceModifier toModel() =>
      PriceModifier(percentage: percentage, amount: amount.toModel());
}

/// Extension adding models construction from an
/// [OperationDepositMethods$Query$OperationDepositMethods].
extension OperationDepositMethodsConversion
    on OperationDepositMethods$Query$OperationDepositMethods {
  /// Constructs a new [OperationDepositMethod] from this
  /// [OperationDepositMethods$Query$OperationDepositMethods].
  OperationDepositMethod toModel() {
    return OperationDepositMethod(
      id: id,
      kind: kind,
      countries: switch (countries?.$$typename) {
        'CriteriaCountryExcept' => CriteriaCountryExcept(
          (countries
                  as OperationDepositMethodMixin$Countries$CriteriaCountryExcept)
              .except,
        ),
        'CriteriaCountryOnly' => CriteriaCountryOnly(
          (countries
                  as OperationDepositMethodMixin$Countries$CriteriaCountryOnly)
              .only,
        ),
        (_) => null,
      },
      nominals: nominals?.map((e) => e.toModel()).toList(),
      pricing: pricing == null
          ? null
          : OperationDepositPricing(
              nominal: pricing!.nominal.toModel(),
              bonus: pricing!.bonus?.toModel(),
              withoutTax: pricing!.withoutTax?.toModel(),
              tax: pricing!.tax?.toModel(),
              total: pricing!.total?.toModel(),
            ),
    );
  }
}

/// Extension adding models construction from an [OperationDepositMethodMixin].
extension OperationDepositMethodConversion on OperationDepositMethodMixin {
  /// Constructs a new [OperationDepositMethod] from this
  /// [OperationDepositMethodMixin].
  OperationDepositMethod toModel() => OperationDepositMethod(
    id: id,
    kind: kind,
    countries: switch (countries?.$$typename) {
      'CriteriaCountryExcept' => CriteriaCountryExcept(
        (countries
                as OperationDepositMethodMixin$Countries$CriteriaCountryExcept)
            .except,
      ),
      'CriteriaCountryOnly' => CriteriaCountryOnly(
        (countries as OperationDepositMethodMixin$Countries$CriteriaCountryOnly)
            .only,
      ),
      (_) => null,
    },
    nominals: nominals?.map((e) => e.toModel()).toList(),
  );
}

/// Extension adding models construction from
/// [Operations$Query$Operations$Edges$Node].
extension OperationsOperationConversion
    on Operations$Query$Operations$Edges$Node {
  /// Constructs the new [DtoOperation] from this
  /// [Operations$Query$Operations$Edges$Node].
  DtoOperation toDto({OperationsCursor? cursor}) => _operation(this, cursor);
}

/// Constructs a new [DtoOperation]s based on the [node] and [cursor].
DtoOperation _operation(dynamic node, OperationsCursor? cursor) {
  if (node is OperationDepositMixin) {
    return node.toDto(cursor);
  } else if (node is OperationDepositBonusMixin) {
    return node.toDto(cursor);
  }

  throw UnimplementedError('$node is not implemented');
}

/// Extension adding models construction from an [BalanceMixin].
extension BalanceConversion on BalanceMixin {
  /// Constructs a new [Balance] from this [BalanceMixin].
  Balance toModel() => Balance(sum: sum, currency: currency);
}
