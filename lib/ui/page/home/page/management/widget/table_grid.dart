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

import '/ui/widget/progress_indicator.dart';
import '/themes.dart';

/// [TableView] building the provided [TableBuilder]s with items.
class TableGrid<E> extends StatefulWidget {
  const TableGrid({
    super.key,
    this.builders = const [],
    this.items = const [],
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.indicateLoading = false,
    this.onReorder,
  });

  /// [TableBuilder] to build in the [TableView].
  final List<TableBuilder<E>> builders;

  /// Items that [TableBuilder] describe.
  final Iterable<E> items;

  /// [ScrollableDetails] to pass to horizontal details of [TableView].
  final ScrollableDetails horizontalDetails;

  /// [ScrollableDetails] to pass to vertical details of [TableView].
  final ScrollableDetails verticalDetails;

  /// Indicator whether a [CustomProgressIndicator] should be displayed.
  final bool indicateLoading;

  /// Callback, called when the provided [TableBuilder]s are reordered.
  final void Function(TableBuilder<E>, TableBuilder<E>)? onReorder;

  @override
  State<TableGrid<E>> createState() => _TableGridState<E>();
}

/// State of a [TableGrid] keeping the dragged and target indices.
class _TableGridState<E> extends State<TableGrid<E>> {
  int? _dragged;
  int? _target;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).style;

    final double total = widget.builders.fold(0.0, (a, b) => a + b.width);

    return SelectionArea(
      child: TableView(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        verticalDetails: widget.verticalDetails,
        horizontalDetails: widget.horizontalDetails,
        delegate: TableCellBuilderDelegate(
          rowCount:
              max(1, widget.items.length) +
              (widget.indicateLoading ? 1 : 0) +
              1,
          columnCount: widget.builders.length,
          cellBuilder: (BuildContext context, TableVicinity vicinity) {
            final int row = vicinity.row - 1;
            final int column = vicinity.column;
            final TableBuilder<E> builder = widget.builders[column];

            final int target = _target ?? 0;
            final int dragged = _dragged ?? 0;

            final BorderSide side = BorderSide(
              color: style.colors.onBackground,
              width: 2,
            );

            if (row == -1) {
              final header = KeyedSubtree(
                key: builder.key,
                child: DragTarget<TableBuilder<E>>(
                  onAcceptWithDetails: (e) {
                    widget.onReorder?.call(e.data, builder);
                    setState(() => _target = null);
                  },
                  onLeave: (_) {
                    if (_target == column) {
                      setState(() => _target = null);
                    }
                  },
                  onWillAcceptWithDetails: (_) {
                    if (_target != column) {
                      setState(() => _target = column);
                    }

                    return true;
                  },
                  builder: (context, candidates, rejected) {
                    return Container(
                      decoration: BoxDecoration(
                        border: _dragged != _target && _target == column
                            ? Border(
                                left: target < dragged ? side : BorderSide.none,
                                right: target >= dragged
                                    ? side
                                    : BorderSide.none,
                              )
                            : null,
                      ),
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
                  },
                ),
              );

              return TableViewCell(
                child: SelectionContainer.disabled(
                  child: Draggable<TableBuilder<E>>(
                    data: builder,
                    onDragStarted: () => setState(() => _dragged = column),
                    onDragCompleted: () => setState(() => _dragged = null),
                    onDragEnd: (_) => setState(() => _dragged = null),
                    onDraggableCanceled: (_, _) =>
                        setState(() => _dragged = null),
                    feedback: const SizedBox(),
                    childWhenDragging: Stack(
                      children: [
                        header,
                        Positioned.fill(
                          child: Container(
                            color: style.colors.onBackgroundOpacity20,
                          ),
                        ),
                      ],
                    ),
                    child: header,
                  ),
                ),
              );
            }

            if (row >= widget.items.length) {
              return const TableViewCell(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Center(child: CustomProgressIndicator()),
                ),
              );
            }

            final Widget cell = Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: DefaultTextStyle(
                  style: style.fonts.small.regular.onBackground,
                  child: builder.builder(widget.items.elementAt(row)),
                ),
              ),
            );

            if (_dragged == column) {
              return TableViewCell(
                child: Stack(
                  children: [
                    cell,
                    Positioned.fill(
                      child: Container(
                        color: style.colors.onBackgroundOpacity20,
                      ),
                    ),
                  ],
                ),
              );
            }

            return TableViewCell(
              child: Container(
                decoration: BoxDecoration(
                  border: _target == column
                      ? Border(
                          left: target < dragged ? side : BorderSide.none,
                          right: target >= dragged ? side : BorderSide.none,
                        )
                      : null,
                ),
                child: cell,
              ),
            );
          },
          columnBuilder: (int index) {
            return Span(
              extent: MaxSpanExtent(
                FractionalSpanExtent(widget.builders[index].width / total),
                FixedSpanExtent(widget.builders[index].width < 2 ? 68 : 100),
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
  TableBuilder({
    this.key,
    required this.header,
    required this.builder,
    this.width = 1,
    this.identifier,
  });

  /// [GlobalKey] to build the [header] with, if any.
  final GlobalKey? key;

  /// Builder building the header of this row.
  final Widget Function() header;

  /// Builder building the data of this row.
  final Widget Function(E) builder;

  /// Width in flex units this column should occupy.
  final double width;

  /// Meta information embedded into this [TableBuilder].
  final String? identifier;
}
