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

import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/block.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/svg/svg.dart';
import 'controller.dart';

class AffiliateView extends StatelessWidget {
  const AffiliateView({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: AffiliateController(),
      builder: (AffiliateController c) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text('label_your_partner_income'.l10n),
            leading: const [SizedBox(width: 4), StyledBackButton()],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
            children: [
              Block(
                title: 'label_your_partner_program_tapopa_partner'.l10n,
                children: [
                  SvgImage.asset(
                    'assets/images/blocks/partner_program_tapopa_partner.svg',
                    width: 324,
                    height: 265,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '1%',
                                  style: style.fonts.giant.bold.currencyPrimary,
                                ),
                                _tripleColumn(
                                  context,
                                  'label_of_users_expenses1'.l10n,
                                  'label_of_users_expenses2'.l10n,
                                  'label_of_users_expenses3'.l10n,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '+',
                          style: style.fonts.giant.bold.currencyPrimary,
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '1%',
                                  style: style.fonts.giant.bold.currencyPrimary,
                                ),
                                _tripleColumn(
                                  context,
                                  'label_of_users_income1'.l10n,
                                  'label_of_users_income2'.l10n,
                                  'label_of_users_income3'.l10n,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '+',
                          style: style.fonts.giant.bold.currencyPrimary,
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '10%',
                                  style: style.fonts.giant.bold.currencyPrimary,
                                ),
                                _tripleColumn(
                                  context,
                                  'label_of_partners_earnings1'.l10n,
                                  'label_of_partners_earnings2'.l10n,
                                  'label_of_partners_earnings3'.l10n,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_partner_percentage_tapopa_partner'.l10n),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description1'
                                  .l10n,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description2'
                                  .l10nfmt({'percent': 1}),
                          style: style.fonts.small.regular.currencyPrimary,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description3'
                                  .l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description4'
                                  .l10n,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description5'
                                  .l10nfmt({'percent': 1}),
                          style: style.fonts.small.regular.currencyPrimary,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description6'
                                  .l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description7'
                                  .l10n,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description8'
                                  .l10nfmt({'percent': 10}),
                          style: style.fonts.small.regular.currencyPrimary,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description9'
                                  .l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text:
                              'label_partner_program_tapopa_partner_description10'
                                  .l10n,
                        ),
                      ],
                    ),
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_partner_number_tapopa_partner'.l10n),
                  const SizedBox(height: 20),
                  Text(
                    'label_partner_program_tapopa_partner_number'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Block(
                title: 'label_partner_program_tapopa_author'.l10n,
                children: [
                  SvgImage.asset(
                    'assets/images/blocks/partner_program_tapopa_author.svg',
                    width: 324,
                    height: 325,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_promotional_percentage_promo'.l10n),
                  const SizedBox(height: 20),
                  Text(
                    'label_promotional_percentage_promo_description'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_promotional_number_promo'.l10n),
                  const SizedBox(height: 20),
                  Text(
                    'label_promotional_number_promo_description'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Block(
                title: 'label_your_partner_and_promotional_links'.l10n,
                children: [
                  SvgImage.asset(
                    'assets/images/blocks/partner_links.svg',
                    width: 324,
                    height: 275.74,
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'label_partner_program_links_description1'.l10n,
                        ),
                        TextSpan(
                          text: 'label_partner_program_links_description2'.l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text: 'label_partner_program_links_description3'.l10n,
                        ),
                        TextSpan(
                          text: 'label_partner_program_links_description4'.l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text: 'label_partner_program_links_description5'.l10n,
                        ),
                      ],
                    ),
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_partner_link_tapopa_partner'.l10n),
                  const SizedBox(height: 20),
                  Text(
                    'label_partner_link_tapopa_partner_description'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_promotional_link_promo'.l10n),
                  const SizedBox(height: 20),
                  Text(
                    'label_promotional_link_promo_description'.l10n,
                    style: style.fonts.small.regular.secondary,
                  ),
                  const SizedBox(height: 24),
                  LineDivider('label_link_information'.l10n),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'label_link_information_description1'.l10n,
                        ),
                        TextSpan(
                          text: 'label_link_information_description2'.l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                        TextSpan(
                          text: 'label_link_information_description3'.l10n,
                        ),
                        TextSpan(
                          text: 'label_link_information_description4'.l10n,
                          style: style.fonts.small.regular.onBackground,
                        ),
                      ],
                    ),
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

  Widget _tripleColumn(
    BuildContext context,
    String first,
    String second,
    String third,
  ) {
    final style = Theme.of(context).style;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first.isNotEmpty)
          Text(first, style: style.fonts.small.regular.secondary),
        if (second.isNotEmpty)
          Text(second, style: style.fonts.small.regular.onBackground),
        if (third.isNotEmpty)
          Text(third, style: style.fonts.small.regular.secondary),
      ],
    );
  }
}
