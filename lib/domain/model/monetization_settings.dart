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

import 'precise_date_time/precise_date_time.dart';
import 'price.dart';

/// Monetization settings of an [User].
class MonetizationSettings {
  MonetizationSettings({this.donation, required this.createdAt});

  /// Monetization settings of [Donation]s.
  final MonetizationSettingsDonation? donation;

  /// [PreciseDateTime] when these [MonetizationSettings] were created.
  final PreciseDateTime createdAt;
}

/// Monetization settings of [Donation]s.
class MonetizationSettingsDonation {
  MonetizationSettingsDonation({this.enabled = true, required this.min});

  /// Indicator whether the [User] accepts [Donation]s or not.
  final bool enabled;

  /// Minimal [Price] of [Donation]s allowed in the [Chat] with the [User].
  final Price min;
}
