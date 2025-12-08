import 'package:flutter/material.dart';

import '../../../../../widget/svg/svg.dart';
import '/themes.dart';
import '/ui/widget/widget_button.dart';
import '/util/platform_utils.dart';

class CheckboxButton extends StatelessWidget {
  const CheckboxButton({
    super.key,
    this.value = false,
    this.onPressed,
    required this.label,
  }) : span = null;

  const CheckboxButton.rich({
    super.key,
    this.value = false,
    this.onPressed,
    required this.span,
  }) : label = null;

  final bool value;
  final void Function(bool s)? onPressed;
  final String? label;
  final TextSpan? span;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return WidgetButton(
      onPressed: onPressed == null ? null : () => onPressed?.call(!value),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Transform.translate(
                offset: PlatformUtils.isWeb
                    ? PlatformUtils.isMobile
                          ? const Offset(-5, 8)
                          : const Offset(-5, 4)
                    : const Offset(-5, 4),
                child: Transform.scale(
                  scale: 0.7,
                  child: IgnorePointer(
                    child: Checkbox(
                      splashRadius: 0,
                      visualDensity: VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      value: value,
                      onChanged: (e) => onPressed?.call(e ?? false),
                      activeColor: style.colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: BorderSide(color: style.colors.primary),
                      ),
                      fillColor: onPressed == null
                          ? WidgetStateColor.resolveWith(
                              (_) => value == true
                                  ? style.colors.secondaryHighlightDarkest
                                  : style.colors.secondaryHighlight,
                            )
                          : null,
                      checkColor: style.colors.onPrimary,
                      focusColor: style.colors.primary,
                      side: onPressed == null
                          ? BorderSide(
                              color: style.colors.secondaryHighlightDarkest,
                              width: 2,
                            )
                          : BorderSide(color: style.colors.primary, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            span ??
                TextSpan(
                  text: label,
                  style: style.fonts.small.regular.secondary,
                ),
          ],
        ),
      ),
    );
  }
}

class BigCheckboxButton extends StatelessWidget {
  const BigCheckboxButton({
    super.key,
    this.value = false,
    this.onPressed,
    required this.label,
  });

  final bool value;
  final void Function(bool s)? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    return WidgetButton(
      onPressed: () => onPressed?.call(!value),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: Transform.translate(
                offset: PlatformUtils.isWeb
                    ? PlatformUtils.isMobile
                          ? const Offset(0, 5)
                          : const Offset(0, 3)
                    : const Offset(0, 3.5),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: value
                        ? style.colors.primary
                        : style.colors.onPrimary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: style.colors.primary, width: 1),
                  ),
                  width: 24,
                  height: 24,
                  child: value
                      ? Center(child: SvgIcon(SvgIcons.sentWhite))
                      : null,
                ),
              ),
            ),
            TextSpan(
              text: label,
              style: style.fonts.small.regular.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
