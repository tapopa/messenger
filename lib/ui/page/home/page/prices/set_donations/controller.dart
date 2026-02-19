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

import 'package:get/get.dart';

import '/domain/model/monetization_settings.dart';
import '/domain/model/price.dart';
import '/domain/service/partner.dart';
import '/l10n/l10n.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';

/// Controller of a [SetDonationsView].
class SetDonationsController extends GetxController {
  SetDonationsController(this._partnerService);

  /// [TextFieldState] for setting the minimum [Sum] of incoming [Donation]s.
  late final TextFieldState state = TextFieldState(
    onFocus: (s) {
      if (s.text == '') {
        s.error.value = null;
        amount.value = 1;
        return;
      }

      final parsed = double.tryParse(s.text);

      if (parsed != null) {
        s.error.value = null;

        if (parsed < 1) {
          s.error.value = 'label_minimum_amount_cannot_be_less_than'.l10nfmt({
            'amount': Price.xxx(1).l10n,
          });

          return;
        } else if (parsed > 9999) {
          s.error.value = 'label_minimum_amount_cannot_be_more_than'.l10nfmt({
            'amount': Price.xxx(9999).l10n,
          });

          return;
        }

        amount.value = parsed;
      }
    },
  );

  /// Indicator whether incoming [Donation]s should be enabled.
  final RxBool enabled = RxBool(false);

  /// [Sum] of minimum incoming [Donation]s parsed from [state].
  final RxnDouble amount = RxnDouble(null);

  /// [PartnerService] controlling the [MonetizationSettings].
  final PartnerService _partnerService;

  /// Returns the [MonetizationSettings] of the authenticated [MyUser].
  Rx<MonetizationSettings> get settings => _partnerService.settings;

  @override
  void onInit() {
    enabled.value = settings.value.donation?.enabled == true;
    amount.value = settings.value.donation?.min.sum.val;
    state.text = amount.value == null
        ? ''
        : '${amount.value?.toStringAsFixed(2)}';

    super.onInit();
  }

  /// Sets the [enabled] and [amount] to the [MonetizationSettings].
  Future<void> save() async {
    try {
      await _partnerService.updateMonetizationSettings(
        donationsEnabled: enabled.value,
        donationsMinimum: Sum(amount.value ?? 1),
      );
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }
}
