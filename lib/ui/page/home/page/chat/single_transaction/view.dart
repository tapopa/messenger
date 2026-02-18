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

import '/domain/model/operation.dart';
import '/l10n/l10n.dart';
import '/ui/page/home/widget/operation.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/progress_indicator.dart';
import 'controller.dart';

/// View displaying a single [Operation].
class SingleTransactionView extends StatelessWidget {
  const SingleTransactionView(this.id, {super.key, this.wallet = true});

  /// [OperationId] of an [Operation] to fetch and display.
  final OperationId id;

  /// Indicator whether the [Operation] is coming from wallet, or from a
  /// monetization otherwise.
  final bool wallet;

  /// Displays a [SingleTransactionView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(
    BuildContext context, {
    required OperationId id,
    required bool wallet,
  }) {
    return ModalPopup.show(
      context: context,
      child: SingleTransactionView(id, wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SingleTransactionController(
        Get.find(),
        Get.find(),
        Get.find(),
        id: id,
        wallet: wallet,
      ),
      builder: (SingleTransactionController c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(text: 'label_transaction'.l10n),
            Flexible(
              child: Obx(() {
                final Operation? operation = c.operation?.value;

                if (c.status.value.isLoading) {
                  return const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: CustomProgressIndicator.primary()),
                  );
                } else if (operation == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('label_nothing_found'.l10n),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: OperationWidget(operation, getUser: c.getUser),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
