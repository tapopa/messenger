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

import 'package:json_annotation/json_annotation.dart';

import 'precise_date_time/precise_date_time.dart';
import 'price.dart';
import 'user.dart';

part 'monetization_settings.g.dart';

/// Monetization settings of an [User].
@JsonSerializable()
class MonetizationSettings {
  MonetizationSettings({this.donation, this.user, required this.createdAt});

  /// Constructs a [MonetizationSettings] from the provided [json].
  factory MonetizationSettings.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsFromJson(json);

  /// Monetization settings of [Donation]s.
  final MonetizationSettingsDonation? donation;

  /// [User] these [MonetizationSettings] are specified individually for.
  final UserId? user;

  /// [PreciseDateTime] when these [MonetizationSettings] were created.
  final PreciseDateTime createdAt;

  /// Returns a [Map] representing this [MonetizationSettings].
  Map<String, dynamic> toJson() => _$MonetizationSettingsToJson(this);
}

/// Monetization settings of [Donation]s.
@JsonSerializable()
class MonetizationSettingsDonation {
  MonetizationSettingsDonation({this.enabled = true, required this.min});

  /// Constructs a [MonetizationSettingsDonation] from the provided [json].
  factory MonetizationSettingsDonation.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsDonationFromJson(json);

  /// Indicator whether the [User] accepts [Donation]s or not.
  final bool enabled;

  /// Minimal [Price] of [Donation]s allowed in the [Chat] with the [User].
  final Price min;

  /// Returns a [Map] representing this [MonetizationSettingsDonation].
  Map<String, dynamic> toJson() => _$MonetizationSettingsDonationToJson(this);
}
