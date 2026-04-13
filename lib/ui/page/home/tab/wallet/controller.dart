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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/api/backend/schema.dart';
import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/price.dart';
import '/domain/model/session.dart';
import '/domain/service/session.dart';
import '/domain/service/wallet.dart';
import '/routes.dart';
import '/util/message_popup.dart';
import 'paypal/view.dart';
import 'widget/deposit_expandable.dart';

/// Unique identifier of a single [OperationDepositMethod] along with its
/// possible [OperationDepositSubKind].
class OperationDepositId {
  OperationDepositId(this.id, [this.subkind]);

  /// [OperationDepositMethodId] itself.
  final OperationDepositMethodId id;

  /// Possible [OperationDepositSubKind] of the [id], if any.
  final OperationDepositSubKind? subkind;

  @override
  bool operator ==(Object other) {
    return other is OperationDepositId &&
        id == other.id &&
        subkind == other.subkind;
  }

  @override
  int get hashCode => Object.hash(id, subkind);
}

/// Controller of the `HomeTab.wallet` tab.
class WalletTabController extends GetxController {
  WalletTabController(this._sessionService, this._walletService);

  /// [ScrollController] to pass to a [Scrollbar].
  final ScrollController scrollController = ScrollController();

  /// [OperationDepositId]s being expanded currently.
  final RxSet<OperationDepositId> expanded = RxSet();

  /// [DepositFields] to pass to a [DepositExpandable].
  final Rx<DepositFields> fields = Rx(DepositFields());

  /// [SessionService] used for [IpGeoLocation] retrieving.
  final SessionService _sessionService;

  /// [WalletService] used to retrieve available [OperationDepositMethod]s.
  final WalletService _walletService;

  /// Returns the [OperationDepositMethod]s available for the [MyUser].
  RxList<OperationDepositMethod> get methods => _walletService.methods;

  /// Balance [MyUser] has in its wallet to display.
  Rx<Balance?> get balance => _walletService.balance;

  @override
  void onInit() {
    _fetchIp();
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Sets the [country].
  Future<void> setCountry(CountryCode country) async {
    await _walletService.setCountry(country);
  }

  /// Creates an [OperationDeposit] using the provided [method], [country],
  /// [nominal] and [pricing].
  Future<void> createDeposit(
    OperationDepositMethod method,
    OperationDepositSubKind? subkind,
    CountryCode country,
    Price nominal,
    Price? pricing,
  ) async {
    try {
      switch (method.kind) {
        case OperationDepositKind.paypal:
          await PayPalDepositView.show(
            router.context!,
            method: method,
            subkind: subkind,
            country: country,
            nominal: nominal,
          );
          break;

        case OperationDepositKind.artemisUnknown:
          throw Exception('Unsupported');
      }
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }

  /// Fetches the current [IpGeoLocation] to update [IsoCode].
  Future<void> _fetchIp() async {
    final IpGeoLocation ip = await _sessionService.fetch();
    fields.value.applyCountry(IsoCode.fromJson(ip.countryCode));
    fields.refresh();
  }
}
