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
import '/domain/model/user.dart';
import '/domain/service/partner.dart';
import '/l10n/l10n.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';
import '/util/new_type.dart';

/// [MonetizationSettings] parameter that should be changed.
enum SetMonetizationMode { donation, message }

/// Controller of a [SetDonationsView].
class SetDonationsController extends GetxController {
  SetDonationsController(
    this._partnerService, {
    this.userId,
    this.mode = SetMonetizationMode.donation,
  });

  /// [UserId] of a [User] for whom the [MonetizationSettings] are being
  /// changed.
  final UserId? userId;

  /// [SetMonetizationMode] this controller should set.
  final SetMonetizationMode mode;

  /// [TextFieldState] for setting a [Sum] of the [mode].
  late final TextFieldState state = TextFieldState(
    onFocus: (s) {
      if (s.text == '') {
        s.error.value = null;

        switch (mode) {
          case SetMonetizationMode.donation:
            amount.value = 1;
            break;

          case SetMonetizationMode.message:
            amount.value = 0;
            break;
        }
        return;
      }

      final parsed = double.tryParse(s.text);

      if (parsed != null) {
        s.error.value = null;

        if (parsed < 1) {
          switch (mode) {
            case SetMonetizationMode.donation:
              s.error.value = 'label_minimum_amount_cannot_be_less_than'
                  .l10nfmt({'amount': Price.xxx(1).l10n});

              return;

            case SetMonetizationMode.message:
              // No-op.
              break;
          }
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

  /// Indicator whether incoming [mode] should be enabled.
  final RxBool enabled = RxBool(false);

  /// [Sum] of [mode] parsed from [state].
  final RxnDouble amount = RxnDouble(null);

  /// [PartnerService] controlling the [MonetizationSettings].
  final PartnerService _partnerService;

  /// Returns the [MonetizationSettings] of the authenticated [MyUser].
  Rx<MonetizationSettings> get settings => _partnerService.settings;

  /// Returns the [MonetizationSettings] of the authenticated [MyUser].
  RxMap<UserId, Rx<MonetizationSettings>> get individual =>
      _partnerService.individual;

  @override
  void onInit() {
    final MonetizationSettings? monetization;

    if (userId == null) {
      monetization = settings.value;
    } else {
      monetization = individual[userId]?.value;
    }

    switch (mode) {
      case SetMonetizationMode.donation:
        enabled.value = monetization?.donation?.enabled == true;
        amount.value = monetization?.donation?.min.sum.val;
        break;

      case SetMonetizationMode.message:
        enabled.value = monetization?.message?.enabled == true;
        amount.value = monetization?.message?.price?.sum.val;
        break;
    }

    state.text = amount.value == null
        ? ''
        : '${amount.value?.toStringAsFixed(2)}';

    super.onInit();
  }

  /// Sets the [enabled] and [amount] to the [MonetizationSettings].
  Future<void> save() async {
    try {
      switch (mode) {
        case SetMonetizationMode.donation:
          await _partnerService.updateMonetizationSettings(
            userId: userId,
            donation: NewType(
              MonetizationSettingsDonation(
                enabled: enabled.value,
                min: Price.xxx(amount.value ?? 1),
              ),
            ),
          );
          break;

        case SetMonetizationMode.message:
          print('==== amount.value -> ${amount.value}');
          await _partnerService.updateMonetizationSettings(
            userId: userId,
            message: NewType(
              MonetizationSettingsMessage(
                enabled: enabled.value,
                price: amount.value == null
                    ? null
                    : Price.xxx(amount.value ?? 1),
              ),
            ),
          );
          break;
      }
    } catch (e) {
      MessagePopup.error(e);
      rethrow;
    }
  }
}
