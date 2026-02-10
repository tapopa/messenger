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

import 'dart:async';

import 'package:get/get.dart';

import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import 'paginated.dart';

/// [MyUser] wallet repository interface.
abstract class AbstractWalletRepository {
  /// Returns the balance [MyUser] has in their wallet.
  Rx<Balance> get balance;

  /// Returns the [Operation]s happening in [MyUser]'s wallet.
  Paginated<OperationId, Rx<Operation>> get operations;

  /// Returns the [OperationDepositMethod]s available for the [MyUser].
  RxList<OperationDepositMethod> get methods;

  /// Sets the available [methods] to be accounted as the provided [country].
  Future<void> setCountry(CountryCode country);

  /// Returns an [Operation] identified by the provided [id] or [num].
  FutureOr<Rx<Operation>?> get({OperationId? id, OperationNum? num});

  /// Creates a new [OperationDeposit].
  Future<Rx<Operation>?> createOperationDeposit({
    required OperationDepositMethodId methodId,
    required Price nominal,
    OperationDepositSecret? paypal,
    required CountryCode country,
  });

  /// Completes an [OperationDeposit].
  Future<Rx<Operation>?> completeOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  });

  /// Declines an [OperationDeposit].
  Future<Rx<Operation>?> declineOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  });
}
