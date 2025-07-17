import 'package:flutter/material.dart';
import '../../model/data_grid_filters.dart';
import '../../model/data_grid_model.dart';
import '../utils/data_grid_dialog.dart';

/// Global search panel
class DataGridSearchPanel extends StatefulWidget {
  final List<DataGridColumn> columns;
  final DataGridFilterState filterState;
  final Function(DataGridFilterState) onFilterChanged;
  final VoidCallback onClose;

  const DataGridSearchPanel({
    super.key,
    required this.columns,
    required this.filterState,
    required this.onFilterChanged,
    required this.onClose,
  });

  @override
  State<DataGridSearchPanel> createState() => _DataGridSearchPanelState();
}

class _DataGridSearchPanelState extends State<DataGridSearchPanel> {
  late DataGridFilterState _currentFilterState;
  String _searchText = '';
  List<String> _selectedFields = [];

  @override
  void initState() {
    super.initState();
    _currentFilterState = widget.filterState;
    _selectedFields = widget.columns.map((col) => col.dataField).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Global Search',
      icon: Icons.search,
      headerColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input
          const Text(
            'Search Term',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter search term...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
          const SizedBox(height: 20),
          // Column selection
          const Text(
            'Search in Columns',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Select All'),
                  leading: Checkbox(
                    value: _selectedFields.length == widget.columns.length,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedFields = widget.columns.map((col) => col.dataField).toList();
                        } else {
                          _selectedFields.clear();
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (_selectedFields.length == widget.columns.length) {
                        _selectedFields.clear();
                      } else {
                        _selectedFields = widget.columns.map((col) => col.dataField).toList();
                      }
                    });
                  },
                ),
                const Divider(height: 1),
                ...widget.columns.map((column) {
                  return CheckboxListTile(
                    title: Text(column.caption),
                    subtitle: Text(column.dataField),
                    value: _selectedFields.contains(column.dataField),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedFields.add(column.dataField);
                        } else {
                          _selectedFields.remove(column.dataField);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Search options
          const Text(
            'Search Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSearchOption(
                  'Case Sensitive',
                  Icons.text_fields,
                  Colors.blue,
                  false,
                  (value) {
                    // Handle case sensitive option
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSearchOption(
                  'Whole Word',
                  Icons.text_format,
                  Colors.green,
                  false,
                  (value) {
                    // Handle whole word option
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applySearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildSearchOption(
    String label,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: value ? color : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: value ? color : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                value ? Icons.check : Icons.close,
                color: value ? color : Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applySearch() {
    if (_searchText.isEmpty || _selectedFields.isEmpty) {
      // Clear search
      _currentFilterState = _currentFilterState.copyWith(
        searchFilter: null,
      );
    } else {
      // Apply search
      final searchFilter = DataGridSearchFilter(
        searchText: _searchText,
        searchFields: _selectedFields,
        caseSensitive: false, // TODO: Add case sensitive option
      );
      
      _currentFilterState = _currentFilterState.copyWith(
        searchFilter: searchFilter,
      );
    }
    
    widget.onFilterChanged(_currentFilterState);
    widget.onClose();
  }
} 