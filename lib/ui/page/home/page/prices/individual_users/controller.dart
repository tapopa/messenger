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

import 'package:get/get.dart';

import '/domain/repository/user.dart';
import '/domain/model/monetization_settings.dart';
import '/domain/model/user.dart';
import '/domain/repository/paginated.dart';
import '/domain/service/partner.dart';
import '/domain/service/user.dart';

/// Controller of a [IndividualUsersView].
class IndividualUsersController extends GetxController {
  IndividualUsersController(this._partnerService, this._userService);

  /// [PartnerService] maintaining the [MonetizationSettings].
  final PartnerService _partnerService;

  /// [UserService] for retrieving the [RxUser]s.
  final UserService _userService;

  /// Returns the total amount of [MonetizationSettings] applied by the
  /// [MyUser].
  RxInt get total => _partnerService.total;

  /// Returns the [Paginated] for [MonetizationSettings] per individual
  /// [UserId]s.
  Paginated<UserId, Rx<MonetizationSettings>> get paginated =>
      _partnerService.paginated;

  @override
  void onInit() {
    paginated.around();
    super.onInit();
  }

  /// Returns a [RxUser] identified by the provided [id], if any.
  FutureOr<RxUser?> getUser(UserId id) => _userService.get(id);

  /// Removes [MonetizationSettings] settings for the provided [UserId].
  Future<void> removeSettings(UserId id) async {
    await _partnerService.updateMonetizationSettings(userId: id);
  }
}
