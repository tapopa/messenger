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

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '/config.dart';
import '/domain/model/country.dart';
import '/domain/model/my_user.dart';
import '/domain/model/operation_deposit_method.dart';
import '/domain/model/operation.dart';
import '/domain/model/price.dart';
import '/domain/service/my_user.dart';
import '/domain/service/wallet.dart';
import '/l10n/l10n.dart';
import '/ui/widget/primary_button.dart';
import '/util/log.dart';
import '/util/message_popup.dart';
import '/util/platform_utils.dart';
import '/util/web/web_utils.dart';

/// Status of [PayPalDepositView].
enum PayPalDepositStatus { initial, inProgress }

/// Controller of a [PayPalDepositView].
class PayPalDepositController extends GetxController {
  PayPalDepositController(
    this._walletService,
    this._myUserService, {
    required this.method,
    required this.country,
    required this.nominal,
    this.id,
  });

  /// [OperationDepositMethod] to deposit with.
  final OperationDepositMethod method;

  /// [CountryCode] of the deposit.
  final CountryCode country;

  /// [Price] to deposit.
  final Price nominal;

  /// [PayPalDepositStatus] of the [createDeposit] operation.
  final Rx<PayPalDepositStatus> status = Rx(PayPalDepositStatus.initial);

  /// [OperationId] of an [OperationDeposit] already existing, if any.
  final OperationId? id;

  /// [OperationDeposit] being deposited.
  final Rx<Rx<Operation>?> operation = Rx(null);

  /// Error happened during [OperationDeposit] creating.
  final RxnString error = RxnString();

  /// [RxStatus] of the [operation] creating.
  final Rx<RxStatus> operationStatus = Rx(RxStatus.empty());

  /// Seconds until displaying inability to process the [operation]
  /// automatically.
  final RxnInt responseSeconds = RxnInt(null);

  /// [WalletService] used to create the [OperationDeposit] itself.
  final WalletService _walletService;

  /// [MyUserService] used for retrieving the current [MyUser].
  final MyUserService _myUserService;

  /// [OperationDepositSecret] to use with [OperationDeposit] related
  /// management.
  OperationDepositSecret? _secret;

  /// [Timer] counting down the [responseSeconds].
  Timer? _responseTimer;

  /// [StreamSubscription] to messages from the PayPal popup window.
  StreamSubscription? _messagesSubscription;

  /// Returns the currently authenticated [MyUser].
  Rx<MyUser?> get myUser => _myUserService.myUser;

  @override
  void onClose() {
    _responseTimer?.cancel();
    _messagesSubscription?.cancel();
    super.onClose();
  }

  /// Creates a [OperationDeposit].
  Future<Operation?> createDeposit() async {
    operationStatus.value = RxStatus.loading();

    try {
      // Under Web platforms, it's better to open the popup as fast as possible
      // due to browser usual policies to block unexpected popups.
      //
      // Thus the mutation itself is happening within the popup afterwards
      //
      // Message passing cannot be reliable due to iOS Safari, for example,
      // freezing the execution when tab is not in focus.
      if (PlatformUtils.isDesktop && !PlatformUtils.isWeb) {
        operation.value = await _walletService.createOperationDeposit(
          methodId: method.id,
          nominal: nominal,
          country: country,
          paypal: _secret ??= OperationDepositSecret.generate(),
        );
      }

      operationStatus.value = RxStatus.success();

      String? orderId;
      Price? total;

      final OperationDepositMethodPricing? pricing = method.pricing;
      final Price? perNominal = pricing?.total;
      if (perNominal != null) {
        total = nominal * perNominal;
      }

      final Operation? order = operation.value?.value;
      if (order is OperationDeposit) {
        orderId = order.processingUrl?.val.split('?order_id=').last;

        if (total == null) {
          final OperationDepositPricing? pricing = order.pricing;
          final Price? perNominal = pricing?.total;
          if (perNominal != null) {
            total = nominal * perNominal;
          }
        }
      }

      // Ensure parameters used by PayPal HTML page are up to date.
      final MyUser? myUser = this.myUser.value;
      if (myUser != null) {
        WebUtils.putAccount(myUser.id);
      }

      final String url = '${Config.origin}/payment/paypal.html';
      final Map<String, dynamic> parameters = {
        'price': total?.l10n ?? nominal.l10next(digits: 0),
        'account': myUser?.num.toString(),
        'name': myUser?.title,
        'client-id': Config.payPalClientId,
        if (orderId == null) ...{
          'operation-id': operation.value?.value.id.val,
          'secret': _secret?.val,
          'method-id': method.id,
          'nominal': nominal.l10next(digits: 0),
          'country': country.val,
        } else
          'order-id': orderId,
      };

      final WindowHandle handle = await WebUtils.openPopup(
        url,
        parameters: parameters,
      );

      _messagesSubscription?.cancel();
      _messagesSubscription = handle.messages.listen((e) async {
        Log.debug('Message received from `WindowHandle` -> $e', '$runtimeType');

        if (e is Map) {
          final type = e['type'];

          if (type is String) {
            switch (type) {
              case 'createOperationDeposit':
                final operationId = e['operationId'];

                if (operationId is String) {
                  operation.value = await _walletService.get(
                    id: OperationId(operationId),
                  );

                  _startResponseTimer();
                }
                break;
            }
          }
        }
      });

      if (!handle.isOpen) {
        Log.warning(
          'createDeposit() -> Popup didn\'t open, trying `launchUrlString()`...',
          '$runtimeType',
        );

        try {
          final bool isOpen = await launchUrlString(
            '$url?${parameters.entries.map((e) => '${e.key}=${e.value}').join('&')}',
          );

          Log.warning(
            'createDeposit() -> `launchUrlString()` is open: $isOpen',
            '$runtimeType',
          );

          if (!isOpen) {
            await MessagePopup.alert(
              'Window cannot be opened automatically',
              button: (context) {
                return PrimaryButton(
                  onPressed: () async {
                    await launchUrlString(
                      '$url?${parameters.entries.map((e) => '${e.key}=${e.value}').join('&')}',
                    );
                  },
                  title: 'btn_proceed'.l10n,
                );
              },
            );
          }
        } catch (e) {
          Log.error(
            'createDeposit() -> unable to do `launchUrlString()` due to $e',
            '$runtimeType',
          );

          MessagePopup.error(e);

          rethrow;
        }

        _startResponseTimer();
      }

      return operation.value?.value;
    } catch (e) {
      operationStatus.value = RxStatus.error('err_data_transfer'.l10n);
      error.value = e.toString();
      rethrow;
    } finally {
      status.value = PayPalDepositStatus.inProgress;
    }
  }

  /// Starts the [_responseTimer] counting down the [responseSeconds].
  void _startResponseTimer() {
    responseSeconds.value = 600;

    _responseTimer?.cancel();
    _responseTimer = Timer.periodic(Duration(seconds: 1), (_) {
      responseSeconds.value = (responseSeconds.value ?? 1) - 1;
      if ((responseSeconds.value ?? 0) <= 0) {
        _responseTimer?.cancel();
      }
    });
  }
}
