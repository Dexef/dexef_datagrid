import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_selection.dart';
import 'data_grid_cell.dart';
import 'editing/data_grid_editing_widgets.dart';
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
  String? _editingField;
  dynamic _editingValue;

  void _startEditing(String field, dynamic value) {
    setState(() {
      _editingField = field;
      _editingValue = value;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingField = null;
      _editingValue = null;
    });
  }

  void _saveEditing() {
    if (!mounted || _editingField == null) return;
    if (widget.onCellEdit != null) {
      widget.onCellEdit!(widget.rowIndex, _editingField!, _editingValue);
    }
    setState(() {
      _editingField = null;
      _editingValue = null;
    });
  }

  Widget _buildEditingCell(BuildContext context, DataGridColumn column, dynamic value) {
    final hasEditBuilder = column.editCellBuilder != null;
    final editor = DataGridCellEditor(
      field: column.dataField,
      value: value,
      column: column,
      textAlign: hasEditBuilder ? TextAlign.start : TextAlign.center,
      onValueChanged: (field, newValue) {
        _editingValue = newValue;
      },
      onSave: _saveEditing,
      onCancel: _cancelEditing,
    );

    // For list/date type, keep the original cell appearance while the picker shows
    if (column.dataType == DataType.list || column.dataType == DataType.date) {
      return SizedBox(
        height: widget.config.rowHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: column.cellBuilder != null
                  ? column.buildCell(context, value)
                  : Center(child: Text(value?.toString() ?? '')),
            ),
            Positioned(
              width: 0,
              height: 0,
              child: Opacity(opacity: 0, child: editor),
            ),
          ],
        ),
      );
    }

    final content = hasEditBuilder
        ? column.editCellBuilder!(context, value, editor)
        : Center(child: editor);

    return Container(
      height: widget.config.rowHeight,
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DataGridRowSelectionHighlight(
          isSelected: widget.isSelected,
          child: GestureDetector(
            onTap: widget.editMode != EditMode.none ? null : () {
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
                height: widget.config.rowHeight,
                width: double.infinity,
                child: Row(
                  children: [
                    // Checkbox for selection
                    if (widget.selectionMode == SelectionMode.multiple) ...[
                      Container(
                        width: 6,
                        height: widget.config.rowHeight,
                        color: const Color(0xff2196F3),
                      ),
                      SizedBox(
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                right: widget.config.showBorders ? BorderSide(
                                  color: widget.config.borderColor,
                                  width: widget.config.borderWidth,
                                ) : BorderSide.none,
                                bottom: BorderSide(
                                  color: widget.config.borderColor,
                                  width: widget.config.borderWidth,
                                ),
                              ),
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
                    ],
                ...widget.columns.asMap().entries.map((entry) {
                  final columnIndex = entry.key;
                  final column = entry.value;
                  final value = widget.rowData[column.dataField];
                  final isEditingThisCell = _editingField == column.dataField;

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
                      child: isEditingThisCell
                          ? _buildEditingCell(context, column, value)
                          : DataGridCell(
                              value: value,
                              column: column,
                              config: widget.config,
                              isSelected: widget.isSelected,
                              isAlternateRow: widget.isAlternateRow,
                              onTap: widget.editMode != EditMode.none && widget.onCellEdit != null
                                  ? () => _startEditing(column.dataField, value)
                                  : widget.onCellTap != null
                                      ? () => widget.onCellTap!(widget.rowIndex)
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
    ),
        const SizedBox(
          height: 3,
          child: ColoredBox(color: Colors.white),
        ),
      ],
    );
  }
}