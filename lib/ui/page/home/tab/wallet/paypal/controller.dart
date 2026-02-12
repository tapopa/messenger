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

import '../../../../../../config.dart';
import '../../../../../../l10n/l10n.dart';
import '../../../../../../util/web/web_utils.dart';
import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/service/wallet.dart';
import '/provider/gql/exceptions.dart';

/// Status of [PayPalDepositView].
enum PayPalDepositStatus { initial, inProgress }

/// Controller of a [PayPalDepositView].
class PayPalDepositController extends GetxController {
  PayPalDepositController(
    this._walletService, {
    required this.method,
    required this.country,
    required this.nominal,
    this.id,
  });

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// [PayPalDepositStatus] of the [createDeposit] operation.
  final Rx<PayPalDepositStatus> status = Rx(PayPalDepositStatus.initial);

  /// [OperationId] of an [OperationDeposit] already existing, if any.
  final OperationId? id;

  /// [OperationDeposit] being deposited.
  final Rx<Rx<Operation>?> operation = Rx(null);

  /// Error happened during [OperationDeposit] creating.
  final RxnString error = RxnString();

  /// [RxStatus] of the [operation] creating.
  final Rx<RxStatus> operationStatus = Rx(RxStatus.empty());

  /// Seconds until displaying inability to process the [operation]
  /// automatically.
  final RxnInt responseSeconds = RxnInt(null);

  /// [WalletService] used to create the [OperationDeposit] itself.
  final WalletService _walletService;

  /// [OperationDepositSecret] to use with [OperationDeposit] related
  /// management.
  OperationDepositSecret? _secret;

  /// [Timer] counting down the [responseSeconds].
  Timer? _responseTimer;

  @override
  void onClose() {
    _responseTimer?.cancel();
    super.onClose();
  }

  /// Creates a [OperationDeposit].
  Future<Operation?> createDeposit() async {
    operationStatus.value = RxStatus.loading();

    try {
      operation.value = await _walletService.createOperationDeposit(
        methodId: method.id,
        nominal: nominal,
        country: country,
        paypal: _secret ??= OperationDepositSecret.generate(),
      );

      operationStatus.value = RxStatus.success();

      final Operation? order = operation.value?.value;
      if (order is OperationDeposit) {
        await WebUtils.openPopup(
          '${Config.origin}/payment/paypal.html',
          parameters: {
            'client-id': Config.payPalClientId,
            'nominal': nominal.l10next(digits: 0),
            'price': order.pricing?.total?.l10n,
            'deposit-id': '${order.id}',
            'order-num': '${order.num.val}',
            'order-id': '${order.processingUrl?.val.split('?order_id=').last}',
            'methodId': method.id.val,
            'country': country.val,
          },
        );

        _startResponseTimer();
      }

      return operation.value?.value;
    } catch (e) {
      operationStatus.value = RxStatus.error('err_data_transfer'.l10n);
      error.value = e.toString();
      rethrow;
    } finally {
      status.value = PayPalDepositStatus.inProgress;
    }
  }

  /// Completes the [OperationDeposit].
  Future<void> completeDeposit() async {
    status.value = PayPalDepositStatus.inProgress;

    final Operation? operation = this.operation.value?.value;
    if (operation != null) {
      // Wait for ~5 seconds, since PayPal might take some time to validate the
      // transaction.
      await Future.delayed(Duration(seconds: 5));

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
            error.value = e.toString();
            rethrow;
        }
      }
    }
  }

  /// Declines the [OperationDeposit].
  Future<void> declineDeposit() async {
    status.value = PayPalDepositStatus.inProgress;

    final Operation? operation = this.operation.value?.value;
    if (operation != null) {
      try {
        this.operation.value = await _walletService.declineOperationDeposit(
          id: operation.id,
          secret: _secret,
        );
      } catch (e) {
        error.value = e.toString();
        rethrow;
      }
    }
  }

  /// Starts the [_responseTimer] counting down the [responseSeconds].
  void _startResponseTimer() {
    responseSeconds.value = 600;

    _responseTimer?.cancel();
    _responseTimer = Timer.periodic(Duration(seconds: 1), (_) {
      responseSeconds.value = (responseSeconds.value ?? 1) - 1;
      if ((responseSeconds.value ?? 0) <= 0) {
        _responseTimer?.cancel();
      }
    });
  }
}
