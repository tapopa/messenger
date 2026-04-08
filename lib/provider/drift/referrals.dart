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

import 'package:drift/drift.dart';

import '/domain/model/user.dart';
import '/util/log.dart';
import 'drift.dart';

/// [UserId]s stored as the referrals for [UserId].
@DataClassName('ReferralRow')
class Referrals extends Table {
  @override
  Set<Column> get primaryKey => {forId};

  TextColumn get forId => text()();
  TextColumn get referrerId => text()();
}

/// [DriftProviderBase] for manipulating the persisted [UserId]s as the
/// referrals.
class ReferralDriftProvider extends DriftProviderBase {
  ReferralDriftProvider(super.common);

  /// Creates or updates the provided [referrerId] for the [forId] in the
  /// database.
  Future<void> upsert(UserId forId, UserId referrerId) async {
    Log.debug('upsert($forId from $referrerId)', '$runtimeType');

    await safe((db) async {
      await db
          .into(db.referrals)
          .insert(
            ReferralRow(forId: forId.val, referrerId: referrerId.val),
            mode: InsertMode.insertOrReplace,
          );
    }, tag: 'slugs.upsert()');
  }

  /// Returns the [UserId] stored in the database, if any.
  Future<UserId?> read(UserId forId) async {
    Log.debug('read($forId)', '$runtimeType');

    return await safe<UserId?>((db) async {
      final stmt = db.select(db.referrals)
        ..where((u) => u.forId.equals(forId.val));
      final ReferralRow? row = await stmt.getSingleOrNull();
      Log.debug('read($forId) -> $row', '$runtimeType');

      if (row == null) {
        return null;
      }

      return UserId(row.referrerId);
    }, tag: 'slugs.read()');
  }

  /// Deletes the stored [UserId] from the database.
  Future<void> delete(UserId forId) async {
    Log.debug('delete($forId)', '$runtimeType');

    await safe((db) async {
      final stmt = db.delete(db.referrals)
        ..where((e) => e.forId.equals(forId.val));

      await stmt.go();
    }, tag: 'slugs.delete()');
  }
}
