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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/message_field/view.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/widget/animated_button.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import 'controller.dart';

class WalletTransactionsView extends StatelessWidget {
  const WalletTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: WalletTransactionsController(),
      builder: (WalletTransactionsController c) {
        return Scaffold(
          appBar: CustomAppBar(
            leading: const [SizedBox(width: 4), StyledBackButton()],
            actions: [
              AnimatedButton(
                onPressed: () {
                  c.expanded.toggle();
                  c.ids.clear();
                },
                decorator: (child) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                  child: Obx(() {
                    return SvgIcon(
                      c.expanded.value ? SvgIcons.viewFull : SvgIcons.viewShort,
                    );
                  }),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (_) {
              final List<Widget> children = [];

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: [
                        const SizedBox(height: 8),
                        ...children,
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  _search(context, c),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _search(BuildContext context, WalletTransactionsController c) {
    final style = Theme.of(context).style;

    return Container(
      decoration: BoxDecoration(
        color: style.cardColor,
        boxShadow: [
          CustomBoxShadow(
            blurRadius: 8,
            color: style.colors.onBackgroundOpacity13,
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 57),

      child: Row(
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
                  c.query.value = c.search.text.isEmpty ? null : c.search.text;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
