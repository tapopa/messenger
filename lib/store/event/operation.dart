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

import '/api/backend/schema.dart' show OperationOrigin;
import '/domain/model/chat_call.dart';
import '/domain/model/chat.dart';
import '/domain/model/operation.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/store/model/operation.dart';

/// Possible kinds of a [OperationEvent].
enum OperationEventKind {
  canceled,
  chargeCreated,
  depositBonusCreated,
  depositCompleted,
  depositCreated,
  depositDeclined,
  depositFailed,
  dividendCreated,
  earnDonationCreated,
  grantCreated,
  purchaseDonationCreated,
  rewardCreated,
}

/// Tag representing a [OperationsEvents] kind.
enum OperationsEventsKind { initialized, list, event }

/// [Operation] event union.
abstract class OperationsEvents {
  const OperationsEvents();

  /// [OperationsEventsKind] of this event.
  OperationsEventsKind get kind;
}

/// Indicator notifying about a GraphQL subscription being successfully
/// initialized.
class OperationsEventsInitialized extends OperationsEvents {
  const OperationsEventsInitialized();

  @override
  OperationsEventsKind get kind => OperationsEventsKind.initialized;
}

/// Initial state of the [Operation]s.
class OperationsEventsList extends OperationsEvents {
  const OperationsEventsList();

  @override
  OperationsEventsKind get kind => OperationsEventsKind.list;
}

/// [OperationsEventsEvent] happening in the [Operation]s.
class OperationsEventsEvent extends OperationsEvents {
  const OperationsEventsEvent(this.event);

  /// [OperationsEventsVersioned] itself.
  final OperationsEventsVersioned event;

  @override
  OperationsEventsKind get kind => OperationsEventsKind.event;
}

/// [OperationsEvents]s along with the corresponding [OperationVersion].
class OperationsEventsVersioned {
  const OperationsEventsVersioned(this.events, this.ver, this.listVer);

  /// [OperationEvent]s themselves.
  final List<OperationEvent> events;

  /// Version of the [Operation]'s state updated by these [OperationEvent]s.
  final OperationVersion ver;

  /// Version of the [OperationsEventsList] state updated by these [events].
  final OperationVersion listVer;
}

/// Events happening in a [Chat].
abstract class OperationEvent {
  const OperationEvent(this.id, this.origin, this.at, this.operation);

  /// ID of the [Operation] this [OperationEvent] is related to.
  final OperationId id;

  /// [OperationOrigin] this [OperationEvent] happened in.
  final OperationOrigin origin;

  /// [PreciseDateTime] when this [OperationEvent] happened.
  final PreciseDateTime at;

  /// [DtoOperation] that was affected by this [OperationEvent].
  final DtoOperation operation;

  /// Returns [OperationEventKind] of this [OperationEvent].
  OperationEventKind get kind;
}

/// Event of an [Operation] being canceled.
class EventOperationCanceled extends OperationEvent {
  const EventOperationCanceled(
    super.id,
    super.origin,
    super.at,
    super.operation,
    this.canceled,
  );

  /// [PreciseDateTime] when the [ChatCall] was moved.
  final OperationCancellation canceled;

  @override
  OperationEventKind get kind => OperationEventKind.canceled;
}

/// Event of a new [OperationCharge] being created.
class EventOperationChargeCreated extends OperationEvent {
  const EventOperationChargeCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.chargeCreated;
}

/// Event of a new [OperationDepositBonus] being created.
class EventOperationDepositBonusCreated extends OperationEvent {
  const EventOperationDepositBonusCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.depositBonusCreated;
}

/// Event of an [OperationDeposit] being completed.
class EventOperationDepositCompleted extends OperationEvent {
  const EventOperationDepositCompleted(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.depositCompleted;
}

/// Event of a new [OperationDeposit] being created.
class EventOperationDepositCreated extends OperationEvent {
  const EventOperationDepositCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.depositCreated;
}

/// Event of an [OperationDeposit] being declined.
class EventOperationDepositDeclined extends OperationEvent {
  const EventOperationDepositDeclined(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.depositDeclined;
}

/// Event of an [OperationDeposit] being failed.
class EventOperationDepositFailed extends OperationEvent {
  const EventOperationDepositFailed(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.depositFailed;
}

/// Event of a new [OperationDividend] being created.
class EventOperationDividendCreated extends OperationEvent {
  const EventOperationDividendCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.dividendCreated;
}

/// Event of a new [OperationEarnDonation] being created.
class EventOperationEarnDonationCreated extends OperationEvent {
  const EventOperationEarnDonationCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.earnDonationCreated;
}

/// Event of a new [OperationGrant] being created.
class EventOperationGrantCreated extends OperationEvent {
  const EventOperationGrantCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.grantCreated;
}

/// Event of a new [OperationPurchaseDonation] being created.
class EventOperationPurchaseDonationCreated extends OperationEvent {
  const EventOperationPurchaseDonationCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.purchaseDonationCreated;
}

/// Event of a new [OperationReward] being created.
class EventOperationRewardCreated extends OperationEvent {
  const EventOperationRewardCreated(
    super.id,
    super.origin,
    super.at,
    super.operation,
  );

  @override
  OperationEventKind get kind => OperationEventKind.rewardCreated;
}
