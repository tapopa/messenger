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

import 'package:graphql/client.dart';

import '../base.dart';
import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/my_user.dart';
import '/domain/model/price.dart';
import '/domain/model/session.dart';
import '/store/model/operation.dart';
import '/util/log.dart';

/// [MyUser]'s purse related functionality.
mixin WalletGraphQlMixin {
  GraphQlClient get client;

  AccessTokenSecret? get token;

  /// Returns [Operation]s filtered by the provided criteria.
  ///
  /// ### Authentication
  ///
  /// Mandatory.
  ///
  /// ### Sorting
  ///
  /// The returned [Operation]s are sorted by their [OperationNum] in descending
  /// order.
  ///
  /// ### Pagination
  ///
  /// It's allowed to specify both [first] and [last] counts at the same time,
  /// provided that [after] and [before] cursors are equal. In such case the
  /// returned page will include the [Operation] pointed by the cursor and the
  /// requested count of [Operation]s preceding and following it.
  ///
  /// If it's desired to receive the [Operation], pointed by the cursor, without
  /// querying in both directions, one can specify [first] or [last] count as 0.
  ///
  /// If no arguments are provided, then [first] parameter will be considered as
  /// 50.
  ///
  /// [after] and [before] cursors are only meaningful once other non-pagination
  /// arguments remain the same between queries. Trying to query a page of some
  /// filtered entries with a cursor pointing to a page of totally different
  /// filtered entries is nonsense and will produce an invalid result (usually
  /// returning nothing).
  Future<Operations$Query$Operations> operations({
    int? first,
    OperationsCursor? after,
    int? last,
    OperationsCursor? before,
  }) async {
    Log.debug('operations($first, $after, $last, $before)', '$runtimeType');

    final variables = OperationsArguments(
      origin: OperationOrigin.purse,
      pagination: OperationsPagination(
        first: first,
        after: after,
        last: last,
        before: before,
      ),
    );
    final QueryResult result = await client.query(
      QueryOptions(
        operationName: 'Operations',
        document: OperationsQuery(variables: variables).document,
        variables: variables.toJson(),
      ),
    );
    return Operations$Query.fromJson(result.data!).operations;
  }

  /// Returns information about available [OperationDepositMethod]s for the
  /// authenticated [MyUser].
  Future<List<OperationDepositMethods$Query$OperationDepositMethods>>
  operationDepositMethods(CountryCode country, Currency? currency) async {
    Log.debug('OperationDepositMethods($country, $currency)', '$runtimeType');

    final variables = OperationDepositMethodsArguments(
      country: country,
      currency: currency,
    );
    final QueryResult result = await client.query(
      QueryOptions(
        operationName: 'OperationDepositMethods',
        document: OperationDepositMethodsQuery(variables: variables).document,
        variables: variables.toJson(),
      ),
    );

    return OperationDepositMethods$Query.fromJson(
      result.data!,
    ).operationDepositMethods;
  }

  /// Returns the current [Balance] of the authenticated [MyUser] in the
  /// provided [BalanceOrigin].
  Future<Balance$Query$Balance> balance(BalanceOrigin origin) async {
    Log.debug('balance(${origin.name})', '$runtimeType');

    final variables = BalanceArguments(origin: origin);
    final QueryResult result = await client.query(
      QueryOptions(
        operationName: 'Balance',
        document: BalanceQuery(variables: variables).document,
        variables: variables.toJson(),
      ),
    );

    return Balance$Query.fromJson(result.data!).balance;
  }

  /// Subscribes to [Balance] updates of the authenticated [MyUser] in the
  /// provided [BalanceOrigin].
  ///
  /// ### Authentication
  ///
  /// Mandatory.
  ///
  /// ### Initialization
  ///
  /// Once this subscription is initialized completely, it immediately emits
  /// `SubscriptionInitialized`.
  ///
  /// If nothing has been emitted for a long period of time after establishing
  /// this subscription (while not being completed), it should be considered as
  /// an unexpected server error. This fact can be used on a client side to
  /// decide whether this subscription has been initialized successfully.
  ///
  /// ### Result
  ///
  /// Initial [Balance] will be emitted after `SubscriptionInitialized`. This
  /// allows to skip calling [balance] before establishing this subscription.
  ///
  /// ### Completion
  ///
  /// Infinite.
  ///
  /// Completes requiring a re-subscription when:
  /// - Authenticated Session expires (`SESSION_EXPIRED` error is emitted).
  /// - An error occurs on the server (error is emitted).
  /// - The server is shutting down or becoming unreachable (unexpectedly
  /// completes after initialization).
  ///
  /// ### Idempotency
  ///
  /// Emits only changed [Balance] against the previously emitted one, so a
  /// client side is expected to handle all the updates idempotently using the
  /// same logic.
  Future<Stream<QueryResult>> balanceUpdates(BalanceOrigin origin) async {
    Log.debug('balanceUpdates(${origin.name})', '$runtimeType');

    final variables = BalanceUpdatesArguments(origin: origin);
    return client.subscribe(
      SubscriptionOptions(
        operationName: 'BalanceUpdates',
        document: BalanceUpdatesSubscription(variables: variables).document,
        variables: variables.toJson(),
      ),
    );
  }

  /// Subscribes to [OperationEvent]s happening in the provided
  /// [OperationOrigin].
  ///
  /// ### Authentication
  ///
  /// Mandatory.
  ///
  /// ### Initialization
  ///
  /// Once this subscription is initialized completely, it immediately emits
  /// `SubscriptionInitialized`.
  ///
  /// If nothing has been emitted for a long period of time after establishing
  /// this subscription (while not being completed), it should be considered as
  /// an unexpected server error. This fact can be used on a client side to
  /// decide whether this subscription has been initialized successfully.
  ///
  /// ### Result
  ///
  /// If [ver] argument is not specified (or is `null`) an initial state of the
  /// `OperationsList` will be emitted after `SubscriptionInitialized` and
  /// before any other [OperationEvent]s (and won't be emitted ever again until
  /// this subscription completes). This allows to skip calling [operations]
  /// before establishing this subscription.
  ///
  /// If the specified [ver] is not fresh (was queried quite a time ago), it may
  /// become stale, so this subscription will return `STALE_VERSION` error on
  /// initialization. In such case:
  /// - either a fresh version should be obtained via [operations];
  /// - or a re-subscription should be done without specifying a ver argument
  /// (so the fresh ver may be obtained in the emitted initial state of the
  /// `OperationsList`).
  ///
  /// ### Completion
  ///
  /// Infinite.
  ///
  /// Completes requiring a re-subscription when:
  /// - Authenticated [Session] expires (`SESSION_EXPIRED` error is emitted).
  /// - An error occurs on the server (error is emitted).
  /// - The server is shutting down or becoming unreachable (unexpectedly
  /// completes after initialization).
  ///
  /// ### Idempotency
  ///
  /// It's possible that in rare scenarios this subscription could emit an event
  /// which have already been applied to the state of some [Operation], so a
  /// client side is expected to handle all the events idempotently considering
  /// the [DtoOperation.version].
  Future<Stream<QueryResult>> operationsEvents(
    OperationOrigin origin,
    OperationVersion? ver,
    FutureOr<OperationVersion?> Function() onVer,
  ) async {
    Log.debug('operationsEvents(${origin.name})', '$runtimeType');

    final variables = OperationsEventsArguments(origin: origin, ver: ver);
    return client.subscribe(
      SubscriptionOptions(
        operationName: 'OperationsEvents',
        document: OperationsEventsSubscription(variables: variables).document,
        variables: variables.toJson(),
      ),
      ver: onVer,
    );
  }
}
