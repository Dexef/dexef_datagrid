import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_selection.dart';
import 'data_grid_cell.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Represents a row in the data grid
class DataGridRow extends StatefulWidget {
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
  State<DataGridRow> createState() => _DataGridRowState();
}

class _DataGridRowState extends State<DataGridRow> {
 bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return DataGridRowSelectionHighlight(
      isSelected: widget.isSelected,
      child: GestureDetector(
        onTap: () {
          if (widget.selectionMode != SelectionMode.none && widget.onRowSelect != null) {
            widget.onRowSelect!(widget.rowIndex);
          }
          if (widget.onRowTap != null) {
            widget.onRowTap!();
          }
        },
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: Container(
            color: isHover ? Colors.red : Colors.transparent,
            height: widget.config.rowHeight,
            width: double.infinity,
            child: Row(
              children: [
                // Checkbox for selection
                if (widget.selectionMode == SelectionMode.multiple)
                  SizedBox(
                    width: 50,
                    child: Container(
                      decoration: widget.config.showBorders ? BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                          border: Border(
                            right: BorderSide(
                              color: widget.config.borderColor,
                              width: widget.config.borderWidth,
                            ),
                          ),
                        ):BoxDecoration(
                        color: widget.isSelected ? Colors.blue.withOpacity(0.2) : Colors.white   // change background of checkbox
                      ),
                      child: DataGridCheckboxColumn(
                        rowIndex: widget.rowIndex,
                        isSelected: widget.isSelected,
                        onChanged: (value) {
                          if (widget.onRowSelect != null) {
                            widget.onRowSelect!(widget.rowIndex);
                          }
                        },
                        config: widget.config,
                      ),
                    ),
                  ),
                ...widget.columns.asMap().entries.map((entry) {
                  final columnIndex = entry.key;
                  final column = entry.value;
                  final value = widget.rowData[column.dataField];

                  return Expanded(
                    flex: column.width?.toInt() ?? 1,
                    child: Container(
                      decoration: widget.config.showBorders
                          ? BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: widget.config.borderColor,
                                  width: widget.config.borderWidth,
                                ),
                              ),
                            )
                          : null,
                      child: DataGridCell(
                        value: value,
                        column: column,
                        config: widget.config,
                        isSelected: widget.isSelected,
                        isAlternateRow: widget.isAlternateRow,
                        onTap: widget.onCellTap != null ? () => widget.onCellTap!(widget.rowIndex) : null,
                        onDoubleTap: widget.editMode != EditMode.none && widget.onCellEdit != null
                            ? () => widget.onCellEdit!(widget.rowIndex, column.dataField, value)
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}