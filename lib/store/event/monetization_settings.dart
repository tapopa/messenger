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

import '/domain/model/chat.dart';
import '/domain/model/monetization_settings.dart';
import '/domain/model/precise_date_time/precise_date_time.dart';
import '/store/model/monetization_settings.dart';

/// Possible kinds of a [MonetizationSettingsEvent].
enum MonetizationSettingsEventKind {
  donationDeleted,
  donationMinPriceUpdated,
  donationToggled,
}

/// Tag representing a [MonetizationSettingsEvents] kind.
enum MonetizationSettingsEventsKind { initialized, list, event }

/// [MonetizationSettings] event union.
abstract class MonetizationSettingsEvents {
  const MonetizationSettingsEvents();

  /// [MonetizationSettingsEventsKind] of this event.
  MonetizationSettingsEventsKind get kind;
}

/// Indicator notifying about a GraphQL subscription being successfully
/// initialized.
class MonetizationSettingsEventsInitialized extends MonetizationSettingsEvents {
  const MonetizationSettingsEventsInitialized();

  @override
  MonetizationSettingsEventsKind get kind =>
      MonetizationSettingsEventsKind.initialized;
}

/// Initial state of the [MonetizationSettings].
class MonetizationSettingsEventsList extends MonetizationSettingsEvents {
  const MonetizationSettingsEventsList({
    this.monetizationSettings,
    this.myMonetizationSettings,
    this.myMonetizationSettingsVer,
  });

  /// [MonetizationSettings] of a [User] this [MonetizationSettingsEventsList]
  /// corresponds to.
  final DtoMonetizationSettings? monetizationSettings;

  /// [MonetizationSettings] of a [MyUser] this [MonetizationSettingsEventsList]
  /// corresponds to.
  final DtoMonetizationSettings? myMonetizationSettings;

  /// [MonetizationSettingsVersion] of [myMonetizationSettings].
  final MonetizationSettingsVersion? myMonetizationSettingsVer;

  @override
  MonetizationSettingsEventsKind get kind =>
      MonetizationSettingsEventsKind.list;
}

/// [MonetizationSettingsEventsVersioned] happening in the
/// [MonetizationSettings].
class MonetizationSettingsEventsEvent extends MonetizationSettingsEvents {
  const MonetizationSettingsEventsEvent(this.event);

  /// [MonetizationSettingsEventsVersioned] itself.
  final MonetizationSettingsEventsVersioned event;

  @override
  MonetizationSettingsEventsKind get kind =>
      MonetizationSettingsEventsKind.event;
}

/// [MonetizationSettingsEvents] along with the corresponding
/// [MonetizationSettingsVersion].
class MonetizationSettingsEventsVersioned {
  const MonetizationSettingsEventsVersioned(
    this.events,
    this.ver,
    this.listVer,
  );

  /// [MonetizationSettingsEvent]s themselves.
  final List<MonetizationSettingsEvent> events;

  /// Version of the [MonetizationSettings] state updated by these [MonetizationSettingsEvent]s.
  final MonetizationSettingsVersion ver;

  /// Version of the [MonetizationSettingsEventsList] state updated by these
  /// [events].
  final MonetizationSettingsVersion listVer;
}

/// Events happening in a [Chat].
abstract class MonetizationSettingsEvent {
  const MonetizationSettingsEvent(this.monetizationSettings, this.at);

  /// State of the [MonetizationSettings] after this [MonetizationSettingsEvent]
  /// being applied.
  final DtoMonetizationSettings? monetizationSettings;

  /// [PreciseDateTime] when this [MonetizationSettingsEvent] happened.
  final PreciseDateTime at;

  /// Returns [MonetizationSettingsEventKind] of this [MonetizationSettingsEvent].
  MonetizationSettingsEventKind get kind;
}

/// Event of [MonetizationSettingsDonation] being deleted.
class EventMonetizationSettingsDonationDeleted
    extends MonetizationSettingsEvent {
  const EventMonetizationSettingsDonationDeleted(
    super.monetizationSettings,
    super.at,
  );

  @override
  MonetizationSettingsEventKind get kind =>
      MonetizationSettingsEventKind.donationDeleted;
}

/// Event of a [MonetizationSettingsDonation.min] [Price] being updated.
class EventMonetizationSettingsDonationMinPriceUpdated
    extends MonetizationSettingsEvent {
  const EventMonetizationSettingsDonationMinPriceUpdated(
    super.monetizationSettings,
    super.at,
  );

  @override
  MonetizationSettingsEventKind get kind =>
      MonetizationSettingsEventKind.donationMinPriceUpdated;
}

/// Event of a [MonetizationSettingsDonation.enabled] state being updated.
class EventMonetizationSettingsDonationToggled
    extends MonetizationSettingsEvent {
  const EventMonetizationSettingsDonationToggled(
    super.monetizationSettings,
    super.at,
  );

  @override
  MonetizationSettingsEventKind get kind =>
      MonetizationSettingsEventKind.donationToggled;
}
