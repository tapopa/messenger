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
import 'package:url_launcher/url_launcher_string.dart';

import '/api/backend/schema.dart';
import '/config.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/model/user.dart';
import '/domain/service/disposable_service.dart';
import '/domain/service/wallet.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/ui/page/home/tab/wallet/paypal/controller.dart';
import '/ui/page/home/tab/wallet/paypal/view.dart';
import '/util/log.dart';
import '/util/platform_utils.dart';
import '/util/web/web_utils.dart';

/// Worker responsible for creating [OperationDeposit]s and maintaining
/// communication with deposit popups.
class WalletWorker extends Dependency with IdentityAware {
  WalletWorker(this._walletService);

  /// [WalletService] used for creating [OperationDeposit]s.
  final WalletService _walletService;

  /// List of ongoing [_Operation]s happening currently.
  final Map<String, _Operation> _operations = {};

  @override
  void onInit() {
    Log.debug('onInit', '$runtimeType');
    super.onInit();
  }

  @override
  void onClose() {
    Log.debug('onClose', '$runtimeType');

    for (var e in _operations.values) {
      e.dispose();
    }
    _operations.clear();

    super.onClose();
  }

  @override
  void onIdentityChanged(UserId me) {
    for (var e in _operations.values) {
      e.dispose();
    }
    _operations.clear();
  }

  /// Creates an [OperationDeposit] using the provided [method], [country],
  /// [nominal] and [pricing].
  Future<void> create(
    OperationDepositMethod method,
    CountryCode country,
    Price nominal,
    Price? pricing,
  ) async {
    // Display a [PayPalDepositView] for desktop platforms.
    if (!PlatformUtils.isWeb) {
      return await PayPalDepositView.show(
        router.context!,
        nominal: nominal,
        method: method,
        country: country,
      );
    }

    final _Operation operation = await _Operation.create(
      method: method,
      country: country,
      nominal: nominal,
      pricing: pricing,
      onMessage: (e) async {
        Log.debug('onMessage -> $e', '$runtimeType');

        if (e is Map) {
          final id = e['id'];
          final type = e['type'];

          if (id is String && type is String) {
            final _Operation? operation = _operations[id];
            if (operation == null) {
              Log.debug(
                'onMessage -> ignoring `$type` event, as `$id` is not found',
                '$runtimeType',
              );
              return;
            }

            switch (type) {
              case 'createOrder':
                operation._secret = OperationDepositSecret.generate();
                final Rx<Operation>? deposit = await _walletService
                    .createOperationDeposit(
                      methodId: operation.method.id,
                      nominal: operation.nominal,
                      country: operation.country,
                      paypal: operation._secret,
                    );

                operation.deposit = deposit;

                final Operation? operationDeposit = deposit?.value;
                if (operationDeposit is OperationDeposit) {
                  final String? url = operationDeposit.processingUrl?.val;
                  if (url != null) {
                    operation.postBroadcast({
                      'id': id,
                      'type': 'orderCreated',
                      'orderId': url.split('?order_id=').last,
                    });
                  }
                }
                break;

              case 'onApprove':
                final operationId = e['transactionId'];
                if (operationId is String) {
                  await PayPalDepositView.show(
                    router.context!,
                    nominal: nominal,
                    method: method,
                    country: country,
                    id: OperationId(operationId),
                    status: PayPalDepositStatus.inProgress,
                  );
                }

                final OperationId? id = operation.deposit?.value?.id;
                if (id != null) {
                  await _walletService.completeOperationDeposit(
                    id: id,
                    secret: operation._secret,
                  );
                }

                final OperationNum? num = operation.deposit?.value?.num;
                if (num != null) {
                  operation.postBroadcast({
                    'id': id,
                    'type': 'inProgress',
                    'transactionId': '${num.val}',
                  });
                }
                break;

              case 'onCancel':
                final operationId = e['transactionId'];
                if (operationId is String) {
                  await PayPalDepositView.show(
                    router.context!,
                    nominal: nominal,
                    method: method,
                    country: country,
                    id: OperationId(operationId),
                    status: PayPalDepositStatus.inProgress,
                  );
                }

                final OperationId? id = operation.deposit?.value?.id;
                if (id != null) {
                  await _walletService.declineOperationDeposit(
                    id: id,
                    secret: operation._secret,
                  );
                }
                break;

              case 'onError':
                // No-op.
                break;
            }
          }
        }
      },
    );

    if (!operation._handle.isOpen) {
      await launchUrlString(operation._handle.url);
      operation.dispose();
      return;
    }

    _operations[operation.id] = operation;
  }
}

/// Ongoing [OperationDeposit].
class _Operation {
  _Operation(
    this._handle, {
    required this.method,
    required this.country,
    required this.nominal,
    this.pricing,
    void Function(dynamic e)? onMessage,
  }) {
    _onMessage = WebUtils.onBroadcastMessage(name: id).listen(onMessage);
  }

  /// Creates an [_Operation] with a [WindowHandle] set up.
  static Future<_Operation> create({
    required OperationDepositMethod method,
    required CountryCode country,
    required Price nominal,
    required Price? pricing,
    void Function(dynamic e)? onMessage,
  }) async {
    return _Operation(
      await WebUtils.openPopup(
        '${Config.origin}/payment/paypal.html',
        parameters: {
          'client-id': Config.payPalClientId,
          'nominal': nominal.l10next(digits: 0),
          'price': '${pricing?.l10n}',
          'methodId': method.id.val,
          'country': country.val,
        },
      ),
      method: method,
      country: country,
      nominal: nominal,
      pricing: pricing,
      onMessage: onMessage,
    );
  }

  /// [OperationDepositMethod] of this [_Operation].
  final OperationDepositMethod method;

  /// [CountryCode] the [OperationDeposit] is taking place as.
  final CountryCode country;

  /// [Price] of the [OperationDeposit].
  final Price nominal;

  /// Total calculated pricing of this [OperationDeposit].
  final Price? pricing;

  /// [WindowHandle] of a window where [_Operation] is happening.
  final WindowHandle _handle;

  OperationDepositSecret? _secret;

  StreamSubscription? _onMessage;
  StreamSubscription? _onStatus;

  /// [OperationDeposit] attached to this [_Operation], if any.
  Rx<Operation?>? _deposit;

  /// Returns an [OperationDeposit] attached to this [_Operation], if any.
  Rx<Operation?>? get deposit => _deposit;

  /// Returns the [OperationDeposit] to attach to this [_Operation].
  set deposit(Rx<Operation?>? value) {
    _deposit = value;

    OperationStatus? previous;

    _onStatus?.cancel();
    _onStatus = value?.subject.listen((e) {
      if (previous != e?.status) {
        previous = e?.status;

        switch (e?.status) {
          case OperationStatus.inProgress:
          case OperationStatus.artemisUnknown:
          case null:
            // No-op.
            break;

          case OperationStatus.completed:
            postBroadcast({'id': id, 'type': 'success'});
            break;

          case OperationStatus.canceled:
          case OperationStatus.declined:
          case OperationStatus.failed:
            postBroadcast({'id': id, 'type': 'failed'});
            break;
        }
      }
    });
  }

  String get id => _handle.id;

  void dispose() {
    _onMessage?.cancel();
    _onMessage = null;

    _onStatus?.cancel();
    _onStatus = null;

    close();
  }

  void close() => _handle.close();
  void postBroadcast(Map<String, dynamic> message) {
    WebUtils.postBroadcastMessage(id, message);
  }

  void postMessage(Map<String, dynamic> message) =>
      _handle.postMessage(message);
}
