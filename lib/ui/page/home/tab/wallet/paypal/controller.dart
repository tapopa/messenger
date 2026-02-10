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
import '/config.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/service/wallet.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart';
import '/util/web/web_utils.dart';

/// Status of [PayPalDepositView].
enum PayPalDepositStatus { loading, inProgress }

/// Controller of a [PayPalDepositView].
class PayPalDepositController extends GetxController {
  PayPalDepositController(
    this._walletService, {
    required this.method,
    required this.country,
    required this.nominal,
    this.id,
    PayPalDepositStatus status = PayPalDepositStatus.loading,
  }) : status = Rx(status);

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// [PayPalDepositStatus] of the [createDeposit] operation.
  final Rx<PayPalDepositStatus> status;

  /// [OperationId] of an [OperationDeposit] already existing, if any.
  final OperationId? id;

  /// [OperationDeposit] being deposited.
  final Rx<Rx<Operation>?> operation = Rx(null);

  /// Error happened during [OperationDeposit] creating.
  final RxnString error = RxnString();

  /// [WalletService] used to create the [OperationDeposit] itself.
  final WalletService _walletService;

  /// [OperationDepositSecret] to use with [OperationDeposit] related
  /// management.
  OperationDepositSecret? _secret;

  @override
  void onInit() {
    switch (status.value) {
      case PayPalDepositStatus.loading:
        _redirectAndClose();
        break;

      case PayPalDepositStatus.inProgress:
        if (id != null) {
          final operationOrFuture = _walletService.get(id: id);
          if (operationOrFuture is Future<Rx<Operation>?>) {
            operationOrFuture.then((e) {
              operation.value = e;
              completeDeposit();
            });
          } else {
            operation.value = operationOrFuture;
            completeDeposit();
          }
        }
        break;
    }

    super.onInit();
  }

  /// Creates a [OperationDeposit].
  Future<Operation?> createDeposit() async {
    try {
      operation.value = await _walletService.createOperationDeposit(
        methodId: method.id,
        nominal: nominal,
        country: country,
        paypal: _secret ??= OperationDepositSecret.generate(),
      );

      return operation.value?.value;
    } catch (e) {
      error.value = e.toString();
      rethrow;
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

  /// Creates an [OperationDeposit] and opens a PayPal in a separate Web page.
  Future<void> _redirectAndClose() async {
    try {
      final Operation? order = await createDeposit();

      status.value = PayPalDepositStatus.inProgress;

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
      }
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }
}
