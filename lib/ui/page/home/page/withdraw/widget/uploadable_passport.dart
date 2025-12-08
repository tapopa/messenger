import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/domain/model/attachment.dart';
import '/domain/model/native_file.dart';
import '/l10n/l10n.dart';
import '/themes.dart';
import '/ui/page/home/page/chat/widget/media_attachment.dart';
import '/ui/widget/svg/svg.dart';
import '/ui/widget/widget_button.dart';

class UploadablePassport extends StatelessWidget {
  const UploadablePassport({
    super.key,
    this.onPressed,
    this.file,
    this.blurred = false,
    this.onUnblur,
  });

  final void Function()? onPressed;
  final NativeFile? file;
  final bool blurred;
  final void Function()? onUnblur;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    if (file == null) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: style.colors.onSecondary,
            ),
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: AspectRatio(
                aspectRatio: 192 / 133,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: style.colors.onBackgroundOpacity40,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: SvgImage.asset(
                    'assets/images/passport.svg',
                    height: 140,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'btn_upload_photo'.l10n,
                  style: style.fonts.small.regular.primary,
                  recognizer: TapGestureRecognizer()..onTap = onPressed,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final media = MediaAttachment(
        attachment: LocalAttachment(file!),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );

      return Column(
        children: [
          WidgetButton(
            onPressed: () async {
              if (blurred) {
                return onUnblur?.call();
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: blurred
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: media,
                    )
                  : media,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'btn_replace_photo'.l10n,
                  style: style.fonts.small.regular.primary,
                  recognizer: TapGestureRecognizer()..onTap = onPressed,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
