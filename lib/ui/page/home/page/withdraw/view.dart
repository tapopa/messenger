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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widget/primary_button.dart';
import '../../../../widget/svg/svg.dart';
import '../../../../widget/text_field.dart';
import '../../widget/centered_table.dart';
import '../../widget/field_button.dart';
import '../../widget/rectangle_button.dart';
import '/domain/model/country.dart';
import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/block.dart';
import '/ui/page/home/widget/country_button.dart';
import '/ui/widget/line_divider.dart';
import 'controller.dart';
import 'usdt_network/view.dart';
import 'widget/checkbox_button.dart';
import 'widget/uploadable_passport.dart';

/// View for the [Routes.withdraw] page.
class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: WithdrawController(Get.find()),
      builder: (WithdrawController c) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text('label_order_payment'.l10n),
            leading: const [SizedBox(width: 4), StyledBackButton()],
          ),
          body: ListView(
            children: [
              Obx(() {
                final IsoCode? country = c.country.value;

                return Block(
                  title: 'label_withdrawal_option'.l10n,
                  children: [
                    LineDivider('label_select_billing_country'.l10n),
                    const SizedBox(height: 20),
                    CountryFlag(
                      country: c.country.value,
                      onCode: c.selectCountry,
                    ),
                    const SizedBox(height: 24),
                    LineDivider('label_select_withdrawal_option'.l10n),
                    if (country != null) ...[
                      const SizedBox(height: 16),
                      ...WithdrawalOption.values.map((e) {
                        return Obx(() {
                          final bool selected = c.option.value == e;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: RectangleButton(
                              selected: selected,
                              onPressed: selected
                                  ? null
                                  : () {
                                      c.option.value = e;
                                    },
                              label: e.l10n.l10n,
                              subtitle: switch (e) {
                                .usdt => 'label_commission_from_value'.l10nfmt({
                                  'value': Price.usdt(0.0001).l10n,
                                }),
                                .paypal => 'label_commission_value'.l10nfmt({
                                  'value': '0%',
                                }),
                                .monobank => 'label_commission_value'.l10nfmt({
                                  'value': Price.eur(0.25).l10n,
                                }),
                                .sepa => 'label_commission_value'.l10nfmt({
                                  'value': Price.eur(7).l10n,
                                }),
                              },
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: style.colors.background,
                                ),
                                width: 37,
                                height: 37,
                                child: Center(child: SvgIcon(e.icon)),
                              ),
                            ),
                          );
                        });
                      }),
                    ],
                  ],
                );
              }),
              Obx(() {
                final WithdrawalOption? option = c.option.value;
                if (option == null) {
                  return const SizedBox();
                }

                return _information(context, c, option);
              }),
              Obx(() {
                final WithdrawalOption? option = c.option.value;
                if (option == null) {
                  return const SizedBox();
                }

                return _details(context, c, option);
              }),
              Obx(() {
                final WithdrawalOption? option = c.option.value;
                if (option == null) {
                  return const SizedBox();
                }

                return _beneficiary(context, c, option);
              }),
              Obx(() {
                final WithdrawalOption? option = c.option.value;
                if (option == null) {
                  return const SizedBox();
                }

                return _order(context, c);
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _information(
    BuildContext context,
    WithdrawController c,
    WithdrawalOption option,
  ) {
    final style = Theme.of(context).style;

    switch (option) {
      case .usdt:
        return Obx(() {
          final UsdtNetwork? network = c.usdtNetwork.value;

          final String? title = switch (network) {
            .arbitrumOne => 'label_usdt_arbitrum_one'.l10n,
            .optimism => 'label_usdt_optimism'.l10n,
            .plasma => 'label_usdt_plasma'.l10n,
            .polygon => 'label_usdt_polygon'.l10n,
            .solana => 'label_usdt_solana'.l10n,
            .ton => 'label_usdt_ton'.l10n,
            .tron => 'label_usdt_tron'.l10n,
            null => null,
          };

          return Block(
            title: title ?? option.l10n.l10n,
            children: [
              SvgIcon(switch (network) {
                .arbitrumOne => SvgIcons.withdrawInfoTetherArbitrum,
                .optimism => SvgIcons.withdrawInfoTetherOptimism,
                .plasma => SvgIcons.withdrawInfoTetherPlasma,
                .polygon => SvgIcons.withdrawInfoTetherPolygon,
                .solana => SvgIcons.withdrawInfoTetherSolana,
                .ton => SvgIcons.withdrawInfoTetherTon,
                .tron => SvgIcons.withdrawInfoTetherTron,
                null => SvgIcons.withdrawInfoTether,
              }),
              const SizedBox(height: 24),
              FieldButton(
                onPressed: () async {
                  final network = await UsdtNetworkView.show(context);
                  if (network is UsdtNetwork) {
                    c.usdtNetwork.value = network;
                  }
                },
                headline: Text('label_network_type'.l10n),
                child: Text(
                  title ?? 'btn_select_network_type'.l10n,
                  style: style.fonts.normal.regular.primary,
                ),
              ),
              const SizedBox(height: 8),
              if (network != null) ...[
                const SizedBox(height: 8),
                CenteredTable(
                  children: [
                    CenteredRow(
                      Text('label_commission'.l10n),
                      Text(
                        'label_up_to_amount_usdt'.l10nfmt({'amount': '0.10'}),
                      ),
                    ),
                    CenteredRow(
                      Text('label_minimum_amount'.l10n),
                      Text(Price.g(10).l10n),
                    ),
                    CenteredRow(
                      Text('label_processing_time'.l10n),
                      Text('label_n_business_days'.l10nfmt({'n': 3})),
                    ),
                  ],
                ),
              ],
            ],
          );
        });

      case .paypal:
        return Block();

      case .monobank:
        return Block();

      case .sepa:
        return Block();
    }
  }

  Widget _details(
    BuildContext context,
    WithdrawController c,
    WithdrawalOption option,
  ) {
    final style = Theme.of(context).style;

    switch (option) {
      case .usdt:
        return Block(
          title: 'label_details'.l10n,
          children: [
            Text(
              'label_amount_sent_depends_on_crypto_exchange_platform'.l10n,
              style: style.fonts.small.regular.secondary,
            ),
            const SizedBox(height: 16),
            ReactiveTextField(
              state: c.amountToWithdraw,
              label: 'label_amount_to_withdraw_currency'.l10nfmt({
                'currency': Currency('G').l10n,
              }),
              hint: 'label_available_semicolon_amount'.l10nfmt({
                'amount': Price.zero.l10n,
              }),
              floatingLabelBehavior: .always,
            ),
            const SizedBox(height: 16),
            ReactiveTextField(
              state: c.amountToSend,
              label: 'label_amount_to_be_sent_approximate_currency'.l10nfmt({
                'currency': 'USDT',
              }),
              floatingLabelBehavior: .always,
            ),
            const SizedBox(height: 16),
            ReactiveTextField(
              state: c.usdtWallet,
              label: 'label_usdt_wallet_number'.l10n,
              hint: 'label_usdt_wallet_number_example'.l10n,
              floatingLabelBehavior: .always,
            ),
            const SizedBox(height: 16),
            ReactiveTextField(
              state: c.usdtMemo,
              label: 'label_usdt_tag_memo_etc'.l10n,
              hint: 'label_usdt_tag_memo_etc_example'.l10n,
              floatingLabelBehavior: .always,
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'label_in_case_crypto_platform_no_identifier1'.l10n,
                  ),
                  TextSpan(
                    text: 'label_in_case_crypto_platform_no_identifier2'.l10n,
                    style: style.fonts.small.regular.onBackground,
                  ),
                  TextSpan(
                    text: 'label_in_case_crypto_platform_no_identifier3'.l10n,
                  ),
                ],
              ),
              style: style.fonts.small.regular.secondary,
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            ReactiveTextField(
              state: c.usdtPlatform,
              label: 'label_usdt_crypto_exchange_platform'.l10n,
              hint: 'label_usdt_crypto_exchange_platform_example'.l10n,
              floatingLabelBehavior: .always,
            ),
            const SizedBox(height: 8),
          ],
        );

      case .paypal:
        return Block(
          title: 'label_details'.l10n,
          children: [
            //
          ],
        );

      case .monobank:
        return Block(
          title: 'label_details'.l10n,
          children: [
            //
          ],
        );

      case .sepa:
        return Block(
          title: 'label_details'.l10n,
          children: [
            //
          ],
        );
    }
  }

  Widget _beneficiary(
    BuildContext context,
    WithdrawController c,
    WithdrawalOption option,
  ) {
    final style = Theme.of(context).style;

    return Block(
      title: 'label_beneficiary'.l10n,
      crossAxisAlignment: .start,
      children: [
        Text(
          'label_beneficiary_data_is_required_description'.l10n,
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 24),
        LineDivider('label_identification'.l10n),
        const SizedBox(height: 20),
        Text(
          'label_to_confirm_identity_upload_photo'.l10n,
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 16),
        Text(
          'label_important_semicolon'.l10n,
          style: style.fonts.small.regular.onBackground,
        ),
        Text(
          'label_identification_requirements_description'.l10n,
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 16),
        Obx(() {
          return UploadablePassport(
            file: c.passport.value,
            onPressed: c.pickPassport,
            blurred: !c.showPassport.value,
            onUnblur: () => c.showPassport.value = false,
          );
        }),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.passportExpiry,
          label: 'label_date_of_expiry'.l10n,
          hint: 'label_date_of_expiry_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_date_of_expiry_in_format1'.l10n),
              TextSpan(
                text: 'label_date_of_expiry_in_format2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_date_of_expiry_in_format3'.l10n),
              TextSpan(text: 'label_date_of_expiry_in_format4'.l10n),
              TextSpan(text: 'label_date_of_expiry_in_format5'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 24),
        LineDivider('label_billing_details'.l10n),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_billing_all_fields_are_latin1'.l10n),
              TextSpan(
                text: 'label_billing_all_fields_are_latin2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_billing_all_fields_are_latin3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingName,
          label: 'label_full_name'.l10n,
          hint: 'label_full_name_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingBirth,
          label: 'label_date_of_birth'.l10n,
          hint: 'label_date_of_birth_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_date_of_birth_in_format1'.l10n),
              TextSpan(
                text: 'label_date_of_birth_in_format2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_date_of_birth_in_format3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        const SizedBox(height: 16),
        CountryButton(country: c.country.value),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingAddress,
          label: 'label_address'.l10n,
          hint: 'label_address_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingZip,
          label: 'label_zip'.l10n,
          hint: 'label_zip_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingEmail,
          label: 'label_email'.l10n,
          hint: 'label_email_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
        ReactiveTextField(
          state: c.billingPhone,
          label: 'label_phone_number'.l10n,
          hint: 'label_phone_number_example'.l10n,
          floatingLabelBehavior: .always,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _order(BuildContext context, WithdrawController c) {
    final style = Theme.of(context).style;

    return Block(
      children: [
        Obx(() {
          return CheckboxButton.rich(
            span: TextSpan(
              children: [
                TextSpan(
                  text:
                      'label_i_confirm_withdraw_details_are_correct_and_i_accept1'
                          .l10n,
                ),
                TextSpan(
                  text:
                      'label_i_confirm_withdraw_details_are_correct_and_i_accept2'
                          .l10n,
                  style: style.fonts.small.regular.primary,
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                TextSpan(
                  text:
                      'label_i_confirm_withdraw_details_are_correct_and_i_accept3'
                          .l10n,
                ),
              ],
              style: style.fonts.small.regular.secondary,
            ),
            value: c.confirmed.value,
            onPressed: (e) => c.confirmed.value = e,
          );
        }),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        PrimaryButton(onPressed: null, title: 'btn_order'),
      ],
    );
  }
}
