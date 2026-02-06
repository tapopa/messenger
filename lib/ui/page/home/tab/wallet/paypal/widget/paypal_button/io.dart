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

import '/ui/widget/outlined_rounded_button.dart';
import '/themes.dart';

/// PayPal pay button widget.
class PayPalButton extends StatelessWidget {
  const PayPalButton({
    super.key,
    this.onCreateOrder,
    this.onSuccess,
    this.onCancel,
    this.onError,
    this.currency = 'USD',
  });

  /// Callback, called when order ID should be created.
  final Future<String> Function()? onCreateOrder;

  /// Callback, called when PayPal SDK returned complete status.
  final void Function()? onSuccess;

  /// Callback, called when PayPal SDK returned cancel status.
  final void Function()? onCancel;

  /// Callback, called when PayPal SDK returned error status.
  final void Function(Object error)? onError;

  /// Currency to use in the PayPal SDK.
  final String currency;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return OutlinedRoundedButton(
      color: const Color.fromARGB(255, 255, 196, 58),
      onPressed: () async {
        await onCreateOrder?.call();
      },
      maxWidth: double.infinity,
      height: 64,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Pay with '),
            TextSpan(
              text: 'Pay',
              style: style.fonts.largest.bold.onBackground.copyWith(
                fontSize: 24,
                color: Color.fromRGBO(0, 48, 135, 1),
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: 'Pal',
              style: style.fonts.largest.bold.onBackground.copyWith(
                fontSize: 24,
                color: Color.fromRGBO(0, 156, 222, 1),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        style: style.fonts.large.regular.onBackground,
      ),
    );
  }
}
