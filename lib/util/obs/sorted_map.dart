// Copyright © 2022-2026 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
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

import 'dart:collection';

import 'map.dart';

class _Keyed<K, V> implements Comparable<_Keyed<K, V>> {
  _Keyed(this.key, this.value);

  final K key;
  V value;

  @override
  String toString() => '_Keyed($key: $value)';

  @override
  int compareTo(_Keyed<K, V> other) {
    if (value is Comparable) {
      return (value as Comparable).compareTo(other.value);
    }

    return key.toString().compareTo(other.key.toString());
  }
}

/// Self-sorting observable [Map].
///
/// Please note that [V] values must implement [Comparable], otherwise adding or
/// removing of the items can behave in an unexpected way.
class SortedObsMap<K, V> extends MapMixin<K, V> {
  SortedObsMap([Comparator<V>? compare])
    : _compare = compare ?? _defaultCompare<V>();

  /// Callback, comparing the provided [V] items.
  final Comparator<V> _compare;

  /// [Map] for an constant complexity for getting elements by its keys.
  final ObsMap<K, V> _keys = ObsMap();

  /// [SplayTreeSet] of the sorted [V] values.
  late final SplayTreeSet<_Keyed<K, V>> _values = SplayTreeSet((a, b) {
    if (a.key == b.key) {
      return 0;
    }

    return _compare(a.value, b.value);
  });

  /// Unsorted [K] keys.
  @override
  Iterable<K> get keys => _keys.keys;

  @override
  Iterable<V> get values => _values.map((e) => e.value);

  @override
  bool get isEmpty => _values.isEmpty;

  @override
  bool get isNotEmpty => _values.isNotEmpty;

  @override
  int get length => _values.length;

  /// First [V] item.
  V get first => _values.first.value;

  /// Last [V] item.
  V get last => _values.last.value;

  /// Returns stream of record of changes of this [SortedObsMap].
  Stream<MapChangeNotification<K, V>> get changes => _keys.changes;

  @override
  operator []=(K key, V value) {
    final Iterable<_Keyed<K, V>> existing = _values.where((e) => e.key == key);

    for (var e in existing) {
      e.value = value;
    }

    if (existing.isEmpty) {
      _values.add(_Keyed(key, value));
    }

    _keys[key] = value;
  }

  @override
  V? operator [](Object? key) => _keys[key];

  @override
  V? remove(Object? key) {
    V? removed = _keys.remove(key);
    _values.removeWhere((e) => e.key == key);

    return removed;
  }

  @override
  void clear() {
    _keys.clear();
    _values.clear();
  }

  /// Returns a [Comparator] for the provided [V].
  static Comparator<V> _defaultCompare<V>() {
    if (V is Comparable<V>) {
      return (a, b) {
        return (a as Comparable).compareTo(b);
      };
    }

    return (_, _) => -1;
  }
}
