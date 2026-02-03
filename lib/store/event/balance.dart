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

import '/domain/model/balance.dart';

/// Tag representing a [BalanceUpdates] kind.
enum BalanceUpdatesKind { initialized, balance }

/// [Balance] event union.
abstract class BalanceUpdates {
  const BalanceUpdates();

  /// [BalanceUpdatesKind] of this event.
  BalanceUpdatesKind get kind;
}

/// [BalanceUpdates] with [Balance] itself.
class BalanceUpdatesBalance extends BalanceUpdates {
  const BalanceUpdatesBalance(this.balance);

  /// [Balance] itself.
  final Balance balance;

  @override
  BalanceUpdatesKind get kind => BalanceUpdatesKind.balance;
}

/// Indicator notifying about a GraphQL subscription being successfully
/// initialized.
class BalanceUpdatesInitialized extends BalanceUpdates {
  const BalanceUpdatesInitialized();

  @override
  BalanceUpdatesKind get kind => BalanceUpdatesKind.initialized;
}
