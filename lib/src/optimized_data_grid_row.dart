import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_selection.dart';
import 'optimized_data_grid_cell.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Optimized DataGridRow with performance enhancements:
/// - RepaintBoundary for efficient repaints
/// - Lazy loading for images and complex widgets
/// - Efficient key management for diffing
class OptimizedDataGridRow extends StatelessWidget {
  final Map<String, dynamic> rowData;
  final List<DataGridColumn> columns;
  final DataGridConfig config;
  final int rowIndex;
  final bool isSelected;
  final bool isAlternateRow;
  final VoidCallback? onRowTap;
  final Function(int)? onCellTap;
  final SelectionMode selectionMode;
  final EditMode editMode;
  final bool isEditing;
  final Function(int)? onRowSelect;
  final Function(int, String, dynamic)? onCellEdit;

  const OptimizedDataGridRow({
    super.key,
    required this.rowData,
    required this.columns,
    required this.config,
    required this.rowIndex,
    this.isSelected = false,
    this.isAlternateRow = false,
    this.onRowTap,
    this.onCellTap,
    this.selectionMode = SelectionMode.none,
    this.editMode = EditMode.none,
    this.isEditing = false,
    this.onRowSelect,
    this.onCellEdit,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DataGridRowSelectionHighlight(
        isSelected: isSelected,
        child: GestureDetector(
          onTap: () {
            if (selectionMode != SelectionMode.none && onRowSelect != null) {
              onRowSelect!(rowIndex);
            }
            if (onRowTap != null) {
              onRowTap!();
            }
          },
          child: Container(
            height: config.rowHeight,
            child: IntrinsicWidth(
              child: Row(
                children: [
                  // Checkbox for selection
                  if (selectionMode == SelectionMode.multiple)
                    RepaintBoundary(
                      child: DataGridCheckboxColumn(
                        rowIndex: rowIndex,
                        isSelected: isSelected,
                        onChanged: (value) {
                          if (onRowSelect != null) {
                            onRowSelect!(rowIndex);
                          }
                        },
                        config: config,
                      ),
                    ),
                  ...columns.map((column) {
                    final value = rowData[column.dataField];
                    final width = column.width ?? config.minColumnWidth;
                    
                    return OptimizedDataGridCell(
                      key: ValueKey('cell_${rowIndex}_${column.dataField}'),
                      value: value,
                      column: column,
                      config: config,
                      isSelected: isSelected,
                      isAlternateRow: isAlternateRow,
                      onTap: onCellTap != null ? () => onCellTap!(rowIndex) : null,
                      onDoubleTap: editMode != EditMode.none && onCellEdit != null 
                          ? () => onCellEdit!(rowIndex, column.dataField, value) 
                          : null,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 