import 'package:flutter/material.dart';
import '../../model/data_grid_model.dart';
import '../../model/data_grid_selection.dart';

/// Inline cell editor widget
class DataGridCellEditor extends StatefulWidget {
  final String field;
  final dynamic value;
  final DataGridColumn column;
  final Function(String field, dynamic value) onValueChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? errorMessage;

  const DataGridCellEditor({
    super.key,
    required this.field,
    required this.value,
    required this.column,
    required this.onValueChanged,
    required this.onSave,
    required this.onCancel,
    this.errorMessage,
  });

  @override
  State<DataGridCellEditor> createState() => _DataGridCellEditorState();
}

class _DataGridCellEditorState extends State<DataGridCellEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
    
    // Auto-focus when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.errorMessage != null ? Colors.red : Theme.of(context).primaryColor,
          width: 2,
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEditor(),
          if (widget.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, size: 16),
                onPressed: widget.onSave,
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: widget.onCancel,
                tooltip: 'Cancel',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    switch (widget.column.dataType) {
      case DataType.boolean:
        return _buildBooleanEditor();
      case DataType.date:
        return _buildDateEditor();
      case DataType.number:
        return _buildNumberEditor();
      case DataType.string:
      case DataType.custom:
      default:
        return _buildTextEditor();
    }
  }

  Widget _buildTextEditor() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onChanged: (value) {
        widget.onValueChanged(widget.field, value);
      },
      onSubmitted: (_) => widget.onSave(),
    );
  }

  Widget _buildNumberEditor() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onChanged: (value) {
        final number = double.tryParse(value);
        widget.onValueChanged(widget.field, number);
      },
      onSubmitted: (_) => widget.onSave(),
    );
  }

  Widget _buildBooleanEditor() {
    final boolValue = widget.value is bool ? widget.value : widget.value?.toString().toLowerCase() == 'true';
    
    return DropdownButton<bool>(
      value: boolValue,
      items: const [
        DropdownMenuItem(value: true, child: Text('True')),
        DropdownMenuItem(value: false, child: Text('False')),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.onValueChanged(widget.field, value);
        }
      },
    );
  }

  Widget _buildDateEditor() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: widget.value is DateTime ? widget.value : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          widget.onValueChanged(widget.field, date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          widget.value is DateTime 
              ? '${widget.value.day.toString().padLeft(2, '0')}/${widget.value.month.toString().padLeft(2, '0')}/${widget.value.year}'
              : 'Select Date',
        ),
      ),
    );
  }
}

/// Form editor widget for row editing
class DataGridFormEditor extends StatefulWidget {
  final Map<String, dynamic> rowData;
  final List<DataGridColumn> columns;
  final Function(String field, dynamic value) onValueChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Map<String, String> validationErrors;

  const DataGridFormEditor({
    super.key,
    required this.rowData,
    required this.columns,
    required this.onValueChanged,
    required this.onSave,
    required this.onCancel,
    this.validationErrors = const {},
  });

  @override
  State<DataGridFormEditor> createState() => _DataGridFormEditorState();
}

class _DataGridFormEditorState extends State<DataGridFormEditor> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (final column in widget.columns) {
      _controllers[column.dataField] = TextEditingController(
        text: widget.rowData[column.dataField]?.toString() ?? '',
      );
      _focusNodes[column.dataField] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.columns.map((column) => _buildFormField(column)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(DataGridColumn column) {
    final controller = _controllers[column.dataField];
    final focusNode = _focusNodes[column.dataField];
    final errorMessage = widget.validationErrors[column.dataField];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            column.caption,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildFieldEditor(column, controller!, focusNode!),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldEditor(DataGridColumn column, TextEditingController controller, FocusNode focusNode) {
    switch (column.dataType) {
      case DataType.boolean:
        return _buildBooleanField(column, controller);
      case DataType.date:
        return _buildDateField(column, controller);
      case DataType.number:
        return _buildNumberField(column, controller, focusNode);
      case DataType.string:
      case DataType.custom:
      default:
        return _buildTextField(column, controller, focusNode);
    }
  }

  Widget _buildTextField(DataGridColumn column, TextEditingController controller, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        widget.onValueChanged(column.dataField, value);
      },
    );
  }

  Widget _buildNumberField(DataGridColumn column, TextEditingController controller, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        final number = double.tryParse(value);
        widget.onValueChanged(column.dataField, number);
      },
    );
  }

  Widget _buildBooleanField(DataGridColumn column, TextEditingController controller) {
    final boolValue = widget.rowData[column.dataField] is bool 
        ? widget.rowData[column.dataField] 
        : widget.rowData[column.dataField]?.toString().toLowerCase() == 'true';
    
    return DropdownButtonFormField<bool>(
      value: boolValue,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: true, child: Text('True')),
        DropdownMenuItem(value: false, child: Text('False')),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.onValueChanged(column.dataField, value);
        }
      },
    );
  }

  Widget _buildDateField(DataGridColumn column, TextEditingController controller) {
    final currentDate = widget.rowData[column.dataField] is DateTime 
        ? widget.rowData[column.dataField] 
        : DateTime.now();
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          widget.onValueChanged(column.dataField, date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          currentDate is DateTime 
              ? '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}'
              : 'Select Date',
        ),
      ),
    );
  }
}

/// Validation error indicator widget
class DataGridValidationErrorIndicator extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onDismiss;

  const DataGridValidationErrorIndicator({
    super.key,
    required this.errorMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
} 