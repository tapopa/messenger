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

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/domain/model/balance.dart';
import '/themes.dart';

/// Greyed out [Container] of determined size.
class BalancePlaceholder extends StatelessWidget {
  const BalancePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Container(
      width: 42,
      height: 20,
      color: style.colors.secondaryHighlight,
    );
  }
}

/// [AnimatedSizeAndFade] switching between [BalancePlaceholder] and [builder]
/// depending on the [value].
class BalancePlaceholderBuilder extends StatelessWidget {
  const BalancePlaceholderBuilder({
    super.key,
    required this.builder,
    required this.value,
  });

  /// Builder building [Widget] to display when [value] is non-`null`.
  final Widget Function(Balance) builder;

  /// Reactive [Balance] value.
  final Rx<Balance?> value;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Balance? balance = value.value;
      final Widget child;

      if (balance == null) {
        child = BalancePlaceholder(key: const Key('Placeholder'));
      } else {
        child = builder(balance);
      }

      return AnimatedSizeAndFade(
        fadeDuration: const Duration(milliseconds: 200),
        sizeDuration: const Duration(milliseconds: 200),
        child: child,
      );
    });
  }
}
