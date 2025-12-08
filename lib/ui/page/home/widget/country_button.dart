import 'package:flutter/material.dart';

import '../../../../themes.dart';
import '../../../widget/widget_button.dart';
import '/domain/model/country.dart';
import '/l10n/l10n.dart';
import '/ui/page/home/tab/wallet/select_country/view.dart';
import '/ui/widget/svg/svg.dart';
import 'field_button.dart';

class CountryButton extends StatelessWidget {
  const CountryButton({
    super.key,
    this.country,
    this.onCode,
    this.available = const {},
    this.restricted = const {},
    this.error = false,
  });

  final IsoCode? country;
  final void Function(IsoCode)? onCode;
  final Set<IsoCode> available;
  final Set<IsoCode> restricted;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return FieldButton(
      headline: Text('label_country'.l10n),
      onPressed: onCode == null
          ? null
          : () async {
              final result = await SelectCountryView.show(
                context,
                available: available,
                restricted: restricted,
              );

              if (result != null) {
                onCode?.call(result);
              }
            },
      error: error,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (country != null) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: ClipOval(
                child: SvgImage.asset(
                  'assets/images/country/${country?.name.toLowerCase()}.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            country == null
                ? 'label_choose_country'.l10n
                : 'country_${country?.name.toLowerCase()}'.l10n,
          ),
        ],
      ),
    );
  }
}

class CountryFlag extends StatelessWidget {
  const CountryFlag({
    super.key,
    this.country,
    this.onCode,
    this.available = const {},
    this.restricted = const {},
    this.error = false,
  });

  final IsoCode? country;
  final void Function(IsoCode)? onCode;
  final Set<IsoCode> available;
  final Set<IsoCode> restricted;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    final TextStyle bigWithShadows = style.fonts.big.regular.onPrimary.copyWith(
      shadows: [
        Shadow(
          color: style.colors.onBackgroundOpacity50,
          blurRadius: 1,
          offset: Offset(-1, 1),
        ),
        Shadow(
          color: style.colors.acceptShadow,
          blurRadius: 1,
          offset: Offset(1, 1),
        ),
        Shadow(
          color: style.colors.acceptShadow,
          blurRadius: 1,
          offset: Offset(-0.5, -0.5),
        ),
      ],
    );

    return WidgetButton(
      onPressed: () async {
        final result = await SelectCountryView.show(
          context,
          available: available,
          restricted: restricted,
        );

        if (result != null) {
          onCode?.call(result);
        }
      },
      child: Container(
        width: 164,
        height: 122,
        decoration: BoxDecoration(
          color: country == null ? style.colors.secondaryLight : null,
          border: Border.all(color: style.colors.secondary, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (country != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SvgImage.asset(
                  'assets/images/country/${country?.name.toLowerCase()}.svg',
                  fit: BoxFit.cover,
                ),
              ),
            Center(
              child: Text(
                country == null
                    ? 'label_choose_country'.l10n
                    : 'country_${country?.name.toLowerCase()}'.l10n,
                style: bigWithShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
