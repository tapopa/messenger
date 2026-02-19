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

import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/widget/widget_button.dart';

/// [Column] of two [Row]s designed to display a [Price].
class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    this.subtitle,
    this.onChange,
    this.enabled = true,
    this.price = Price.zero,
  });

  /// Label to display.
  final String label;

  /// Optional subtitle to display under a [label].
  final String? subtitle;

  /// Callback, called when a change button is pressed.
  final void Function()? onChange;

  /// Indicator whether the [price] is enabled.
  final bool enabled;

  /// [Price] to display.
  final Price price;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: style.fonts.medium.regular.onBackground,
              ),
            ),
            const SizedBox(width: 8),
            if (enabled) ...[
              if (price.isZero)
                Text(
                  'label_free'.l10n,
                  style: style.fonts.medium.regular.currencyPrimary,
                )
              else
                Text(
                  price.l10n,
                  style: style.fonts.medium.regular.currencyPrimary,
                ),
            ] else
              Text(
                'label_disabled'.l10n,
                style: style.fonts.medium.regular.secondary,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Expanded(
                child: Text(
                  subtitle!,
                  style: style.fonts.small.regular.secondary,
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: 8),
            WidgetButton(
              onPressed: onChange,
              child: Text(
                'btn_change'.l10n,
                style: style.fonts.small.regular.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
