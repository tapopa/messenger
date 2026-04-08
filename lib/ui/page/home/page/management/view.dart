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
import 'package:share_plus/share_plus.dart';

import '../../../../../domain/model/monetization_settings.dart';
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
import '/ui/widget/context_menu/menu.dart';
import '/ui/widget/context_menu/region.dart';
import '/ui/widget/future_or_builder.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/progress_indicator.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/text_field.dart';
import '/ui/widget/widget_button.dart';
import '/util/log.dart';
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
      init: ManagementController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
      builder: (ManagementController c) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text('btn_link_management'.l10n),
            leading: const [SizedBox(width: 4), StyledBackButton()],
          ),
          body: Container(
            // padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            decoration: BoxDecoration(
              color: style.colors.onPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'btn_link_management_subtitle'.l10n,
                  textAlign: TextAlign.center,
                  style: style.fonts.big.regular.onBackground,
                ),
                const SizedBox(height: 12),
                if (context.isNarrow)
                  Flexible(child: _list(context, c))
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _table(context, c),
                    ),
                  ),
                // const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a [TableGrid] representing the [DirectLink]s.
  Widget _table(BuildContext context, ManagementController c) {
    final style = Theme.of(context).style;

    return Container(
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
          padding: EdgeInsets.fromLTRB(0, 8 + 64, 2, 8),
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
                indicateLoading: c.links.hasNext.value,
                onReorder: (a, b) {
                  Log.debug(
                    'onReorder(${a.identifier}, ${b.identifier})',
                    '$runtimeType',
                  );

                  final first = LinkColumn.values.firstWhereOrNull(
                    (e) => e.name == a.identifier,
                  );

                  final second = LinkColumn.values.firstWhereOrNull(
                    (e) => e.name == b.identifier,
                  );

                  if (first != null && second != null) {
                    int aIndex = c.headers.indexOf(first);
                    int bIndex = c.headers.indexOf(second);

                    if (aIndex != -1 && bIndex != -1) {
                      c.headers.insert(bIndex, c.headers.removeAt(aIndex));
                    }
                  }
                },
                items: c.links.values,
                builders: c.headers
                    .map((e) => _builder(context, c, e))
                    .toList(),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Builds a [TableBuilder] for the provided [column].
  TableBuilder<DirectLink> _builder(
    BuildContext context,
    ManagementController c,
    LinkColumn column,
  ) {
    final style = Theme.of(context).style;

    return switch (column) {
      LinkColumn.created => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 1.31,
        header: () => Text('label_created'.l10n),
        builder: (e) => Text(
          '${e.createdAt.val.yyMd}\n${e.createdAt.val.hms}',
          textAlign: TextAlign.center,
        ),
      ),
      LinkColumn.slug => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 8,
        header: () => Obx(() {
          return Text(
            'label_all_links_amount'.l10nfmt({'amount': c.total.value}),
          );
        }),
        builder: (e) => Text('${Config.link}${e.slug}'),
      ),
      LinkColumn.leads => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 4,
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

          return Text(
            'label_unknown'.l10n,
            style: style.fonts.small.regular.secondary,
          );
        },
      ),
      LinkColumn.percentage => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
        header: () => Text('label_promotional_percentage'.l10n),
        builder: (e) {
          if (e.isEnabled) {
            final DirectLinkLocation location = e.location;
            if (location is DirectLinkLocationUser) {
              return Obx(() {
                final Rx<MonetizationSettings>? settings =
                    c.monetization[location.responder];

                if (settings != null) {
                  return Text('${settings.value.referral?.fee?.val ?? 0}%');
                }

                return Text('---');
              });
            }
          }

          return Text('---');
        },
      ),
      LinkColumn.income => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
        header: () => Text('label_link_income'.l10n),
        builder: (e) => Text(
          (e.stats.income ?? Price.xxx(0)).l10n,
          style: style.fonts.small.regular.currencyPrimary,
        ),
      ),
      LinkColumn.clicks => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
        header: () => Text('label_unique_clicks'.l10n),
        builder: (e) => Text('${e.stats.visitors}'),
      ),
      LinkColumn.partners => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
        header: () => Text('label_partner_numbers_assigned'.l10n),
        builder: (e) => Text('${e.stats.affiliations ?? 0}'),
      ),
      LinkColumn.promotions => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
        header: () => Text('label_promotional_numbers_assigned'.l10n),
        builder: (e) => Text('${e.stats.referrals ?? 0}'),
      ),
      LinkColumn.actions => TableBuilder(
        key: c.keys[column],
        identifier: column.name,
        width: 2,
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
                    if (await _confirmUnlink(context, e)) {
                      await c.unlinkLink(e.slug);
                    }
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
    };
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

  /// Builds a [ListView] representing the [DirectLink]s.
  Widget _list(BuildContext context, ManagementController c) {
    final style = Theme.of(context).style;

    return Obx(() {
      return ListView.builder(
        controller: c.listController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: 1 + c.links.length + (c.links.hasNext.value ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: LineDivider(
                'label_links_amount'.l10nfmt({'amount': c.total.value}),
              ),
            );
          }

          --i;

          if (i == c.links.length) {
            return const Center(child: CustomProgressIndicator());
          }

          final DirectLink? link = c.links.values.elementAtOrNull(i);
          if (link == null) {
            return const SizedBox();
          }

          final String url = '${Config.link}${link.slug}';

          final Widget subtitle;

          if (!link.isEnabled) {
            subtitle = Text(
              'label_unlinked'.l10n,
              style: style.fonts.small.regular.secondary,
            );
          } else {
            final DirectLinkLocation location = link.location;

            if (location is DirectLinkLocationUser) {
              subtitle = _locationAsUser(context, c, location);
            } else {
              subtitle = Text(
                'label_unknown'.l10n,
                style: style.fonts.small.regular.secondary,
              );
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReactiveTextField.copyable(
                text: url,
                label: link.createdAt.val.yMd,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      link.isEnabled ? '0%' : '---',
                      style: style.fonts.small.regular.currencyPrimary,
                    ),
                    Text(
                      (link.stats.income ?? Price.xxx(0)).l10n,
                      style: style.fonts.small.regular.currencyPrimary,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SvgIcon(SvgIcons.linksViews),
                        const SizedBox(width: 4),
                        Text(
                          '${link.stats.visitors}',
                          style: style.fonts.small.regular.onBackground,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SvgIcon(SvgIcons.linksAffiliations),
                        const SizedBox(width: 4),
                        Text(
                          '${link.stats.affiliations ?? 0}',
                          style: style.fonts.small.regular.onBackground,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SvgIcon(SvgIcons.linksReferrals),
                        const SizedBox(width: 4),
                        Text(
                          '${link.stats.referrals ?? 0}',
                          style: style.fonts.small.regular.onBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: subtitle),
                  WidgetButton(
                    onPressed: () async {
                      if (PlatformUtils.isMobile) {
                        await SharePlus.instance.share(ShareParams(text: url));
                      }
                    },
                    onPressedWithDetails: (u) {
                      if (!PlatformUtils.isMobile) {
                        PlatformUtils.copy(text: url);
                        MessagePopup.success(
                          'label_copied'.l10n,
                          at: u.globalPosition,
                        );
                      }
                    },
                    child: Text(
                      'btn_share'.l10n,
                      style: style.fonts.small.regular.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 12,
                    decoration: BoxDecoration(
                      color: style.colors.onBackgroundOpacity13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ContextMenuRegion(
                    enableLongTap: false,
                    enableSecondaryTap: false,
                    enablePrimaryTap: true,
                    actions: [
                      ContextMenuButton(
                        onPressed: () async {
                          await QrCodeView.show(context, data: url);
                        },
                        label: 'btn_show_qr_code'.l10n,
                        trailing: SvgIcon(SvgIcons.contextQr),
                        inverted: SvgIcon(SvgIcons.contextQrWhite),
                      ),
                      ContextMenuButton(
                        onPressed: () async {
                          if (await _confirmUnlink(context, link)) {
                            await c.unlinkLink(link.slug);
                          }
                        },
                        label: 'btn_unlink'.l10n,
                        trailing: SvgIcon(SvgIcons.contextUnlink),
                        inverted: SvgIcon(SvgIcons.contextUnlinkWhite),
                      ),
                    ],
                    child: SvgIcon(SvgIcons.linksMore),
                  ),
                ],
              ),
              const SizedBox(height: 36),
            ],
          );
        },
      );
    });
  }

  /// Returns whether user agrees to unlink the provided [link] or not.
  Future<bool> _confirmUnlink(BuildContext context, DirectLink link) async {
    final style = Theme.of(context).style;
    final String url = '${Config.link}${link.slug}';

    final proceed = await MessagePopup.alert(
      'label_unlink_link'.l10n,
      additional: [
        Text(url, style: style.fonts.normal.regular.onBackground),
        const SizedBox(height: 16),
        Text(
          'label_unlink_link_confirm_description1'.l10n,
          style: style.fonts.small.regular.secondary,
        ),
      ],
      button: (context) => MessagePopup.deleteButton(
        context,
        label: 'btn_unlink'.l10n,
        icon: SvgIcons.buttonUnlink,
      ),
    );

    return proceed == true;
  }
}
