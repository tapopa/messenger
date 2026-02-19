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

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/my_profile/widget/switch_field.dart';
import '/ui/page/home/widget/field_button.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/primary_button.dart';
import '/ui/widget/text_field.dart';
import 'controller.dart';

/// View for setting the incoming [Donation]s settings.
class SetDonationsView extends StatelessWidget {
  const SetDonationsView({super.key});

  /// Displays a [SetDonationsView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context) {
    return ModalPopup.show(context: context, child: const SetDonationsView());
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: SetDonationsController(Get.find()),
      builder: (SetDonationsController c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(text: 'label_donations'.l10n),
            Flexible(
              child: ListView(
                padding: ModalPopup.padding(context),
                shrinkWrap: true,
                children: [
                  Obx(() {
                    return SwitchField(
                      text: 'btn_accept_donations'.l10n,
                      value: c.enabled.value,
                      onChanged: (b) => c.enabled.value = b,
                    );
                  }),
                  const SizedBox(height: 16),
                  ReactiveTextField(
                    state: c.state,
                    hint: 'label_a_hyphen_b'.l10nfmt({
                      'a': Price.xxx(1).l10n,
                      'b': Price.xxx(9999).l10n,
                    }),
                    label: 'label_minimum_amount'.l10n,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Obx(() {
                      final Widget subtitle;

                      if (c.state.error.value != null) {
                        subtitle = const SizedBox(key: Key('Error'));
                      } else if (!c.enabled.value) {
                        subtitle = Text(
                          key: const Key('Disabled'),
                          'label_you_have_disabled_incoming_donations'.l10n,
                          style: style.fonts.small.regular.secondary,
                        );
                      } else {
                        subtitle = Text(
                          key: const Key('Enabled'),
                          'label_donations_described_subtitle'.l10n,
                          style: style.fonts.small.regular.secondary,
                        );
                      }

                      return AnimatedSizeAndFade(
                        fadeDuration: const Duration(milliseconds: 250),
                        sizeDuration: const Duration(milliseconds: 250),
                        alignment: Alignment.centerLeft,
                        child: subtitle,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FieldButton(
                          text: 'btn_cancel'.l10n,
                          onPressed: Navigator.of(context).pop,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() {
                          final bool enabledDiffer =
                              c.settings.value.donation?.enabled !=
                              c.enabled.value;

                          final bool amountDiffer =
                              c.settings.value.donation?.min.sum.val !=
                              (c.amount.value ?? 1);

                          return PrimaryButton(
                            title: 'btn_save'.l10n,
                            onPressed: enabledDiffer || amountDiffer
                                ? () {
                                    c.save();
                                    Navigator.of(context).pop();
                                  }
                                : null,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
