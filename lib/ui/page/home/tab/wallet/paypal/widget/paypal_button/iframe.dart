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

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '/config.dart';
import '/util/web/web_utils.dart';

/// PayPal pay button widget.
class PayPalButton extends StatefulWidget {
  const PayPalButton({
    super.key,
    this.onCreateOrder,
    this.onSuccess,
    this.onCancel,
    this.onError,
    this.currency = 'USD',
  });

  /// Callback, called when order ID should be created.
  final Future<String> Function()? onCreateOrder;

  /// Callback, called when PayPal SDK returned complete status.
  final void Function()? onSuccess;

  /// Callback, called when PayPal SDK returned cancel status.
  final void Function()? onCancel;

  /// Callback, called when PayPal SDK returned error status.
  final void Function(Object error)? onError;

  /// Currency to use in the PayPal SDK.
  final String currency;

  @override
  State<PayPalButton> createState() => _PayPalButtonWebState();
}

/// State of a [PayPalButton] maintaining [web.HTMLDivElement].
class _PayPalButtonWebState extends State<PayPalButton> {
  /// View ID to use to register [_element] as.
  late final String _viewId = 'paypal-btn';

  /// [web.HTMLIFrameElement] of a PayPal button.
  web.HTMLIFrameElement? _element;

  /// Indicator whether [_viewId] has been already registered or not.
  static bool _registered = false;

  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();

    _messagesSubscription = WebUtils.onMessage().listen((e) async {
      switch (e) {
        case 'createOrder':
          final orderId = await widget.onCreateOrder?.call();
          _element?.contentWindow?.postMessage('orderId:$orderId'.toJS);
          break;

        case 'onCancel':
          widget.onCancel?.call();
          break;

        case 'onError':
          widget.onError?.call(Exception());
          break;
      }
    });

    if (!_registered) {
      _registered = true;
      ui.platformViewRegistry.registerViewFactory(_viewId, (
        int viewId, {
        Object? params,
      }) {
        _element = web.HTMLIFrameElement()
          ..id = _viewId
          ..style.overflow = 'auto'
          ..style.width = '100%'
          ..style.height = '100%'
          ..frameBorder = '0'
          ..src = '${Config.origin}/payment/paypal.html';

        return _element!;
      });
    }
  }

  @override
  void dispose() {
    _element?.remove();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 72, child: HtmlElementView(viewType: _viewId));
  }
}
