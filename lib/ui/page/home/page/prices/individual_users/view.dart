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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/domain/repository/user.dart';
import '/l10n/l10n.dart';
import '/ui/widget/future_or_builder.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/member_tile.dart';
import '/ui/widget/modal_popup.dart';
import 'controller.dart';

/// View for displaying the list of individual [MonetizationSettings] set by
/// [MyUser].
class IndividualUsersView extends StatelessWidget {
  const IndividualUsersView({super.key});

  /// Displays a [IndividualUsersView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context) {
    return ModalPopup.show(
      context: context,
      child: const IndividualUsersView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: IndividualUsersController(Get.find(), Get.find()),
      builder: (IndividualUsersController c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(
              text: 'label_users_with_individual_monetization_settings'.l10n,
            ),
            Flexible(
              child: Obx(() {
                return ListView(
                  shrinkWrap: true,
                  padding: ModalPopup.padding(context),
                  children: [
                    LineDivider(
                      'label_users_count'.l10nfmt({
                        'count': max(c.total.value - 1, 0),
                      }),
                    ),
                    const SizedBox(height: 20),
                    ...c.paginated.items.entries.map((e) {
                      return FutureOrBuilder<RxUser?>(
                        key: Key('${e.key}'),
                        futureOr: () => c.getUser(e.key),
                        builder: (context, user) {
                          if (user == null || user.id.isLocal) {
                            return const SizedBox();
                          }

                          return MemberTile(
                            user: user,
                            onKick: () async {
                              c.removeSettings(user.id);
                            },
                          );
                        },
                      );
                    }),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
