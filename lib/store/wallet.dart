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
import '/api/backend/schema.dart'
    show
        OperationStatus,
        BalanceOrigin,
        BalanceUpdates$Subscription,
        BalanceUpdates$Subscription$BalanceUpdates$SubscriptionInitialized,
        BalanceUpdates$Subscription$BalanceUpdates$Balance;
import '/domain/model/balance.dart';
import '/domain/model/country.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/domain/model/price.dart';
import '/domain/model/user.dart';
import '/domain/repository/wallet.dart';
import '/domain/service/disposable_service.dart';
import '/provider/gql/graphql.dart';
import '/util/log.dart';
import '/util/stream_utils.dart';
import '/util/web/web.dart';
import 'event/balance.dart';
import 'model/operation.dart';
import 'model/page_info.dart';
import 'paginated.dart';
import 'pagination.dart';
import 'pagination/graphql.dart';

typedef OperationsPaginated =
    RxPaginatedImpl<OperationId, Operation, DtoOperation, OperationsCursor>;

/// [MyUser] wallet repository interface.
class WalletRepository extends IdentityDependency
    implements AbstractWalletRepository {
  WalletRepository(this._graphQlProvider, {required super.me});

  @override
  final Rx<Balance> balance = Rx(Balance.zero);

  @override
  late final OperationsPaginated operations = OperationsPaginated(
    initial: [
      {
        OperationId('aaaaaaaaaa'): OperationDeposit(
          id: OperationId('aaaaaaaaaa'),
          num: OperationNum(BigInt.from(1)),
          status: OperationStatus.inProgress,
          amount: Price(sum: Sum(10), currency: Currency('G')),
          createdAt: PreciseDateTime.now().subtract(
            Duration(days: 5, hours: 3, minutes: 2, seconds: 10),
          ),
          billingCountry: CountryCode('US'),
        ),
        OperationId('bbbbbbbbbb'): OperationDeposit(
          id: OperationId('bbbbbbbbbb'),
          num: OperationNum(BigInt.from(2)),
          status: OperationStatus.failed,
          amount: Price(sum: Sum(50), currency: Currency('G')),
          createdAt: PreciseDateTime.now().subtract(
            Duration(days: 2, hours: 7, minutes: 49, seconds: 49),
          ),
          billingCountry: CountryCode('US'),
        ),
        OperationId('cccccccccc'): OperationDeposit(
          id: OperationId('cccccccccc'),
          num: OperationNum(BigInt.from(3)),
          status: OperationStatus.completed,
          invoice: InvoiceFile('example.com'),
          amount: Price(sum: Sum(1000), currency: Currency('G')),
          createdAt: PreciseDateTime.now(),
          billingCountry: CountryCode('US'),
        ),
        OperationId('dddddddddd'): OperationDepositBonus(
          id: OperationId('dddddddddd'),
          num: OperationNum(BigInt.from(4)),
          status: OperationStatus.completed,
          amount: Price(sum: Sum(5), currency: Currency('G')),
          createdAt: PreciseDateTime.now(),
          depositId: OperationId('cccccccccc'),
        ),
      },
    ],
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
    transform: ({required DtoOperation data, Operation? previous}) {
      return data.value;
    },
  );

  @override
  final RxList<OperationDepositMethod> methods = RxList();

  /// [GraphQlProvider] for fetching the [Operation]s list.
  final GraphQlProvider _graphQlProvider;

  /// [Balance] subscription.
  StreamQueue<BalanceUpdates>? _remoteSubscription;

  @override
  void onInit() {
    Log.debug('onInit()', '$runtimeType');
    super.onInit();
  }

  @override
  void onClose() {
    _remoteSubscription?.close(immediate: true);
    super.onClose();
  }

  @override
  void onIdentityChanged(UserId me) {
    super.onIdentityChanged(me);

    Log.debug('onIdentityChanged($me)', '$runtimeType');

    operations.clear();
    balance.value = Balance.zero;
    _remoteSubscription?.close(immediate: true);

    if (!me.isLocal) {
      operations.around();
      _queryMethods();

      _initRemoteSubscription();
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
      first: first,
      after: after,
      last: last,
      before: before,
    );

    return Page(
      query.edges.map((e) => e.node.toDto(cursor: e.cursor)).toList(),
      query.pageInfo.toModel((c) => OperationsCursor(c)),
    );
  }

  /// Queries the available [OperationDepositMethod]s into [methods].
  Future<void> _queryMethods() async {
    final list = await _graphQlProvider.operationDepositMethods();
    methods.value = list.map((e) => e.toModel()).toList();
  }

  /// Initializes [_balanceUpdates] subscription.
  Future<void> _initRemoteSubscription() async {
    Log.debug('_initRemoteSubscription()', '$runtimeType');

    _remoteSubscription?.close(immediate: true);

    if (me.isLocal || isClosed) {
      return;
    }

    await WebUtils.protect(() async {
      if (me.isLocal || isClosed) {
        return;
      }

      _remoteSubscription = StreamQueue(await _balanceUpdates());
      await _remoteSubscription!.execute(_balanceUpdate);
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
}
