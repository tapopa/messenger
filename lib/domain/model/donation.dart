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

import '/util/new_type.dart';
import 'operation.dart';
import 'price.dart';

part 'donation.g.dart';

/// [Donation] attached to a [ChatMessage].
@JsonSerializable()
class Donation {
  const Donation({required this.id, required this.amount, this.operation});

  /// Constructs a [Donation] from the provided [json].
  factory Donation.fromJson(Map<String, dynamic> json) =>
      _$DonationFromJson(json);

  /// Unique ID of this [Donation].
  final DonationId id;

  /// [Sum] of this [Donation].
  final Sum amount;

  /// [OperationId] representing this [Donation].
  final OperationId? operation;

  /// Returns a [Map] representing this [Donation].
  Map<String, dynamic> toJson() => _$DonationToJson(this);

  @override
  String toString() =>
      'Donation(id: $id, amount: $amount, operation: $operation)';
}

/// ID of a `Donation`.
class DonationId extends NewType<String> {
  const DonationId(super.val);

  /// Constructs a [DonationId] from the provided [val].
  factory DonationId.fromJson(String val) = DonationId;

  /// Returns a [String] representing this [DonationId].
  String toJson() => val;
}
