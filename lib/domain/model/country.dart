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

import 'package:collection/collection.dart';

import '/util/new_type.dart';
import 'operation_deposit_method.dart';

// ignore_for_file: constant_identifier_names

/// Country code in ISO 3166-1 alpha-2 format.
///
/// [ISO 3166-1 alpha-2]: https://www.iso.org/iso-3166-country-codes.html
class CountryCode extends NewType<String> {
  CountryCode(String val) : super(val.toUpperCase());
}

/// All known country codes in [ISO 3166-1 alpha-2] format.
///
/// [ISO 3166-1 alpha-2]: https://www.iso.org/iso-3166-country-codes.html
enum IsoCode {
  AC,
  AD,
  AE,
  AF,
  AG,
  AI,
  AL,
  AM,
  AO,
  AR,
  AS,
  AT,
  AU,
  AW,
  AX,
  AZ,
  BA,
  BB,
  BD,
  BE,
  BF,
  BG,
  BH,
  BI,
  BJ,
  BL,
  BM,
  BN,
  BO,
  BQ,
  BR,
  BS,
  BT,
  BW,
  BY,
  BZ,
  CA,
  CC,
  CD,
  CF,
  CG,
  CH,
  CI,
  CK,
  CL,
  CM,
  CN,
  CO,
  CR,
  CU,
  CV,
  CW,
  CX,
  CY,
  CZ,
  DE,
  DJ,
  DK,
  DM,
  DO,
  DZ,
  EC,
  EE,
  EG,
  EH,
  ER,
  ES,
  ET,
  FI,
  FJ,
  FK,
  FM,
  FO,
  FR,
  GA,
  GB,
  GD,
  GE,
  GF,
  GG,
  GH,
  GI,
  GL,
  GM,
  GN,
  GP,
  GQ,
  GR,
  GS,
  GT,
  GU,
  GW,
  GY,
  HK,
  HN,
  HR,
  HT,
  HU,
  IC,
  ID,
  IE,
  IL,
  IM,
  IN,
  IO,
  IQ,
  IR,
  IS,
  IT,
  JE,
  JM,
  JO,
  JP,
  KE,
  KG,
  KH,
  KI,
  KM,
  KN,
  KP,
  KR,
  KW,
  KY,
  KZ,
  LA,
  LB,
  LC,
  LI,
  LK,
  LR,
  LS,
  LT,
  LU,
  LV,
  LY,
  MA,
  MC,
  MD,
  ME,
  MF,
  MG,
  MH,
  MK,
  ML,
  MM,
  MN,
  MO,
  MP,
  MQ,
  MR,
  MS,
  MT,
  MU,
  MV,
  MW,
  MX,
  MY,
  MZ,
  NA,
  NC,
  NE,
  NF,
  NG,
  NI,
  NL,
  NO,
  NP,
  NR,
  NU,
  NZ,
  OM,
  PA,
  PE,
  PF,
  PG,
  PH,
  PK,
  PL,
  PM,
  PR,
  PS,
  PT,
  PW,
  PY,
  QA,
  RE,
  RO,
  RS,
  RU,
  RW,
  SA,
  SB,
  SC,
  SD,
  SE,
  SG,
  SH,
  SI,
  SJ,
  SK,
  SL,
  SM,
  SN,
  SO,
  SR,
  SS,
  ST,
  SV,
  SX,
  SY,
  SZ,
  TA,
  TC,
  TD,
  TG,
  TH,
  TJ,
  TK,
  TL,
  TM,
  TN,
  TO,
  TR,
  TT,
  TV,
  TW,
  TZ,
  UA,
  UG,
  US,
  UY,
  UZ,
  VA,
  VC,
  VE,
  VG,
  VI,
  VN,
  VU,
  WF,
  WS,
  XK,
  YE,
  YT,
  ZA,
  ZM,
  ZW;

  const IsoCode();

  /// Constructs an [IsoCode] from the provided [value].
  static IsoCode? fromJson(String value) {
    return values.firstWhereOrNull((e) => e.name == value);
  }

  /// Returns a [String] from this [IsoCode].
  String toJson() => name;
}

/// Extention adding ability to list restricted [IsoCode] for
/// [OperationDepositMethod]s.
extension IsoCodeExtension on IsoCode {
  /// Returns [IsoCode]s that aren't available for the provided
  /// [OperationDepositMethod].
  static Set<IsoCode> restricted(OperationDepositMethod method) {
    return IsoCode.values
        .whereNot((e) => available(method).contains(e))
        .toSet();
  }

  /// Returns [IsoCode] that are available for the provided
  /// [OperationDepositMethod].
  static Set<IsoCode> available(OperationDepositMethod method) {
    final CriteriaCountry? countries = method.countries;

    if (countries == null) {
      return IsoCode.values.toSet();
    }

    if (countries is CriteriaCountryOnly) {
      return IsoCode.values
          .where((e) => countries.only.contains(CountryCode(e.name)))
          .toSet();
    }

    if (countries is CriteriaCountryExcept) {
      return IsoCode.values
          .whereNot((e) => countries.except.contains(CountryCode(e.name)))
          .toSet();
    }

    return {};
  }
}
