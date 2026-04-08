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

import '/domain/model/operation.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/message_field/view.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/operation.dart';
import '/ui/widget/context_menu/menu.dart';
import '/ui/widget/context_menu/region.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import 'controller.dart';

/// View of the [Routes.walletTransactions] page.
class WalletTransactionsView extends StatelessWidget {
  const WalletTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: WalletTransactionsController(Get.find(), Get.find()),
      builder: (WalletTransactionsController c) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, CustomAppBar.height),
            child: _bar(context, c),
          ),
          body: Obx(() {
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
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
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
                                (expanded && !c.ids.contains(e.value.id)) ||
                                (!expanded && c.ids.contains(e.value.id)),
                            getUser: c.getUser,
                          );
                        }),
                      ),
                    ),
                  ),
                );

                if (i == c.operations.length - 1) {
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
        );
      },
    );
  }

  /// Builds the contents of an [AppBar].
  Widget _bar(BuildContext context, WalletTransactionsController c) {
    final style = Theme.of(context).style;

    return Obx(() {
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
                    hint: 'label_search'.l10n,
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
                    label: 'btn_collapse_all'.l10n,
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
    });
  }
}
