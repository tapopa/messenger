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
import 'package:get/get.dart';
import 'package:graphql/client.dart' show QueryResult;
import 'package:mutex/mutex.dart';

import '/api/backend/extension/page_info.dart';
import '/api/backend/extension/wallet.dart';
import '/api/backend/schema.dart';
import '/domain/model/balance.dart';
import '/domain/model/monetization_settings.dart';
import '/domain/model/operation.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/domain/model/price.dart';
import '/domain/model/user.dart';
import '/domain/repository/partner.dart';
import '/domain/service/disposable_service.dart';
import '/provider/gql/graphql.dart';
import '/util/log.dart';
import '/util/stream_utils.dart';
import '/util/web/web_utils.dart';
import 'event/balance.dart';
import 'event/monetization_settings.dart';
import 'event/operation.dart';
import 'event/wallet.dart' show operationsEvents;
import 'model/monetization_settings.dart';
import 'model/operation.dart';
import 'model/page_info.dart';
import 'paginated.dart';
import 'pagination.dart';
import 'pagination/graphql.dart';
import 'wallet.dart';

typedef MonetizationSettingsPaginated =
    RxPaginatedImpl<
      UserId,
      Rx<MonetizationSettings>,
      DtoMonetizationSettings,
      MonetizationSettingsCursor
    >;

/// [MyUser] wallet repository interface.
class PartnerRepository extends IdentityDependency
    implements AbstractPartnerRepository {
  PartnerRepository(this._graphQlProvider, {required super.me});

  @override
  final Rx<Balance> available = Rx(Balance.zero);

  @override
  final Rx<Balance> hold = Rx(Balance.zero);

  @override
  final Rx<MonetizationSettings> settings = Rx(
    MonetizationSettings(createdAt: PreciseDateTime.now()),
  );

  @override
  final RxMap<UserId, Rx<MonetizationSettings>> individual = RxMap();

  @override
  final RxInt total = RxInt(0);

  @override
  late final MonetizationSettingsPaginated paginated =
      MonetizationSettingsPaginated(
        pagination: Pagination(
          onKey: (e) => e.value.user ?? UserId.local(),
          perPage: 15,
          provider: GraphQlPageProvider(
            fetch: ({after, before, first, last}) async {
              return await _monetizationSettings(
                after: after,
                before: before,
                first: first,
                last: last,
              );
            },
          ),
          compare: (a, b) => a.compareTo(b),
        ),
        transform:
            ({
              required DtoMonetizationSettings data,
              Rx<MonetizationSettings>? previous,
            }) {
              if (previous != null) {
                return previous..value = data.value;
              }

              return Rx(data.value);
            },
        compare: (a, b) => a.value.compareTo(b.value),
      );

  @override
  RxMap<UserId, Rx<MonetizationSettings>> monetization = RxMap();

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
      if (previous != null) {
        return previous..value = data.value;
      }

      return Rx(data.value);
    },
    compare: (a, b) => a.value.compareTo(b.value),
  );

  /// [GraphQlProvider] for fetching the [Balance]s.
  final GraphQlProvider _graphQlProvider;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _availableSubscription;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _holdSubscription;

  /// [Operation]s subscription.
  StreamQueue<OperationsEvents>? _operationsSubscription;

  /// [MonetizationSettings] subscription.
  StreamQueue<MonetizationSettingsEvents>? _myMonetizationSettingsSubscription;

  /// Latest [OperationVersion] of the [operations] list events.
  OperationVersion? _ver;

  /// [MonetizationSettingsVersion] of the [settings] currently applied, if any.
  MonetizationSettingsVersion? _monetizationSettingsVer;

  /// [Mutex]ex guarding access to [get].
  final Map<_OperationIdentifier, Mutex> _locks = {};

  /// [StreamController] for the [updatesFor] listening of
  /// [MonetizationSettings] updates for [individual] users.
  final Map<UserId, StreamController<MonetizationSettings?>> _updates = {};

  /// [_monetizationSettingsEvents] of [_updates].
  final Map<UserId, StreamQueue<MonetizationSettingsEvents>> _subscriptions =
      {};

  @override
  void onInit() {
    Log.debug('onInit()', '$runtimeType');
    super.onInit();
  }

  @override
  void onClose() {
    Log.debug('onClose()', '$runtimeType');

    _availableSubscription?.close(immediate: true);
    _holdSubscription?.close(immediate: true);
    _operationsSubscription?.close(immediate: true);
    _myMonetizationSettingsSubscription?.close(immediate: true);
    operations.dispose();
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
    _operationsSubscription?.close(immediate: true);
    _myMonetizationSettingsSubscription?.close(immediate: true);

    for (var e in _updates.values) {
      e.close();
    }
    _updates.clear();

    for (var e in _subscriptions.values) {
      e.cancel();
    }
    _subscriptions.clear();

    if (!me.isLocal) {
      operations.around();

      _initAvailableSubscription();
      _initHoldSubscription();
      _initOperationsSubscription();
      _initMyMonetizationSettingsSubscription();
    }
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

  @override
  Stream<MonetizationSettings?> updatesFor(UserId id) {
    final controller = _updates[id] ??= StreamController.broadcast(
      onListen: () async {
        Log.debug('updates($id) -> onListen()', '$runtimeType($id)');
        await _initMonetizationSubscription(id);
      },
      onCancel: () {
        Log.debug('updates($id) -> onCancel()', '$runtimeType($id)');
        _subscriptions.remove(id)?.close(immediate: true);
      },
    );

    _updates[id]?.add(monetization[id]?.value);

    return controller.stream;
  }

  @override
  Future<void> updateMonetizationSettings({
    UserId? userId,
    bool? donationsEnabled,
    Sum? donationsMinimum,
  }) async {
    Log.debug(
      'updateMonetizationSettings(userId: $userId, donationsEnabled: $donationsEnabled, donationsMinimum: $donationsMinimum)',
      '$runtimeType',
    );

    final bool hasAny = donationsEnabled != null || donationsMinimum != null;

    if (userId != null) {
      final Rx<MonetizationSettings>? existing = individual[userId];

      // If any setting is provided, then apply the [MonetizationSettings].
      if (hasAny) {
        final settings = MonetizationSettings(
          createdAt: PreciseDateTime.now(),
          donation: MonetizationSettingsDonation(
            enabled: donationsEnabled ?? true,
            min: Price.xxx(donationsMinimum?.val ?? 1),
          ),
        );

        if (existing != null) {
          existing.value = settings;
        } else {
          individual[userId] = Rx(settings);
        }
      }
      // Otherwise remove the applied settings, if any.
      else {
        individual.remove(userId);
        paginated.remove(userId);
      }
    }

    final mixin = await _graphQlProvider.updateMonetizationSettings(
      userId: userId,
      settings: MonetizationSettingsInput(
        donation: MonetizationSettingsDonationInput(
          // `null` provided in the `new` argument resets the settings to use
          // the default one set by [MyUser].
          kw$new: donationsEnabled == null && donationsMinimum == null
              ? null
              : MonetizationSettingsDonationSettingsInput(
                  enabled:
                      donationsEnabled ??
                      settings.value.donation?.enabled ??
                      true,
                  min:
                      donationsMinimum ??
                      settings.value.donation?.min.sum ??
                      Sum(1),
                ),
        ),
      ),
    );

    if (mixin != null) {
      final events = MonetizationSettingsEventsEvent(
        MonetizationSettingsEventsVersioned(
          mixin.events.map(_decodeMonetizationSettingsEvent).toList(),
          mixin.ver,
          mixin.listVer,
        ),
      );

      if (userId == null) {
        _myMonetizationSettingsEvent(events);
      } else {
        _monetizationSettingsEvent(events, userId);
      }
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

      _operationsSubscription = StreamQueue(
        await operationsEvents(
          await _graphQlProvider.operationsEvents(
            OperationOrigin.income,
            null,
            () => null,
          ),
        ),
      );
      await _operationsSubscription!.execute(_operationsEvent);
    }, tag: 'partner.operationsEvents()');
  }

  /// Handles [OperationsEvents] from the [operationsEvents] subscription.
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

  /// Initializes [operations] subscription.
  Future<void> _initMyMonetizationSettingsSubscription() async {
    Log.debug('_initMyMonetizationSettingsSubscription()', '$runtimeType');

    _myMonetizationSettingsSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _myMonetizationSettingsSubscription = StreamQueue(
        await _myMonetizationSettingsEvents(),
      );

      await _myMonetizationSettingsSubscription!.execute(
        _myMonetizationSettingsEvent,
      );
    }, tag: 'myMonetizationSettingsEvents()');
  }

  /// Handles [MonetizationSettingsEvents].
  ///
  /// If [of] is `null`, then these [events] are [MyUser] related.
  void _myMonetizationSettingsEvent(
    MonetizationSettingsEvents events, {
    bool updateVersion = true,
  }) {
    switch (events.kind) {
      case MonetizationSettingsEventsKind.initialized:
        events as MonetizationSettingsEventsInitialized;
        Log.debug(
          '_myMonetizationSettingsEvent(${events.kind})',
          '$runtimeType',
        );
        break;

      case MonetizationSettingsEventsKind.list:
        events as MonetizationSettingsEventsList;
        Log.debug(
          '_myMonetizationSettingsEvent(${events.kind})',
          '$runtimeType',
        );

        settings.value = events.myMonetizationSettings?.value ?? settings.value;
        total.value = events.myMonetizationSettingsTotalCount;
        _monetizationSettingsVer = events.myMonetizationSettingsVer;
        break;

      case MonetizationSettingsEventsKind.event:
        events as MonetizationSettingsEventsEvent;

        final MonetizationSettingsEventsVersioned versioned = events.event;

        if (versioned.ver >= _monetizationSettingsVer) {
          Log.debug(
            '_monetizationSettingsEvent(${events.kind}): ignored ${versioned.events.map((e) => e.kind.name).join(', ')}',
            '$runtimeType',
          );
          return;
        }

        if (updateVersion) {
          _monetizationSettingsVer = versioned.ver;
        }

        Log.debug(
          '_operationsEvent(${events.kind}): ${versioned.events.map((e) => e.kind.name).join(', ')}',
          '$runtimeType',
        );

        for (var event in versioned.events) {
          switch (event.kind) {
            case MonetizationSettingsEventKind.donationDeleted:
              event as EventMonetizationSettingsDonationDeleted;
              break;

            case MonetizationSettingsEventKind.donationMinPriceUpdated:
              event as EventMonetizationSettingsDonationMinPriceUpdated;
              break;

            case MonetizationSettingsEventKind.donationToggled:
              event as EventMonetizationSettingsDonationToggled;
              break;
          }

          final UserId? userId = event.userId;
          final MonetizationSettings? monetization =
              event.monetizationSettings?.value;

          if (monetization != null) {
            // `userId` here being non-`null` mean that the settings applied are
            // individual ones.
            if (userId != null && userId != me) {
              final Rx<MonetizationSettings>? existing = individual[userId];
              if (existing != null) {
                existing.value = monetization;
              } else {
                individual[userId] = Rx(monetization);
              }

              final Rx<MonetizationSettings>? stored = paginated.items[userId];
              if (stored != null) {
                stored.value = monetization;
              }
            } else {
              settings.value = monetization;
            }
          } else {
            // `userId` here being non-`null` mean that the settings applied are
            // individual ones.
            if (userId != null && userId != me) {
              individual.remove(userId);
              paginated.remove(userId);
            }
          }
        }
        break;
    }
  }

  /// Handles [MonetizationSettingsEvents].
  ///
  /// If [of] is `null`, then these [events] are [MyUser] related.
  void _monetizationSettingsEvent(
    MonetizationSettingsEvents events,
    UserId of,
  ) {
    switch (events.kind) {
      case MonetizationSettingsEventsKind.initialized:
        events as MonetizationSettingsEventsInitialized;
        Log.debug(
          '_monetizationSettingsEvent(of $of, ${events.kind})',
          '$runtimeType',
        );
        break;

      case MonetizationSettingsEventsKind.list:
        events as MonetizationSettingsEventsList;
        Log.debug(
          '_monetizationSettingsEvent(of $of, ${events.kind})',
          '$runtimeType',
        );

        final MonetizationSettings? settings =
            events.monetizationSettings?.value;

        _updates[of]?.add(settings);

        if (settings == null) {
          monetization.remove(of);
        } else {
          final existing = monetization[of];
          if (existing == null) {
            monetization[of] = Rx(settings);
          } else {
            existing.value = settings;
          }
        }
        break;

      case MonetizationSettingsEventsKind.event:
        events as MonetizationSettingsEventsEvent;

        final MonetizationSettingsEventsVersioned versioned = events.event;

        Log.debug(
          '_monetizationSettingsEvent(of $of, ${events.kind}): ${versioned.events.map((e) => e.kind.name).join(', ')}',
          '$runtimeType',
        );

        for (var event in versioned.events) {
          switch (event.kind) {
            case MonetizationSettingsEventKind.donationDeleted:
              event as EventMonetizationSettingsDonationDeleted;
              break;

            case MonetizationSettingsEventKind.donationMinPriceUpdated:
              event as EventMonetizationSettingsDonationMinPriceUpdated;
              break;

            case MonetizationSettingsEventKind.donationToggled:
              event as EventMonetizationSettingsDonationToggled;
              break;
          }

          final MonetizationSettings? monetization =
              event.monetizationSettings?.value;

          _updates[of]?.add(monetization);

          if (monetization == null) {
            this.monetization.remove(of);
          } else {
            final Rx<MonetizationSettings>? existing = this.monetization[of];
            if (existing == null) {
              this.monetization[of] = Rx(monetization);
            } else {
              existing.value = monetization;
            }
          }
        }
        break;
    }
  }

  /// Returns a [Stream] of [MonetizationSettings] of the currently
  /// authenticated [MyUser].
  Future<Stream<MonetizationSettingsEvents>>
  _myMonetizationSettingsEvents() async {
    Log.debug('_myMonetizationSettingsEvents()');

    final Stream<QueryResult> events = await _graphQlProvider
        .myMonetizationSettingsEvents();

    return events.asyncExpand((event) async* {
      Log.debug(
        '_myMonetizationSettingsEvents() -> ${event.data}',
        '$runtimeType',
      );

      final events = MyMonetizationSettingsEvents$Subscription.fromJson(
        event.data!,
      ).myMonetizationSettingsEvents;

      if (events.$$typename == 'SubscriptionInitialized') {
        events
            as MyMonetizationSettingsEvents$Subscription$MyMonetizationSettingsEvents$SubscriptionInitialized;
        yield const MonetizationSettingsEventsInitialized();
      } else if (events.$$typename == 'MonetizationSettingsList') {
        final mixin =
            events
                as MyMonetizationSettingsEvents$Subscription$MyMonetizationSettingsEvents$MonetizationSettingsList;
        yield MonetizationSettingsEventsList(
          myMonetizationSettings: mixin.myMonetizationSettings.nodes.firstOrNull
              ?.toDto(),
          myMonetizationSettingsVer: mixin.myMonetizationSettings.ver,
          myMonetizationSettingsTotalCount:
              mixin.myMonetizationSettings.totalCount,
        );
      } else if (events.$$typename == 'MonetizationSettingsEventsVersioned') {
        final mixin =
            events
                as MyMonetizationSettingsEvents$Subscription$MyMonetizationSettingsEvents$MonetizationSettingsEventsVersioned;
        yield MonetizationSettingsEventsEvent(
          MonetizationSettingsEventsVersioned(
            mixin.events.map(_decodeMonetizationSettingsEvent).toList(),
            mixin.ver,
            mixin.listVer,
          ),
        );
      }
    });
  }

  /// Constructs a [MonetizationSettingsEvent] from the
  /// [MonetizationSettingsEventsVersionedMixin$Events].
  MonetizationSettingsEvent _decodeMonetizationSettingsEvent(
    MonetizationSettingsEventsVersionedMixin$Events e,
  ) {
    Log.trace('_decodeMonetizationSettingsEvent($e)', '$runtimeType');

    if (e.$$typename == 'EventMonetizationSettingsDonationDeleted') {
      return EventMonetizationSettingsDonationDeleted(
        e.monetizationSettings?.node.toDto(),
        e.user?.id,
        e.at,
      );
    } else if (e.$$typename ==
        'EventMonetizationSettingsDonationMinPriceUpdated') {
      return EventMonetizationSettingsDonationMinPriceUpdated(
        e.monetizationSettings?.node.toDto(),
        e.user?.id,
        e.at,
      );
    } else if (e.$$typename == 'EventMonetizationSettingsDonationToggled') {
      return EventMonetizationSettingsDonationToggled(
        e.monetizationSettings?.node.toDto(),
        e.user?.id,
        e.at,
      );
    } else {
      throw UnimplementedError(
        'Unknown MonetizationSettingsEvent: ${e.$$typename}',
      );
    }
  }

  /// Initializes [operations] subscription.
  Future<void> _initMonetizationSubscription(UserId id) async {
    Log.debug('_initMonetizationSubscription(UserId id)', '$runtimeType');

    _subscriptions.remove(id)?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _subscriptions.remove(id)?.close(immediate: true);
      _subscriptions[id] = StreamQueue(await _monetizationSettingsEvents(id));
      await _subscriptions[id]?.execute(
        (e) => _monetizationSettingsEvent(e, id),
      );
    }, tag: 'monetizationSettingsEvents($id)');
  }

  /// Returns a [Stream] of [MonetizationSettings] of the currently
  /// authenticated [MyUser].
  Future<Stream<MonetizationSettingsEvents>> _monetizationSettingsEvents(
    UserId id,
  ) async {
    Log.debug('_monetizationSettingsEvents($id)');

    final Stream<QueryResult> events = await _graphQlProvider
        .monetizationSettingsEvents(id);

    return events.asyncExpand((event) async* {
      Log.debug(
        '_monetizationSettingsEvents() -> ${event.data}',
        '$runtimeType',
      );

      final events = MonetizationSettingsEvents$Subscription.fromJson(
        event.data!,
      ).monetizationSettingsEvents;

      if (events.$$typename == 'SubscriptionInitialized') {
        events
            as MonetizationSettingsEvents$Subscription$MonetizationSettingsEvents$SubscriptionInitialized;
        yield const MonetizationSettingsEventsInitialized();
      } else if (events.$$typename == 'MonetizationSettingsList') {
        final mixin =
            events
                as MonetizationSettingsEvents$Subscription$MonetizationSettingsEvents$MonetizationSettingsList;
        yield MonetizationSettingsEventsList(
          monetizationSettings: mixin.monetizationSettings?.toDto(),
        );
      } else if (events.$$typename == 'MonetizationSettingsEventsVersioned') {
        final mixin =
            events
                as MonetizationSettingsEvents$Subscription$MonetizationSettingsEvents$MonetizationSettingsEventsVersioned;
        yield MonetizationSettingsEventsEvent(
          MonetizationSettingsEventsVersioned(
            mixin.events.map(_decodeMonetizationSettingsEvent).toList(),
            mixin.ver,
            mixin.listVer,
          ),
        );
      }
    });
  }

  /// Fetches the [MonetizationSettings] with pagination.
  Future<Page<DtoMonetizationSettings, MonetizationSettingsCursor>>
  _monetizationSettings({
    int? first,
    MonetizationSettingsCursor? after,
    int? last,
    MonetizationSettingsCursor? before,
  }) async {
    Log.debug(
      '_monetizationSettings($first, $after, $last, $before)',
      '$runtimeType',
    );

    final query = await _graphQlProvider.myMonetizationSettings(
      first: first,
      after: after,
      last: last,
      before: before,
    );

    total.value = query.totalCount;

    return Page(
      query.edges.map((e) => e.node.toDto(cursor: e.cursor)).toList(),
      query.pageInfo.toModel((c) => MonetizationSettingsCursor(c)),
    );
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
