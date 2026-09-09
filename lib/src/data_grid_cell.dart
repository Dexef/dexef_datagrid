import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Represents a cell in the data grid
class DataGridCell extends StatefulWidget {
  final dynamic value;
  final DataGridColumn column;
  final DataGridConfig config;
  final bool isSelected;
  final bool isAlternateRow;
  final bool isRowHover;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isEditing;
  final String? errorMessage;
  final bool showMoreVert;
  /// Full row data, forwarded to [DataGridColumn.rowCellBuilder] when set.
  final Map<String, dynamic>? rowData;

  const DataGridCell({
    super.key,
    required this.value,
    required this.column,
    required this.config,
    this.isSelected = false,
    this.isAlternateRow = false,
    this.isRowHover = false,
    this.onTap,
    this.onDoubleTap,
    this.isEditing = false,
    this.errorMessage,
    this.showMoreVert = false,
    this.rowData,
  });

  @override
  State<DataGridCell> createState() => _DataGridCellState();
}

class _DataGridCellState extends State<DataGridCell> {
  bool _isCellHover = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isCellHover = true),
      onExit: (_) => setState(() => _isCellHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: DataGridCellSelectionHighlight(
        isSelected: widget.isSelected,
        hasError: widget.errorMessage != null,
        child: Container(
          height: widget.config.rowHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: widget.config.showHorizontalBorders && !widget.config.showBorders
                ? Border(
                    bottom: BorderSide(
                      color: widget.config.borderColor,
                      width: widget.config.borderWidth,
                    ),
                  )
                : widget.config.showBorders
                    ? Border(
                    right: BorderSide(
                      color: widget.config.borderColor,
                      width: widget.config.borderWidth,
                    ),
                    bottom: BorderSide(
                      color: widget.config.borderColor,
                      width: widget.config.borderWidth,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: widget.showMoreVert
                ? Row(
                    children: [
                      Expanded(child: widget.column.buildCell(context, widget.value, widget.rowData)),
                      const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  )
                : widget.column.buildCell(context, widget.value, widget.rowData),
          ),
        ),
      ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) {
      return Colors.blue.withValues(alpha: 0.2);
    }

    // Default white background
    return Colors.white;
  }
} 