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

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart' show QueryResult;
import 'package:mutex/mutex.dart';

import '/api/backend/extension/page_info.dart';
import '/api/backend/extension/wallet.dart';
import '/api/backend/schema.dart';
import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/model/session.dart';
import '/domain/model/user.dart';
import '/domain/repository/session.dart';
import '/domain/repository/wallet.dart';
import '/domain/service/disposable_service.dart';
import '/provider/gql/graphql.dart';
import '/util/backoff.dart';
import '/util/log.dart';
import '/util/stream_utils.dart';
import '/util/web/web_utils.dart';
import 'event/balance.dart';
import 'event/operation.dart';
import 'model/operation.dart';
import 'model/page_info.dart';
import 'paginated.dart';
import 'pagination.dart';
import 'pagination/graphql.dart';

typedef OperationsPaginated =
    RxPaginatedImpl<OperationId, Rx<Operation>, DtoOperation, OperationsCursor>;

/// [MyUser] wallet repository interface.
class WalletRepository extends IdentityDependency
    implements AbstractWalletRepository {
  WalletRepository(
    this._graphQlProvider,
    this._sessionRepository, {
    required super.me,
  });

  @override
  final Rx<Balance> balance = Rx(Balance.zero);

  @override
  late final OperationsPaginated operations = OperationsPaginated(
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
      compare: (a, b) => a.compareTo(b),
    ),
    transform: ({required DtoOperation data, Rx<Operation>? previous}) {
      if (previous != null) {
        return previous..value = data.value;
      }

      return Rx(data.value);
    },
    compare: (a, b) => a.value.compareTo(b.value),
  );

  @override
  final RxList<OperationDepositMethod> methods = RxList();

  /// [GraphQlProvider] for fetching the [Operation]s list.
  final GraphQlProvider _graphQlProvider;

  /// [AbstractSessionRepository] used to fetch [IpAddress].
  final AbstractSessionRepository _sessionRepository;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _balanceSubscription;

  /// [Operation]s subscription.
  StreamQueue<OperationsEvents>? _operationsSubscription;

  /// [IpGeoLocation] of the current device.
  IpGeoLocation? _ip;

  /// [CountryCode] selected for the [OperationDepositMethod].
  CountryCode? _country;

  /// [Currency] to see [OperationDepositMethod] pricing in.
  Currency _currency = Currency('USD');

  /// [CancelToken] to cancel [_queryMethods].
  CancelToken? _queryToken;

  /// Latest [OperationVersion] of the [operations] list events.
  OperationVersion? _ver;

  /// [Mutex]ex guarding access to [get].
  final Map<_OperationIdentifier, Mutex> _locks = {};

  @override
  void onInit() {
    Log.debug('onInit()', '$runtimeType');
    super.onInit();
  }

  @override
  void onClose() {
    _balanceSubscription?.close(immediate: true);
    _operationsSubscription?.close(immediate: true);
    super.onClose();
  }

  @override
  void onIdentityChanged(UserId me) {
    super.onIdentityChanged(me);

    Log.debug('onIdentityChanged($me)', '$runtimeType');

    _queryToken?.cancel();
    _queryToken = null;

    operations.clear();
    balance.value = Balance.zero;

    _balanceSubscription?.close(immediate: true);
    _operationsSubscription?.close(immediate: true);

    if (!me.isLocal) {
      operations.around();

      _queryMethods();
      _initBalanceSubscription();
      _initOperationsSubscription();
    }
  }

  @override
  Future<void> setCountry(CountryCode country) async {
    Log.debug('setCountry($country)', '$runtimeType');

    if (isClosed || me.isLocal) {
      return;
    }

    _country = country;

    // TODO: Might replace currencies when local ones are supported.
    _currency = Currency(switch (country.val) {
      (_) => 'USD',
    });

    await _queryMethods();
  }

  @override
  FutureOr<Rx<Operation>?> get({OperationId? id, OperationNum? num}) {
    Log.debug('get($id: id, num: $num)', '$runtimeType');

    final Rx<Operation>? operation = operations.items[id];
    if (operation != null) {
      return operation;
    }

    final identifier = _OperationIdentifier(id: id, num: num);

    // If [operation] doesn't exist, we should lock the [mutex] to avoid remote
    // double invoking.
    Mutex? mutex = _locks[identifier];
    if (mutex == null) {
      mutex = Mutex();
      _locks[identifier] = mutex;
    }

    return mutex.protect(() async {
      Rx<Operation>? operation = operations.items[id];

      if (operation == null) {
        final response = await _graphQlProvider.operation(id, num);
        if (response != null) {
          final DtoOperation dto = response.node.toDto(cursor: response.cursor);

          final rxOperation = operations.items[dto.id] = Rx(dto.value);
          operations.put(dto);

          return rxOperation;
        }
      }

      return operation;
    });
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

  /// Queries the available [OperationDepositMethod]s into [methods].
  Future<void> _queryMethods() async {
    Log.debug('_queryMethods()', '$runtimeType');

    _queryToken?.cancel();
    _queryToken = CancelToken();

    _ip ??= await _sessionRepository.fetch();
    if (_ip != null) {
      _country ??= CountryCode(_ip?.countryCode ?? 'us');
    }

    if (isClosed || me.isLocal) {
      return;
    }

    if (_country == null) {
      Log.warning('_queryMethods() -> country is `null`', '$runtimeType');
      methods.value = [];
      return;
    }

    try {
      await Backoff.run(() async {
        final list = await _graphQlProvider.operationDepositMethods(
          _country!,
          _currency,
        );

        methods.value = list.map((e) => e.toModel()).toList();
      }, cancel: _queryToken);
    } on OperationCanceledException {
      // No-op.
    }
  }

  /// Initializes [_balanceUpdates] subscription.
  Future<void> _initBalanceSubscription() async {
    Log.debug('_initBalanceSubscription()', '$runtimeType');

    _balanceSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _balanceSubscription = StreamQueue(await _balanceUpdates());
      await _balanceSubscription!.execute(_balanceUpdate);
    }, tag: 'balanceUpdates()');
  }

  /// Returns a [Stream] of [Balance]s of the specified [MyUser]'s purse.
  Future<Stream<BalanceUpdates>> _balanceUpdates() async {
    Log.debug('_balanceEvents()', '$runtimeType');

    final Stream<QueryResult> events = await _graphQlProvider.balanceUpdates(
      BalanceOrigin.purse,
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

  /// Handles [BalanceUpdates] from the [_balanceUpdates] subscription.
  Future<void> _balanceUpdate(BalanceUpdates events) async {
    switch (events.kind) {
      case BalanceUpdatesKind.initialized:
        Log.debug('_balanceUpdate(${events.kind})', '$runtimeType');
        break;

      case BalanceUpdatesKind.balance:
        events as BalanceUpdatesBalance;

        Log.debug(
          '_balanceUpdate(${events.kind}) -> ${events.balance}',
          '$runtimeType',
        );

        balance.value = events.balance;
        break;
    }
  }

  /// Initializes [operations] subscription.
  Future<void> _initOperationsSubscription() async {
    Log.debug('_initOperationsSubscription()', '$runtimeType');

    _operationsSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _operationsSubscription = StreamQueue(await _operationsEvents());
      await _operationsSubscription!.execute(_operationsEvent);
    }, tag: 'operationsEvents()');
  }

  /// Returns a [Stream] of [Balance]s of the specified [MyUser]'s purse.
  Future<Stream<OperationsEvents>> _operationsEvents() async {
    Log.debug('_operationsEvents()', '$runtimeType');

    final Stream<QueryResult> events = await _graphQlProvider.operationsEvents(
      OperationOrigin.purse,
      null,
      () => null,
    );

    return events.asyncExpand((event) async* {
      Log.debug('_operationsEvents() -> ${event.data}', '$runtimeType');

      final events = OperationsEvents$Subscription.fromJson(
        event.data!,
      ).operationsEvents;

      if (events.$$typename == 'SubscriptionInitialized') {
        events
            as OperationsEvents$Subscription$OperationsEvents$SubscriptionInitialized;
        yield const OperationsEventsInitialized();
      } else if (events.$$typename == 'OperationsList') {
        events as OperationsEvents$Subscription$OperationsEvents$OperationsList;
        yield OperationsEventsList();
      } else if (events.$$typename == 'OperationEventsVersioned') {
        final mixin =
            events
                as OperationsEvents$Subscription$OperationsEvents$OperationEventsVersioned;
        yield OperationsEventsEvent(
          OperationsEventsVersioned(
            mixin.events.map(_operationEvent).toList(),
            mixin.ver,
            mixin.listVer,
          ),
        );
      }
    });
  }

  /// Constructs a [OperationEvent] from the
  /// [OperationEventsVersionedMixin$Events].
  OperationEvent _operationEvent(OperationEventsVersionedMixin$Events e) {
    Log.trace('_operationEvent($e)', '$runtimeType');

    if (e.$$typename == 'EventOperationCanceled') {
      e as OperationEventsVersionedMixin$Events$EventOperationCanceled;
      return EventOperationCanceled(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
        e.canceled.toModel(),
      );
    } else if (e.$$typename == 'EventOperationChargeCreated') {
      return EventOperationChargeCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDepositBonusCreated') {
      return EventOperationDepositBonusCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDepositCompleted') {
      return EventOperationDepositCompleted(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDepositCreated') {
      return EventOperationDepositCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDepositDeclined') {
      return EventOperationDepositDeclined(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDepositFailed') {
      return EventOperationDepositFailed(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationDividendCreated') {
      return EventOperationDividendCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationEarnDonationCreated') {
      return EventOperationEarnDonationCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationGrantCreated') {
      return EventOperationGrantCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationPurchaseDonationCreated') {
      return EventOperationPurchaseDonationCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else if (e.$$typename == 'EventOperationRewardCreated') {
      return EventOperationRewardCreated(
        e.id,
        e.origin,
        e.at,
        e.operation.node.toDto(cursor: e.operation.cursor),
      );
    } else {
      throw UnimplementedError('Unknown OperationEvent: ${e.$$typename}');
    }
  }

  /// Handles [OperationsEvents] from the [_operationsEvents] subscription.
  Future<void> _operationsEvent(
    OperationsEvents events, {
    bool updateVersion = true,
  }) async {
    switch (events.kind) {
      case OperationsEventsKind.initialized:
        events as OperationsEventsInitialized;
        Log.debug('_operationsEvent(${events.kind})', '$runtimeType');
        break;

      case OperationsEventsKind.list:
        events as OperationsEventsList;
        Log.debug('_operationsEvent(${events.kind})', '$runtimeType');
        break;

      case OperationsEventsKind.event:
        events as OperationsEventsEvent;

        final OperationsEventsVersioned versioned = events.event;

        if (versioned.ver >= _ver) {
          Log.debug(
            '_operationsEvent(${events.kind}): ignored ${versioned.events.map((e) => e.kind.name).join(', ')}',
            '$runtimeType',
          );
          return;
        }

        if (updateVersion) {
          _ver = versioned.ver;
        }

        Log.debug(
          '_operationsEvent(${events.kind}): ${versioned.events.map((e) => e.kind.name).join(', ')}',
          '$runtimeType',
        );

        for (var event in versioned.events) {
          switch (event.kind) {
            case OperationEventKind.canceled:
              event as EventOperationCanceled;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.chargeCreated:
              event as EventOperationChargeCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.depositBonusCreated:
              event as EventOperationDepositBonusCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.depositCompleted:
              event as EventOperationDepositCompleted;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.depositCreated:
              event as EventOperationDepositCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.depositDeclined:
              event as EventOperationDepositDeclined;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.depositFailed:
              event as EventOperationDepositFailed;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.dividendCreated:
              event as EventOperationDividendCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.earnDonationCreated:
              event as EventOperationEarnDonationCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.grantCreated:
              event as EventOperationGrantCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.purchaseDonationCreated:
              event as EventOperationPurchaseDonationCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;

            case OperationEventKind.rewardCreated:
              event as EventOperationRewardCreated;
              await operations.put(
                event.operation,
                ignoreBounds: operations.contains(event.id),
              );
              break;
          }
        }
        break;
    }
  }
}

/// [OperationId] or [OperationNum] identifying an [Operation].
class _OperationIdentifier {
  const _OperationIdentifier({this.id, this.num});

  /// [OperationId] of the identifier.
  final OperationId? id;

  /// [OperationNum] of the identifier.
  final OperationNum? num;

  @override
  int get hashCode => Object.hash(id, num);

  @override
  bool operator ==(Object other) {
    return other is _OperationIdentifier && other.id == id && other.num == num;
  }
}
