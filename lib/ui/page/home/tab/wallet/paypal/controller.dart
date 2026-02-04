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

import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/service/wallet.dart';
import '/provider/gql/exceptions.dart';
import '/util/message_popup.dart';

/// Status of [PayPalDepositView].
enum PayPalDepositStatus { initial, inProgress }

/// Controller of a [PayPalDepositView].
class PayPalDepositController extends GetxController {
  PayPalDepositController(
    this._walletService, {
    required this.method,
    required this.country,
    required this.nominal,
  });

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// [PayPalDepositStatus] of the [createDeposit] operation.
  final Rx<PayPalDepositStatus> status = Rx(PayPalDepositStatus.initial);

  /// [OperationDeposit] being deposited.
  final Rx<OperationDeposit?> operation = Rx(null);

  final RxnString error = RxnString();

  /// [WalletService] used to create the [OperationDeposit] itself.
  final WalletService _walletService;

  /// [OperationDepositSecret] to use with [OperationDeposit] related
  /// management.
  OperationDepositSecret? _secret;

  /// Creates a [OperationDeposit].
  Future<OperationDeposit?> createDeposit() async {
    try {
      operation.value = await _walletService.createOperationDeposit(
        methodId: method.id,
        nominal: nominal,
        country: country,
        paypal: _secret ??= OperationDepositSecret.generate(),
      );

      return operation.value;
    } catch (e) {
      status.value = PayPalDepositStatus.initial;
      MessagePopup.error(e);
      rethrow;
    }
  }

  /// Completes the [OperationDeposit].
  Future<void> completeDeposit() async {
    status.value = PayPalDepositStatus.inProgress;

    final OperationDeposit? operation = this.operation.value;
    if (operation != null) {
      try {
        this.operation.value = await _walletService.completeOperationDeposit(
          id: operation.id,
          secret: _secret,
        );
      } on CompleteOperationDepositException catch (e) {
        switch (e.code) {
          case CompleteOperationDepositErrorCode.inProgress:
            // No-op.
            break;

          case CompleteOperationDepositErrorCode.unavailable:
          case CompleteOperationDepositErrorCode.unknownOperation:
          case CompleteOperationDepositErrorCode.unprocessable:
          case CompleteOperationDepositErrorCode.artemisUnknown:
            MessagePopup.error(e);
            rethrow;
        }
      }
    }
  }

  /// Declines the [OperationDeposit].
  Future<void> declineDeposit() async {
    status.value = PayPalDepositStatus.inProgress;

    final OperationDeposit? operation = this.operation.value;
    if (operation != null) {
      try {
        this.operation.value = await _walletService.declineOperationDeposit(
          id: operation.id,
          secret: _secret,
        );
      } catch (e) {
        MessagePopup.error(e);
        rethrow;
      }
    }
  }
}
