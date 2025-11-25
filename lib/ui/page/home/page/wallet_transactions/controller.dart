// Copyright © 2025 Ideas Networks Solutions S.A.,
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

import '/domain/model/operation.dart';
import '/domain/repository/paginated.dart';
import '/domain/service/wallet.dart';
import '/ui/widget/text_field.dart';

class WalletTransactionsController extends GetxController {
  WalletTransactionsController(this._walletService);

  final RxBool expanded = RxBool(false);
  final RxSet<OperationId> ids = RxSet();

  final TextFieldState search = TextFieldState();
  final RxnString query = RxnString();

  final WalletService _walletService;

  Worker? _queryWorker;

  Paginated<OperationId, Operation> get operations => _walletService.operations;

  @override
  void onInit() {
    _queryWorker = debounce(query, (String? query) {
      // TODO: Searching.
    });

    super.onInit();
  }

  @override
  void onClose() {
    _queryWorker?.dispose();
    super.onClose();
  }
}
