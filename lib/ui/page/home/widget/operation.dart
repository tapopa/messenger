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

import 'dart:async';
import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '/api/backend/schema.graphql.dart';
import '/domain/model/operation.dart';
import '/domain/model/user.dart';
import '/domain/repository/user.dart';
import '/l10n/l10n.dart';
import '/routes.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/message_info/view.dart';
import '/ui/page/home/page/user/controller.dart';
import '/ui/widget/future_or_builder.dart';
import '/ui/widget/line_divider.dart';
import '/ui/widget/svg/svgs.dart';
import '/ui/widget/widget_button.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';
import 'avatar.dart';

/// Widget displaying the provided [Operation] visually.
class OperationWidget extends StatelessWidget {
  const OperationWidget(
    this.operation, {
    super.key,
    this.expanded = true,
    this.getUser,
  });

  /// [Operation] itself.
  final Operation operation;

  /// Indicator whether the details of [operation] should be displayed.
  final bool expanded;

  /// Callback, called when a [RxUser] identified by the provided [UserId] is
  /// required.
  final FutureOr<RxUser?> Function(UserId userId)? getUser;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Container(
      decoration: BoxDecoration(
        borderRadius: style.cardRadius,
        border: style.cardBorder,
        color: style.colors.onPrimary,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: _content(context, operation, expanded: expanded),
    );
  }

  /// Contents of the provided [operation] in [expanded] or not state.
  Widget _content(
    BuildContext context,
    Operation operation, {
    bool expanded = false,
  }) {
    final style = Theme.of(context).style;

    final bool positive = switch (operation.direction) {
      OperationDirection.outgoing => false,
      OperationDirection.incoming => true,
      OperationDirection.artemisUnknown => true,
    };

    final List<Widget> more;

    switch (operation.runtimeType) {
      case const (OperationDeposit):
        operation as OperationDeposit;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(context, 'label_details'.l10n, switch (operation.kind) {
                OperationDepositKind.paypal => Text('label_top_up_paypal'.l10n),
                OperationDepositKind.artemisUnknown => Text(
                  'label_unknown'.l10n,
                ),
              }),
            ],
          ),

          if (operation.invoice != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: WidgetButton(
                onPressed: () async {
                  final file = await PlatformUtils.createAndDownload(
                    'invoice_${operation.num.val}.pdf',
                    base64.decode(operation.invoice!.val),
                  );

                  if (file != null && PlatformUtils.isMobile) {
                    await SharePlus.instance.share(
                      ShareParams(files: [XFile(file.path)]),
                    );
                  }
                },
                child: Text(
                  'btn_invoice'.l10n,
                  style: style.fonts.small.regular.primary,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 8),
        ];
        break;

      case const (OperationDepositBonus):
        operation as OperationDepositBonus;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(
                context,
                'label_details'.l10n,
                Text(
                  'label_top_up_bonus_with_id'.l10nfmt({
                    'id': operation.depositId.val,
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationCharge):
        operation as OperationCharge;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(context, 'label_details'.l10n, Text('${operation.reason}')),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationGrant):
        operation as OperationGrant;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(context, 'label_details'.l10n, Text('${operation.reason}')),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationDividend):
        operation as OperationDividend;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(
                context,
                'label_details'.l10n,
                Text('${operation.sourceId}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationReward):
        operation as OperationReward;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(
                context,
                'label_author'.l10n,
                Text('${operation.affiliatedNum}'),
              ),
              _row(context, 'label_details'.l10n, Text(operation.cause.name)),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationEarnDonation):
        operation as OperationEarnDonation;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(
                context,
                'label_author'.l10n,
                FutureOrBuilder<RxUser?>(
                  key: Key('${operation.id}_${operation.customerId}'),
                  futureOr: () => getUser?.call(operation.customerId),
                  builder: (context, user) {
                    if (user == null) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarWidget(radius: AvatarRadius.smaller),
                          const SizedBox(width: 3),
                          Flexible(child: Text('dot'.l10n * 3)),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarWidget.fromRxUser(
                          user,
                          radius: AvatarRadius.smaller,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: WidgetButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              router.user(user.id, push: true);
                            },
                            child: Text(
                              user.title(),
                              style: style.fonts.normal.regular.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _row(
                context,
                'label_details'.l10n,
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Donation. '),
                      TextSpan(
                        text: 'ID_${operation.chatItemId}',
                        style: style.fonts.normal.regular.primary,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final chatItemId = operation.chatItemId;
                            if (chatItemId != null) {
                              MessageInfo.show(context, chatItemId);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      case const (OperationPurchaseDonation):
        operation as OperationPurchaseDonation;

        more = [
          Table(
            columnWidths: {0: FlexColumnWidth(11), 1: FlexColumnWidth(20)},
            children: [
              _status(context, operation),
              _id(context, operation),
              _row(
                context,
                'label_author'.l10n,
                FutureOrBuilder<RxUser?>(
                  key: Key('${operation.id}_${operation.vendorId}'),
                  futureOr: () => getUser?.call(operation.vendorId),
                  builder: (context, user) {
                    if (user == null) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarWidget(radius: AvatarRadius.smaller),
                          const SizedBox(width: 3),
                          Flexible(child: Text('dot'.l10n * 3)),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarWidget.fromRxUser(
                          user,
                          radius: AvatarRadius.smaller,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: WidgetButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              router.user(user.id, push: true);
                            },
                            child: Text(
                              user.title(),
                              style: style.fonts.normal.regular.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _row(
                context,
                'label_details'.l10n,
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Donation. '),
                      TextSpan(
                        text: 'ID_${operation.chatItemId}',
                        style: style.fonts.normal.regular.primary,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final chatItemId = operation.chatItemId;
                            if (chatItemId != null) {
                              MessageInfo.show(context, chatItemId);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ];
        break;

      default:
        more = [];
        break;
    }

    final String primaryText =
        '${positive ? '+' : '-'}${operation.amount.l10n}';
    final TextStyle primaryStyle = style.fonts.big.regular.onBackground
        .copyWith(
          fontWeight: FontWeight.bold,
          color: switch (operation.direction) {
            OperationDirection.incoming => switch (operation.status) {
              OperationStatus.completed => style.colors.currencyPrimary,
              OperationStatus.inProgress => style.colors.currencySecondary,
              OperationStatus.failed => style.colors.currencySecondary,
              OperationStatus.declined => style.colors.currencySecondary,
              OperationStatus.canceled => style.colors.currencySecondary,
              OperationStatus.artemisUnknown => style.colors.secondary,
            },
            OperationDirection.outgoing => switch (operation.status) {
              OperationStatus.completed => style.colors.onBackground,
              OperationStatus.inProgress => style.colors.secondary,
              OperationStatus.failed => style.colors.secondary,
              OperationStatus.declined => style.colors.secondary,
              OperationStatus.canceled => style.colors.secondary,
              OperationStatus.artemisUnknown => style.colors.secondary,
            },
            OperationDirection.artemisUnknown => style.colors.currencyPrimary,
          },
        );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: primaryText, style: primaryStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(primaryText, style: primaryStyle),
                  ),

                  if (operation.status == OperationStatus.failed ||
                      operation.status == OperationStatus.canceled ||
                      operation.status == OperationStatus.declined)
                    Positioned(
                      left: 0,
                      top: 1,
                      bottom: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 2,
                          width: textPainter.size.width + 10,
                          color: style.colors.secondaryBackgroundLightest,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Text(
              operation.id.isLocal
                  ? 'label_waiting_dots'.l10n
                  : '${operation.createdAt.val.toLocal().yMd} ${operation.createdAt.val.toLocal().hms}',
              style: style.fonts.smaller.regular.secondary,
            ),
            const SizedBox(width: 8),
            SvgIcon(switch (operation.status) {
              OperationStatus.completed => SvgIcons.operationDone,
              OperationStatus.inProgress => SvgIcons.operationSending,
              OperationStatus.failed => SvgIcons.operationCanceled,
              OperationStatus.declined => SvgIcons.operationCanceled,
              OperationStatus.canceled => SvgIcons.operationCanceled,
              OperationStatus.artemisUnknown => SvgIcons.operationCanceled,
            }),
          ],
        ),
        AnimatedSizeAndFade(
          fadeDuration: const Duration(milliseconds: 250),
          sizeDuration: const Duration(milliseconds: 250),
          child: expanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    LineDivider('label_information'.l10n),
                    const SizedBox(height: 8),
                    ...more,
                  ],
                )
              : const SizedBox(
                  key: Key('None'),
                  width: double.infinity,
                  height: 8,
                ),
        ),
        SizedBox(height: 8),
      ],
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

  /// Returns a [TableRow] describing the status of [operation].
  TableRow _status(BuildContext context, Operation operation) {
    final style = Theme.of(context).style;

    if (operation.id.isLocal) {
      return _row(
        context,
        'label_status'.l10n,
        Text('label_waiting_dots'.l10n),
      );
    }

    return _row(context, 'label_status'.l10n, switch (operation.status) {
      OperationStatus.completed => Text('label_operation_completed'.l10n),
      OperationStatus.inProgress => Text('label_operation_in_progress'.l10n),
      OperationStatus.failed => Text(
        'label_operation_failed'.l10n,
        style: style.fonts.normal.regular.secondary,
      ),
      OperationStatus.canceled => Text(
        'label_operation_canceled'.l10n,
        style: style.fonts.normal.regular.secondary,
      ),
      OperationStatus.declined => Text(
        'label_operation_declined'.l10n,
        style: style.fonts.normal.regular.secondary,
      ),
      OperationStatus.artemisUnknown => Text('label_unknown'.l10n),
    });
  }

  /// Returns a [TableRow] describing the ID of [operation].
  TableRow _id(BuildContext context, Operation operation) {
    if (operation.id.isLocal) {
      return _row(
        context,
        'label_transaction_id'.l10n,
        Text('label_waiting_dots'.l10n),
      );
    }

    return _row(
      context,
      'label_transaction_id'.l10n,
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${operation.num}'),
            WidgetSpan(
              child: WidgetButton(
                onPressed: () async {
                  PlatformUtils.copy(text: '${operation.num}');
                  MessagePopup.success('label_copied'.l10n);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SvgIcon(SvgIcons.copySmallThick),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
