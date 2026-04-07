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
import '/domain/model/promo_share.dart';
import '/domain/service/partner.dart';
import '/l10n/l10n.dart';
import '/provider/gql/exceptions.dart';
import '/ui/widget/text_field.dart';
import '/util/message_popup.dart';
import '/util/new_type.dart';

/// Controller of the [Routes.promotion] page.
class PromotionController extends GetxController {
  PromotionController(this._partnerService);

  /// Indicator whether the [PromoShare] percentage is being edited or not.
  final RxBool percentEditing = RxBool(false);

  /// [TextFieldState] for setting and editing a [Percentage].
  late final TextFieldState percentage = TextFieldState(
    onChanged: (s) {
      expected.value = int.tryParse(s.text) ?? 0;
    },
  );

  /// Percentage parsed from a [percentage] field.
  final RxInt expected = RxInt(0);

  /// [PartnerService] used for retrieving and modifying the
  /// [MonetizationSettings].
  final PartnerService _partnerService;

  /// Returns the [MonetizationSettings] of the authenticated [MyUser].
  Rx<MonetizationSettings> get settings => _partnerService.settings;

  /// Enables [percentEditing].
  void editPercentage() {
    percentEditing.value = true;
    percentage.text = '${settings.value.referral?.fee?.val ?? 0}';
  }

  /// Stores the [Percentage] in a [MonetizationSettingsReferral].
  Future<void> savePercentage() async {
    final int? changed = int.tryParse(percentage.text);
    final int current = settings.value.referral?.fee?.val ?? 0;

    if ((changed ?? 0) != current) {
      try {
        await _partnerService.updateMonetizationSettings(
          referral: NewType(
            MonetizationSettingsReferral(
              fee: changed == null || changed == 0 ? null : Percentage(changed),
            ),
          ),
        );
      } on UpdateMonetizationSettingsException catch (e) {
        MessagePopup.error(e);
        rethrow;
      } catch (_) {
        MessagePopup.error('err_data_transfer'.l10n);
        rethrow;
      }
    }

    percentEditing.value = false;
  }
}
