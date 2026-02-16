// Copyright © 2025 Ideas Networks Solutions S.A.,
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

import 'package:flutter/material.dart';

import '/domain/model/price.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/widget/inner_shadow.dart';

class DonateWidget extends StatelessWidget {
  const DonateWidget(
    this.amount, {
    super.key,
    required this.name,
    this.leading,
    this.trailing,
    this.tag,
    this.height = 104 * 1,
  });

  final num amount;

  final String name;
  final double height;

  final Widget? leading;
  final Widget? trailing;
  final Widget? tag;

  static const double _defaultHeight = 104;

  double get _ratio => height / _defaultHeight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment(-1, 1),
          end: Alignment(1, -1),
          colors: [
            Color(0xFFF8C823),
            Color(0xFFE4B01A),
            Color(0xFFFFF889),
            Color(0xFFFFD441),
          ],
          stops: [0, 0.32, 0.68, 1],
        ),
        // color: const Color(0xFFF3CD01),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment(-1, 1),
            end: Alignment(1, -1),
            colors: [
              Color(0xFFF8C823),
              Color(0xFFE4B01A),
              Color(0xFFFFF889),
              Color(0xFFFFD441),
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
          boxShadow: [
            BoxShadow(
              blurStyle: BlurStyle.normal,
              color: const Color.fromARGB(110, 0, 0, 0),
              blurRadius: 2 * _ratio,
              offset: Offset(-1, -1) * _ratio,
            ),
            BoxShadow(
              blurStyle: BlurStyle.normal,
              color: const Color.fromARGB(255, 255, 255, 255),
              blurRadius: 4 * _ratio,
              offset: Offset(1, 1) * _ratio,
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: InnerShadow(
                offset: Offset(-0.5, 0.5) * _ratio,
                blur: 0.5 * _ratio,
                color: const Color(0x7F60350B),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.fonts.medium.regular.onDonateSecondary.copyWith(
                    shadows: [
                      Shadow(
                        offset: Offset(-0.5, 0.5) * _ratio,
                        blurRadius: 0.5 * _ratio,
                        color: const Color(0x40FFFFFF),
                      ),
                    ],
                    fontSize:
                        style.fonts.medium.regular.onBackground.fontSize! *
                        _ratio,
                  ),
                ),
              ),
            ),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?leading,
                  InnerShadow(
                    offset: Offset(-0.5, 0.5) * _ratio,
                    blur: 0.5 * _ratio,
                    color: const Color(0x7F60350B),
                    child: Text(
                      Price(
                        sum: Sum(amount.toDouble()),
                        currency: Currency('XXX'),
                      ).l10next(digits: 2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.fonts.medium.regular.onDonateSecondary
                          .copyWith(
                            shadows: [
                              Shadow(
                                offset: Offset(-0.5, 0.5) * _ratio,
                                blurRadius: 0.5 * _ratio,
                                color: const Color(0x40FFFFFF),
                              ),
                            ],
                            fontSize: 32 * _ratio,
                          ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child:
                  tag ??
                  InnerShadow(
                    offset: Offset(-0.5, 0.5) * _ratio,
                    blur: 0.5 * _ratio,
                    color: const Color(0x7F60350B),
                    child: Text(
                      '© Tapopa',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.fonts.medium.regular.onDonateSecondary
                          .copyWith(
                            shadows: [
                              Shadow(
                                offset: Offset(-0.5, 0.5) * _ratio,
                                blurRadius: 0.5 * _ratio,
                                color: const Color(0x40FFFFFF),
                              ),
                            ],
                            fontSize: 11 * _ratio,
                          ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
