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

import 'package:get/get.dart';

import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/repository/paginated.dart';
import '/domain/repository/wallet.dart';
import '/util/log.dart';
import 'disposable_service.dart';

/// Service responsible for [MyUser] wallet functionality.
class WalletService extends Dependency {
  WalletService(this._walletRepository);

  /// [AbstractWalletRepository] managing the wallet data.
  final AbstractWalletRepository _walletRepository;

  /// Returns the balance [MyUser] has in their wallet.
  Rx<Balance> get balance => _walletRepository.balance;

  /// Returns the [Operation]s happening in [MyUser]'s wallet.
  Paginated<OperationId, Operation> get operations =>
      _walletRepository.operations;

  /// Returns the [OperationDepositMethod]s available for the [MyUser].
  RxList<OperationDepositMethod> get methods => _walletRepository.methods;

  /// Sets the available [methods] to be accounted as the provided [country].
  Future<void> setCountry(CountryCode country) {
    Log.debug('setCountry($country)', '$runtimeType');
    return _walletRepository.setCountry(country);
  }

  /// Creates a new [OperationDeposit].
  Future<OperationDeposit?> createOperationDeposit({
    required OperationDepositMethodId methodId,
    required Price nominal,
    OperationDepositSecret? paypal,
    required CountryCode country,
  }) {
    Log.debug(
      'createOperationDeposit(methodId: $methodId, nominal: $nominal, paypal: ${paypal?.obscured}, country: $country)',
      '$runtimeType',
    );

    return _walletRepository.createOperationDeposit(
      methodId: methodId,
      nominal: nominal,
      paypal: paypal,
      country: country,
    );
  }

  /// Completes an [OperationDeposit].
  Future<OperationDeposit?> completeOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  }) {
    Log.debug(
      'completeOperationDeposit(id: $id, secret: ${secret?.obscured})',
      '$runtimeType',
    );

    return _walletRepository.completeOperationDeposit(id: id, secret: secret);
  }

  /// Declines an [OperationDeposit].
  Future<OperationDeposit?> declineOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  }) {
    Log.debug(
      'completeOperationDeposit(id: $id, secret: ${secret?.obscured})',
      '$runtimeType',
    );

    return _walletRepository.declineOperationDeposit(id: id, secret: secret);
  }
}
