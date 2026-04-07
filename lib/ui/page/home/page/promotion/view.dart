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
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/block.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import 'controller.dart';

/// View of the [Routes.promotion] page.
class PromotionView extends StatelessWidget {
  const PromotionView({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: PromotionController(Get.find()),
      builder: (PromotionController c) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text('label_your_promotion'.l10n),
            leading: const [SizedBox(width: 4), StyledBackButton()],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
            children: [
              Block(
                title: 'label_your_author_partner_program_tapopa_author'.l10n,
                children: [
                  SvgImage.asset(
                    'assets/images/blocks/promotion_partner_program.svg',
                    width: 324,
                    height: 312,
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'label_your_promotion_program_description1'.l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text:
                              'label_your_promotion_program_description2'.l10n,
                        ),
                      ],
                    ),
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Block(
                title: 'label_set_your_promo_percentage_promo'.l10n,
                padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                children: [
                  Obx(() {
                    final List<Widget> children;

                    if (c.percentEditing.value) {
                      children = [
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            ReactiveTextField(
                              state: c.percentage,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              label: 'label_promotional_percentage'.l10n,
                              hint: '0',
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              trailing: SvgIcon(SvgIcons.acceptAudioCall),
                            ),
                            Positioned(
                              top: 5,
                              right: 2,
                              child: Theme(
                                data: ThemeData(platform: TargetPlatform.macOS),

                                child: Obx(() {
                                  return Switch.adaptive(
                                    activeTrackColor: style.colors.primary,
                                    activeThumbColor: style.colors.onPrimary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: c.expected.value != 0,
                                    onChanged: (e) async {
                                      if (e) {
                                        c.percentage.text = '5';
                                      } else {
                                        c.percentage.text = '0';
                                      }
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        WidgetButton(
                          onPressed: c.savePercentage,
                          child: Text(
                            'btn_save'.l10n,
                            style: style.fonts.small.regular.primary,
                          ),
                        ),
                      ];
                    } else {
                      children = [
                        const SizedBox(width: double.infinity),
                        Obx(() {
                          final settings = c.settings.value;

                          return Text(
                            '${settings.referral?.fee?.val ?? '0'}%',
                            style: style.fonts.giant.regular.onBackground,
                          );
                        }),
                        const SizedBox(height: 12),
                        WidgetButton(
                          onPressed: c.editPercentage,
                          child: Text(
                            'btn_change'.l10n,
                            style: style.fonts.small.regular.primary,
                          ),
                        ),
                      ];
                    }

                    return AnimatedSizeAndFade(
                      sizeDuration: const Duration(milliseconds: 300),
                      fadeDuration: const Duration(milliseconds: 300),
                      child: Column(
                        key: Key(c.percentEditing.value.toString()),
                        children: children,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32 - 4, 0, 32 - 4, 0),
                    child: LineDivider('label_description'.l10n),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'label_set_your_promo_percentage_promo_description'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
