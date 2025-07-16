import 'package:flutter/material.dart';

/// Data types supported by the data grid
enum DataType { string, number, date, boolean, custom }

// Sort order is now defined in data_grid_sorting.dart

/// Represents a column in the data grid with enhanced configuration
class DataGridColumn {
  final String dataField;
  final String caption;
  final DataType dataType;
  final double? width;
  final bool sortable;
  final bool filterable;
  final bool resizable;
  final bool visible;
  final Widget Function(BuildContext, dynamic)? cellBuilder;
  final Widget Function(BuildContext)? headerBuilder;
  final String? format; // for dates and numbers

  const DataGridColumn({
    required this.dataField,
    required this.caption,
    this.dataType = DataType.string,
    this.width,
    this.sortable = true,
    this.filterable = true,
    this.resizable = true,
    this.visible = true,
    this.cellBuilder,
    this.headerBuilder,
    this.format,
  });

  /// Creates a text column
  factory DataGridColumn.text({
    required String dataField,
    required String caption,
    double? width,
    bool sortable = true,
    bool filterable = true,
    bool resizable = true,
    bool visible = true,
    Widget Function(BuildContext, dynamic)? cellBuilder,
    Widget Function(BuildContext)? headerBuilder,
  }) {
    return DataGridColumn(
      dataField: dataField,
      caption: caption,
      dataType: DataType.string,
      width: width,
      sortable: sortable,
      filterable: filterable,
      resizable: resizable,
      visible: visible,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Creates a number column
  factory DataGridColumn.number({
    required String dataField,
    required String caption,
    double? width,
    bool sortable = true,
    bool filterable = true,
    bool resizable = true,
    bool visible = true,
    String? format,
    Widget Function(BuildContext, dynamic)? cellBuilder,
    Widget Function(BuildContext)? headerBuilder,
  }) {
    return DataGridColumn(
      dataField: dataField,
      caption: caption,
      dataType: DataType.number,
      width: width,
      sortable: sortable,
      filterable: filterable,
      resizable: resizable,
      visible: visible,
      format: format,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Creates a date column
  factory DataGridColumn.date({
    required String dataField,
    required String caption,
    double? width,
    bool sortable = true,
    bool filterable = true,
    bool resizable = true,
    bool visible = true,
    String? format,
    Widget Function(BuildContext, dynamic)? cellBuilder,
    Widget Function(BuildContext)? headerBuilder,
  }) {
    return DataGridColumn(
      dataField: dataField,
      caption: caption,
      dataType: DataType.date,
      width: width,
      sortable: sortable,
      filterable: filterable,
      resizable: resizable,
      visible: visible,
      format: format,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Creates a boolean column
  factory DataGridColumn.boolean({
    required String dataField,
    required String caption,
    double? width,
    bool sortable = true,
    bool filterable = true,
    bool resizable = true,
    bool visible = true,
    Widget Function(BuildContext, dynamic)? cellBuilder,
    Widget Function(BuildContext)? headerBuilder,
  }) {
    return DataGridColumn(
      dataField: dataField,
      caption: caption,
      dataType: DataType.boolean,
      width: width,
      sortable: sortable,
      filterable: filterable,
      resizable: resizable,
      visible: visible,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Creates a custom column
  factory DataGridColumn.custom({
    required String dataField,
    required String caption,
    required Widget Function(BuildContext, dynamic) cellBuilder,
    double? width,
    bool sortable = false,
    bool filterable = false,
    bool resizable = true,
    bool visible = true,
    Widget Function(BuildContext)? headerBuilder,
  }) {
    return DataGridColumn(
      dataField: dataField,
      caption: caption,
      dataType: DataType.custom,
      width: width,
      sortable: sortable,
      filterable: filterable,
      resizable: resizable,
      visible: visible,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Builds the default cell widget based on data type
  Widget buildCell(BuildContext context, dynamic value) {
    if (cellBuilder != null) {
      return cellBuilder!(context, value);
    }

    switch (dataType) {
      case DataType.string:
        return _buildStringCell(context, value);
      case DataType.number:
        return _buildNumberCell(context, value);
      case DataType.date:
        return _buildDateCell(context, value);
      case DataType.boolean:
        return _buildBooleanCell(context, value);
      case DataType.custom:
        return _buildStringCell(context, value); // fallback
    }
  }

  /// Builds the default header widget
  Widget buildHeader(BuildContext context) {
    if (headerBuilder != null) {
      return headerBuilder!(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        caption,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStringCell(BuildContext context, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        value?.toString() ?? '',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNumberCell(BuildContext context, dynamic value) {
    final number = value is num ? value : double.tryParse(value?.toString() ?? '');
    if (number == null) return const Text('-');
    
    String formattedValue;
    if (format != null) {
      // Apply custom format
      formattedValue = number.toStringAsFixed(int.tryParse(format!) ?? 2);
    } else {
      formattedValue = number.toStringAsFixed(2);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        formattedValue,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateCell(BuildContext context, dynamic value) {
    if (value == null) return const Text('-');
    
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }
    
    if (date == null) return const Text('-');
    
    String formattedDate;
    if (format != null) {
      // Apply custom format (simple implementation)
      switch (format) {
        case 'dd/MM/yyyy':
          formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          break;
        case 'MM/dd/yyyy':
          formattedDate = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
          break;
        default:
          formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } else {
      formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        formattedDate,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBooleanCell(BuildContext context, dynamic value) {
    final boolValue = value is bool ? value : value?.toString().toLowerCase() == 'true';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Icon(
        boolValue ? Icons.check_circle : Icons.cancel,
        color: boolValue ? Colors.green : Colors.red,
        size: 20,
      ),
    );
  }
}

/// Represents the data source for the data grid
class DataGridSource {
  final List<Map<String, dynamic>> data;
  final int totalCount;
  final bool isLoading;
  final String? error;

  const DataGridSource({
    required this.data,
    required this.totalCount,
    this.isLoading = false,
    this.error,
  });

  /// Creates a DataGridSource from a list of maps
  factory DataGridSource.fromList(List<Map<String, dynamic>> data) {
    return DataGridSource(
      data: data,
      totalCount: data.length,
    );
  }

  /// Creates an empty DataGridSource
  factory DataGridSource.empty() {
    return const DataGridSource(
      data: [],
      totalCount: 0,
    );
  }

  /// Creates a loading DataGridSource
  factory DataGridSource.loading() {
    return const DataGridSource(
      data: [],
      totalCount: 0,
      isLoading: true,
    );
  }

  /// Creates an error DataGridSource
  factory DataGridSource.error(String error) {
    return DataGridSource(
      data: [],
      totalCount: 0,
      error: error,
    );
  }

  /// Gets the value at a specific row and field
  dynamic getValue(int rowIndex, String field) {
    if (rowIndex >= 0 && rowIndex < data.length) {
      return data[rowIndex][field];
    }
    return null;
  }

  /// Gets a specific row
  Map<String, dynamic>? getRow(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < data.length) {
      return data[rowIndex];
    }
    return null;
  }

  /// Gets the number of rows
  int get rowCount => data.length;

  /// Checks if the source has data
  bool get hasData => data.isNotEmpty;

  /// Checks if the source is in error state
  bool get hasError => error != null;
} 