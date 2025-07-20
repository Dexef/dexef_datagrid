import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Represents a cell in the data grid
class DataGridCell extends StatelessWidget {
  final dynamic value;
  final DataGridColumn column;
  final DataGridConfig config;
  final bool isSelected;
  final bool isAlternateRow;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isEditing;
  final String? errorMessage;
  final bool showMoreVert;

  const DataGridCell({
    super.key,
    required this.value,
    required this.column,
    required this.config,
    this.isSelected = false,
    this.isAlternateRow = false,
    this.onTap,
    this.onDoubleTap,
    this.isEditing = false,
    this.errorMessage,
    this.showMoreVert = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: DataGridCellSelectionHighlight(
        isSelected: isSelected,
        hasError: errorMessage != null,
        child: Container(
          height: config.rowHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: config.showHorizontalBorders && !config.showBorders
                ? Border(
                    bottom: BorderSide(
                      color: config.borderColor,
                      width: config.borderWidth,
                    ),
                  )
                : config.showBorders
                    ? Border(
                        right: BorderSide(
                          color: config.borderColor,
                          width: config.borderWidth,
                        ),
                        bottom: BorderSide(
                          color: config.borderColor,
                          width: config.borderWidth,
                        ),
                      )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: showMoreVert 
                ? Row(
                    children: [
                      Expanded(child: column.buildCell(context, value)),
                      const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  )
                : column.buildCell(context, value),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return Colors.blue.withOpacity(0.2);
    }
    
    // Always return white background, no alternate row coloring
    return Colors.white;
  }
} 