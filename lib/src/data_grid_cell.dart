import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_selection.dart';
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
            border: config.showBorders
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
            child: column.buildCell(context, value),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return Colors.blue.withOpacity(0.2);
    }
    
    if (isAlternateRow && config.showAlternateRows) {
      return config.alternateRowBackgroundColor;
    }
    
    return config.rowBackgroundColor;
  }
} 