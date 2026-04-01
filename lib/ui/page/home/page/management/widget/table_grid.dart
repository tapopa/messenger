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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '/themes.dart';

/// [TableView] building the provided [TableBuilder]s with items.
class TableGrid<E> extends StatelessWidget {
  const TableGrid({
    super.key,
    this.builders = const [],
    this.items = const [],
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.verticalDetails = const ScrollableDetails.vertical(),
  });

  /// [TableBuilder] to build in the [TableView].
  final List<TableBuilder<E>> builders;

  /// Items that [TableBuilder] describe.
  final Iterable<E> items;

  /// [ScrollableDetails] to pass to horizontal details of [TableView].
  final ScrollableDetails horizontalDetails;

  /// [ScrollableDetails] to pass to vertical details of [TableView].
  final ScrollableDetails verticalDetails;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    final double total = builders.fold(0.0, (a, b) => a + b.width);

    return SelectionArea(
      child: TableView(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        verticalDetails: verticalDetails,
        horizontalDetails: horizontalDetails,
        delegate: TableCellBuilderDelegate(
          rowCount: max(1, items.length),
          columnCount: builders.length,
          cellBuilder: (BuildContext context, TableVicinity vicinity) {
            final builder = builders[vicinity.column];

            if (vicinity.row == 0) {
              return TableViewCell(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: DefaultTextStyle(
                      style: style.fonts.small.regular.secondary,
                      textAlign: TextAlign.center,
                      child: builder.header(),
                    ),
                  ),
                ),
              );
            }

            return TableViewCell(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: DefaultTextStyle(
                    style: style.fonts.small.regular.onBackground,
                    child: builder.builder(items.elementAt(vicinity.row)),
                  ),
                ),
              ),
            );
          },
          columnBuilder: (int index) {
            return Span(
              extent: MaxSpanExtent(
                FractionalSpanExtent(builders[index].width / total),
                FixedSpanExtent(100),
              ),
              foregroundDecoration: SpanDecoration(
                border: SpanBorder(
                  trailing: BorderSide(
                    width: 0.5,
                    color: style.colors.secondaryHighlightDark,
                  ),
                ),
              ),
            );
          },
          pinnedRowCount: 1,
          rowBuilder: (int index) {
            return Span(
              extent: FixedSpanExtent(64),
              foregroundDecoration: SpanDecoration(
                border: SpanBorder(
                  trailing: BorderSide(
                    width: 0.5,
                    color: style.colors.secondaryHighlightDark,
                  ),
                ),
              ),
              backgroundDecoration: index == 0
                  ? SpanDecoration(color: style.colors.onPrimaryLight)
                  : null,
            );
          },
        ),
      ),
    );
  }
}

/// Data of a single [TableView] column.
class TableBuilder<E> {
  TableBuilder({required this.header, required this.builder, this.width = 1});

  /// Builder building the header of this row.
  final Widget Function() header;

  /// Builder building the data of this row.
  final Widget Function(E) builder;

  /// Width in flex units this column should occupy.
  final double width;
}
