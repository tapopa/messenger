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

import '../controller.dart';
import '/l10n/l10n.dart';
import '/ui/page/home/widget/rectangle_button.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svg.dart';
import 'controller.dart';

/// View for choosing a [UsdcNetwork] as a modal.
class UsdcNetworkView extends StatelessWidget {
  const UsdcNetworkView({super.key});

  /// Displays a [UsdcNetworkView] wrapped in a [ModalPopup].
  static Future<UsdcNetwork?> show<T>(BuildContext context) {
    return ModalPopup.show(context: context, child: const UsdcNetworkView());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UsdcNetworkController(),
      builder: (UsdcNetworkController c) {
        return Column(
          mainAxisSize: .min,
          children: [
            ModalPopupHeader(text: 'label_usdc_network_type'.l10n),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: ModalPopup.padding(
                  context,
                ).add(EdgeInsets.fromLTRB(0, 0, 0, 16)),
                children: UsdcNetwork.values.map((e) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                    child: RectangleButton(
                      subtitle: 'label_commission_up_to_amount_usdc'.l10nfmt({
                        'amount': switch (e) {
                          .base => '0.10',
                          .ethereum => '2.00',
                          .optimism => '2.00',
                        },
                      }),

                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgIcon(e.icon),
                      ),
                      onPressed: () => Navigator.of(context).pop(e),
                      child: Text(e.l10n),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
