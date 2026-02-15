import 'package:flutter/material.dart';
import '../../model/data_grid_model.dart';
import '../style/style_size.dart';
import '../widgets/default_text.dart';

/// Inline cell editor widget
class DataGridCellEditor extends StatefulWidget {
  final String field;
  final dynamic value;
  final DataGridColumn column;
  final Function(String field, dynamic value) onValueChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? errorMessage;
  final TextAlign textAlign;

  const DataGridCellEditor({
    super.key,
    required this.field,
    required this.value,
    required this.column,
    required this.onValueChanged,
    required this.onSave,
    required this.onCancel,
    this.errorMessage,
    this.textAlign = TextAlign.center,
  });

  @override
  State<DataGridCellEditor> createState() => _DataGridCellEditorState();
}

class _DataGridCellEditorState extends State<DataGridCellEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _saved = false;

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_saved && mounted) {
      _saved = true;
      widget.onSave();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditor();
  }

  Widget _buildEditor() {
    switch (widget.column.dataType) {
      case DataType.boolean:
        return _buildBooleanEditor();
      case DataType.date:
        return _buildDateEditor();
      case DataType.number:
        return _buildNumberEditor();
      case DataType.list:
        return _buildListEditor();
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
      textAlign: widget.textAlign,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff464646)),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      onChanged: (value) {
        widget.onValueChanged(widget.field, value);
      },
      onSubmitted: (_) {
        if (!_saved) {
          _saved = true;
          widget.onSave();
        }
      },
    );
  }

  Widget _buildNumberEditor() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textAlign: widget.textAlign,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff464646)),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      onChanged: (value) {
        final number = double.tryParse(value);
        widget.onValueChanged(widget.field, number);
      },
      onSubmitted: (_) {
        if (!_saved) {
          _saved = true;
          widget.onSave();
        }
      },
    );
  }

  static const List<Color> _listItemColors = [
    Color(0xFF5AACD4), // light blue
    Color(0xFF9B59B6), // purple
    Color(0xFF2ECC71), // green
    Color(0xFFE8A838), // orange
    Color(0xFF3A7BD5), // blue
    Color(0xFF1ABC9C), // teal
    Color(0xFFE74C3C), // red
    Color(0xFFF39C12), // yellow
  ];

  final GlobalKey _listKey = GlobalKey();
  bool _listMenuOpened = false;

  void _showListMenu() async {
    if (_listMenuOpened) return;
    _listMenuOpened = true;

    final items = widget.column.listItems ?? [];
    final renderBox = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate position, ensure it stays within screen bounds
    double top = offset.dy + size.height + 4;
    double left = offset.dx - 8;
    const double menuWidth = 200.0;
    final double menuHeight = (items.length * 42.0) + 100;

    if (top + menuHeight > screenSize.height) {
      top = offset.dy - menuHeight - 4;
    }
    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 8;
    }
    if (left < 8) left = 8;

    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black26,
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final color = _listItemColors[index % _listItemColors.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(item),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: color,
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Divider(height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.edit, size: 18, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  'Edit Labels',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              Icon(Icons.auto_awesome, size: 18, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Auto-assign labels',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      widget.onValueChanged(widget.field, result);
    }
    if (!_saved && mounted) {
      _saved = true;
      widget.onSave();
    }
  }

  Widget _buildListEditor() {
    final currentValue = widget.value?.toString() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showListMenu();
    });

    return Container(
      key: _listKey,
      child: Text(
        currentValue,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xff0075F4),
        ),
        textAlign: widget.textAlign,
      ),
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
          DefaultText(
            text: column.caption,
            isTextTheme:true,
            themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            column.caption,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildFieldEditor(column, controller!, focusNode!),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: DefaultText(
                text: errorMessage,
                isTextTheme:true,
                themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.red,
                  fontSize: AppFontSize().setFontSize(context,webFontSize: 10),
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
      case DataType.list:
        return _buildListField(column, controller);
      case DataType.string:
      case DataType.custom:
      default:
        return _buildTextField(column, controller, focusNode);
    }
  }

  Widget _buildListField(DataGridColumn column, TextEditingController controller) {
    final items = column.listItems ?? [];
    final currentValue = widget.rowData[column.dataField]?.toString() ?? '';

    return DropdownButtonFormField<String>(
      value: items.contains(currentValue) ? currentValue : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
          widget.onValueChanged(column.dataField, value);
        }
      },
    );
  }

  Widget _buildTextField(DataGridColumn column, TextEditingController controller, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: DefaultText(
              text:errorMessage,
              isTextTheme:true,
              themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.red,
                fontSize:  AppFontSize().setFontSize(context,webFontSize: 10),
              ),
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