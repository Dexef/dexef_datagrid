// No imports needed for this file

/// Sort order for columns
enum SortOrder { none, ascending, descending }

/// Group summary calculation types
enum GroupSummaryType { sum, count, average, min, max, custom }

/// Represents a sort configuration for a column
class DataGridSort {
  final String field;
  final SortOrder order;
  final int priority; // 0 = highest priority
  final Comparator<dynamic>? customComparator;

  const DataGridSort({
    required this.field,
    required this.order,
    required this.priority,
    this.customComparator,
  });

  /// Creates a copy with updated values
  DataGridSort copyWith({
    String? field,
    SortOrder? order,
    int? priority,
    Comparator<dynamic>? customComparator,
  }) {
    return DataGridSort(
      field: field ?? this.field,
      order: order ?? this.order,
      priority: priority ?? this.priority,
      customComparator: customComparator ?? this.customComparator,
    );
  }

  /// Cycles through sort states: none -> ascending -> descending -> none
  DataGridSort cycle() {
    switch (order) {
      case SortOrder.none:
        return copyWith(order: SortOrder.ascending);
      case SortOrder.ascending:
        return copyWith(order: SortOrder.descending);
      case SortOrder.descending:
        return copyWith(order: SortOrder.none);
    }
  }

  /// Compares two values based on the sort configuration
  int compare(dynamic a, dynamic b) {
    if (customComparator != null) {
      return customComparator!(a, b);
    }

    // Handle null values
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    // Handle different data types
    if (a.runtimeType != b.runtimeType) {
      return a.toString().compareTo(b.toString());
    }

    // Type-specific comparisons
    if (a is String) {
      return a.compareTo(b as String);
    } else if (a is num) {
      return a.compareTo(b as num);
    } else if (a is DateTime) {
      return a.compareTo(b as DateTime);
    } else if (a is bool) {
      return a == b ? 0 : (a ? 1 : -1);
    } else {
      return a.toString().compareTo(b.toString());
    }
  }

  /// Applies the sort order to the comparison result
  int applyOrder(int comparison) {
    return order == SortOrder.descending ? -comparison : comparison;
  }
}

/// Represents a group configuration
class DataGridGroup {
  final String field;
  final bool isExpanded;
  final GroupSummaryType summaryType;
  final String? summaryField; // For sum, average, min, max calculations
  final String Function(dynamic)? customSummaryFormatter;

  const DataGridGroup({
    required this.field,
    this.isExpanded = true,
    this.summaryType = GroupSummaryType.count,
    this.summaryField,
    this.customSummaryFormatter,
  });

  /// Creates a copy with updated values
  DataGridGroup copyWith({
    String? field,
    bool? isExpanded,
    GroupSummaryType? summaryType,
    String? summaryField,
    String Function(dynamic)? customSummaryFormatter,
  }) {
    return DataGridGroup(
      field: field ?? this.field,
      isExpanded: isExpanded ?? this.isExpanded,
      summaryType: summaryType ?? this.summaryType,
      summaryField: summaryField ?? this.summaryField,
      customSummaryFormatter: customSummaryFormatter ?? this.customSummaryFormatter,
    );
  }

  /// Toggles the expanded state
  DataGridGroup toggleExpanded() {
    return copyWith(isExpanded: !isExpanded);
  }

  /// Calculates summary for a group of rows
  String calculateSummary(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '0';

    switch (summaryType) {
      case GroupSummaryType.count:
        return rows.length.toString();
      
      case GroupSummaryType.sum:
        if (summaryField == null) return '0';
        final values = rows.map((row) => row[summaryField]).whereType<num>();
        final sum = values.fold<num>(0, (sum, value) => sum + value);
        return sum.toString();
      
      case GroupSummaryType.average:
        if (summaryField == null) return '0';
        final values = rows.map((row) => row[summaryField]).whereType<num>();
        if (values.isEmpty) return '0';
        final average = values.fold<num>(0, (sum, value) => sum + value) / values.length;
        return average.toStringAsFixed(2);
      
      case GroupSummaryType.min:
        if (summaryField == null) return '';
        final values = rows.map((row) => row[summaryField]).whereType<num>();
        if (values.isEmpty) return '';
        final min = values.reduce((a, b) => a < b ? a : b);
        return min.toString();
      
      case GroupSummaryType.max:
        if (summaryField == null) return '';
        final values = rows.map((row) => row[summaryField]).whereType<num>();
        if (values.isEmpty) return '';
        final max = values.reduce((a, b) => a > b ? a : b);
        return max.toString();
      
      case GroupSummaryType.custom:
        if (customSummaryFormatter != null) {
          return customSummaryFormatter!(rows);
        }
        return rows.length.toString();
    }
  }
}

/// Represents a grouped row
class DataGridGroupRow {
  final String groupKey;
  final dynamic groupValue;
  final List<Map<String, dynamic>> rows;
  final DataGridGroup group;
  final String summary;

  const DataGridGroupRow({
    required this.groupKey,
    required this.groupValue,
    required this.rows,
    required this.group,
    required this.summary,
  });

  /// Creates a group row from data
  factory DataGridGroupRow.fromData(
    String groupKey,
    dynamic groupValue,
    List<Map<String, dynamic>> rows,
    DataGridGroup group,
  ) {
    final summary = group.calculateSummary(rows);
    return DataGridGroupRow(
      groupKey: groupKey,
      groupValue: groupValue,
      rows: rows,
      group: group,
      summary: summary,
    );
  }
}

/// Sort and group state management
class DataGridSortState {
  final List<DataGridSort> sorts;
  final List<DataGridGroup> groups;

  const DataGridSortState({
    this.sorts = const [],
    this.groups = const [],
  });

  /// Creates a copy with updated values
  DataGridSortState copyWith({
    List<DataGridSort>? sorts,
    List<DataGridGroup>? groups,
  }) {
    return DataGridSortState(
      sorts: sorts ?? this.sorts,
      groups: groups ?? this.groups,
    );
  }

  /// Adds or updates a sort
  DataGridSortState addSort(DataGridSort sort) {
    final existingIndex = sorts.indexWhere((s) => s.field == sort.field);
    final newSorts = List<DataGridSort>.from(sorts);
    
    if (existingIndex >= 0) {
      newSorts[existingIndex] = sort;
    } else {
      newSorts.add(sort);
    }
    
    // Reorder priorities
    final activeSorts = newSorts.where((s) => s.order != SortOrder.none).toList();
    for (int i = 0; i < activeSorts.length; i++) {
      activeSorts[i] = activeSorts[i].copyWith(priority: i);
    }
    
    return copyWith(sorts: newSorts);
  }

  /// Removes a sort by field
  DataGridSortState removeSort(String field) {
    final newSorts = sorts.where((s) => s.field != field).toList();
    return copyWith(sorts: newSorts);
  }

  /// Clears all sorts
  DataGridSortState clearSorts() {
    return copyWith(sorts: []);
  }

  /// Adds a group
  DataGridSortState addGroup(DataGridGroup group) {
    final newGroups = List<DataGridGroup>.from(groups);
    if (!newGroups.any((g) => g.field == group.field)) {
      newGroups.add(group);
    }
    return copyWith(groups: newGroups);
  }

  /// Removes a group by field
  DataGridSortState removeGroup(String field) {
    final newGroups = groups.where((g) => g.field != field).toList();
    return copyWith(groups: newGroups);
  }

  /// Updates a group
  DataGridSortState updateGroup(DataGridGroup group) {
    final newGroups = groups.map((g) => g.field == group.field ? group : g).toList();
    return copyWith(groups: newGroups);
  }

  /// Clears all groups
  DataGridSortState clearGroups() {
    return copyWith(groups: []);
  }

  /// Sorts data according to current sort configuration
  List<Map<String, dynamic>> sortData(List<Map<String, dynamic>> data) {
    final activeSorts = sorts.where((s) => s.order != SortOrder.none).toList();
    if (activeSorts.isEmpty) return data;

    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      for (final sort in activeSorts) {
        final aValue = a[sort.field];
        final bValue = b[sort.field];
        final comparison = sort.compare(aValue, bValue);
        if (comparison != 0) {
          return sort.applyOrder(comparison);
        }
      }
      return 0;
    });

    return sortedData;
  }

  /// Groups data according to current group configuration
  List<dynamic> groupData(List<Map<String, dynamic>> data) {
    if (groups.isEmpty) return data;

    final groupedData = <dynamic>[];
    final groupedRows = <String, List<Map<String, dynamic>>>{};

    // Group the data
    for (final row in data) {
      final groupKey = _createGroupKey(row);
      groupedRows.putIfAbsent(groupKey, () => []).add(row);
    }

    // Create group rows and add individual rows
    for (final group in groups) {
      final groupKey = _createGroupKeyForField(group.field);
      final groupRows = groupedRows[groupKey] ?? [];
      
      if (groupRows.isNotEmpty) {
        final groupRow = DataGridGroupRow.fromData(
          groupKey,
          groupRows.first[group.field],
          groupRows,
          group,
        );
        groupedData.add(groupRow);
        
        if (group.isExpanded) {
          groupedData.addAll(groupRows);
        }
      }
    }

    return groupedData;
  }

  String _createGroupKey(Map<String, dynamic> row) {
    return groups.map((g) => row[g.field]?.toString() ?? '').join('|');
  }

  String _createGroupKeyForField(String field) {
    return field;
  }
} 