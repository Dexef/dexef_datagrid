// No imports needed for this file

/// Filter types for different data types
enum FilterType {
  // Text filters
  contains,
  startsWith,
  endsWith,
  equals,
  notEquals,
  
  // Number filters
  greaterThan,
  lessThan,
  between,
  
  // Date filters
  dateRange,
  before,
  after,
  
  // Boolean filters
  isTrue,
  isFalse,
  
  // Custom filters
  inList,
  notInList,
}

/// Filter condition for combining multiple filters
enum FilterCondition { and, or }

/// Represents a single filter
class DataGridFilter {
  final String field;
  final FilterType type;
  final dynamic value;
  final dynamic secondValue; // For between filters
  final List<dynamic>? values; // For inList filters

  const DataGridFilter({
    required this.field,
    required this.type,
    required this.value,
    this.secondValue,
    this.values,
  });

  /// Creates a text filter
  factory DataGridFilter.text({
    required String field,
    required FilterType type,
    required String value,
  }) {
    return DataGridFilter(
      field: field,
      type: type,
      value: value,
    );
  }

  /// Creates a number filter
  factory DataGridFilter.number({
    required String field,
    required FilterType type,
    required num value,
    num? secondValue,
  }) {
    return DataGridFilter(
      field: field,
      type: type,
      value: value,
      secondValue: secondValue,
    );
  }

  /// Creates a date filter
  factory DataGridFilter.date({
    required String field,
    required FilterType type,
    required DateTime value,
    DateTime? secondValue,
  }) {
    return DataGridFilter(
      field: field,
      type: type,
      value: value,
      secondValue: secondValue,
    );
  }

  /// Creates a boolean filter
  factory DataGridFilter.boolean({
    required String field,
    required bool value,
  }) {
    return DataGridFilter(
      field: field,
      type: value ? FilterType.isTrue : FilterType.isFalse,
      value: value,
    );
  }

  /// Creates a list filter
  factory DataGridFilter.list({
    required String field,
    required FilterType type,
    required List<dynamic> values,
  }) {
    return DataGridFilter(
      field: field,
      type: type,
      value: null,
      values: values,
    );
  }

  /// Applies the filter to a data row
  bool apply(Map<String, dynamic> row) {
    final fieldValue = row[field];
    
    switch (type) {
      // Text filters
      case FilterType.contains:
        return fieldValue?.toString().toLowerCase().contains(value.toString().toLowerCase()) ?? false;
      case FilterType.startsWith:
        return fieldValue?.toString().toLowerCase().startsWith(value.toString().toLowerCase()) ?? false;
      case FilterType.endsWith:
        return fieldValue?.toString().toLowerCase().endsWith(value.toString().toLowerCase()) ?? false;
      case FilterType.equals:
        return fieldValue?.toString().toLowerCase() == value.toString().toLowerCase();
      case FilterType.notEquals:
        return fieldValue?.toString().toLowerCase() != value.toString().toLowerCase();
      
      // Number filters
      case FilterType.greaterThan:
        final numValue = _parseNumber(fieldValue);
        final filterValue = _parseNumber(value);
        return numValue != null && filterValue != null && numValue > filterValue;
      case FilterType.lessThan:
        final numValue = _parseNumber(fieldValue);
        final filterValue = _parseNumber(value);
        return numValue != null && filterValue != null && numValue < filterValue;
      case FilterType.between:
        final numValue = _parseNumber(fieldValue);
        final minValue = _parseNumber(value);
        final maxValue = _parseNumber(secondValue);
        return numValue != null && minValue != null && maxValue != null && 
               numValue >= minValue && numValue <= maxValue;
      
      // Date filters
      case FilterType.dateRange:
        final dateValue = _parseDate(fieldValue);
        final startDate = _parseDate(value);
        final endDate = _parseDate(secondValue);
        return dateValue != null && startDate != null && endDate != null && 
               dateValue.isAfter(startDate.subtract(const Duration(days: 1))) && 
               dateValue.isBefore(endDate.add(const Duration(days: 1)));
      case FilterType.before:
        final dateValue = _parseDate(fieldValue);
        final filterDate = _parseDate(value);
        return dateValue != null && filterDate != null && dateValue.isBefore(filterDate);
      case FilterType.after:
        final dateValue = _parseDate(fieldValue);
        final filterDate = _parseDate(value);
        return dateValue != null && filterDate != null && dateValue.isAfter(filterDate);
      
      // Boolean filters
      case FilterType.isTrue:
        return fieldValue == true;
      case FilterType.isFalse:
        return fieldValue == false;
      
      // List filters
      case FilterType.inList:
        return values?.contains(fieldValue) ?? false;
      case FilterType.notInList:
        return !(values?.contains(fieldValue) ?? false);
    }
  }

  num? _parseNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Represents a group of filters with AND/OR conditions
class DataGridFilterGroup {
  final List<DataGridFilter> filters;
  final List<DataGridFilterGroup> groups;
  final FilterCondition condition;

  const DataGridFilterGroup({
    this.filters = const [],
    this.groups = const [],
    this.condition = FilterCondition.and,
  });

  /// Applies the filter group to a data row
  bool apply(Map<String, dynamic> row) {
    if (filters.isEmpty && groups.isEmpty) return true;

    final filterResults = filters.map((filter) => filter.apply(row)).toList();
    final groupResults = groups.map((group) => group.apply(row)).toList();

    final allResults = [...filterResults, ...groupResults];
    if (allResults.isEmpty) return true;

    return condition == FilterCondition.and 
        ? allResults.every((result) => result)
        : allResults.any((result) => result);
  }
}

/// Global search filter
class DataGridSearchFilter {
  final String searchText;
  final List<String> searchFields;
  final bool caseSensitive;

  const DataGridSearchFilter({
    required this.searchText,
    this.searchFields = const [],
    this.caseSensitive = false,
  });

  /// Applies the search filter to a data row
  bool apply(Map<String, dynamic> row) {
    if (searchText.isEmpty) return true;

    final searchLower = caseSensitive ? searchText : searchText.toLowerCase();
    
    if (searchFields.isEmpty) {
      // Search all fields
      return row.values.any((value) {
        final valueStr = value?.toString() ?? '';
        final valueLower = caseSensitive ? valueStr : valueStr.toLowerCase();
        return valueLower.contains(searchLower);
      });
    } else {
      // Search specific fields
      return searchFields.any((field) {
        final value = row[field];
        final valueStr = value?.toString() ?? '';
        final valueLower = caseSensitive ? valueStr : valueStr.toLowerCase();
        return valueLower.contains(searchLower);
      });
    }
  }
}

/// Filter state management
class DataGridFilterState {
  final DataGridFilterGroup? filterGroup;
  final DataGridSearchFilter? searchFilter;
  final Map<String, List<DataGridFilter>> columnFilters;

  const DataGridFilterState({
    this.filterGroup,
    this.searchFilter,
    this.columnFilters = const {},
  });

  /// Applies all filters to a data row
  bool apply(Map<String, dynamic> row) {
    // Apply column filters
    for (final entry in columnFilters.entries) {
      final field = entry.key;
      final filters = entry.value;
      
      if (filters.isNotEmpty) {
        final fieldValue = row[field];
        final matchesAny = filters.any((filter) => filter.apply(row));
        if (!matchesAny) return false;
      }
    }

    // Apply filter group
    if (filterGroup != null && !filterGroup!.apply(row)) {
      return false;
    }

    // Apply search filter
    if (searchFilter != null && !searchFilter!.apply(row)) {
      return false;
    }

    return true;
  }

  /// Creates a copy with updated filters
  DataGridFilterState copyWith({
    DataGridFilterGroup? filterGroup,
    DataGridSearchFilter? searchFilter,
    Map<String, List<DataGridFilter>>? columnFilters,
  }) {
    return DataGridFilterState(
      filterGroup: filterGroup ?? this.filterGroup,
      searchFilter: searchFilter ?? this.searchFilter,
      columnFilters: columnFilters ?? this.columnFilters,
    );
  }

  /// Adds a column filter
  DataGridFilterState addColumnFilter(String field, DataGridFilter filter) {
    final currentFilters = List<DataGridFilter>.from(columnFilters[field] ?? []);
    currentFilters.add(filter);
    
    final newColumnFilters = Map<String, List<DataGridFilter>>.from(columnFilters);
    newColumnFilters[field] = currentFilters;
    
    return copyWith(columnFilters: newColumnFilters);
  }

  /// Removes a column filter
  DataGridFilterState removeColumnFilter(String field, DataGridFilter filter) {
    final currentFilters = List<DataGridFilter>.from(columnFilters[field] ?? []);
    currentFilters.remove(filter);
    
    final newColumnFilters = Map<String, List<DataGridFilter>>.from(columnFilters);
    if (currentFilters.isEmpty) {
      newColumnFilters.remove(field);
    } else {
      newColumnFilters[field] = currentFilters;
    }
    
    return copyWith(columnFilters: newColumnFilters);
  }

  /// Clears all filters
  DataGridFilterState clear() {
    return const DataGridFilterState();
  }
} 