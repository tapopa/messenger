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
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mutex/mutex.dart';
import 'package:web/web.dart' as web;

import '/config.dart';
import '/util/log.dart';

@JS('paypal')
external JSObject get paypal;

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

  /// [web.HTMLDivElement] of a PayPal button.
  web.HTMLDivElement? _element;

  /// Indicator whether [_viewId] has been already registered or not.
  static bool _registered = false;

  /// [Mutex] guarding [_initialize] and [_sdk] races.
  final Mutex _guard = Mutex();

  @override
  void initState() {
    super.initState();

    if (!_registered) {
      _registered = true;
      ui.platformViewRegistry.registerViewFactory(_viewId, (
        int viewId, {
        Object? params,
      }) {
        _element = web.HTMLDivElement()
          ..id = _viewId
          ..style.overflow = 'auto'
          ..style.width = '100%'
          ..style.height = '100%';

        return _element!;
      });
    }

    _initialize();
  }

  @override
  void dispose() {
    _element?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: HtmlElementView(
        viewType: _viewId,
        onPlatformViewCreated: (id) {
          SchedulerBinding.instance.addPostFrameCallback((_) => _setConfig());
        },
      ),
    );
  }

  /// Initializes the [_sdk] for PayPal SDK.
  Future<void> _initialize() async {
    try {
      Log.debug('_initialize() -> await _sdk()...', '$runtimeType');
      await _sdk();
      Log.debug('_initialize() -> await _sdk()... done!', '$runtimeType');
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  /// Sets the [_paypalButtonsConfig] and renders the PayPal SDK button in the
  /// [_element].
  Future<void> _setConfig() async {
    if (!mounted) {
      return;
    }

    await _guard.protect(() async {
      if (!mounted) {
        return;
      }

      Log.debug('_setConfig() -> rendering...', '$runtimeType');

      final JSObject config = _paypalButtonsConfig(
        createOrder: _createOrder.toJS,
        onApprove: _onApprove.toJS,
        onCancel: _onCancel.toJS,
        onError: _onError.toJS,
      );

      paypal.buttons(config).render('#$_viewId');

      Log.debug('_setConfig() -> rendering... done!', '$runtimeType');
    });
  }

  /// Receives and returns an order ID from the [PayPalButton.onCreateOrder].
  JSAny _createOrder() {
    Log.debug('_createOrder()', '$runtimeType');

    final future = Future(() async {
      final String? orderId = await widget.onCreateOrder?.call();
      return orderId?.toJS;
    });

    return future.toJS;
  }

  /// Invokes [PayPalButton.onSuccess].
  JSVoid _onApprove(JSAny data, JSAny actions) {
    Log.debug('_onApprove(${data.dartify()})', '$runtimeType');
    widget.onSuccess?.call();
  }

  /// Invokes [PayPalButton.onCancel].
  void _onCancel(JSAny _) {
    Log.debug('_onCancel()', '$runtimeType');
    widget.onCancel?.call();
  }

  /// Invokes [PayPalButton.onError].
  void _onError(JSAny err) {
    Log.debug('_onError($err)', '$runtimeType');
    widget.onError?.call(err);
  }

  /// Initializes the PayPal JS SDK script and appends it.
  Future<void> _sdk() async {
    if (web.document.querySelector('script[data-paypal-sdk]') != null) {
      return;
    }

    await _guard.protect(() async {
      final Completer completer = Completer<void>();

      final script = web.HTMLScriptElement()
        ..src =
            'https://www.paypal.com/sdk/js?client-id=${Config.payPalClientId}&currency=${widget.currency}&disable-funding=credit,card,paylater,venmo&intent=authorize'
        ..async = true
        ..dataset['paypalSdk'] = 'true'
        ..type = 'text/javascript'
        ..async = true
        ..onLoad.listen((_) => completer.complete())
        ..onError.listen((e) {
          completer.completeError('Failed to load PayPal SDK: $e');
        });

      web.document.head!.append(script);

      await completer.future;
    });
  }
}

/// Extension adding helper methods to get objects from PayPal JS SDK.
extension on JSObject {
  /// Returns the `Buttons` with the provided [config] from this [JSObject].
  JSObject buttons(JSObject config) {
    return callMethodVarArgs('Buttons'.toJS, [config]);
  }

  /// Invokes `render` method over this [JSObject].
  void render(String selector) {
    callMethodVarArgs('render'.toJS, [selector.toJS]);
  }
}

/// Returns a [JSObject] configured with the specified options.
JSObject _paypalButtonsConfig({
  required JSFunction createOrder,
  required JSFunction onApprove,
  required JSFunction onCancel,
  required JSFunction onError,
  String color = 'gold',
  String shape = 'rect',
  int borderRadius = 12,
  String label = 'pay',
  bool tagline = false,
}) {
  final obj = JSObject();
  obj.setProperty('createOrder'.toJS, createOrder);
  obj.setProperty('onApprove'.toJS, onApprove);
  obj.setProperty('onCancel'.toJS, onCancel);
  obj.setProperty('onError'.toJS, onError);
  obj.setProperty('color'.toJS, color.toJS);
  obj.setProperty('shape'.toJS, shape.toJS);
  obj.setProperty('borderRadius'.toJS, borderRadius.toJS);
  obj.setProperty('label'.toJS, label.toJS);
  obj.setProperty('tagline'.toJS, tagline.toJS);
  return obj;
}
