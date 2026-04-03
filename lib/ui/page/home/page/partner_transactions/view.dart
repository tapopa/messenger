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

import '/domain/model/balance.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/message_field/view.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/operation.dart';
import '/ui/widget/context_menu/menu.dart';
import '/ui/widget/context_menu/region.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import 'controller.dart';

/// View of the [Routes.partnerTransactions] page.
class PartnerTransactionsView extends StatelessWidget {
  const PartnerTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: PartnerTransactionsController(Get.find(), Get.find()),
      builder: (PartnerTransactionsController c) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, CustomAppBar.height),
            child: Obx(() {
              final Widget child;

              if (c.searching.value) {
                child = CustomAppBar(
                  key: const Key('Search'),
                  border: Border.all(color: style.colors.primary, width: 2),
                  title: Row(
                    children: [
                      const SizedBox(width: 16),
                      const SvgIcon(SvgIcons.search),
                      Expanded(
                        child: Theme(
                          data: MessageFieldView.theme(context),
                          child: ReactiveTextField(
                            dense: true,
                            state: c.search,
                            hint: 'label_search_dots'.l10n,
                            style: style.fonts.medium.regular.onBackground,
                            onChanged: () {
                              c.query.value = c.search.text.isEmpty
                                  ? null
                                  : c.search.text;
                            },
                          ),
                        ),
                      ),
                      WidgetButton(
                        onPressed: c.toggleSearch,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                          child: const SvgIcon(SvgIcons.closePrimary),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                child = CustomAppBar(
                  leading: const [SizedBox(width: 4), StyledBackButton()],
                  title: Text('label_your_transactions'.l10n),
                  actions: [
                    ContextMenuRegion(
                      enablePrimaryTap: true,
                      enableLongTap: false,
                      enableSecondaryTap: false,
                      actions: [
                        if (c.expanded.value)
                          ContextMenuButton(
                            label: 'btn_shrink_all'.l10n,
                            trailing: SvgIcon(SvgIcons.viewFull),
                            inverted: SvgIcon(SvgIcons.viewFullWhite),
                            onPressed: () {
                              c.expanded.toggle();
                              c.ids.clear();
                            },
                          )
                        else
                          ContextMenuButton(
                            label: 'btn_expand_all'.l10n,
                            trailing: SvgIcon(SvgIcons.viewShort),
                            inverted: SvgIcon(SvgIcons.viewShortWhite),
                            onPressed: () {
                              c.expanded.toggle();
                              c.ids.clear();
                            },
                          ),
                        ContextMenuButton(
                          label: 'btn_search'.l10n,
                          trailing: SvgIcon(SvgIcons.search),
                          inverted: SvgIcon(SvgIcons.searchWhite),
                          onPressed: c.toggleSearch,
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
                        child: SvgIcon(SvgIcons.more),
                      ),
                    ),
                  ],
                );
              }

              return AnimatedSizeAndFade(
                fadeDuration: const Duration(milliseconds: 250),
                sizeDuration: const Duration(milliseconds: 250),
                child: child,
              );
            }),
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  Iterable<Rx<Operation>> filtered = c.operations.values;

                  final String? query = c.query.value;

                  if (query != null && query.isNotEmpty) {
                    filtered = filtered.where((e) {
                      final Operation operation = e.value;

                      return query.contains(operation.id.val) ||
                          query.contains(operation.num.toString());
                    });
                  }

                  return ListView.builder(
                    controller: c.scrollController,
                    itemCount: 1 + filtered.length,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                              child: _information(context, c),
                            ),
                          ),
                        );
                      }

                      --i;

                      final Rx<Operation> e = filtered.elementAt(i);

                      final Widget child = Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                            child: WidgetButton(
                              onPressed: () {
                                if (c.ids.contains(e.value.id)) {
                                  c.ids.remove(e.value.id);
                                } else {
                                  c.ids.add(e.value.id);
                                }
                              },
                              child: Obx(() {
                                final bool expanded = c.expanded.value;

                                return OperationWidget(
                                  e.value,
                                  expanded:
                                      (expanded &&
                                          !c.ids.contains(e.value.id)) ||
                                      (!expanded && c.ids.contains(e.value.id)),
                                  getUser: c.getUser,
                                );
                              }),
                            ),
                          ),
                        ),
                      );

                      if (i == filtered.length - 1) {
                        return Column(
                          children: [
                            if (c.hasNext.value) ...[
                              const SizedBox(height: 8),
                              const CustomProgressIndicator.small(),
                              const SizedBox(height: 8),
                            ],
                            child,
                          ],
                        );
                      }

                      return child;
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns [Container] displaying available and hold [Balance]s.
  Widget _information(BuildContext context, PartnerTransactionsController c) {
    final style = Theme.of(context).style;

    return Container(
      decoration: BoxDecoration(
        borderRadius: style.cardRadius,
        border: Border.all(color: style.colors.primary),
        color: style.colors.onPrimary,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Obx(() {
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'label_total_balance_amount1'.l10n,
                    style: style.fonts.big.regular.secondary,
                  ),
                  TextSpan(
                    text: 'label_total_balance_amount2'.l10nfmt({
                      'amount': Balance(
                        currency: c.available.value.currency,
                        sum: Sum(
                          c.available.value.sum.val + c.hold.value.sum.val,
                        ),
                      ).l10n,
                    }),
                    style: style.fonts.big.regular.primary,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          LineDivider('label_information'.l10n),
          const SizedBox(height: 16),
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [_hold(context, c), _available(context, c)],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Returns a [TableRow] styled to build [label] and [child].
  TableRow _row(BuildContext context, String label, Widget child) {
    final style = Theme.of(context).style;

    return TableRow(
      children: [
        Text(
          label,
          style: style.fonts.normal.regular.secondary,
          textAlign: TextAlign.right,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DefaultTextStyle(
              style: style.fonts.normal.regular.secondary.copyWith(
                color: style.colors.secondaryBackgroundLight,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a [TableRow] describing the [Balance] in hold.
  TableRow _hold(BuildContext context, PartnerTransactionsController c) {
    final style = Theme.of(context).style;

    return _row(
      context,
      'label_hold'.l10n,
      Obx(() {
        return Text(
          c.hold.value.l10n,
          style: style.fonts.normal.bold.currencySecondary,
        );
      }),
    );
  }

  /// Returns a [TableRow] describing the available [Balance].
  TableRow _available(BuildContext context, PartnerTransactionsController c) {
    final style = Theme.of(context).style;

    return _row(
      context,
      'label_available'.l10n,
      Obx(() {
        return Text(
          c.available.value.l10n,
          style: style.fonts.normal.bold.currencyPrimary,
        );
      }),
    );
  }
}
