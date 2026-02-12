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

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '/domain/model/operation.dart';
import '/domain/repository/paginated.dart';
import '/domain/service/wallet.dart';
import '/ui/widget/text_field.dart';

/// Controller of the [Routes.walletTransactions] page.
class WalletTransactionsController extends GetxController {
  WalletTransactionsController(this._walletService);

  /// Indicator whether the [operations] should be all expanded or not.
  final RxBool expanded = RxBool(false);

  /// [OperationId]s of the [Operation]s that are should be expanded only.
  final RxSet<OperationId> ids = RxSet();

  /// [TextFieldState] of a search field for filtering the [operations].
  final TextFieldState search = TextFieldState();

  /// Query of the [search].
  final RxnString query = RxnString();

  /// [ScrollController] to pass to a [ListView] of [Operation]s to fetch more.
  final ScrollController scrollController = ScrollController();

  /// [WalletService] maintaining the [Operation]s.
  final WalletService _walletService;

  /// [Worker] executing the filtering of the [operations] on [query] changes.
  Worker? _queryWorker;

  /// Returns the [Operation]s happening in [MyUser]'s wallet.
  Paginated<OperationId, Rx<Operation>> get operations =>
      _walletService.operations;

  /// Indicator whether [operations] have next page.
  RxBool get hasNext => _walletService.operations.hasNext;

  /// Indicator whether [operations] have next page loading.
  RxBool get nextLoading => _walletService.operations.nextLoading;

  /// Indicator whether [operations] have previous page.
  RxBool get hasPrevious => _walletService.operations.hasPrevious;

  /// Indicator whether [operations] have previous page loading.
  RxBool get previousLoading => _walletService.operations.previousLoading;

  @override
  void onInit() {
    _queryWorker = debounce(query, (String? query) {
      // TODO: Searching.
    });

    scrollController.addListener(_scrollListener);

    super.onInit();
  }

  @override
  void onClose() {
    _queryWorker?.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  /// Requests the next page of [Operation]s based on the
  /// [ScrollController.position] value.
  Future<void> _scrollListener() async {
    if (scrollController.hasClients && hasNext.value && !nextLoading.value) {
      final bool isAtTop =
          scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 60;

      if (isAtTop) {
        await operations.next();
      }
    }
  }
}
