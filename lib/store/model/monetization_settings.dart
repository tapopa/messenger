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

import '/domain/model/monetization_settings.dart';
import '/util/new_type.dart';
import 'version.dart';

/// Persisted in storage [MonetizationSettings]'s [value].
class DtoMonetizationSettings implements Comparable<DtoMonetizationSettings> {
  DtoMonetizationSettings(this.value, this.ver, this.cursor);

  /// Persisted [MonetizationSettings] model.
  MonetizationSettings value;

  /// Version of these [MonetizationSettings] state.
  ///
  /// It increases monotonically, so may be used (and is intended to) for
  /// tracking state's actuality.
  MonetizationSettingsVersion ver;

  /// [MonetizationSettingsCursor] of the [value].
  final MonetizationSettingsCursor? cursor;

  @override
  String toString() => '$runtimeType($value, $ver)';

  @override
  int compareTo(DtoMonetizationSettings other) => other.value.compareTo(value);
}

/// Version of the [MonetizationSettings] state.
class MonetizationSettingsVersion extends Version {
  MonetizationSettingsVersion(super.val);

  /// Constructs a [MonetizationSettingsVersion] from the provided [val].
  factory MonetizationSettingsVersion.fromJson(String val) =
      MonetizationSettingsVersion;

  /// Compares whether [MonetizationSettingsVersion] is bigger than [other].
  bool operator >(MonetizationSettingsVersion? other) {
    if (other == null) {
      return false;
    }

    return val.compareTo(other.val) == -1;
  }

  /// Compares whether [MonetizationSettingsVersion] is bigger or equals to
  /// [other].
  bool operator >=(MonetizationSettingsVersion? other) {
    if (other == null) {
      return false;
    }

    return val.compareTo(other.val) <= 0;
  }

  /// Returns a [String] representing this [MonetizationSettingsVersion].
  String toJson() => val;
}

/// Cursor of [MonetizationSettings].
class MonetizationSettingsCursor extends NewType<String> {
  MonetizationSettingsCursor(super.val);
}
