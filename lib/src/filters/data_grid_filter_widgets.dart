import 'package:flutter/material.dart';
import '../../model/data_grid_filters.dart';
import '../../model/data_grid_model.dart';

/// Base filter widget
abstract class DataGridFilterWidget extends StatefulWidget {
  final String field;
  final DataType dataType;
  final Function(DataGridFilter) onFilterChanged;
  final Function() onFilterCleared;

  const DataGridFilterWidget({
    super.key,
    required this.field,
    required this.dataType,
    required this.onFilterChanged,
    required this.onFilterCleared,
  });
}

/// Text filter widget
class DataGridTextFilterWidget extends DataGridFilterWidget {
  const DataGridTextFilterWidget({
    super.key,
    required super.field,
    required super.dataType,
    required super.onFilterChanged,
    required super.onFilterCleared,
  });

  @override
  State<DataGridTextFilterWidget> createState() => _DataGridTextFilterWidgetState();
}

class _DataGridTextFilterWidgetState extends State<DataGridTextFilterWidget> {
  final TextEditingController _controller = TextEditingController();
  FilterType _selectedType = FilterType.contains;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter type dropdown
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<FilterType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter Type',
                border: OutlineInputBorder(),
              ),
              items: [
                FilterType.contains,
                FilterType.startsWith,
                FilterType.endsWith,
                FilterType.equals,
                FilterType.notEquals,
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getFilterTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                  _applyFilter();
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Text input
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Filter Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _applyFilter(),
          ),
          const SizedBox(height: 8),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onFilterCleared();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    if (_controller.text.isNotEmpty) {
      final filter = DataGridFilter.text(
        field: widget.field,
        type: _selectedType,
        value: _controller.text,
      );
      widget.onFilterChanged(filter);
    }
  }

  String _getFilterTypeLabel(FilterType type) {
    switch (type) {
      case FilterType.contains:
        return 'Contains';
      case FilterType.startsWith:
        return 'Starts With';
      case FilterType.endsWith:
        return 'Ends With';
      case FilterType.equals:
        return 'Equals';
      case FilterType.notEquals:
        return 'Not Equals';
      default:
        return 'Contains';
    }
  }
}

/// Number filter widget
class DataGridNumberFilterWidget extends DataGridFilterWidget {
  const DataGridNumberFilterWidget({
    super.key,
    required super.field,
    required super.dataType,
    required super.onFilterChanged,
    required super.onFilterCleared,
  });

  @override
  State<DataGridNumberFilterWidget> createState() => _DataGridNumberFilterWidgetState();
}

class _DataGridNumberFilterWidgetState extends State<DataGridNumberFilterWidget> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _secondValueController = TextEditingController();
  FilterType _selectedType = FilterType.equals;

  @override
  void dispose() {
    _valueController.dispose();
    _secondValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter type dropdown
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<FilterType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter Type',
                border: OutlineInputBorder(),
              ),
              items: [
                FilterType.equals,
                FilterType.notEquals,
                FilterType.greaterThan,
                FilterType.lessThan,
                FilterType.between,
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getFilterTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                  _applyFilter();
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // First value input
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _applyFilter(),
          ),
          if (_selectedType == FilterType.between) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _secondValueController,
              decoration: const InputDecoration(
                labelText: 'Second Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _applyFilter(),
            ),
          ],
          const SizedBox(height: 8),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _valueController.clear();
                    _secondValueController.clear();
                    widget.onFilterCleared();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    final value = double.tryParse(_valueController.text);
    if (value != null) {
      num? secondValue;
      if (_selectedType == FilterType.between) {
        secondValue = double.tryParse(_secondValueController.text);
      }

      final filter = DataGridFilter.number(
        field: widget.field,
        type: _selectedType,
        value: value,
        secondValue: secondValue,
      );
      widget.onFilterChanged(filter);
    }
  }

  String _getFilterTypeLabel(FilterType type) {
    switch (type) {
      case FilterType.equals:
        return 'Equals';
      case FilterType.notEquals:
        return 'Not Equals';
      case FilterType.greaterThan:
        return 'Greater Than';
      case FilterType.lessThan:
        return 'Less Than';
      case FilterType.between:
        return 'Between';
      default:
        return 'Equals';
    }
  }
}

/// Date filter widget
class DataGridDateFilterWidget extends DataGridFilterWidget {
  const DataGridDateFilterWidget({
    super.key,
    required super.field,
    required super.dataType,
    required super.onFilterChanged,
    required super.onFilterCleared,
  });

  @override
  State<DataGridDateFilterWidget> createState() => _DataGridDateFilterWidgetState();
}

class _DataGridDateFilterWidgetState extends State<DataGridDateFilterWidget> {
  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  FilterType _selectedType = FilterType.equals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter type dropdown
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<FilterType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter Type',
                border: OutlineInputBorder(),
              ),
              items: [
                FilterType.equals,
                FilterType.before,
                FilterType.after,
                FilterType.dateRange,
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getFilterTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                  _applyFilter();
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Date picker
          ListTile(
            title: Text(_selectedDate?.toString().split(' ')[0] ?? 'Select Date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
                _applyFilter();
              }
            },
          ),
          if (_selectedType == FilterType.dateRange) ...[
            const SizedBox(height: 8),
            ListTile(
              title: Text(_selectedEndDate?.toString().split(' ')[0] ?? 'Select End Date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedEndDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedEndDate = date;
                  });
                  _applyFilter();
                }
              },
            ),
          ],
          const SizedBox(height: 8),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                      _selectedEndDate = null;
                    });
                    widget.onFilterCleared();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    if (_selectedDate != null) {
      final filter = DataGridFilter.date(
        field: widget.field,
        type: _selectedType,
        value: _selectedDate!,
        secondValue: _selectedEndDate,
      );
      widget.onFilterChanged(filter);
    }
  }

  String _getFilterTypeLabel(FilterType type) {
    switch (type) {
      case FilterType.equals:
        return 'Equals';
      case FilterType.before:
        return 'Before';
      case FilterType.after:
        return 'After';
      case FilterType.dateRange:
        return 'Date Range';
      default:
        return 'Equals';
    }
  }
}

/// Boolean filter widget
class DataGridBooleanFilterWidget extends DataGridFilterWidget {
  const DataGridBooleanFilterWidget({
    super.key,
    required super.field,
    required super.dataType,
    required super.onFilterChanged,
    required super.onFilterCleared,
  });

  @override
  State<DataGridBooleanFilterWidget> createState() => _DataGridBooleanFilterWidgetState();
}

class _DataGridBooleanFilterWidgetState extends State<DataGridBooleanFilterWidget> {
  bool? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Boolean options
          RadioListTile<bool?>(
            title: const Text('All'),
            value: null,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onFilterCleared();
            },
          ),
          RadioListTile<bool?>(
            title: const Text('True'),
            value: true,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              _applyFilter();
            },
          ),
          RadioListTile<bool?>(
            title: const Text('False'),
            value: false,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              _applyFilter();
            },
          ),
          const SizedBox(height: 8),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedValue = null;
                    });
                    widget.onFilterCleared();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    if (_selectedValue != null) {
      final filter = DataGridFilter.boolean(
        field: widget.field,
        value: _selectedValue!,
      );
      widget.onFilterChanged(filter);
    }
  }
}

/// Filter widget factory
class DataGridFilterWidgetFactory {
  static DataGridFilterWidget createFilterWidget({
    required String field,
    required DataType dataType,
    required Function(DataGridFilter) onFilterChanged,
    required Function() onFilterCleared,
  }) {
    switch (dataType) {
      case DataType.string:
        return DataGridTextFilterWidget(
          field: field,
          dataType: dataType,
          onFilterChanged: onFilterChanged,
          onFilterCleared: onFilterCleared,
        );
      case DataType.number:
        return DataGridNumberFilterWidget(
          field: field,
          dataType: dataType,
          onFilterChanged: onFilterChanged,
          onFilterCleared: onFilterCleared,
        );
      case DataType.date:
        return DataGridDateFilterWidget(
          field: field,
          dataType: dataType,
          onFilterChanged: onFilterChanged,
          onFilterCleared: onFilterCleared,
        );
      case DataType.boolean:
        return DataGridBooleanFilterWidget(
          field: field,
          dataType: dataType,
          onFilterChanged: onFilterChanged,
          onFilterCleared: onFilterCleared,
        );
      case DataType.custom:
        return DataGridTextFilterWidget(
          field: field,
          dataType: dataType,
          onFilterChanged: onFilterChanged,
          onFilterCleared: onFilterCleared,
        );
    }
  }
} 