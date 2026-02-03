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
import '/domain/service/partner.dart';

/// Controller of the `HomeTab.partner` tab.
class PartnerTabController extends GetxController {
  PartnerTabController(this._partnerService);

  /// [ScrollController] to pass to a [Scrollbar].
  final ScrollController scrollController = ScrollController();

  /// Returns the balance [MyUser] has in their partner available wallet.
  Rx<Balance> get available => _partnerService.available;

  /// Returns the balance [MyUser] has in their partner hold wallet.
  Rx<Balance> get hold => _partnerService.hold;

  /// [PartnerService] used to query [available] and [hold] balances.
  final PartnerService _partnerService;

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
