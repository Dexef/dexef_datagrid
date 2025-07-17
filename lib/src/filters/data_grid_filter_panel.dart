import 'package:flutter/material.dart';
import '../../model/data_grid_filters.dart';
import '../../model/data_grid_model.dart';
import '../utils/data_grid_dialog.dart';
import 'data_grid_filter_widgets.dart';

/// Advanced filter panel with AND/OR conditions
class DataGridFilterPanel extends StatefulWidget {
  final List<DataGridColumn> columns;
  final DataGridFilterState filterState;
  final Function(DataGridFilterState) onFilterChanged;
  final VoidCallback onClose;

  const DataGridFilterPanel({
    super.key,
    required this.columns,
    required this.filterState,
    required this.onFilterChanged,
    required this.onClose,
  });

  @override
  State<DataGridFilterPanel> createState() => _DataGridFilterPanelState();
}

class _DataGridFilterPanelState extends State<DataGridFilterPanel> {
  late DataGridFilterState _currentFilterState;
  final List<DataGridFilter> _filters = [];
  FilterCondition _condition = FilterCondition.and;

  @override
  void initState() {
    super.initState();
    _currentFilterState = widget.filterState;
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Advanced Filter',
      icon: Icons.filter_list,
      headerColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ // Filter condition selector
          const Text(
            'Filter Condition',
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
                child: _buildConditionButton(
                  FilterCondition.and,
                  'AND',
                  Icons.add,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConditionButton(
                  FilterCondition.or,
                  'OR',
                  Icons.radio_button_unchecked,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Active filters
          if (_filters.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._filters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return _buildFilterItem(filter, index);
            }),
            const SizedBox(height: 20),
          ],
          // Add filter button
          Center(
            child: ElevatedButton.icon(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildConditionButton(
    FilterCondition condition,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _condition == condition;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          setState(() {
            _condition = condition;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(DataGridFilter filter, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          _getFilterTypeIcon(filter.type),
          color: _getFilterTypeColor(filter.type),
        ),
        title: Text(
          '${filter.field} ${_getFilterTypeLabel(filter.type)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_getFilterValueText(filter)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeFilter(index),
          iconSize: 20,
        ),
      ),
    );
  }

  IconData _getFilterTypeIcon(FilterType type) {
    switch (type) {
      case FilterType.equals:
        return Icons.check;
      case FilterType.notEquals:
        return Icons.close;
      case FilterType.contains:
        return Icons.search;
      case FilterType.startsWith:
        return Icons.text_fields;
      case FilterType.endsWith:
        return Icons.text_fields;
      case FilterType.greaterThan:
        return Icons.keyboard_arrow_up;
      case FilterType.lessThan:
        return Icons.keyboard_arrow_down;
      case FilterType.between:
        return Icons.compare_arrows;
      case FilterType.inList:
        return Icons.list;
      case FilterType.notInList:
        return Icons.list_alt;
      case FilterType.before:
        return Icons.schedule;
      case FilterType.after:
        return Icons.schedule;
      case FilterType.dateRange:
        return Icons.date_range;
      case FilterType.isTrue:
        return Icons.check;
      case FilterType.isFalse:
        return Icons.close;
    }
  }

  Color _getFilterTypeColor(FilterType type) {
    switch (type) {
      case FilterType.equals:
      case FilterType.contains:
      case FilterType.startsWith:
      case FilterType.endsWith:
        return Colors.blue;
      case FilterType.greaterThan:
        return Colors.green;
      case FilterType.lessThan:
        return Colors.red;
      case FilterType.between:
      case FilterType.dateRange:
        return Colors.orange;
      case FilterType.inList:
      case FilterType.notInList:
        return Colors.purple;
      case FilterType.isTrue:
        return Colors.green;
      case FilterType.isFalse:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFilterTypeLabel(FilterType type) {
    switch (type) {
      case FilterType.equals:
        return 'equals';
      case FilterType.notEquals:
        return 'not equals';
      case FilterType.contains:
        return 'contains';
      case FilterType.startsWith:
        return 'starts with';
      case FilterType.endsWith:
        return 'ends with';
      case FilterType.greaterThan:
        return 'greater than';
      case FilterType.lessThan:
        return 'less than';
      case FilterType.between:
        return 'between';
      case FilterType.inList:
        return 'in list';
      case FilterType.notInList:
        return 'not in list';
      case FilterType.before:
        return 'before';
      case FilterType.after:
        return 'after';
      case FilterType.dateRange:
        return 'date range';
      case FilterType.isTrue:
        return 'is true';
      case FilterType.isFalse:
        return 'is false';
    }
  }

  String _getFilterValueText(DataGridFilter filter) {
    if (filter.value == null) return '';
    
    if (filter.value is List) {
      final list = filter.value as List;
      return list.join(', ');
    }
    
    return filter.value.toString();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => DataGridDialogWithHeader(
        title: 'Add Filter',
        icon: Icons.add,
        headerColor: Colors.blue,
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<DataGridColumn>(
                  decoration: const InputDecoration(
                    labelText: 'Column',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.columns.map((column) {
                    return DropdownMenuItem(
                      value: column,
                      child: Text(column.caption),
                    );
                  }).toList(),
                  onChanged: (column) {
                    if (column != null) {
                      _showFilterWidget(column);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterWidget(DataGridColumn column) {
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (context) => DataGridDialogWithHeader(
        title: 'Filter ${column.caption}',
        icon: Icons.filter_list,
        headerColor: Colors.blue,
        content: SizedBox(
          width: 400,
          child: DataGridFilterWidgetFactory.createFilterWidget(
            field: column.dataField,
            dataType: column.dataType,
            onFilterChanged: (filter) {
              setState(() {
                _filters.add(filter);
              });
              Navigator.of(context).pop();
            },
            onFilterCleared: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
  }

  void _applyFilters() {
    if (_filters.isEmpty) {
      _currentFilterState = _currentFilterState.copyWith(
        filterGroup: null,
      );
    } else {
      final filterGroup = DataGridFilterGroup(
        filters: _filters,
        condition: _condition,
      );
      _currentFilterState = _currentFilterState.copyWith(
        filterGroup: filterGroup,
      );
    }
    
    widget.onFilterChanged(_currentFilterState);
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
    });
    _currentFilterState = _currentFilterState.clear();
    widget.onFilterChanged(_currentFilterState);
  }
}

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
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFields = [];
  bool _caseSensitive = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.filterState.searchFilter?.searchText ?? '';
    _selectedFields.addAll(widget.filterState.searchFilter?.searchFields ?? []);
    _caseSensitive = widget.filterState.searchFilter?.caseSensitive ?? false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Global Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Text',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _applySearch(),
            ),
          ),
          // Field selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search Fields (leave empty for all fields):'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.columns.map((column) {
                    final isSelected = _selectedFields.contains(column.dataField);
                    return FilterChip(
                      label: Text(column.caption),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFields.add(column.dataField);
                          } else {
                            _selectedFields.remove(column.dataField);
                          }
                        });
                        _applySearch();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Case sensitive option
          Padding(
            padding: const EdgeInsets.all(16),
            child: CheckboxListTile(
              title: const Text('Case Sensitive'),
              value: _caseSensitive,
              onChanged: (value) {
                setState(() {
                  _caseSensitive = value ?? false;
                });
                _applySearch();
              },
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applySearch,
                    child: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearSearch,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applySearch() {
    final searchFilter = DataGridSearchFilter(
      searchText: _searchController.text,
      searchFields: _selectedFields,
      caseSensitive: _caseSensitive,
    );
    
    final newFilterState = widget.filterState.copyWith(
      searchFilter: searchFilter,
    );
    
    widget.onFilterChanged(newFilterState);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedFields.clear();
      _caseSensitive = false;
    });
    
    final newFilterState = widget.filterState.copyWith(
      searchFilter: null,
    );
    
    widget.onFilterChanged(newFilterState);
  }
} 