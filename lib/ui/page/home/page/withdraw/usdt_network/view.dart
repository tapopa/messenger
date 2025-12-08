import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';
import '/l10n/l10n.dart';
import '/ui/page/home/widget/rectangle_button.dart';
import '/ui/widget/modal_popup.dart';
import '/ui/widget/svg/svg.dart';
import 'controller.dart';

class UsdtNetworkView extends StatelessWidget {
  const UsdtNetworkView({super.key});

  /// Displays a [LoginView] wrapped in a [ModalPopup].
  static Future<UsdtNetwork?> show<T>(BuildContext context) {
    return ModalPopup.show(context: context, child: const UsdtNetworkView());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UsdtNetworkController(),
      builder: (UsdtNetworkController c) {
        return Column(
          mainAxisSize: .min,
          children: [
            ModalPopupHeader(text: 'label_usdt_network_type'.l10n),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: ModalPopup.padding(
                  context,
                ).add(EdgeInsets.fromLTRB(0, 0, 0, 16)),
                children: UsdtNetwork.values.map((e) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                    child: RectangleButton(
                      subtitle: 'label_commission_up_to_amount_usdt'.l10nfmt({
                        'amount': switch (e) {
                          .arbitrumOne => '0.80',
                          .optimism => '0.15',
                          .plasma => '0.0001',
                          .polygon => '0.80',
                          .solana => '1.00',
                          .ton => '0.15',
                          .tron => '2.50',
                        },
                      }),

                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgIcon(e.icon),
                      ),
                      onPressed: () => Navigator.of(context).pop(e),
                      child: Text(e.l10n.l10n),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
