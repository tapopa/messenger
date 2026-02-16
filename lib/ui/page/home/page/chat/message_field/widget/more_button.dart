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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/themes.dart';
import '/ui/widget/animated_button.dart';
import '/ui/widget/animated_switcher.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/widget_button.dart';
import 'buttons.dart';

/// [AnimatedButton] with an [icon].
class ChatMoreWidget extends StatefulWidget {
  /// Constructs a [ChatMoreWidget] from the provided [ChatButton].
  const ChatMoreWidget(
    this.button, {
    super.key,
    this.pinned = false,
    this.onPin,
    this.onPressed,
  });

  /// [ChatButton] to render.
  final ChatButton button;

  /// Callback, called when this [ChatMoreWidget] is pressed.
  final void Function()? onPressed;

  /// Indicator whether this [ChatMoreWidget] is pinned.
  final bool pinned;

  /// Callback, called when this [ChatMoreWidget] is pinned.
  final void Function()? onPin;

  @override
  State<ChatMoreWidget> createState() => _ChatMoreWidgetState();
}

/// State of a [ChatMoreWidget] maintaining the [_hovered].
class _ChatMoreWidgetState extends State<ChatMoreWidget> {
  /// Indicator whether this [ChatMoreWidget] is hovered.
  bool _hovered = false;

  /// [GlobalKey] to prevent icon widget from rebuilding.
  final GlobalKey _iconKey = GlobalKey();

  /// [GlobalKey] to prevent pin widget from rebuilding.
  final GlobalKey _pinKey = GlobalKey();

  /// Returns the [ChatButton] this widget is about.
  ChatButton get _button => widget.button;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    final bool disabled = widget.onPressed == null;
    final ChatButton? trailing = _button.trailing;

    return IgnorePointer(
      ignoring: disabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        opaque: false,
        child: WidgetButton(
          onPressed: _button.onPressed == null
              ? null
              : () {
                  if (!_button.repeatable) {
                    widget.onPressed?.call();
                  }

                  _button.onPressed?.call();
                },
          child: Container(
            width: double.infinity,
            color: (_hovered && !disabled)
                ? style.colors.onBackgroundOpacity2
                : null,
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                SizedBox(
                  width: 26,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 100),
                    scale: (_hovered && !disabled) ? 1.05 : 1,
                    child: Transform.translate(
                      offset: _button.offsetMini,
                      child: Opacity(
                        key: _iconKey,
                        opacity: disabled ? 0.6 : 1,
                        child: SvgIcon(_button.assetMini ?? _button.asset),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _button.hint,
                  style: disabled
                      ? style.fonts.medium.regular.primaryHighlightLightest
                      : style.fonts.medium.regular.primary,
                ),
                const Spacer(),
                const SizedBox(width: 16),
                if (trailing != null) ...[
                  WidgetButton(
                    onPressed: trailing.onPressed,
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      key: _pinKey,
                      child: Center(
                        child: AnimatedButton(
                          child: SvgIcon(trailing.assetMini ?? trailing.asset),
                        ),
                      ),
                    ),
                  ),
                ] else if (widget.onPin != null) ...[
                  WidgetButton(
                    onPressed: widget.onPin ?? () {},
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: AnimatedButton(
                          child: SafeAnimatedSwitcher(
                            key: _pinKey,
                            duration: 100.milliseconds,
                            child: widget.pinned
                                ? const SvgIcon(
                                    SvgIcons.unpin,
                                    key: Key('Unpin'),
                                  )
                                : Opacity(
                                    key: const Key('Pin'),
                                    opacity: widget.onPin == null || disabled
                                        ? 0.6
                                        : 1,
                                    child: const SvgIcon(SvgIcons.pin),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
