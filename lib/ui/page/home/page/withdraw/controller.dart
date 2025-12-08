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

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../../../domain/model/native_file.dart';
import '../../../../widget/text_field.dart';
import '/domain/model/country.dart';
import '/domain/model/session.dart';
import '/domain/service/session.dart';
import '/ui/widget/svg/svg.dart';

/// Available withdrawal options.
enum WithdrawalOption {
  usdt,
  paypal,
  monobank,
  sepa;

  /// Returns a [l10n] key label associated with this [WithdrawalOption].
  String get l10n => switch (this) {
    .usdt => 'label_usdt',
    .paypal => 'label_paypal',
    .monobank => 'label_monobank',
    .sepa => 'label_sepa_transfer',
  };

  /// Returns a [l10n] key label associated with this [WithdrawalOption].
  SvgData get icon => switch (this) {
    .usdt => SvgIcons.withdrawUsdt,
    .paypal => SvgIcons.withdrawPayPal,
    .monobank => SvgIcons.withdrawMonobank,
    .sepa => SvgIcons.withdrawSepa,
  };
}

/// Available [WithdrawalOption.usdt] network withdrawal options.
enum UsdtNetwork {
  arbitrumOne,
  optimism,
  plasma,
  polygon,
  solana,
  ton,
  tron;

  /// Returns a [l10n] key label associated with this [UsdtNetwork].
  String get l10n => switch (this) {
    .arbitrumOne => 'label_arbitrum_one',
    .optimism => 'label_optimism_op_mainnet',
    .plasma => 'label_plasma',
    .polygon => 'label_polygon',
    .solana => 'label_solana',
    .ton => 'label_ton',
    .tron => 'label_tron_trc20',
  };

  /// Returns a [l10n] key label associated with this [UsdtNetwork].
  SvgData get icon => switch (this) {
    .arbitrumOne => SvgIcons.usdtNetworkArbitrumIcon,
    .optimism => SvgIcons.usdtNetworkOptimismIcon,
    .plasma => SvgIcons.usdtNetworkPlasmaIcon,
    .polygon => SvgIcons.usdtNetworkPolygonIcon,
    .solana => SvgIcons.usdtNetworkSolanaIcon,
    .ton => SvgIcons.usdtNetworkTonIcon,
    .tron => SvgIcons.usdtNetworkTronIcon,
  };
}

/// Controller for the [Routes.withdraw] page.
class WithdrawController extends GetxController {
  WithdrawController(this._sessionService);

  /// [IsoCode] of the country selected for withdrawal.
  final Rx<IsoCode?> country = Rx(null);

  /// Currently selected [WithdrawalOption].
  final Rx<WithdrawalOption?> option = Rx(null);

  /// Selected [UsdtNetwork] for [WithdrawalOption.usdt] option selected.
  final Rx<UsdtNetwork?> usdtNetwork = Rx(null);

  final TextFieldState amountToWithdraw = TextFieldState();
  final TextFieldState amountToSend = TextFieldState(editable: false);

  final TextFieldState usdtWallet = TextFieldState();
  final TextFieldState usdtMemo = TextFieldState();
  final TextFieldState usdtPlatform = TextFieldState();

  final Rx<NativeFile?> passport = Rx(null);
  final RxBool showPassport = RxBool(false);
  final TextFieldState passportExpiry = TextFieldState();

  final TextFieldState billingName = TextFieldState();
  final TextFieldState billingBirth = TextFieldState();
  final TextFieldState billingAddress = TextFieldState();
  final TextFieldState billingZip = TextFieldState();
  final TextFieldState billingEmail = TextFieldState();
  final TextFieldState billingPhone = TextFieldState();

  final RxBool confirmed = RxBool(false);

  /// [SessionService] used for [IpGeoLocation] retrieving.
  final SessionService _sessionService;

  @override
  void onInit() {
    _fetchIp();
    super.onInit();
  }

  /// Sets the [country] to be the provided [code].
  void selectCountry(IsoCode? code) {
    country.value = code;
    option.value = WithdrawalOption.values.firstOrNull;
  }

  Future<void> pickPassport() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      lockParentWindow: true,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      passport.value = NativeFile.fromPlatformFile(result.files.first);
    }
  }

  /// Fetches the current [IpGeoLocation] to update [IsoCode].
  Future<void> _fetchIp() async {
    final IpGeoLocation ip = await _sessionService.fetch();
    selectCountry(IsoCode.fromJson(ip.countryCode));
  }
}
