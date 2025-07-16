import 'package:flutter/material.dart';
import '../../model/data_grid_sorting.dart';
import '../utils/data_grid_dialog.dart';

/// Sort indicator widget
class DataGridSortIndicator extends StatelessWidget {
  final SortOrder sortOrder;

  const DataGridSortIndicator({
    super.key,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (sortOrder) {
      case SortOrder.ascending:
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case SortOrder.descending:
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case SortOrder.none:
        icon = Icons.unfold_more;
        color = Colors.grey;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }
}

/// Sort priority indicator widget
class DataGridSortPriorityIndicator extends StatelessWidget {
  final List<DataGridSort> activeSorts;
  final VoidCallback? onTap;

  const DataGridSortPriorityIndicator({
    super.key,
    required this.activeSorts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (activeSorts.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              '${activeSorts.length} sort${activeSorts.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sort controls widget
class DataGridSortControls extends StatelessWidget {
  final String field;
  final SortOrder currentSort;
  final int? priority;
  final VoidCallback onSort;
  final VoidCallback? onRemoveSort;
  final bool showPriority;

  const DataGridSortControls({
    super.key,
    required this.field,
    required this.currentSort,
    this.priority,
    required this.onSort,
    this.onRemoveSort,
    this.showPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPriority && priority != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${priority!}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 4),
        InkWell(
          onTap: onSort,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DataGridSortIndicator(sortOrder: currentSort),
          ),
        ),
        if (onRemoveSort != null && currentSort != SortOrder.none) ...[
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemoveSort,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 12, color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }
}

/// Sort configuration dialog
class DataGridSortDialog extends StatefulWidget {
  final List<DataGridSort> currentSorts;
  final List<String> availableFields;

  const DataGridSortDialog({
    super.key,
    required this.currentSorts,
    required this.availableFields,
  });

  @override
  State<DataGridSortDialog> createState() => _DataGridSortDialogState();
}

class _DataGridSortDialogState extends State<DataGridSortDialog> {
  late List<DataGridSort> sorts;

  @override
  void initState() {
    super.initState();
    sorts = List.from(widget.currentSorts);
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Sort Configuration',
      icon: Icons.sort,
      headerColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active sorts
          if (sorts.isNotEmpty) ...[
            const Text(
              'Active Sorts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...sorts.map((sort) => _buildSortItem(sort)),
            const SizedBox(height: 20),
          ],
          // Add new sort
          _buildAddSortSection(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(sorts),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSortItem(DataGridSort sort) {
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
        title: Text(
          sort.field,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Priority: ${sort.priority + 1}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DataGridSortIndicator(sortOrder: sort.order),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeSort(sort.field),
              iconSize: 20,
            ),
          ],
        ),
        onTap: () => _cycleSort(sort.field),
      ),
    );
  }

  Widget _buildAddSortSection() {
    final availableFields = widget.availableFields
        .where((field) => !sorts.any((sort) => sort.field == field))
        .toList();

    if (availableFields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'All fields are already sorted',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Sort',
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
          child: DropdownButton<String>(
            value: null,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Select Field'),
            ),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: availableFields.map((field) {
              return DropdownMenuItem(value: field, child: Text(field));
            }).toList(),
            onChanged: (field) {
              if (field != null) {
                _addSort(field);
              }
            },
          ),
        ),
      ],
    );
  }

  void _addSort(String field) {
    setState(() {
      sorts.add(DataGridSort(
        field: field,
        order: SortOrder.ascending,
        priority: sorts.length,
      ));
    });
  }

  void _removeSort(String field) {
    setState(() {
      sorts.removeWhere((sort) => sort.field == field);
      // Reorder priorities
      for (int i = 0; i < sorts.length; i++) {
        sorts[i] = sorts[i].copyWith(priority: i);
      }
    });
  }

  void _cycleSort(String field) {
    setState(() {
      final index = sorts.indexWhere((sort) => sort.field == field);
      if (index >= 0) {
        sorts[index] = sorts[index].cycle();
      }
    });
  }
}

/// Drag and drop sort priority widget
class DataGridSortPriorityList extends StatefulWidget {
  final List<DataGridSort> sorts;
  final ValueChanged<List<DataGridSort>>? onSortsChanged;

  const DataGridSortPriorityList({
    super.key,
    required this.sorts,
    this.onSortsChanged,
  });

  @override
  State<DataGridSortPriorityList> createState() => _DataGridSortPriorityListState();
}

class _DataGridSortPriorityListState extends State<DataGridSortPriorityList> {
  late List<DataGridSort> sorts;

  @override
  void initState() {
    super.initState();
    sorts = List.from(widget.sorts);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: sorts.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final sort = sorts[index];
        return Card(
          key: ValueKey(sort.field),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(sort.field),
            subtitle: Text('Priority: ${sort.priority + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DataGridSortIndicator(sortOrder: sort.order),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeSort(sort.field),
                ),
              ],
            ),
            onTap: () => _cycleSort(sort.field),
          ),
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = sorts.removeAt(oldIndex);
      sorts.insert(newIndex, item);
      
      // Update priorities
      for (int i = 0; i < sorts.length; i++) {
        sorts[i] = sorts[i].copyWith(priority: i);
      }
    });
    
    widget.onSortsChanged?.call(sorts);
  }

  void _removeSort(String field) {
    setState(() {
      sorts.removeWhere((sort) => sort.field == field);
      // Reorder priorities
      for (int i = 0; i < sorts.length; i++) {
        sorts[i] = sorts[i].copyWith(priority: i);
      }
    });
    
    widget.onSortsChanged?.call(sorts);
  }

  void _cycleSort(String field) {
    setState(() {
      final index = sorts.indexWhere((sort) => sort.field == field);
      if (index >= 0) {
        sorts[index] = sorts[index].cycle();
      }
    });
    
    widget.onSortsChanged?.call(sorts);
  }
} 