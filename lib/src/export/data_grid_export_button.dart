import 'package:flutter/material.dart';
import '../../model/data_grid_model.dart';
import 'data_grid_export_dialog.dart';

/// Export button widget
class DataGridExportButton extends StatelessWidget {
  final List<DataGridColumn> columns;
  final List<Map<String, dynamic>> data;
  final Function(ExportFormat, ExportTemplate, List<String>, Map<String, String>) onExport;

  const DataGridExportButton({
    super.key,
    required this.columns,
    required this.data,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.file_download),
      onPressed: () => _showExportDialog(context),
      tooltip: 'Export Data',
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DataGridExportDialog(
        columns: columns,
        data: data,
        onExport: onExport,
      ),
    );
  }
}

/// Export button with dropdown
class DataGridExportDropdownButton extends StatelessWidget {
  final List<DataGridColumn> columns;
  final List<Map<String, dynamic>> data;
  final Function(ExportFormat, ExportTemplate, List<String>, Map<String, String>) onExport;

  const DataGridExportDropdownButton({
    super.key,
    required this.columns,
    required this.data,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExportFormat>(
      icon: const Icon(Icons.file_download),
      tooltip: 'Export Data',
      onSelected: (format) => _exportWithFormat(context, format),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ExportFormat.csv,
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text('Export as CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ExportFormat.excel,
          child: Row(
            children: [
              Icon(Icons.table_view, color: Colors.green),
              SizedBox(width: 8),
              Text('Export as Excel'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ExportFormat.pdf,
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('Export as PDF'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ExportFormat.csv, // This will be ignored
          child: const Row(
            children: [
              Icon(Icons.settings, color: Colors.grey),
              SizedBox(width: 8),
              Text('Advanced Export...'),
            ],
          ),
          onTap: () => _showAdvancedExportDialog(context),
        ),
      ],
    );
  }

  void _exportWithFormat(BuildContext context, ExportFormat format) {
    // Quick export with default settings
    final selectedColumns = columns.map((col) => col.dataField).toList();
    final customHeaders = <String, String>{};
    
    const defaultTemplate = ExportTemplate(
      name: 'Simple',
      includedColumns: [],
      customHeaders: {},
    );
    
    onExport(format, defaultTemplate, selectedColumns, customHeaders);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting as ${_getFormatName(format)}...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAdvancedExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DataGridExportDialog(
        columns: columns,
        data: data,
        onExport: onExport,
      ),
    );
  }

  String _getFormatName(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }
} 