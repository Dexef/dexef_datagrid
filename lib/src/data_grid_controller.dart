import 'package:flutter/material.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_filters.dart';
import '../model/data_grid_sorting.dart';
import '../model/data_grid_selection.dart';
import '../model/data_grid_pagination.dart';

/// Controller for managing the data grid state and interactions
class DataGridController extends ChangeNotifier {
  DataGridSource? _source;
  List<int> _selectedRows = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;
  Map<String, double> _columnWidths = {};
  Map<String, bool> _columnVisibility = {};
  DataGridFilterState _filterState = const DataGridFilterState();
  DataGridSortState _sortState = const DataGridSortState();
  DataGridSelectionState _selectionState = const DataGridSelectionState();
  DataGridEditState _editState = const DataGridEditState();
  DataGridPaginationState _paginationState = const DataGridPaginationState();
  PaginationMode _paginationMode = PaginationMode.none;
  VirtualScrollMode _virtualScrollMode = VirtualScrollMode.none;
  VirtualScrollConfig _virtualConfig = const VirtualScrollConfig();
  Function(DataGridServerRequest)? _serverDataCallback;
  DataGridPaginationCache? _paginationCache;
  String? _lastRequestId;
  bool _isLoadingServerData = false;
  String _globalSearch = '';

  /// The current data source
  DataGridSource? get source => _source;

  /// Currently selected row indices
  List<int> get selectedRows => List.unmodifiable(_selectedRows);

  /// The index of the currently sorted column
  int? get sortColumnIndex => _sortColumnIndex;

  /// Whether the current sort is ascending
  bool get sortAscending => _sortAscending;

  /// Column widths
  Map<String, double> get columnWidths => Map.unmodifiable(_columnWidths);

  /// Column visibility
  Map<String, bool> get columnVisibility => Map.unmodifiable(_columnVisibility);

  /// Current filter state
  DataGridFilterState get filterState => _filterState;

  /// Current sort state
  DataGridSortState get sortState => _sortState;

  /// Current selection state
  DataGridSelectionState get selectionState => _selectionState;

  /// Current edit state
  DataGridEditState get editState => _editState;

  /// Current pagination state
  DataGridPaginationState get paginationState => _paginationState;

  /// Current pagination mode
  PaginationMode get paginationMode => _paginationMode;

  /// Current virtual scroll mode
  VirtualScrollMode get virtualScrollMode => _virtualScrollMode;

  /// Virtual scroll configuration
  VirtualScrollConfig get virtualConfig => _virtualConfig;

  /// Enable pagination caching
  void enablePaginationCache({Duration? cacheExpiry, int? maxCacheSize}) {
    _paginationCache = DataGridPaginationCache(
      cacheExpiry: cacheExpiry,
      maxCacheSize: maxCacheSize,
    );
  }

  /// Disable pagination caching
  void disablePaginationCache() {
    _paginationCache = null;
  }

  /// Clear pagination cache
  void clearPaginationCache() {
    _paginationCache?.clear();
  }

  /// Sets the data source
  void setSource(DataGridSource source) {
    _source = source;
    _initializeColumnSettings();
    
    // Initialize pagination state if in client mode
    if (_paginationMode == PaginationMode.client && source.hasData) {
      // Use total source data count for pagination calculation
      final totalRecords = source.rowCount;
      
      // Set initial page size to 25 if data length is greater than 20
      int initialPageSize = 20; // Default page size
      if (totalRecords > 20) {
        initialPageSize = 25;
      }
      
      final totalPages = (totalRecords / initialPageSize).ceil();
      final safeTotalPages = totalPages < 1 ? 1 : totalPages;
      
      // Force recalculation of pagination state
      _paginationState = DataGridPaginationState(
        currentPage: 1,
        pageSize: initialPageSize,
        totalPages: safeTotalPages,
        totalRecords: totalRecords,
        isLoading: false,
      );
    }
    
    notifyListeners();
  }

  /// Initializes column settings
  void _initializeColumnSettings() {
    if (_source == null || _source!.data.isEmpty) return;

    // Initialize column widths and visibility based on data fields
    for (final field in _source!.data.first.keys) {
      if (!_columnWidths.containsKey(field)) {
        _columnWidths[field] = 150.0; // Default width
      }
      if (!_columnVisibility.containsKey(field)) {
        _columnVisibility[field] = true; // Default visible
      }
    }
  }

  /// Toggles row selection
  void toggleRowSelection(int rowIndex) {
    // Get the original data index from the display index
    final originalIndex = _getOriginalDataIndex(rowIndex);
    
    if (_selectionState.selectedRows.contains(originalIndex)) {
      deselectRow(originalIndex);
    } else {
      selectRow(originalIndex);
    }
  }

  // Selection methods
  void selectRow(int rowIndex) {
    if (_source == null || rowIndex < 0 || rowIndex >= _source!.rowCount) return;
    
    final newSelectedRows = Set<int>.from(_selectionState.selectedRows);
    newSelectedRows.add(rowIndex);
    
    _selectionState = _selectionState.copyWith(selectedRows: newSelectedRows);
    notifyListeners();
  }

  void deselectRow(int rowIndex) {
    final newSelectedRows = Set<int>.from(_selectionState.selectedRows);
    newSelectedRows.remove(rowIndex);
    
    _selectionState = _selectionState.copyWith(selectedRows: newSelectedRows);
    notifyListeners();
  }

  void clearSelection() {
    _selectionState = _selectionState.clear();
    notifyListeners();
  }

  void selectAll() {
    if (_source == null) return;
    
    final allRows = Set<int>.from(Iterable.generate(_source!.rowCount, (index) => index));
    _selectionState = _selectionState.copyWith(
      selectedRows: allRows,
      isSelectAll: true,
    );
    notifyListeners();
  }

  void selectRange(int startIndex, int endIndex) {
    if (_source == null) return;
    
    final start = startIndex < endIndex ? startIndex : endIndex;
    final end = startIndex < endIndex ? endIndex : startIndex;
    
    final newSelectedRows = Set<int>.from(_selectionState.selectedRows);
    for (int i = start; i <= end; i++) {
      if (i >= 0 && i < _source!.rowCount) {
        newSelectedRows.add(i);
      }
    }
    
    _selectionState = _selectionState.copyWith(selectedRows: newSelectedRows);
    notifyListeners();
  }



  // Editing methods
  void startCellEdit(int rowIndex, String field) {
    if (_source == null || rowIndex < 0 || rowIndex >= _source!.rowCount) return;
    
    final rowData = _source!.getRow(rowIndex);
    if (rowData == null) return;
    
    _editState = _editState.copyWith(
      mode: EditMode.cell,
      editingRow: Map<String, dynamic>.from(rowData),
      editingRowIndex: rowIndex,
      originalRow: Map<String, dynamic>.from(rowData),
    );
    notifyListeners();
  }

  void startRowEdit(int rowIndex) {
    if (_source == null || rowIndex < 0 || rowIndex >= _source!.rowCount) return;
    
    final rowData = _source!.getRow(rowIndex);
    if (rowData == null) return;
    
    _editState = _editState.copyWith(
      mode: EditMode.row,
      editingRow: Map<String, dynamic>.from(rowData),
      editingRowIndex: rowIndex,
      originalRow: Map<String, dynamic>.from(rowData),
    );
    notifyListeners();
  }

  void updateEditField(String field, dynamic value) {
    if (_editState.mode == EditMode.none) return;
    
    _editState = _editState.updateField(field, value);
    notifyListeners();
  }

  void saveEdit() {
    if (_editState.mode == EditMode.none || _source == null) return;
    
    // Validate the edit - create a simple config map
    final columnConfigs = <String, Map<String, dynamic>>{};
    // TODO: Get columns from widget and create config map
    _editState = _editState.validate(columnConfigs);
    
    if (!_editState.isValid) {
      notifyListeners();
      return;
    }
    
    // Update the data source
    if (_editState.editingRow != null && _editState.editingRowIndex != null) {
      final updatedData = List<Map<String, dynamic>>.from(_source!.data);
      updatedData[_editState.editingRowIndex!] = Map<String, dynamic>.from(_editState.editingRow!);
      
      _source = DataGridSource(
        data: updatedData,
        totalCount: updatedData.length,
        isLoading: _source!.isLoading,
        error: _source!.error,
      );
    }
    
    _editState = _editState.clear();
    notifyListeners();
  }

  void cancelEdit() {
    _editState = _editState.clear();
    notifyListeners();
  }

  bool isEditing() {
    return _editState.isEditing;
  }

  bool isEditingRow(int rowIndex) {
    return _editState.mode != EditMode.none && _editState.editingRowIndex == rowIndex;
  }

  bool isEditingCell(int rowIndex, String field) {
    return _editState.mode == EditMode.cell && 
           _editState.editingRowIndex == rowIndex;
  }

  // Pagination methods
  void setPaginationMode(PaginationMode mode) {
    _paginationMode = mode;
    if (mode == PaginationMode.none) {
      _paginationState = const DataGridPaginationState();
    } else if (mode == PaginationMode.client && _source != null && _source!.hasData) {
      // Initialize pagination state for client mode
      final totalRecords = _source!.rowCount;
      
      // Set initial page size to 25 if data length is greater than 20
      int initialPageSize = 20; // Default page size
      if (totalRecords > 20) {
        initialPageSize = 25;
      }
      
      final totalPages = (totalRecords / initialPageSize).ceil();
      final safeTotalPages = totalPages < 1 ? 1 : totalPages;
      
      _paginationState = DataGridPaginationState(
        currentPage: 1,
        pageSize: initialPageSize,
        totalPages: safeTotalPages,
        totalRecords: totalRecords,
        isLoading: false,
      );
    }
    notifyListeners();
  }

  void setVirtualScrollMode(VirtualScrollMode mode, {VirtualScrollConfig? config}) {
    _virtualScrollMode = mode;
    if (config != null) {
      _virtualConfig = config;
    }
    notifyListeners();
  }

  void setServerDataCallback(Function(DataGridServerRequest) callback) {
    _serverDataCallback = callback;
  }

  void setPageSize(int pageSize) {
    // Ensure pageSize is valid
    if (pageSize <= 0) return;
    
    if (_paginationMode == PaginationMode.client) {
      // Use total source data count for pagination calculation
      final totalRecords = _source?.rowCount ?? 0;
      final totalPages = (totalRecords / pageSize).ceil();
      final safeTotalPages = totalPages < 1 ? 1 : totalPages;
      
      // Ensure current page is within valid range
      final newCurrentPage = _paginationState.currentPage.clamp(1, safeTotalPages);
      
      _paginationState = _paginationState.copyWith(
        pageSize: pageSize,
        totalRecords: totalRecords,
        totalPages: safeTotalPages,
        currentPage: newCurrentPage,
      );
    } else if (_paginationMode == PaginationMode.server) {
      _paginationState = _paginationState.copyWith(pageSize: pageSize);
      _loadServerData();
    }
    notifyListeners();
  }

  void goToPage(int page) {
    if (_paginationMode == PaginationMode.client) {
      _paginationState = _paginationState.goToPage(page);
    } else if (_paginationMode == PaginationMode.server) {
      _paginationState = _paginationState.copyWith(currentPage: page);
      _loadServerData();
    }
    notifyListeners();
  }

  void nextPage() {
    if (_paginationState.hasNextPage) {
      goToPage(_paginationState.currentPage + 1);
    }
  }

  void previousPage() {
    if (_paginationState.hasPreviousPage) {
      goToPage(_paginationState.currentPage - 1);
    }
  }

  void _loadServerData() {
    if (_serverDataCallback == null) return;

    // Prevent duplicate requests
    if (_isLoadingServerData) return;

    final request = DataGridServerRequest(
      page: _paginationState.currentPage,
      pageSize: _paginationState.pageSize,
      sorts: _sortState.sorts.map((s) => {
        'field': s.field,
        'order': s.order.index,
        'priority': s.priority,
      }).toList(),
      filterState: {
        'columnFilters': _filterState.columnFilters.map((key, value) => MapEntry(key, value.map((f) => {
          'field': f.field,
          'type': f.type.index,
          'value': f.value,
        }).toList())),
      },
      requestId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Check cache first
    if (_paginationCache != null && !request.forceRefresh) {
      final cached = _paginationCache!.getCached(request.cacheKey);
      if (cached != null) {
        updateServerData(cached);
        return;
      }
    }

    _isLoadingServerData = true;
    _paginationState = _paginationState.copyWith(isLoading: true);
    notifyListeners();

    try {
      _lastRequestId = request.requestId;
      _serverDataCallback!(request);
    } catch (e) {
      _isLoadingServerData = false;
      _paginationState = _paginationState.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  void updateServerData(DataGridServerResponse response) {
    // Check if this response is for the current request
    if (response.requestId != null && response.requestId != _lastRequestId) {
      return; // Ignore outdated responses
    }

    _isLoadingServerData = false;

    if (response.error != null) {
      _paginationState = _paginationState.copyWith(
        isLoading: false,
        error: response.error,
      );
    } else {
      _source = DataGridSource(
        data: response.data,
        totalCount: response.totalRecords,
        isLoading: false,
      );
      
      _paginationState = _paginationState.copyWith(
        isLoading: false,
        totalRecords: response.totalRecords,
        totalPages: response.totalPages,
        error: null,
      );

      // Cache the response if caching is enabled
      if (_paginationCache != null && !response.fromCache) {
        final request = DataGridServerRequest(
          page: _paginationState.currentPage,
          pageSize: _paginationState.pageSize,
          sorts: _sortState.sorts.map((s) => {
            'field': s.field,
            'order': s.order.index,
            'priority': s.priority,
          }).toList(),
          filterState: {
            'columnFilters': _filterState.columnFilters.map((key, value) => MapEntry(key, value.map((f) => {
              'field': f.field,
              'type': f.type.index,
              'value': f.value,
            }).toList())),
          },
        );
        _paginationCache!.cache(request.cacheKey, response);
      }
    }
    notifyListeners();
  }

  void setGlobalSearch(String search) {
    _globalSearch = search.trim().toLowerCase();
    
    // Recalculate pagination for client mode when search changes
    if (_paginationMode == PaginationMode.client && _source != null) {
      // Use total source data count for pagination calculation
      final totalRecords = _source!.rowCount;
      final totalPages = (totalRecords / _paginationState.pageSize).ceil();
      final safeTotalPages = totalPages < 1 ? 1 : totalPages;
      
      _paginationState = _paginationState.copyWith(
        totalRecords: totalRecords,
        totalPages: safeTotalPages,
        currentPage: _paginationState.currentPage.clamp(1, safeTotalPages),
      );
    }
    
    notifyListeners();
  }

  // Get filtered data without pagination
  List<Map<String, dynamic>> _getFilteredData() {
    if (_source == null) return [];
    
    // Apply filters
    var filteredData = _source!.data.where((row) => _filterState.apply(row)).toList();
    
    // Apply global search
    if (_globalSearch.isNotEmpty) {
      filteredData = filteredData.where((row) {
        return row.values.any((value) => value != null && value.toString().toLowerCase().contains(_globalSearch));
      }).toList();
    }
    
    // Apply sorting
    filteredData = _sortState.sortData(filteredData);
    
    return filteredData;
  }

  // Get display data with pagination support
  List<Map<String, dynamic>> getDisplayData() {
    if (_source == null) return [];
    
    final visibleFields = _source!.data.first.keys.where((field) => _columnVisibility[field] ?? true).toList();
    
    // Get filtered data
    final filteredData = _getFilteredData();
    
    // Filter to visible fields
    final displayData = filteredData.map((row) {
      final filteredRow = <String, dynamic>{};
      for (final field in visibleFields) {
        filteredRow[field] = row[field];
      }
      return filteredRow;
    }).toList();
    
    // Apply client-side pagination
    if (_paginationMode == PaginationMode.client && displayData.isNotEmpty) {
      final startIndex = _paginationState.startIndex;
      final endIndex = _paginationState.endIndex;
      
      if (startIndex < displayData.length) {
        return displayData.sublist(startIndex, (endIndex + 1).clamp(0, displayData.length));
      }
    }
    
    return displayData;
  }

  // Get total row count considering pagination
  int get totalRowCount {
    if (_paginationMode == PaginationMode.server) {
      return _paginationState.totalRecords;
    }
    return _source?.totalCount ?? 0;
  }

  // Get filtered row count considering pagination
  int get filteredRowCount {
    if (_paginationMode == PaginationMode.server) {
      return _paginationState.totalRecords;
    }
    return getDisplayData().length;
  }

  /// Sorts the data by a specific column
  void sortByColumn(int columnIndex) {
    if (_source == null || columnIndex < 0 || columnIndex >= _source!.data.first.keys.length) return;

    final field = _source!.data.first.keys.elementAt(columnIndex);
    
    if (_sortColumnIndex == columnIndex) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumnIndex = columnIndex;
      _sortAscending = true;
    }

    // Sort the data
    _source!.data.sort((a, b) {
      final aValue = a[field];
      final bValue = b[field];
      
      int comparison = 0;
      if (aValue == null && bValue == null) {
        comparison = 0;
      } else if (aValue == null) {
        comparison = -1;
      } else if (bValue == null) {
        comparison = 1;
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    notifyListeners();
  }

  /// Adds or updates a sort
  void addSort(DataGridSort sort) {
    _sortState = _sortState.addSort(sort);
    notifyListeners();
  }

  /// Removes a sort by field
  void removeSort(String field) {
    _sortState = _sortState.removeSort(field);
    notifyListeners();
  }

  /// Clears all sorts
  void clearSorts() {
    _sortState = _sortState.clearSorts();
    notifyListeners();
  }

  /// Adds a group
  void addGroup(DataGridGroup group) {
    _sortState = _sortState.addGroup(group);
    notifyListeners();
  }

  /// Removes a group by field
  void removeGroup(String field) {
    _sortState = _sortState.removeGroup(field);
    notifyListeners();
  }

  /// Updates a group
  void updateGroup(DataGridGroup group) {
    _sortState = _sortState.updateGroup(group);
    notifyListeners();
  }

  /// Clears all groups
  void clearGroups() {
    _sortState = _sortState.clearGroups();
    notifyListeners();
  }

  /// Sets the width of a column
  void setColumnWidth(String field, double width) {
    _columnWidths[field] = width;
    notifyListeners();
  }

  /// Sets the visibility of a column
  void setColumnVisibility(String field, bool visible) {
    _columnVisibility[field] = visible;
    notifyListeners();
  }



  /// Gets the grouped data
  List<dynamic> getGroupedData() {
    if (_source == null) return [];
    
    final visibleFields = _source!.data.first.keys.where((field) => _columnVisibility[field] ?? true).toList();
    
    // Apply filters
    var filteredData = _source!.data.where((row) => _filterState.apply(row)).toList();
    
    // Apply sorting
    filteredData = _sortState.sortData(filteredData);
    
    // Apply grouping
    final groupedData = _sortState.groupData(filteredData);
    
    return groupedData;
  }

  /// Gets the visible fields
  List<String> getVisibleFields() {
    if (_source == null) return [];
    return _source!.data.first.keys.where((field) => _columnVisibility[field] ?? true).toList();
  }

  /// Checks if a row is selected
  bool isRowSelected(int rowIndex) {
    // Get the original data index from the display index
    final originalIndex = _getOriginalDataIndex(rowIndex);
    return _selectionState.selectedRows.contains(originalIndex);
  }

  /// Gets the original data index from display index
  int _getOriginalDataIndex(int displayIndex) {
    if (_source == null) return displayIndex;
    
    // Get the filtered and sorted data (without pagination)
    final visibleFields = _source!.data.first.keys.where((field) => _columnVisibility[field] ?? true).toList();
    
    // Apply filters
    var filteredData = _source!.data.where((row) => _filterState.apply(row)).toList();
    
    // Apply global search
    if (_globalSearch.isNotEmpty) {
      filteredData = filteredData.where((row) {
        return row.values.any((value) => value != null && value.toString().toLowerCase().contains(_globalSearch));
      }).toList();
    }
    
    // Apply sorting
    filteredData = _sortState.sortData(filteredData);
    
    // Find the original index
    if (displayIndex >= 0 && displayIndex < filteredData.length) {
      final displayRow = filteredData[displayIndex];
      return _source!.data.indexOf(displayRow);
    }
    
    return displayIndex;
  }

  /// Gets the selected row data
  List<Map<String, dynamic>> getSelectedRowData() {
    if (_source == null) return [];
    return _selectedRows.map((index) => _source!.data[index]).toList();
  }

  /// Updates the filter state
  void updateFilterState(DataGridFilterState filterState) {
    _filterState = filterState;
    notifyListeners();
  }

  /// Adds a column filter
  void addColumnFilter(String field, DataGridFilter filter) {
    _filterState = _filterState.addColumnFilter(field, filter);
    notifyListeners();
  }

  /// Removes a column filter
  void removeColumnFilter(String field, DataGridFilter filter) {
    _filterState = _filterState.removeColumnFilter(field, filter);
    notifyListeners();
  }

  /// Clears all filters
  void clearFilters() {
    _filterState = _filterState.clear();
    notifyListeners();
  }


} 