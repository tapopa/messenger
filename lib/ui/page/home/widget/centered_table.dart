import 'package:flutter/material.dart';

import '/themes.dart';

class CenteredRow {
  const CenteredRow(this.label, this.child);

  final Widget label;
  final Widget child;

  /// Builds a stylized [TableRow] with [label] and [child].
  TableRow _build(BuildContext context) {
    final style = Theme.of(context).style;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: DefaultTextStyle(
            style: style.fonts.small.regular.secondary,
            textAlign: TextAlign.right,
            child: label,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DefaultTextStyle(
              style: style.fonts.small.regular.secondaryBackgroundLight,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class CenteredTable extends StatelessWidget {
  const CenteredTable({super.key, this.children = const []});

  final List<CenteredRow> children;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: MinColumnWidth(FixedColumnWidth(260), FractionColumnWidth(0.7)),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: children.map((e) => e._build(context)).toList(),
    );
  }
}
