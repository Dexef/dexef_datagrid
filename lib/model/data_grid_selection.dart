/// Selection modes for the data grid
enum SelectionMode {
  none,
  single,
  multiple,
}

/// Edit modes for the data grid
enum EditMode {
  none,
  cell,
  row,
  batch,
  form,
}

/// Represents the selection state of the data grid
class DataGridSelectionState {
  final Set<int> selectedRows;
  final int? focusedRow;
  final int? focusedColumn;
  final bool isSelectAll;

  const DataGridSelectionState({
    this.selectedRows = const {},
    this.focusedRow,
    this.focusedColumn,
    this.isSelectAll = false,
  });

  /// Creates an empty selection state
  factory DataGridSelectionState.empty() {
    return const DataGridSelectionState();
  }

  /// Creates a copy with updated values
  DataGridSelectionState copyWith({
    Set<int>? selectedRows,
    int? focusedRow,
    int? focusedColumn,
    bool? isSelectAll,
  }) {
    return DataGridSelectionState(
      selectedRows: selectedRows ?? this.selectedRows,
      focusedRow: focusedRow ?? this.focusedRow,
      focusedColumn: focusedColumn ?? this.focusedColumn,
      isSelectAll: isSelectAll ?? this.isSelectAll,
    );
  }

  /// Clears all selection
  DataGridSelectionState clear() {
    return const DataGridSelectionState();
  }

  /// Checks if a row is selected
  bool isRowSelected(int rowIndex) {
    return selectedRows.contains(rowIndex);
  }

  /// Gets the number of selected rows
  int get selectedCount => selectedRows.length;

  /// Checks if any row is selected
  bool get hasSelection => selectedRows.isNotEmpty;

  /// Gets the first selected row index
  int? get firstSelectedRow => selectedRows.isNotEmpty ? selectedRows.first : null;

  /// Gets all selected row indices as a list
  List<int> get selectedRowList => selectedRows.toList()..sort();
}

/// Represents the editing state of the data grid
class DataGridEditState {
  final EditMode mode;
  final Map<String, dynamic>? editingRow;
  final int? editingRowIndex;
  final Map<String, dynamic>? originalRow;
  final Map<String, String> validationErrors;
  final bool isDirty;

  const DataGridEditState({
    this.mode = EditMode.none,
    this.editingRow,
    this.editingRowIndex,
    this.originalRow,
    this.validationErrors = const {},
    this.isDirty = false,
  });

  /// Creates an empty edit state
  factory DataGridEditState.empty() {
    return const DataGridEditState();
  }

  /// Creates a copy with updated values
  DataGridEditState copyWith({
    EditMode? mode,
    Map<String, dynamic>? editingRow,
    int? editingRowIndex,
    Map<String, dynamic>? originalRow,
    Map<String, String>? validationErrors,
    bool? isDirty,
  }) {
    return DataGridEditState(
      mode: mode ?? this.mode,
      editingRow: editingRow ?? this.editingRow,
      editingRowIndex: editingRowIndex ?? this.editingRowIndex,
      originalRow: originalRow ?? this.originalRow,
      validationErrors: validationErrors ?? this.validationErrors,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  /// Clears the edit state
  DataGridEditState clear() {
    return const DataGridEditState();
  }

  /// Checks if currently editing
  bool get isEditing => mode != EditMode.none;

  /// Checks if a specific field has validation errors
  bool hasError(String field) {
    return validationErrors.containsKey(field);
  }

  /// Gets the error message for a field
  String? getError(String field) {
    return validationErrors[field];
  }

  /// Updates a field value in the editing row
  DataGridEditState updateField(String field, dynamic value) {
    final updatedRow = Map<String, dynamic>.from(editingRow ?? {});
    updatedRow[field] = value;
    
    return copyWith(
      editingRow: updatedRow,
      isDirty: true,
    );
  }

  /// Validates the current editing row
  DataGridEditState validate(Map<String, Map<String, dynamic>> columnConfigs) {
    final errors = <String, String>{};
    
    for (final entry in columnConfigs.entries) {
      final field = entry.key;
      final config = entry.value;
      
      final isRequired = config['required'] ?? false;
      final dataType = config['dataType'] ?? 'string';
      
      if (isRequired && (editingRow?[field] == null || editingRow![field].toString().isEmpty)) {
        errors[field] = 'This field is required';
      }
      
      // Add more validation rules as needed
      if (dataType == 'number') {
        final value = editingRow?[field];
        if (value != null && value.toString().isNotEmpty) {
          if (double.tryParse(value.toString()) == null) {
            errors[field] = 'Must be a valid number';
          }
        }
      }
      
      if (dataType == 'date') {
        final value = editingRow?[field];
        if (value != null && value.toString().isNotEmpty) {
          if (value is! DateTime && DateTime.tryParse(value.toString()) == null) {
            errors[field] = 'Must be a valid date';
          }
        }
      }
    }
    
    return copyWith(validationErrors: errors);
  }

  /// Checks if the current edit state is valid
  bool get isValid => validationErrors.isEmpty;
} 