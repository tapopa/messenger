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

import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart' show QueryResult;

import '/api/backend/extension/page_info.dart';
import '/api/backend/extension/wallet.dart';
import '/api/backend/schema.dart';
import '/domain/model/balance.dart';
import '/domain/model/operation.dart';
import '/domain/model/user.dart';
import '/domain/repository/partner.dart';
import '/domain/service/disposable_service.dart';
import '/provider/gql/graphql.dart';
import '/util/log.dart';
import '/util/stream_utils.dart';
import '/util/web/web_utils.dart';
import 'event/balance.dart';
import 'model/operation.dart';
import 'model/page_info.dart';
import 'pagination.dart';
import 'pagination/graphql.dart';
import 'wallet.dart';

/// [MyUser] wallet repository interface.
class PartnerRepository extends IdentityDependency
    implements AbstractPartnerRepository {
  PartnerRepository(this._graphQlProvider, {required super.me});

  @override
  final Rx<Balance> available = Rx(Balance.zero);

  @override
  final Rx<Balance> hold = Rx(Balance.zero);

  /// [GraphQlProvider] for fetching the [Balance]s.
  final GraphQlProvider _graphQlProvider;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _availableSubscription;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _holdSubscription;

  @override
  late final OperationsPaginated operations = OperationsPaginated(
    initial: [],
    pagination: Pagination(
      onKey: (e) => e.id,
      perPage: 15,
      provider: GraphQlPageProvider(
        fetch: ({after, before, first, last}) async {
          final Page<DtoOperation, OperationsCursor> page = await _operations(
            after: after,
            before: before,
            first: first,
            last: last,
          );

          return page;
        },
      ),
    ),
    transform: ({required DtoOperation data, Rx<Operation>? previous}) {
      previous?.value = data.value;
      return previous ?? Rx(data.value);
    },
  );

  @override
  void onInit() {
    Log.debug('onInit()', '$runtimeType');
    super.onInit();
  }

  @override
  void onClose() {
    _availableSubscription?.close(immediate: true);
    _holdSubscription?.close(immediate: true);
    super.onClose();
  }

  @override
  void onIdentityChanged(UserId me) {
    super.onIdentityChanged(me);

    Log.debug('onIdentityChanged($me)', '$runtimeType');

    operations.clear();
    available.value = Balance.zero;
    hold.value = Balance.zero;
    _availableSubscription?.close(immediate: true);
    _holdSubscription?.close(immediate: true);

    if (!me.isLocal) {
      operations.around();

      _initAvailableSubscription();
      _initHoldSubscription();
    }
  }

  /// Fetches purse operations with pagination.
  Future<Page<DtoOperation, OperationsCursor>> _operations({
    int? first,
    OperationsCursor? after,
    int? last,
    OperationsCursor? before,
  }) async {
    Log.debug('_operations($first, $after, $last, $before)', '$runtimeType');

    if (me.isLocal) {
      return Page([], PageInfo());
    }

    final query = await _graphQlProvider.operations(
      origin: OperationOrigin.income,
      first: first,
      after: after,
      last: last,
      before: before,
    );

    return Page(
      query.edges.map((e) => e.node.toDto(cursor: e.cursor)).toList(),
      query.pageInfo.toModel(OperationsCursor.new),
    );
  }

  /// Initializes [_availableSubscription] subscription.
  Future<void> _initAvailableSubscription() async {
    Log.debug('_initAvailableSubscription()', '$runtimeType');

    _availableSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _availableSubscription = StreamQueue(
        await _balanceUpdates(BalanceOrigin.incomeAvailable),
      );

      await _availableSubscription!.execute(_availableUpdate);
    }, tag: 'availableUpdates()');
  }

  /// Handles [BalanceUpdates] from the [_availableUpdate] subscription.
  Future<void> _availableUpdate(BalanceUpdates events) async {
    switch (events.kind) {
      case BalanceUpdatesKind.initialized:
        Log.debug('_availableUpdate(${events.kind})', '$runtimeType');
        break;

      case BalanceUpdatesKind.balance:
        events as BalanceUpdatesBalance;

        Log.debug(
          '_availableUpdate(${events.kind}) -> ${events.balance}',
          '$runtimeType',
        );

        available.value = events.balance;
        break;
    }
  }

  /// Initializes [_holdSubscription] subscription.
  Future<void> _initHoldSubscription() async {
    Log.debug('_initHoldSubscription()', '$runtimeType');

    _holdSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _holdSubscription = StreamQueue(
        await _balanceUpdates(BalanceOrigin.incomeHold),
      );

      await _holdSubscription!.execute(_holdUpdate);
    }, tag: 'holdUpdates()');
  }

  /// Handles [BalanceUpdates] from the [_holdUpdate] subscription.
  Future<void> _holdUpdate(BalanceUpdates events) async {
    switch (events.kind) {
      case BalanceUpdatesKind.initialized:
        Log.debug('_holdUpdate(${events.kind})', '$runtimeType');
        break;

      case BalanceUpdatesKind.balance:
        events as BalanceUpdatesBalance;

        Log.debug(
          '_holdUpdate(${events.kind}) -> ${events.balance}',
          '$runtimeType',
        );

        hold.value = events.balance;
        break;
    }
  }

  /// Returns a [Stream] of [Balance]s of the specified [MyUser]'s purse.
  Future<Stream<BalanceUpdates>> _balanceUpdates(BalanceOrigin origin) async {
    Log.debug('_balanceEvents()', '$runtimeType');

    final Stream<QueryResult> events = await _graphQlProvider.balanceUpdates(
      origin,
    );

    return events.asyncExpand((event) async* {
      Log.trace('_balanceEvents() -> ${event.data}', '$runtimeType');

      final events = BalanceUpdates$Subscription.fromJson(
        event.data!,
      ).balanceUpdates;
      if (events.$$typename == 'SubscriptionInitialized') {
        events
            as BalanceUpdates$Subscription$BalanceUpdates$SubscriptionInitialized;
        yield const BalanceUpdatesInitialized();
      } else if (events.$$typename == 'Balance') {
        final mixin =
            events as BalanceUpdates$Subscription$BalanceUpdates$Balance;
        yield BalanceUpdatesBalance(mixin.toModel());
      }
    });
  }
}
