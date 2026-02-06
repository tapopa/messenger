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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/tab/wallet/widget/amount_tile.dart';
import '/ui/page/home/widget/operation.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/primary_button.dart';
import '/ui/widget/progress_indicator.dart';
import '/util/log.dart';
import 'controller.dart';
import 'widget/paypal_button.dart';

/// View for creating a [OperationDeposit] with PayPal.
class PayPalDepositView extends StatelessWidget {
  const PayPalDepositView({
    super.key,
    required this.method,
    required this.country,
    required this.nominal,
  });

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// Displays an [PayPalDepositView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(
    BuildContext context, {
    required OperationDepositMethod method,
    required CountryCode country,
    required Price nominal,
  }) {
    return ModalPopup.show(
      context: context,
      child: PayPalDepositView(
        country: country,
        method: method,
        nominal: nominal,
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
      ),
      builder: (PayPalDepositController c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(text: 'label_top_up_by_paypal'.l10n),
            LineDivider(''),
            Flexible(
              child: Obx(() {
                final List<Widget> children;

                switch (c.status.value) {
                  case PayPalDepositStatus.initial:
                    children = [
                      const SizedBox(height: 16),
                      Text(
                        'label_paypal_popup_window_instruction'.l10n,
                        style: style.fonts.small.regular.secondary,
                      ),
                      const SizedBox(height: 16),
                      LineDivider(''),
                      const SizedBox(height: 16),
                      AmountTile(nominal: nominal, pricing: method.pricing),
                      const SizedBox(height: 16),
                      PayPalButton(
                        currency: 'HKD',
                        onCreateOrder: () async {
                          Log.debug('onCreateOrder()', '$runtimeType');

                          final operation = await c.createDeposit();
                          if (operation is OperationDeposit) {
                            final String? url = operation.processingUrl?.val;
                            if (url != null) {
                              return url.split('?order_id=').last;
                            }
                          }

                          return '';
                        },
                        onSuccess: () async {
                          Log.debug('onSuccess()', '$runtimeType');
                          await c.completeDeposit();
                        },
                        onCancel: () async {
                          Log.error('onCancel() ', '$runtimeType');
                          await c.declineDeposit();
                        },
                        onError: (e) async {
                          if (e.toString().contains(
                            'Document is ready and element #paypal-btn does not exist',
                          )) {
                            // No-op.
                            return;
                          }

                          Log.error('onError() -> $e', '$runtimeType');
                          c.error.value = e.toString();
                          await c.declineDeposit();
                        },
                      ),
                      const SizedBox(height: 16),
                      LineDivider('label_attention'.l10n),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'label_tapopa_will_be_grateful_for_reporting_problems_when_paying1'
                                      .l10n,
                              style: style.fonts.small.regular.primary,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                  router.support();
                                },
                            ),
                            TextSpan(
                              text:
                                  'label_tapopa_will_be_grateful_for_reporting_problems_when_paying2'
                                      .l10n,
                            ),
                          ],
                        ),
                        style: style.fonts.small.regular.secondary,
                      ),
                      const SizedBox(height: 16),
                    ];
                    break;

                  case PayPalDepositStatus.inProgress:
                    children = [
                      const SizedBox(height: 16),
                      Obx(() {
                        if (c.error.value == null) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'err_data_transfer'.l10n,
                            style: style.fonts.small.regular.onBackground,
                          ),
                        );
                      }),
                      AmountTile(nominal: nominal, pricing: method.pricing),
                      const SizedBox(height: 16),
                      LineDivider('label_transaction'.l10n),
                      const SizedBox(height: 16),
                      Obx(() {
                        final Operation? operation = c.operation.value?.value;

                        final Widget child;

                        if (operation == null) {
                          child = const SizedBox(
                            key: Key('None'),
                            width: 100,
                            height: 125,
                            child: Center(
                              child: CustomProgressIndicator.primary(),
                            ),
                          );
                        } else {
                          child = OperationWidget(operation);
                        }

                        return AnimatedSizeAndFade(
                          fadeDuration: const Duration(milliseconds: 250),
                          sizeDuration: const Duration(milliseconds: 250),
                          child: child,
                        );
                      }),
                      const SizedBox(height: 16),
                      LineDivider('label_attention'.l10n),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'label_tapopa_will_be_grateful_for_reporting_problems_when_paying1'
                                      .l10n,
                              style: style.fonts.small.regular.primary,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                  router.support();
                                },
                            ),
                            TextSpan(
                              text:
                                  'label_tapopa_will_be_grateful_for_reporting_problems_when_paying2'
                                      .l10n,
                            ),
                          ],
                        ),
                        style: style.fonts.small.regular.secondary,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        onPressed: Navigator.of(context).pop,
                        title: 'btn_ok'.l10n,
                      ),
                      const SizedBox(height: 16),
                    ];
                    break;
                }

                return AnimatedSizeAndFade(
                  fadeDuration: const Duration(milliseconds: 250),
                  sizeDuration: const Duration(milliseconds: 250),
                  child: ListView(
                    key: Key(c.status.value.name),
                    shrinkWrap: true,
                    padding: ModalPopup.padding(context),
                    children: children,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
