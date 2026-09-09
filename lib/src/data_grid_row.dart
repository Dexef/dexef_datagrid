import 'dart:async';
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
  final bool autoEditFirstCell;
  final VoidCallback? onRowEditComplete;
  final bool showSelectionCheckbox;

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
    this.autoEditFirstCell = false,
    this.onRowEditComplete,
    this.showSelectionCheckbox = true,
  });

  @override
  State<DataGridRow> createState() => _DataGridRowState();
}

class _DataGridRowState extends State<DataGridRow> {
  bool isHover = false;
  String? _editingField;
  dynamic _editingValue;
  Timer? _autoCommitTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoEditFirstCell && widget.editMode != EditMode.none && widget.onCellEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final firstEditableColumn = widget.columns
            .where((col) => col.editable)
            .firstOrNull;
        if (firstEditableColumn != null) {
          final value = widget.rowData[firstEditableColumn.dataField];
          _startEditing(firstEditableColumn.dataField, value);
        }
      });
    }
  }

  @override
  void dispose() {
    _autoCommitTimer?.cancel();
    super.dispose();
  }

  void _startEditing(String field, dynamic value) {
    _autoCommitTimer?.cancel();
    setState(() {
      _editingField = field;
      _editingValue = value;
    });
  }

  void _cancelEditing() {
    _autoCommitTimer?.cancel();
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
    // Auto-commit after a short delay if no other cell starts editing
    if (widget.onRowEditComplete != null) {
      _autoCommitTimer?.cancel();
      _autoCommitTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted && _editingField == null) {
          widget.onRowEditComplete!();
        }
      });
    }
  }

  void _saveAndMoveToNext() {
    if (!mounted || _editingField == null) return;
    final currentField = _editingField!;
    final currentValue = _editingValue;

    // Save current cell
    if (widget.onCellEdit != null) {
      widget.onCellEdit!(widget.rowIndex, currentField, currentValue);
    }

    // Find next editable column
    final editableColumns = widget.columns.where((col) => col.editable).toList();
    final currentIndex = editableColumns.indexWhere((col) => col.dataField == currentField);

    if (currentIndex >= 0 && currentIndex < editableColumns.length - 1) {
      final nextColumn = editableColumns[currentIndex + 1];
      final nextValue = widget.rowData[nextColumn.dataField];
      setState(() {
        _editingField = nextColumn.dataField;
        _editingValue = nextValue;
      });
    } else {
      // No more editable cells
      setState(() {
        _editingField = null;
        _editingValue = null;
      });
      widget.onRowEditComplete?.call();
    }
  }

  Widget _buildEditingCell(BuildContext context, DataGridColumn column, dynamic value) {
    final hasRowEditBuilder = column.rowEditCellBuilder != null;
    final hasEditBuilder = column.editCellBuilder != null;
    final editor = DataGridCellEditor(
      field: column.dataField,
      value: value,
      column: column,
      textAlign: (hasRowEditBuilder || hasEditBuilder) ? TextAlign.start : TextAlign.center,
      onValueChanged: (field, newValue) {
        _editingValue = newValue;
      },
      onSave: _saveEditing,
      onSaveAndNavigateNext: _saveAndMoveToNext,
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
              child: (column.rowCellBuilder != null || column.cellBuilder != null)
                  ? column.buildCell(context, value, widget.rowData)
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

    final Widget content = hasRowEditBuilder
        ? column.rowEditCellBuilder!(context, widget.rowData, editor)
        : hasEditBuilder
            ? column.editCellBuilder!(context, value, editor)
            : Center(child: editor);

    // Apply hover background to editing cell
    final editingBgColor = isHover ? Colors.grey.withValues(alpha: 0.1) : Colors.white;

    return Container(
      height: widget.config.rowHeight,
      decoration: BoxDecoration(
        color: editingBgColor,
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
              child: SizedBox(
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
                              color: isHover ? Colors.grey.withValues(alpha: 0.1) : Colors.white,
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
                          child: widget.showSelectionCheckbox
                              ? DataGridCheckboxColumn(
                                  rowIndex: widget.rowIndex,
                                  isSelected: widget.isSelected,
                                  onChanged: (value) {
                                    if (widget.onRowSelect != null) {
                                      widget.onRowSelect!(widget.rowIndex);
                                    }
                                  },
                                  config: widget.config,
                                )
                              : const SizedBox.shrink(),
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
                              rowData: widget.rowData,
                              column: column,
                              config: widget.config,
                              isSelected: widget.isSelected,
                              isAlternateRow: widget.isAlternateRow,
                              isRowHover: isHover,
                              onTap: widget.editMode != EditMode.none && widget.onCellEdit != null && column.editable
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
          height: 0,
          child: ColoredBox(color: Colors.white),
        ),
      ],
    );
  }
}