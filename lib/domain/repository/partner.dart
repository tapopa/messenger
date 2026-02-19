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

import '/domain/model/balance.dart';
import '/domain/model/monetization_settings.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/model/user.dart';
import 'paginated.dart';

/// [MyUser] partner repository interface.
abstract class AbstractPartnerRepository {
  /// Returns the balance [MyUser] has in their partner available wallet.
  Rx<Balance> get available;

  /// Returns the balance [MyUser] has in their partner hold wallet.
  Rx<Balance> get hold;

  /// Returns the [Operation]s happening in [MyUser]'s partner wallet.
  Paginated<OperationId, Rx<Operation>> get operations;

  /// Returns [MonetizationSettings] of the authenticated [MyUser].
  Rx<MonetizationSettings> get settings;

  /// Returns the individual [MonetizationSettings] for separate [UserId]s.
  RxMap<UserId, Rx<MonetizationSettings>> get individual;

  /// Returns an [Operation] identified by the provided [id] or [num].
  FutureOr<Rx<Operation>?> get({OperationId? id, OperationNum? num});

  /// Listens to the updates of [MonetizationSettings] for the provided [UserId]
  /// while the returned [Stream] is listened to.
  Stream<void> updatesFor(UserId id);

  /// Updates [MonetizationSettings] of the authenticated [MyUser].
  ///
  /// If the [userId] argument is specified, then [MonetizationSettings] will be
  /// updated individually for that [User]. Otherwise, common
  /// [MonetizationSettings] are updated, affecting all [User]s. Naturally,
  /// individual [MonetizationSettings] take precedence over common
  /// [MonetizationSettings].
  Future<void> updateMonetizationSettings({
    UserId? userId,
    bool? donationsEnabled,
    Sum? donationsMinimum,
  });
}
