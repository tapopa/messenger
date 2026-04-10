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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svgs.dart';
import '/util/platform_utils.dart';
import 'controller.dart';

/// View for displaying PWA installation instructions.
class PwaInstructionView extends StatelessWidget {
  const PwaInstructionView({super.key});

  /// Displays a [PwaInstructionView] wrapped in a [ModalPopup].
  static Future<T?> show<T>(BuildContext context) {
    return ModalPopup.show(context: context, child: const PwaInstructionView());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: PwaInstructionController(),
      builder: (PwaInstructionController c) {
        final String title;
        final List<Widget> children;

        if (PlatformUtils.isIOS) {
          title = 'label_install_ios_web_application'.l10n;
          children = _ios(context);
        } else {
          title = 'label_install_macos_web_application'.l10n;
          children = _mac(context);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalPopupHeader(text: title),
            Flexible(
              child: ListView(
                padding: ModalPopup.padding(context),
                shrinkWrap: true,
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Returns a [List] of content describing PWA installation on iOS.
  List<Widget> _ios(BuildContext context) {
    final style = Theme.of(context).style;

    return [
      Text(
        'label_install_ios_web_application1'.l10n,
        style: style.fonts.small.regular.secondary,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_ios_web_application2_1'.l10n),
              TextSpan(
                text: 'label_install_ios_web_application2_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_ios_web_application2_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: style.colors.onPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(child: SvgIcon(SvgIcons.shareBig)),
        ),
        step: 1,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_ios_web_application3_1'.l10n),
              TextSpan(
                text: 'label_install_ios_web_application3_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_ios_web_application3_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          constraints: const BoxConstraints(minHeight: 44.4),
          decoration: BoxDecoration(
            color: style.colors.onPrimaryOpacity50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              CustomBoxShadow(
                color: style.colors.onBackgroundOpacity20,
                blurRadius: 8,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: Row(
            children: [
              const SvgIcon(SvgIcons.addToHomeScreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'label_install_ios_web_application3_4'.l10n,
                  style: style.fonts.normal.regular.onBackground,
                ),
              ),
            ],
          ),
        ),
        step: 2,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_ios_web_application4_1'.l10n),
              TextSpan(
                text: 'label_install_ios_web_application4_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_ios_web_application4_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          decoration: BoxDecoration(
            color: style.colors.primaryHighlight,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: EdgeInsets.fromLTRB(21, 12, 21, 12),
          child: Text(
            'btn_add'.l10n,
            style: style.fonts.medium.regular.onPrimary,
          ),
        ),
        step: 3,
      ),
      const SizedBox(height: 8),
    ];
  }

  /// Returns a [List] of content describing PWA installation on macOS.
  List<Widget> _mac(BuildContext context) {
    final style = Theme.of(context).style;

    return [
      Text(
        'label_install_macos_web_application1'.l10n,
        style: style.fonts.small.regular.secondary,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_macos_web_application2_1'.l10n),
              TextSpan(
                text: 'label_install_macos_web_application2_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_macos_web_application2_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: style.colors.onPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(child: SvgIcon(SvgIcons.shareBig)),
        ),
        step: 1,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_macos_web_application3_1'.l10n),
              TextSpan(
                text: 'label_install_macos_web_application3_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_macos_web_application3_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          constraints: const BoxConstraints(minHeight: 44.4),
          decoration: BoxDecoration(
            color: style.colors.onPrimaryOpacity50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              CustomBoxShadow(
                color: style.colors.onBackgroundOpacity20,
                blurRadius: 8,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: Row(
            children: [
              const SvgIcon(SvgIcons.addToDock),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'label_install_macos_web_application3_4'.l10n,
                  style: style.fonts.normal.regular.onBackground,
                ),
              ),
            ],
          ),
        ),
        step: 2,
      ),
      const SizedBox(height: 21),
      _step(
        context,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'label_install_macos_web_application4_1'.l10n),
              TextSpan(
                text: 'label_install_macos_web_application4_2'.l10n,
                style: style.fonts.small.regular.onBackground,
              ),
              TextSpan(text: 'label_install_macos_web_application4_3'.l10n),
            ],
          ),
          style: style.fonts.small.regular.secondary,
        ),
        center: Container(
          decoration: BoxDecoration(
            color: style.colors.primaryHighlight,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: EdgeInsets.fromLTRB(21, 12, 21, 12),
          child: Text(
            'btn_add'.l10n,
            style: style.fonts.medium.regular.onPrimary,
          ),
        ),
        step: 3,
      ),
      const SizedBox(height: 8),
    ];
  }

  /// Builds a visual represented [Container] containing [center] and [title].
  Widget _step(
    BuildContext context, {
    required Widget center,
    required Widget title,
    int step = 1,
  }) {
    final style = Theme.of(context).style;

    return Container(
      height: 131,
      decoration: BoxDecoration(
        color: style.colors.primaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: style.cardBorder,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: title),
                Expanded(child: Center(child: center)),
              ],
            ),
          ),
          Positioned(
            left: 0.5,
            bottom: 0.5,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: style.colors.onPrimary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.zero,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: style.fonts.small.regular.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
