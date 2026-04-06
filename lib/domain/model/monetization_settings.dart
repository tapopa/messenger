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
import 'promo_share.dart';
import 'user.dart';

part 'monetization_settings.g.dart';

/// Monetization settings of an [User].
@JsonSerializable()
class MonetizationSettings implements Comparable<MonetizationSettings> {
  MonetizationSettings({
    this.donation,
    this.message,
    this.referral,
    this.user,
    required this.createdAt,
  });

  /// Constructs a [MonetizationSettings] from the provided [json].
  factory MonetizationSettings.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsFromJson(json);

  /// Monetization settings of [Donation]s.
  final MonetizationSettingsDonation? donation;

  /// Monetization settings of [ChatMessage]s/[ChatForward]s.
  final MonetizationSettingsMessage? message;

  /// Monetization settings of a referral program.
  final MonetizationSettingsReferral? referral;

  /// [User] these [MonetizationSettings] are specified individually for.
  final UserId? user;

  /// [PreciseDateTime] when these [MonetizationSettings] were created.
  final PreciseDateTime createdAt;

  /// Returns a [Map] representing this [MonetizationSettings].
  Map<String, dynamic> toJson() => _$MonetizationSettingsToJson(this);

  @override
  String toString() =>
      'MonetizationSettings(user: $user, donation: $donation, message: $message, referral: $referral)';

  @override
  int compareTo(MonetizationSettings other) {
    final at = other.createdAt.compareTo(createdAt);
    if (at == 0) {
      if (user != null && other.user != null) {
        return user!.val.compareTo(other.user!.val);
      } else if (other.user == null) {
        return 1;
      } else if (user == null) {
        return -1;
      }

      return 0;
    }

    return at;
  }
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

  @override
  String toString() => 'MonetizationSettingsDonation($enabled, $min)';
}

/// Monetization settings of [ChatMessage]s and [ChatForward]s.
@JsonSerializable()
class MonetizationSettingsMessage {
  MonetizationSettingsMessage({this.enabled = true, this.price});

  /// Constructs a [MonetizationSettingsMessage] from the provided [json].
  factory MonetizationSettingsMessage.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsMessageFromJson(json);

  /// Indicator whether the [User] accepts [ChatMessage]s/[ChatForward]s or not.
  final bool enabled;

  /// [Price] that should be paid for each [ChatMessage]/[ChatForward] sent to
  /// the [User].
  final Price? price;

  /// Returns a [Map] representing this [MonetizationSettingsMessage].
  Map<String, dynamic> toJson() => _$MonetizationSettingsMessageToJson(this);

  @override
  String toString() => 'MonetizationSettingsMessage($enabled, $price)';
}

/// Monetization settings of a referral program.
@JsonSerializable()
class MonetizationSettingsReferral {
  MonetizationSettingsReferral({this.fee});

  /// Constructs a [MonetizationSettingsReferral] from the provided [json].
  factory MonetizationSettingsReferral.fromJson(Map<String, dynamic> json) =>
      _$MonetizationSettingsReferralFromJson(json);

  /// [Percentage] that the referee [User] pays to a referrer [User] for each
  /// received [OperationEarnDonation] caused by some referral [User].
  final Percentage? fee;

  /// Returns a [Map] representing this [MonetizationSettingsReferral].
  Map<String, dynamic> toJson() => _$MonetizationSettingsReferralToJson(this);

  @override
  String toString() => 'MonetizationSettingsReferral($fee)';
}
