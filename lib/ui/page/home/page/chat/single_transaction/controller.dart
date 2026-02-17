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

import '/domain/model/operation.dart';
import '/domain/model/user.dart';
import '/domain/repository/user.dart';
import '/domain/service/user.dart';
import '/domain/service/wallet.dart';
import '/domain/service/partner.dart';

/// Controller for a [SingleTransactionView] modal.
class SingleTransactionController extends GetxController {
  SingleTransactionController(
    this._walletService,
    this._userService,
    this._partnerService, {
    required this.id,
    this.wallet = true,
  });

  /// [OperationId] of an [Operation] to fetch and display.
  final OperationId id;

  /// Indicator whether the [Operation] is coming from wallet, or from a
  /// monetization otherwise.
  final bool wallet;

  /// Reactive [Operation] fetched itself.
  Rx<Operation>? operation;

  /// [RxStatus] of the [operation] fetching.
  ///
  /// May be:
  /// - `status.isEmpty`, meaning the [operation] was fetched and is not found.
  /// - `status.isLoading`, meaning the [operation] is being fetched.
  /// - `status.isSuccess`, meaning the [operation] is successfully fetched.
  final Rx<RxStatus> status = Rx(RxStatus.empty());

  /// [WalletService] fetching [operation] when [wallet] is `true`.
  final WalletService _walletService;

  /// [PartnerService] fetching [operation] when [wallet] is `false`.
  final PartnerService _partnerService;

  /// [User]s service fetching the [User]s in [getUser] method.
  final UserService _userService;

  @override
  void onInit() {
    _fetchOperation();
    super.onInit();
  }

  /// Returns a reactive [User] from [UserService] by the provided [id].
  FutureOr<RxUser?> getUser(UserId id) => _userService.get(id);

  /// Fetches the [Operation] from [_walletService] of [_partnerService].
  void _fetchOperation() {
    status.value = RxStatus.loading();

    final operationOrFuture = wallet
        ? _walletService.get(id: id)
        : _partnerService.get(id: id);

    if (operationOrFuture is Future<Rx<Operation>?>) {
      operationOrFuture.then((e) {
        operation = e;
        status.value = operation == null
            ? RxStatus.empty()
            : RxStatus.success();
      });
    } else {
      operation = operationOrFuture;
      status.value = operation == null ? RxStatus.empty() : RxStatus.success();
    }
  }
}
