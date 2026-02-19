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

import 'package:graphql/client.dart' hide Operation;

import '../base.dart';
import '../exceptions.dart';
import '/api/backend/schema.dart';
import '/domain/model/country.dart';
import '/domain/model/my_user.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/model/session.dart';
import '/domain/model/user.dart';
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
    OperationOrigin origin = OperationOrigin.purse,
    int? first,
    OperationsCursor? after,
    int? last,
    OperationsCursor? before,
  }) async {
    Log.debug('operations($first, $after, $last, $before)', '$runtimeType');

    final variables = OperationsArguments(
      origin: origin,
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

  /// Creates a new [OperationDeposit].
  ///
  /// Exactly one of [kind] argument's fields must be specified (be non-`null`).
  ///
  /// ### Authentication
  ///
  /// Mandatory.
  ///
  /// ### Non-idempotent
  ///
  /// Each time creates a new unique [OperationDeposit].
  Future<OperationEventsVersionedMixin> createOperationDeposit({
    required OperationDepositMethodId methodId,
    required OperationDepositInput kind,
    required CountryCode country,
  }) async {
    Log.debug(
      'createOperationDeposit(methodId: $methodId, kind: $kind, country: $country)',
      '$runtimeType',
    );

    final variables = CreateOperationDepositArguments(
      methodId: methodId,
      kind: kind,
      billingCountry: country,
    );

    final QueryResult res = await client.mutate(
      MutationOptions(
        operationName: 'CreateOperationDeposit',
        document: CreateOperationDepositMutation(variables: variables).document,
        variables: variables.toJson(),
      ),
      onException: (data) => CreateOperationDepositException(
        (CreateOperationDeposit$Mutation.fromJson(data).createOperationDeposit
                as CreateOperationDeposit$Mutation$CreateOperationDeposit$CreateOperationDepositError)
            .code,
      ),
    );

    return CreateOperationDeposit$Mutation.fromJson(
          res.data!,
        ).createOperationDeposit
        as CreateOperationDeposit$Mutation$CreateOperationDeposit$OperationEventsVersioned;
  }

  /// Completes an [OperationDeposit].
  ///
  /// ### Authentication
  ///
  /// Mandatory if the [secret] argument is not specified (or is `null`).
  ///
  /// ### Result
  ///
  /// One of the following [OperationEvent]s may be produced on success:
  /// - [EventOperationDepositCompleted];
  /// - [EventOperationDepositFailed].
  ///
  /// ### Idempotent
  ///
  /// Succeeds as no-op (and returns no [OperationEvent]) if the
  /// [OperationDeposit] with the specified id is completed or failed already.
  Future<OperationEventsVersionedMixin> completeOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  }) async {
    Log.debug(
      'completeOperationDeposit(id: $id, secret: ${secret?.obscured})',
      '$runtimeType',
    );

    final variables = CompleteOperationDepositArguments(id: id, secret: secret);
    final QueryResult res = await client.mutate(
      MutationOptions(
        operationName: 'CompleteOperationDeposit',
        document: CompleteOperationDepositMutation(
          variables: variables,
        ).document,
        variables: variables.toJson(),
      ),
      onException: (data) {
        final fromJson = CompleteOperationDeposit$Mutation.fromJson(
          data,
        ).completeOperationDeposit;

        if (fromJson == null) {
          return null;
        }

        return CompleteOperationDepositException(
          (fromJson
                  as CompleteOperationDeposit$Mutation$CompleteOperationDeposit$CompleteOperationDepositError)
              .code,
        );
      },
    );

    return CompleteOperationDeposit$Mutation.fromJson(
          res.data!,
        ).completeOperationDeposit
        as CompleteOperationDeposit$Mutation$CompleteOperationDeposit$OperationEventsVersioned;
  }

  /// Declines an [OperationDeposit].
  ///
  /// ### Authentication
  ///
  ///  Mandatory if the [secret] argument is not specified (or is `null`).
  ///
  /// ### Result
  ///
  /// Only the following [OperationEvent] may be produced on success:
  /// - [EventOperationDepositDeclined].
  ///
  /// ### Idempotent
  ///
  /// Succeeds if the [OperationDeposit] with the specified id is declined
  /// already.
  Future<OperationEventsVersionedMixin?> declineOperationDeposit({
    required OperationId id,
    OperationDepositSecret? secret,
  }) async {
    Log.debug(
      'declineOperationDeposit(id: $id, secret: ${secret?.obscured})',
      '$runtimeType',
    );

    final variables = DeclineOperationDepositArguments(id: id, secret: secret);

    final QueryResult res = await client.mutate(
      MutationOptions(
        operationName: 'DeclineOperationDeposit',
        document: DeclineOperationDepositMutation(
          variables: variables,
        ).document,
        variables: variables.toJson(),
      ),
      onException: (data) => DeclineOperationDepositException(
        (DeclineOperationDeposit$Mutation.fromJson(data).declineOperationDeposit
                as DeclineOperationDeposit$Mutation$DeclineOperationDeposit$DeclineOperationDepositError)
            .code,
      ),
    );

    return DeclineOperationDeposit$Mutation.fromJson(
          res.data!,
        ).declineOperationDeposit
        as DeclineOperationDeposit$Mutation$DeclineOperationDeposit$OperationEventsVersioned?;
  }

  /// Returns an [Operation] by its [OperationId] or [OperationNum].
  Future<Operation$Query$Operation?> operation(
    OperationId? id,
    OperationNum? num,
  ) async {
    Log.debug('operation(id: $id, num: $num)', '$runtimeType');

    final variables = OperationArguments(id: id, num: num);
    final QueryResult result = await client.query(
      QueryOptions(
        operationName: 'Operation',
        document: OperationQuery(variables: variables).document,
        variables: variables.toJson(),
      ),
    );

    return Operation$Query.fromJson(result.data!).operation;
  }

  /// Subscribes to [MonetizationSettingsEvents] of the [MonetizationSettings]
  /// set by the authenticated [MyUser] (both common and individual ones).
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
  /// An initial state of the `MonetizationSettingsList` will be emitted after
  /// `SubscriptionInitialized` and before any other
  /// [MonetizationSettingsEvents] (and won't be emitted ever again until this
  /// subscription completes). This allows to skip calling
  /// `Query.myMonetizationSettings` before establishing this subscription.
  ///
  /// ### Completion
  ///
  /// Infinite.
  ///
  /// Completes requiring a re-subscription when:
  /// - Authenticated [Session] expires (`SESSION_EXPIRED` error is emitted).
  /// - An error occurs on the server (error is emitted).
  /// - The server is shutting down or becoming unreachable (unexpectedly
  ///   completes after initialization).
  ///
  /// ### Idempotency
  ///
  /// It's possible that in rare scenarios this subscription could emit an event
  /// which have already been applied to the state of some
  /// [MonetizationSettings], so a client side is expected to handle all the
  /// events idempotently considering the [DtoMonetizationSettings.ver].
  Future<Stream<QueryResult>> myMonetizationSettingsEvents() async {
    Log.debug('myMonetizationSettingsEvents()', '$runtimeType');

    return client.subscribe(
      SubscriptionOptions(
        operationName: 'MyMonetizationSettingsEvents',
        document: MyMonetizationSettingsEventsSubscription().document,
      ),
    );
  }

  /// Updates [MonetizationSettings] of the authenticated [MyUser].
  ///
  /// If the [userId] argument is specified, then [MonetizationSettings] will be
  /// updated individually for that [User]. Otherwise, common
  /// [MonetizationSettings] are updated, affecting all [User]s. Naturally,
  /// individual [MonetizationSettings] take precedence over common
  /// [MonetizationSettings].
  ///
  /// ### Authentication
  ///
  /// Mandatory.
  ///
  /// Result
  ///
  /// One of the following [MonetizationSettingsEvents] may be produced on
  /// success:
  /// - [EventMonetizationSettingsDonationDeleted];
  /// - [EventMonetizationSettingsDonationMinPriceUpdated];
  /// - [EventMonetizationSettingsDonationToggled].
  ///
  /// ### Idempotent
  ///
  /// Succeeds as no-op (and returns no [MonetizationSettingsEvent]) if the
  /// specified [MonetizationSettings]' fields are set already to the provided
  /// values.
  Future<MonetizationSettingsEventsVersionedMixin?> updateMonetizationSettings({
    UserId? userId,
    required MonetizationSettingsInput settings,
  }) async {
    Log.debug(
      'updateMonetizationSettings(userId: $userId, settings: $settings)',
      '$runtimeType',
    );

    final variables = UpdateMonetizationSettingsArguments(
      userId: userId,
      settings: settings,
    );

    final QueryResult res = await client.mutate(
      MutationOptions(
        operationName: 'UpdateMonetizationSettings',
        document: UpdateMonetizationSettingsMutation(
          variables: variables,
        ).document,
        variables: variables.toJson(),
      ),
      onException: (data) => UpdateMonetizationSettingsException(
        (UpdateMonetizationSettings$Mutation.fromJson(
                  data,
                ).updateMonetizationSettings
                as UpdateMonetizationSettings$Mutation$UpdateMonetizationSettings$UpdateMonetizationSettingsError)
            .code,
      ),
    );

    return UpdateMonetizationSettings$Mutation.fromJson(
          res.data!,
        ).updateMonetizationSettings
        as UpdateMonetizationSettings$Mutation$UpdateMonetizationSettings$MonetizationSettingsEventsVersioned?;
  }
}
