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

// ignore_for_file: avoid_types_as_parameter_names

import '/api/backend/schema.dart'
    show
        OperationStatus,
        OperationDepositKind,
        OperationOrigin,
        OperationDirection,
        OperationCancellationCode,
        OperationRewardCause;
import '/util/new_type.dart';
import 'chat.dart';
import 'chat_item.dart';
import 'country.dart';
import 'donation.dart';
import 'precise_date_time/precise_date_time.dart';
import 'price.dart';
import 'user.dart';

/// Billing operation.
abstract class Operation implements Comparable<Operation> {
  Operation({
    required this.id,
    required this.num,
    this.status = OperationStatus.completed,
    required this.amount,
    required this.createdAt,
    this.canceled,
    required this.origin,
    required this.direction,
    this.holdUntil,
  });

  /// ID of this [Operation].
  final OperationId id;

  /// Sequential number of this [Operation].
  final OperationNum num;

  /// [OperationStatus] of this [Operation].
  OperationStatus status;

  /// Money [Sum] and [Currency] of this [Operation].
  final Price amount;

  /// [PreciseDateTime] when this [Operation] was created.
  final PreciseDateTime createdAt;

  /// Information about why this [Operation] was canceled, if it was.
  final OperationCancellation? canceled;

  /// [OperationOrigin] of this [Operation].
  final OperationOrigin origin;

  /// [OperationDirection] of this [Operation].
  final OperationDirection direction;

  /// [PreciseDateTime] until which this [Operation] is on hold.
  final PreciseDateTime? holdUntil;

  @override
  int compareTo(Operation other) {
    final at = other.createdAt.compareTo(createdAt);
    if (at == 0) {
      return id.val.compareTo(other.id.val);
    }

    return at;
  }
}

/// [Operation] of charging money from [MyUser].
class OperationCharge extends Operation {
  OperationCharge({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    required this.reason,
  });

  /// Reason of this [OperationCharge].
  final OperationReason reason;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    reason,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationCharge &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        reason == other.reason;
  }
}

/// [Operation] of depositing money to [MyUser]'s purse.
class OperationDeposit extends Operation {
  OperationDeposit({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    required this.billingCountry,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    this.kind = OperationDepositKind.paypal,
    this.invoice,
    this.processingUrl,
    this.pricing,
  });

  /// Kind of this [OperationDeposit].
  final OperationDepositKind kind;

  /// Country of the billing address of this [OperationDeposit].
  final CountryCode billingCountry;

  /// [InvoiceFile] of this [OperationDeposit].
  ///
  /// `null` if this [status] is not `COMPLETED`.
  final InvoiceFile? invoice;

  /// [Url] to process this [OperationDeposit] on.
  final Url? processingUrl;

  /// Pricing of this [OperationDeposit].
  final OperationDepositPricing? pricing;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    kind,
    billingCountry,
    invoice,
    processingUrl,
    pricing,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationDeposit &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        kind == other.kind &&
        billingCountry == other.billingCountry &&
        invoice == other.invoice &&
        processingUrl == other.processingUrl &&
        pricing == other.pricing;
  }

  @override
  String toString() =>
      'OperationDeposit($id, createdAt: $createdAt, status: ${status.name})';
}

/// [Operation] of depositing money to [MyUser]'s purse.
class OperationDepositBonus extends Operation {
  OperationDepositBonus({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required this.depositId,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,
  });

  /// [OperationDeposit] this [OperationDepositBonus] is related to.
  final OperationId depositId;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    depositId,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationDepositBonus &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        depositId == other.depositId;
  }
}

/// [Operation] of receiving dividend money.
class OperationDividend extends Operation {
  OperationDividend({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    required this.sourceId,
  });

  /// ID of the source [Operation] this [OperationDividend] is created for.
  final OperationId sourceId;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    sourceId,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationDividend &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        sourceId == other.sourceId;
  }
}

/// [Operation] of earning money as a `Vendor` from a made [Donation].
class OperationEarnDonation extends Operation {
  OperationEarnDonation({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    this.chatItemId,
    this.chatId,
    required this.donationId,
    required this.customerId,
  });

  /// [ChatItemId] the earned [Donation] is part of.
  final ChatItemId? chatItemId;

  /// [ChatId] the related [ChatItem] of the earned [Donation] belongs to.
  final ChatId? chatId;

  /// ID of the [Donation] earned by this [OperationEarnDonation].
  final DonationId donationId;

  /// [UserId] who made the [Donation] triggering this [OperationEarnDonation].
  final UserId customerId;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    chatItemId,
    chatId,
    donationId,
    customerId,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationEarnDonation &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        chatItemId == other.chatItemId &&
        chatId == other.chatId &&
        donationId == other.donationId &&
        customerId == other.customerId;
  }
}

/// [Operation] of granting money to [MyUser].
class OperationGrant extends Operation {
  OperationGrant({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    required this.reason,
  });

  /// Reason of this [OperationGrant].
  final OperationReason reason;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    reason,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationGrant &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        reason == other.reason;
  }
}

/// [Operation] of making a [Donation] by a [User] to some `Vendor`.
class OperationPurchaseDonation extends Operation {
  OperationPurchaseDonation({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    this.chatItemId,
    this.chatId,
    required this.donationId,
    required this.vendorId,
  });

  /// [ChatItemId] the made Donation is part of.
  final ChatItemId? chatItemId;

  /// [ChatId] the related [ChatItem] of the made [Donation] belongs to
  final ChatId? chatId;

  /// ID of the [Donation] made by this [OperationPurchaseDonation].
  final DonationId donationId;

  /// `Vendor` receiving the [Donation] made by this
  /// [OperationPurchaseDonation].
  final UserId vendorId;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    chatItemId,
    chatId,
    donationId,
    vendorId,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationPurchaseDonation &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        chatItemId == other.chatItemId &&
        chatId == other.chatId &&
        donationId == other.donationId &&
        vendorId == other.vendorId;
  }
}

/// [Operation] of rewarding [MyUser] due to affiliation program.
class OperationReward extends Operation {
  OperationReward({
    required super.id,
    required super.num,
    super.status = OperationStatus.completed,
    required super.amount,
    required super.createdAt,
    super.canceled,
    required super.origin,
    required super.direction,
    super.holdUntil,

    required this.cause,
    required this.affiliatedNum,
  });

  /// Cause of this [OperationReward].
  final OperationRewardCause cause;

  /// Sequential number of the affiliated [User] causing this [OperationReward].
  final UserAffiliatedNum affiliatedNum;

  @override
  int get hashCode => Object.hash(
    id,
    this.num,
    status,
    amount,
    createdAt,
    canceled,
    origin,
    direction,
    holdUntil,
    cause,
    affiliatedNum,
  );

  @override
  bool operator ==(Object other) {
    return other is OperationReward &&
        id == other.id &&
        this.num == other.num &&
        status == other.status &&
        amount == other.amount &&
        createdAt == other.createdAt &&
        canceled == other.canceled &&
        direction == other.direction &&
        holdUntil == other.holdUntil &&
        cause == other.cause &&
        affiliatedNum == other.affiliatedNum;
  }
}

/// ID of an [Operation].
class OperationId extends NewType<String> {
  const OperationId(super.val);
}

/// Sequential number of an [Operation].
class OperationNum extends NewType<BigInt> implements Comparable<OperationNum> {
  const OperationNum(super.val);

  /// Constructs an [OperationNum] from the provided [String].
  OperationNum.parse(String val) : super(BigInt.parse(val));

  /// Constructs an [OperationNum] from the provided [int].
  OperationNum.from(int val) : super(BigInt.from(val));

  @override
  int compareTo(OperationNum other) => val.compareTo(other.val);
}

/// Base64-encoded PDF invoice of an [Operation].
class InvoiceFile extends NewType<String> {
  const InvoiceFile(super.val);
}

/// Arbitrary additional reason of an [OperationCancellation].
class OperationCancellationReason extends NewType<String> {
  const OperationCancellationReason(super.val);
}

/// Information about [Operation]'s cancellation.
class OperationCancellation {
  OperationCancellation({required this.code, this.reason, required this.at});

  /// Code explaining why the [Operation] was canceled.
  final OperationCancellationCode code;

  /// Additional reason of why the [Operation] was canceled.
  final OperationCancellationReason? reason;

  /// [PreciseDateTime] when the [Operation] was canceled.
  final PreciseDateTime at;

  @override
  int get hashCode => Object.hash(code, reason, at);

  @override
  bool operator ==(Object other) {
    return other is OperationCancellation &&
        code == other.code &&
        reason == other.reason &&
        at == other.at;
  }
}

/// Reason of an [Operation] creation.
class OperationReason extends NewType<String> {
  const OperationReason(super.val);
}

/// URL in [RFC 3986] format.
///
/// [RFC 3986]: https://datatracker.ietf.org/doc/html/rfc3986
class Url extends NewType<String> {
  const Url(super.val);
}

/// Sequential number of an affiliated [User].
class UserAffiliatedNum extends NewType<String> {
  const UserAffiliatedNum(super.val);

  @override
  String toString() {
    try {
      return UserNum(val).toString();
    } catch (_) {
      return val;
    }
  }
}

/// Pricing of an [OperationDeposit].
class OperationDepositPricing {
  OperationDepositPricing({
    required this.nominal,
    this.bonus,
    this.withoutTax,
    this.tax,
    this.total,
  });

  /// Nominal [Price] of the [OperationDeposit].
  final Price nominal;

  /// Bonus of the nominal [Price] to be granted as a separate
  /// [OperationDepositBonus] once the original [OperationDeposit] is completed
  /// successfully.
  final PriceModifier? bonus;

  /// Calculated [Price] of the [OperationDeposit] to be paid, before the tax
  /// being applied, in the provided [Currency].
  final Price? withoutTax;

  /// Tax applied to the [withoutTax] [Price], according to the billing
  /// [CountryCode] of the [OperationDeposit], in the provided [Currency].
  final PriceModifier? tax;

  /// Calculated total [Price] of the [OperationDeposit] to be paid, after the
  /// tax being applied, in the provided [Currency].
  final Price? total;
}
