import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';

/// Represents a column in the data grid
class DataGridColumn {
  final String key;
  final String header;
  final double? width;
  final bool sortable;
  final bool resizable;
  final Widget Function(dynamic value)? cellBuilder;
  final Widget Function(String header)? headerBuilder;

  const DataGridColumn({
    required this.key,
    required this.header,
    this.width,
    this.sortable = true,
    this.resizable = true,
    this.cellBuilder,
    this.headerBuilder,
  });

  /// Creates a column with a custom cell builder
  factory DataGridColumn.custom({
    required String key,
    required String header,
    required Widget Function(dynamic value) cellBuilder,
    double? width,
    bool sortable = true,
    bool resizable = true,
    Widget Function(String header)? headerBuilder,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
      cellBuilder: cellBuilder,
      headerBuilder: headerBuilder,
    );
  }

  /// Creates a text column
  factory DataGridColumn.text({
    required String key,
    required String header,
    double? width,
    bool sortable = true,
    bool resizable = true,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
    );
  }

  /// Creates a number column
  factory DataGridColumn.number({
    required String key,
    required String header,
    double? width,
    bool sortable = true,
    bool resizable = true,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
      cellBuilder: (value) {
        final number = value is num ? value : double.tryParse(value?.toString() ?? '');
        if (number == null) return const Text('-');
        return Text(
          number.toStringAsFixed(2),
          textAlign: TextAlign.right,
        );
      },
    );
  }

  /// Creates a date column
  factory DataGridColumn.date({
    required String key,
    required String header,
    double? width,
    bool sortable = true,
    bool resizable = true,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
      cellBuilder: (value) {
        if (value == null) return const Text('-');
        
        DateTime? date;
        if (value is DateTime) {
          date = value;
        } else if (value is String) {
          date = DateTime.tryParse(value);
        }
        
        if (date == null) return const Text('-');
        
        return Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        );
      },
    );
  }

  /// Creates a boolean column
  factory DataGridColumn.boolean({
    required String key,
    required String header,
    double? width,
    bool sortable = true,
    bool resizable = true,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
      cellBuilder: (value) {
        final boolValue = value is bool ? value : value?.toString().toLowerCase() == 'true';
        return Icon(
          boolValue ? Icons.check_circle : Icons.cancel,
          color: boolValue ? Colors.green : Colors.red,
          size: 20,
        );
      },
    );
  }

  /// Creates an action column
  factory DataGridColumn.action({
    required String key,
    required String header,
    required Widget Function(dynamic value, int rowIndex) actionBuilder,
    double? width,
    bool sortable = false,
    bool resizable = true,
  }) {
    return DataGridColumn(
      key: key,
      header: header,
      width: width,
      sortable: sortable,
      resizable: resizable,
      cellBuilder: (value) => actionBuilder(value, 0), // rowIndex will be set by the grid
    );
  }

  /// Builds the default cell widget
  Widget buildCell(dynamic value, DataGridConfig config) {
    if (cellBuilder != null) {
      return cellBuilder!(value);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        value?.toString() ?? '',
        style: config.cellTextStyle,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Builds the default header widget
  Widget buildHeader(DataGridConfig config, {bool isSorted = false, bool isAscending = true}) {
    if (headerBuilder != null) {
      return headerBuilder!(header);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              header,
              style: config.headerTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSorted && sortable)
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: config.headerTextColor,
            ),
        ],
      ),
    );
  }
} 