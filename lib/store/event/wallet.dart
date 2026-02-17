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
