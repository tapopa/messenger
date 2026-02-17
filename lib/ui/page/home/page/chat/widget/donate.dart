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
import '/ui/widget/widget_button.dart';

/// Widget rendering and display the provided [amount] of [Donation].
class DonateWidget extends StatelessWidget {
  const DonateWidget(
    this.amount, {
    super.key,
    required this.name,
    this.leading,
    this.trailing,
    this.tag,
    this.height = 104 * 1,
    this.bottom,
  });

  /// Amount to display.
  final num amount;

  /// Name to display in the top left corner of the [DonateWidget].
  final String name;

  /// Height of [DonateWidget].
  final double height;

  /// Widget to display as a leading relative to the [amount].
  final Widget? leading;

  /// Widget to display as a trailing relative to the [amount].
  final Widget? trailing;

  /// Widget to display at the bottom right corner of the [DonateWidget].
  ///
  /// If `null`, then a copyright is displayed.
  final Widget? tag;

  /// Widget to display below the [amount].
  final Widget? bottom;

  /// Default height of the [DonateWidget].
  ///
  /// Used to calculate [_ratio].
  static const double _defaultHeight = 104;

  /// Ratio of the defined height relative to the default height.
  double get _ratio => height / _defaultHeight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Container(
      constraints: const BoxConstraints(minWidth: 300),
      height: height + (bottom == null ? 0 : 36),
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
              color: const Color.fromARGB(64, 0, 0, 0),
              blurRadius: 1 * _ratio,
              offset: Offset(-1, -1) * _ratio,
            ),
            BoxShadow(
              blurStyle: BlurStyle.normal,
              color: const Color.fromARGB(200, 255, 255, 255),
              blurRadius: 2 * _ratio,
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
                        color: const Color.fromARGB(160, 255, 255, 255),
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                    color: const Color.fromARGB(
                                      160,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                ],
                                fontSize: 32 * _ratio,
                              ),
                        ),
                      ),

                      if (bottom != null) ...[
                        const SizedBox(height: 8),
                        ?bottom,
                      ],
                    ],
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
                                color: const Color.fromARGB(160, 255, 255, 255),
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

/// Button shaped in a diamond shape intended to be placed on [DonateWidget].
class DiamondButton extends StatelessWidget {
  const DiamondButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  /// Text to display within this button.
  final String text;

  /// Callback, called when this button is pressed.
  final void Function()? onPressed;

  /// Color of the button.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    const double cut = 6;

    return WidgetButton(
      onPressed: onPressed,
      child: CustomPaint(
        painter: _ChamferShapePainter(
          cut: cut,
          color: const Color.fromRGBO(237, 193, 15, 1),
          shadows: const [
            Shadow(
              color: Color.fromARGB(150, 255, 255, 255),
              blurRadius: 1,
              offset: Offset(1, -1),
            ),
            Shadow(
              color: Color.fromARGB(90, 0, 0, 0),
              blurRadius: 1,
              offset: Offset(-1, 1),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
          child: InnerShadow(
            blur: 1,
            offset: Offset(-1, 1),
            color: Color.fromARGB(150, 255, 255, 255),
            child: InnerShadow(
              blur: 1,
              color: Color.fromARGB(90, 0, 0, 0),
              offset: Offset(1, -1),
              child: CustomPaint(
                painter: _ChamferShapePainter(
                  cut: cut - 1,
                  color: color ?? style.colors.primary,
                  inset: 6,
                ),
                child: Container(
                  height: 30,
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Center(
                    child: Text(
                      text,
                      style: style.fonts.small.regular.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small version of [DonateWidget] displaying the [amount], if any, in a small
/// rectangle.
class DonateRectangle extends StatelessWidget {
  const DonateRectangle({
    super.key,
    this.height = 50,
    this.width = 50,
    this.amount,
  });

  /// Amount to display, if any.
  ///
  /// If `null`, then only the [Currency] symbol is displayed.
  final num? amount;

  /// Width this [DonateRectangle] should occupy.
  final double? width;

  /// Height this [DonateRectangle] should occupy.
  final double height;

  /// Default height of [DonateRectangle].
  ///
  /// Used to calculate [_ratio].
  static const double _defaultHeight = 50;

  /// Ratio of the defined height relative to the default height.
  double get _ratio => height / _defaultHeight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
              color: const Color.fromARGB(64, 0, 0, 0),
              blurRadius: 1 * _ratio,
              offset: Offset(-1, -1) * _ratio,
            ),
            BoxShadow(
              blurStyle: BlurStyle.normal,
              color: const Color.fromARGB(200, 255, 255, 255),
              blurRadius: 2 * _ratio,
              offset: Offset(1, 1) * _ratio,
            ),
          ],
        ),
        child: Center(
          child: InnerShadow(
            offset: Offset(-0.5, 0.5) * _ratio,
            blur: 0.5 * _ratio,
            color: const Color(0x7F60350B),
            child: Text(
              amount == null
                  ? Currency('XXX').l10n
                  : Price.xxx(amount!.toDouble()).l10next(digits: 0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.fonts.medium.regular.onDonateSecondary.copyWith(
                shadows: [
                  Shadow(
                    offset: Offset(-0.5, 0.5) * _ratio,
                    blurRadius: 0.5 * _ratio,
                    color: const Color.fromARGB(160, 255, 255, 255),
                  ),
                ],
                fontSize: 24 * _ratio,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] painting a chamfer-shaped form with [shadows] and [inset]s.
class _ChamferShapePainter extends CustomPainter {
  _ChamferShapePainter({
    required this.cut,
    required this.color,
    this.shadows = const [],
    this.inset = 0,
  });

  /// Amount of cut to offset the shape.
  final double cut;

  /// Color of the shape to display.
  final Color color;

  /// [Shadow] to draw under the shape.
  final List<Shadow> shadows;

  /// Insets to display in a diamond form.
  final double inset;

  Path _buildPath(Size size, double cut) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size, cut);

    // Draw shadows.
    for (final shadow in shadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // Draw main shape.
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    if (inset != 0) {
      // Top.
      final topFacet = Path()
        ..moveTo(cut, 0)
        ..lineTo(size.width - cut, 0)
        ..lineTo(size.width - cut - inset / 2, inset)
        ..lineTo(cut + inset / 2, inset)
        ..close();
      canvas.drawPath(topFacet, Paint()..color = Colors.white.withAlpha(40));

      // Top-Right.
      final topRightFacet = Path()
        ..moveTo(size.width - cut - inset / 2, inset)
        ..lineTo(size.width - cut, 0)
        ..lineTo(size.width, cut)
        ..lineTo(size.width - inset, cut + inset / 2)
        ..close();
      canvas.drawPath(
        topRightFacet,
        Paint()..color = Colors.white.withAlpha(50),
      );

      // Right.
      final rightFacet = Path()
        ..moveTo(size.width, cut)
        ..lineTo(size.width - inset, cut + inset / 2)
        ..lineTo(size.width - inset, size.height - cut - inset / 2)
        ..lineTo(size.width, size.height - cut)
        ..close();
      canvas.drawPath(rightFacet, Paint()..color = Colors.white.withAlpha(40));

      // Right-Bottom.
      final rightBottomFacet = Path()
        ..moveTo(size.width - inset, size.height - cut - inset / 2)
        ..lineTo(size.width, size.height - cut)
        ..lineTo(size.width - cut, size.height)
        ..lineTo(size.width - cut - inset / 2, size.height - inset)
        ..close();
      canvas.drawPath(
        rightBottomFacet,
        Paint()..color = Colors.white.withAlpha(10),
      );

      // Bottom.
      final bottomFacet = Path()
        ..moveTo(cut, size.height)
        ..lineTo(size.width - cut, size.height)
        ..lineTo(size.width - cut - inset / 2, size.height - inset)
        ..lineTo(cut + inset / 2, size.height - inset)
        ..close();
      canvas.drawPath(bottomFacet, Paint()..color = Colors.black.withAlpha(15));

      // Left-Bottom.
      final leftBottomFacet = Path()
        ..moveTo(0, size.height - cut)
        ..lineTo(cut, size.height)
        ..lineTo(cut + inset / 2, size.height - inset)
        ..lineTo(inset, size.height - cut - inset / 2)
        ..close();
      canvas.drawPath(
        leftBottomFacet,
        Paint()..color = Colors.black.withAlpha(22),
      );

      // Left.
      final leftFacet = Path()
        ..moveTo(0, cut)
        ..lineTo(inset, cut + inset / 2)
        ..lineTo(inset, size.height - cut - inset / 2)
        ..lineTo(0, size.height - cut)
        ..close();
      canvas.drawPath(leftFacet, Paint()..color = Colors.black.withAlpha(15));

      // Left-Top.
      final leftTopFacet = Path()
        ..moveTo(cut, 0)
        ..lineTo(cut + inset / 2, inset)
        ..lineTo(inset, cut + inset / 2)
        ..lineTo(0, cut)
        ..close();
      canvas.drawPath(
        leftTopFacet,
        Paint()..color = Colors.white.withAlpha(10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChamferShapePainter oldDelegate) {
    return oldDelegate.cut != cut ||
        oldDelegate.color != color ||
        oldDelegate.shadows != shadows;
  }
}
