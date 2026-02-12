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

import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/model/user.dart';
import '/domain/service/disposable_service.dart';
import '/routes.dart';
import '/ui/page/home/tab/wallet/paypal/view.dart';
import '/util/log.dart';
import '/util/web/web_utils.dart';

/// Worker responsible for creating [OperationDeposit]s and maintaining
/// communication with deposit popups.
class WalletWorker extends Dependency with IdentityAware {
  WalletWorker();

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
    // Display a [PayPalDepositView].
    return await PayPalDepositView.show(
      router.context!,
      nominal: nominal,
      method: method,
      country: country,
    );
  }
}

/// Ongoing [OperationDeposit].
class _Operation {
  _Operation(
    this._handle, {
    required this.method,
    required this.country,
    required this.nominal,

    void Function(dynamic e)? onMessage,
  }) {
    _onMessage = WebUtils.onBroadcastMessage(name: id).listen(onMessage);
  }

  /// [OperationDepositMethod] of this [_Operation].
  final OperationDepositMethod method;

  /// [CountryCode] the [OperationDeposit] is taking place as.
  final CountryCode country;

  /// [Price] of the [OperationDeposit].
  final Price nominal;

  /// [WindowHandle] of a window where [_Operation] is happening.
  final WindowHandle _handle;

  /// [StreamSubscription] to [WebUtils.onBroadcastMessage] changes.
  StreamSubscription? _onMessage;

  /// [StreamSubscription] to [OperationStatus] changes.
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

  /// Returns an ID of the [WindowHandle].
  String get id => _handle.id;

  /// Disposes this [_Operation].
  void dispose() {
    _onMessage?.cancel();
    _onMessage = null;

    _onStatus?.cancel();
    _onStatus = null;

    close();
  }

  /// Closes the [WindowHandle] this [_Operation] happens.
  void close() => _handle.close();

  /// Posts the [message] to a broadcast channel with [id] identifier.
  void postBroadcast(Map<String, dynamic> message) {
    WebUtils.postBroadcastMessage(id, message);
  }
}
