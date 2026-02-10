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

import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/price.dart';
import '/domain/model/session.dart';
import '/domain/service/session.dart';
import '/domain/service/wallet.dart';
import '/ui/worker/wallet.dart';
import '/util/message_popup.dart';
import 'widget/deposit_expandable.dart';

/// Controller of the `HomeTab.wallet` tab.
class WalletTabController extends GetxController {
  WalletTabController(
    this._sessionService,
    this._walletService,
    this._walletWorker,
  );

  /// [ScrollController] to pass to a [Scrollbar].
  final ScrollController scrollController = ScrollController();

  /// [OperationDepositMethodId]s being expanded currently.
  final RxSet<OperationDepositMethodId> expanded = RxSet();

  /// [DepositFields] to pass to a [DepositExpandable].
  final Rx<DepositFields> fields = Rx(DepositFields());

  /// [SessionService] used for [IpGeoLocation] retrieving.
  final SessionService _sessionService;

  /// [WalletService] used to retrieve available [OperationDepositMethod]s.
  final WalletService _walletService;

  /// [WalletWorker] responsible for creating [OperationDeposit]s.
  final WalletWorker _walletWorker;

  /// Returns the [OperationDepositMethod]s available for the [MyUser].
  RxList<OperationDepositMethod> get methods => _walletService.methods;

  /// Balance [MyUser] has in its wallet to display.
  Rx<Balance> get balance => _walletService.balance;

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
    CountryCode country,
    Price nominal,
    Price? pricing,
  ) async {
    try {
      await _walletWorker.create(method, country, nominal, pricing);
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
