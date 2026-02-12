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

import '../../../../../../util/platform_utils.dart';
import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/widget/operation.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/primary_button.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/widget_button.dart';
import 'controller.dart';

/// View for creating a [OperationDeposit] with PayPal.
class PayPalDepositView extends StatelessWidget {
  const PayPalDepositView({
    super.key,
    required this.method,
    required this.country,
    required this.nominal,
    this.id,
  });

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// [OperationId] of an [OperationDeposit] already existing, if any.
  final OperationId? id;

  /// Displays an [PayPalDepositView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(
    BuildContext context, {
    required OperationDepositMethod method,
    required CountryCode country,
    required Price nominal,
    OperationId? id,
  }) {
    return ModalPopup.show(
      context: context,
      mobilePadding: EdgeInsets.zero,
      desktopPadding: EdgeInsets.zero,
      child: PayPalDepositView(
        country: country,
        method: method,
        nominal: nominal,
        id: id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: PayPalDepositController(
        Get.find(),
        country: country,
        method: method,
        nominal: nominal,
        id: id,
      ),
      builder: (PayPalDepositController c) {
        final String currency = switch (nominal.sum.val) {
          <= 5 => '5',
          <= 10 => '10',
          <= 25 => '25',
          <= 50 => '50',
          <= 75 => '75',
          (_) => '100',
        };

        final Widget header = SizedBox(
          height: 150,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: SvgImage.asset(
                  'assets/images/currency/$currency.svg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Text(
                  nominal.l10next(digits: 0),
                  style: style.fonts.largest.bold.onPrimary.copyWith(
                    fontSize: 64,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.4).round()),
                        offset: Offset(3.5, 1.75),
                        blurRadius: 0,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                ),
              ),

              if (!context.isMobile)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: WidgetButton(
                      onPressed: Navigator.of(context).pop,
                      child: SvgIcon(SvgIcons.closeSmallPrimary),
                    ),
                  ),
                ),
            ],
          ),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: ModalPopup.padding(context),
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'label_top_up_by_paypal'.l10n,
                    style: style.fonts.big.regular.onBackground,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  LineDivider('label_transaction'.l10n),
                  const SizedBox(height: 20),
                  Obx(() {
                    final Operation? operation = c.operation.value?.value;

                    if (operation != null) {
                      return OperationWidget(operation);
                    }

                    return OperationWidget(
                      OperationDeposit(
                        amount: nominal,
                        id: OperationId.local(),
                        num: OperationNum(BigInt.zero),
                        createdAt: PreciseDateTime.now(),
                        billingCountry: CountryCode(''),
                        origin: OperationOrigin.purse,
                        direction: OperationDirection.incoming,
                        status: OperationStatus.inProgress,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Obx(() {
                    final List<Widget> children;

                    switch (c.status.value) {
                      case PayPalDepositStatus.initial:
                        children = [
                          Text(
                            'label_paypal_popup_window_instruction'.l10n,
                            style: style.fonts.small.regular.secondary,
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            title: 'btn_proceed'.l10n,
                            onPressed: c.operationStatus.value.isLoading
                                ? null
                                : c.createDeposit,
                          ),
                        ];
                        break;

                      case PayPalDepositStatus.inProgress:
                        final String text;

                        if (c.error.value != null) {
                          text = c.error.value!;
                        } else {
                          switch (c.operation.value?.value.status) {
                            case OperationStatus.canceled:
                              text = 'label_operation_canceled'.l10n;
                              break;

                            case OperationStatus.completed:
                              text = 'label_operation_completed'.l10n;
                              break;

                            case OperationStatus.declined:
                              text = 'label_operation_label_interrupted'.l10n;
                              break;

                            case OperationStatus.failed:
                              text = 'label_data_transfer_error'.l10n;
                              break;

                            case OperationStatus.inProgress:
                              if (c.responseSeconds.value == 0) {
                                text =
                                    'label_operation_label_cannot_processed_automatically'
                                        .l10n;
                              } else if (c.responseSeconds.value != 0) {
                                text =
                                    'label_operation_label_waiting_for_paypal'
                                        .l10nfmt({
                                          'seconds': c.responseSeconds.value,
                                        });
                              } else {
                                text = 'label_operation_label_in_progress'.l10n;
                              }

                              break;

                            case OperationStatus.artemisUnknown || null:
                              text = 'label_unknown'.l10n;
                              break;
                          }
                        }

                        children = [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              text,
                              style: style.fonts.small.regular.onBackground,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'label_paypal_in_progress_bottom_description'.l10n,
                            style: style.fonts.small.regular.secondary,
                          ),
                          if (c.error.value != null ||
                              c.operation.value?.value.status !=
                                  OperationStatus.inProgress) ...[
                            const SizedBox(height: 20),
                            PrimaryButton(
                              title: 'btn_ok'.l10n,
                              onPressed: Navigator.of(context).pop,
                            ),
                          ],
                        ];
                        break;
                    }

                    return AnimatedSizeAndFade(
                      fadeDuration: const Duration(milliseconds: 250),
                      sizeDuration: const Duration(milliseconds: 250),
                      child: Column(
                        key: Key(c.status.value.name),
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
