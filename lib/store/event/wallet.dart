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
import 'package:graphql/client.dart';

import '/api/backend/extension/wallet.dart';
import '/api/backend/schema.dart';
import '/util/log.dart';
import 'operation.dart';

/// Returns a [Stream] of [Balance]s of the specified [MyUser]'s purse.
Future<Stream<OperationsEvents>> operationsEvents(
  Stream<QueryResult> events,
) async {
  Log.debug('operationsEvents()');

  return events.asyncExpand((event) async* {
    Log.debug('_operationsEvents() -> ${event.data}', 'WalletRepository');

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
          mixin.events.map(operationEvent).toList(),
          mixin.ver,
          mixin.listVer,
        ),
      );
    }
  });
}

/// Constructs a [OperationEvent] from the
/// [OperationEventsVersionedMixin$Events].
OperationEvent operationEvent(OperationEventsVersionedMixin$Events e) {
  Log.trace('_operationEvent($e)', 'WalletRepository');

  if (e.$$typename == 'OperationCanceledEvent') {
    e as OperationEventsVersionedMixin$Events$OperationCanceledEvent;
    return OperationCanceledEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
      e.canceled.toModel(),
    );
  } else if (e.$$typename == 'OperationChargeCreatedEvent') {
    return OperationChargeCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDepositBonusCreatedEvent') {
    return OperationDepositBonusCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDepositCompletedEvent') {
    return OperationDepositCompletedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDepositCreatedEvent') {
    return OperationDepositCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDepositDeclinedEvent') {
    return OperationDepositDeclinedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDepositFailedEvent') {
    return OperationDepositFailedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationDividendCreatedEvent') {
    return OperationDividendCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationEarnDonationCreatedEvent') {
    return OperationEarnDonationCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationGrantCreatedEvent') {
    return OperationGrantCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationPurchaseDonationCreatedEvent') {
    return OperationPurchaseDonationCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else if (e.$$typename == 'OperationRewardCreatedEvent') {
    return OperationRewardCreatedEvent(
      e.id,
      e.origin,
      e.at,
      e.operation.node.toDto(cursor: e.operation.cursor),
    );
  } else {
    throw UnimplementedError('Unknown OperationEvent: ${e.$$typename}');
  }
}
