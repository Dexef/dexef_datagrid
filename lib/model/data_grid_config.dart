import 'package:flutter/material.dart';

/// Configuration for the data grid appearance and behavior
class DataGridConfig {
  final Color headerBackgroundColor;
  final Color headerTextColor;
  final Color rowBackgroundColor;
  final Color alternateRowBackgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double rowHeight;
  final double headerHeight;
  final TextStyle headerTextStyle;
  final TextStyle cellTextStyle;
  final bool showBorders;
  final bool showAlternateRows;
  final bool sortable;
  final bool selectable;
  final bool resizableColumns;
  final double minColumnWidth;
  final double maxColumnWidth;

  const DataGridConfig({
    this.headerBackgroundColor = const Color(0xFFF5F5F5),
    this.headerTextColor = Colors.black87,
    this.rowBackgroundColor = Colors.white,
    this.alternateRowBackgroundColor = const Color(0xFFFAFAFA),
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderWidth = 1.0,
    this.rowHeight = 48.0,
    this.headerHeight = 56.0,
    this.headerTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    this.cellTextStyle = const TextStyle(
      fontSize: 14,
    ),
    this.showBorders = true,
    this.showAlternateRows = true,
    this.sortable = true,
    this.selectable = true,
    this.resizableColumns = false,
    this.minColumnWidth = 100.0,
    this.maxColumnWidth = 300.0,
  });

  /// Creates a copy of this config with the given fields replaced
  DataGridConfig copyWith({
    Color? headerBackgroundColor,
    Color? headerTextColor,
    Color? rowBackgroundColor,
    Color? alternateRowBackgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? rowHeight,
    double? headerHeight,
    TextStyle? headerTextStyle,
    TextStyle? cellTextStyle,
    bool? showBorders,
    bool? showAlternateRows,
    bool? sortable,
    bool? selectable,
    bool? resizableColumns,
    double? minColumnWidth,
    double? maxColumnWidth,
  }) {
    return DataGridConfig(
      headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      rowBackgroundColor: rowBackgroundColor ?? this.rowBackgroundColor,
      alternateRowBackgroundColor: alternateRowBackgroundColor ?? this.alternateRowBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      showBorders: showBorders ?? this.showBorders,
      showAlternateRows: showAlternateRows ?? this.showAlternateRows,
      sortable: sortable ?? this.sortable,
      selectable: selectable ?? this.selectable,
      resizableColumns: resizableColumns ?? this.resizableColumns,
      minColumnWidth: minColumnWidth ?? this.minColumnWidth,
      maxColumnWidth: maxColumnWidth ?? this.maxColumnWidth,
    );
  }

  /// Default configuration
  static const DataGridConfig defaultConfig = DataGridConfig();

  /// Dark theme configuration
  static const DataGridConfig darkConfig = DataGridConfig(
    headerBackgroundColor: Color(0xFF424242),
    headerTextColor: Colors.white,
    rowBackgroundColor: Color(0xFF303030),
    alternateRowBackgroundColor: Color(0xFF424242),
    borderColor: Color(0xFF616161),
    headerTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white,
    ),
    cellTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),
  );
} 