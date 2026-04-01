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

import '/config.dart';
import '/domain/model/link.dart';
import '/domain/model/price.dart';
import '/domain/repository/user.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/back_button.dart';
import '/ui/page/home/page/my_profile/qr_code/view.dart';
import '/ui/page/home/page/user/controller.dart';
import '/ui/page/home/widget/app_bar.dart';
import '/ui/page/home/widget/avatar.dart';
import '/ui/widget/future_or_builder.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/widget_button.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';
import 'controller.dart';
import 'widget/table_grid.dart';

/// View displaying the [DirectLink]s that [MyUser] has in a [TableView].
class ManagementView extends StatelessWidget {
  const ManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return GetBuilder(
      init: ManagementController(Get.find(), Get.find(), Get.find()),
      builder: (ManagementController c) {
        final List<TableBuilder<DirectLink>> builders = [
          TableBuilder(
            width: 1,
            header: () => Text('label_created'.l10n),
            builder: (e) =>
                Text(e.createdAt.val.yMdHm, textAlign: TextAlign.center),
          ),
          TableBuilder(
            width: 4,
            header: () => Text(
              'label_all_links_amount'.l10nfmt({'amount': c.links.length}),
            ),
            builder: (e) => Text('${Config.link}${e.slug}'),
          ),
          TableBuilder(
            width: 2,
            header: () => Text('label_leads_to'.l10n),
            builder: (e) {
              if (!e.isEnabled) {
                return Text(
                  'label_unlinked'.l10n,
                  style: style.fonts.small.regular.secondary,
                );
              }

              final DirectLinkLocation location = e.location;

              if (location is DirectLinkLocationUser) {
                return _locationAsUser(context, c, location);
              }

              return Text('label_unknown'.l10n);
            },
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_promotional_percentage'.l10n),
            builder: (e) => Text('0%'),
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_link_income'.l10n),
            builder: (e) => Text(
              Price.xxx(0).l10n,
              style: style.fonts.small.regular.currencyPrimary,
            ),
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_unique_clicks'.l10n),
            builder: (e) => Text('${e.visitors}'),
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_partner_numbers_assigned'.l10n),
            builder: (e) => Text('0'),
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_promotional_numbers_assigned'.l10n),
            builder: (e) => Text('0'),
          ),
          TableBuilder(
            width: 1,
            header: () => Text('label_actions'.l10n),
            builder: (e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WidgetButton(
                    onPressed: () {},
                    onPressedWithDetails: (u) {
                      PlatformUtils.copy(text: '${Config.link}${e.slug}');
                      MessagePopup.success(
                        'label_copied'.l10n,
                        at: u.globalPosition,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgIcon(SvgIcons.actionCopy),
                    ),
                  ),

                  WidgetButton(
                    onPressed: () async {
                      await QrCodeView.show(
                        context,
                        data: '${Config.link}${e.slug}',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgIcon(SvgIcons.actionQr),
                    ),
                  ),

                  if (e.isEnabled)
                    WidgetButton(
                      onPressed: () async {
                        await c.unlinkLink(e.slug);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgIcon(SvgIcons.actionUnlink),
                      ),
                    ),
                ],
              );
            },
          ),
        ];

        return Scaffold(
          appBar: CustomAppBar(
            title: Text('btn_link_management'.l10n),
            leading: const [SizedBox(width: 4), StyledBackButton()],
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            decoration: BoxDecoration(
              color: style.colors.onPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'btn_link_management_subtitle'.l10n,
                  textAlign: TextAlign.center,
                  style: style.fonts.big.regular.onBackground,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: style.colors.secondaryHighlightDark,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: RawScrollbar(
                      interactive: true,
                      radius: Radius.circular(12),
                      thickness: 6,
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 2),
                      controller: c.horizontal,
                      child: RawScrollbar(
                        interactive: true,
                        radius: Radius.circular(12),
                        thickness: 6,
                        padding: EdgeInsets.fromLTRB(0, 8, 2, 8),
                        controller: c.vertical,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Obx(() {
                            return TableGrid<DirectLink>(
                              horizontalDetails: ScrollableDetails.horizontal(
                                controller: c.horizontal,
                              ),
                              verticalDetails: ScrollableDetails.vertical(
                                controller: c.vertical,
                              ),
                              items: c.links.values,
                              builders: builders,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the [DirectLinkLocationUser] visually.
  Widget _locationAsUser(
    BuildContext context,
    ManagementController c,
    DirectLinkLocationUser location,
  ) {
    final style = Theme.of(context).style;

    return FutureOrBuilder<RxUser?>(
      futureOr: () => c.getUser(location.responder),
      builder: (_, user) => Obx(() {
        if (user == null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarWidget(radius: AvatarRadius.smaller),
              const SizedBox(width: 3),
              Flexible(child: Text('dot'.l10n * 3)),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget.fromRxUser(user, radius: AvatarRadius.smaller),
            const SizedBox(width: 3),
            Flexible(
              child: SelectionContainer.disabled(
                child: WidgetButton(
                  onPressed: () {
                    if (user.id == c.me) {
                      return router.me();
                    }

                    router.user(user.id, push: true);
                  },
                  child: Text(
                    user.title(),
                    style: style.fonts.small.regular.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
