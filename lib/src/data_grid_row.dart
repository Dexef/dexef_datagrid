import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_selection.dart';
import 'data_grid_cell.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Represents a row in the data grid
class DataGridRow extends StatelessWidget {
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

  const DataGridRow({
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
    return DataGridRowSelectionHighlight(
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
        child: SizedBox(
          height: config.rowHeight,
          width: double.infinity,
          child: Row(
            children: [
              // Checkbox for selection
              if (selectionMode == SelectionMode.multiple)
                SizedBox(
                  width: 50,
                  child: Container(
                    decoration: config.showBorders ? BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                        border: Border(
                          right: BorderSide(
                            color: config.borderColor,
                            width: config.borderWidth,
                          ),
                        ),
                      ):BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white   // change background of checkbox
                    ),
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
                ),
              ...columns.asMap().entries.map((entry) {
                final columnIndex = entry.key;
                final column = entry.value;
                final value = rowData[column.dataField];
                
                return Expanded(
                  flex: column.width?.toInt() ?? 1,
                  child: Container(
                    decoration: config.showBorders
                        ? BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: config.borderColor,
                                width: config.borderWidth,
                              ),
                            ),
                          )
                        : null,
                    child: DataGridCell(
                      value: value,
                      column: column,
                      config: config,
                      isSelected: isSelected,
                      isAlternateRow: isAlternateRow,
                      onTap: onCellTap != null ? () => onCellTap!(rowIndex) : null,
                      onDoubleTap: editMode != EditMode.none && onCellEdit != null 
                          ? () => onCellEdit!(rowIndex, column.dataField, value) 
                          : null,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
} 