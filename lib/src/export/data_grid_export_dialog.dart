import 'package:flutter/material.dart';
import '../../model/data_grid_model.dart';
import '../utils/data_grid_dialog.dart';

/// Export format enum
enum ExportFormat {
  csv,
  excel,
  pdf,
}

/// Export template class
class ExportTemplate {
  final String name;
  final List<String> includedColumns;
  final Map<String, String> customHeaders;

  const ExportTemplate({
    required this.name,
    this.includedColumns = const [],
    this.customHeaders = const {},
  });
}

/// Export dialog with format selection and options
class DataGridExportDialog extends StatefulWidget {
  final List<DataGridColumn> columns;
  final List<Map<String, dynamic>> data;
  final Function(ExportFormat, ExportTemplate, List<String>, Map<String, String>) onExport;

  const DataGridExportDialog({
    super.key,
    required this.columns,
    required this.data,
    required this.onExport,
  });

  @override
  State<DataGridExportDialog> createState() => _DataGridExportDialogState();
}

class _DataGridExportDialogState extends State<DataGridExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportTemplate? _selectedTemplate;
  List<String> _selectedColumns = [];
  Map<String, String> _customHeaders = {};
  bool _includeHeaders = true;
  bool _includeRowNumbers = false;
  bool _includeSummary = false;
  
  late List<ExportTemplate> _availableTemplates;

  @override
  void initState() {
    super.initState();
    _selectedColumns = widget.columns.map((col) => col.dataField).toList();
    _availableTemplates = _createTemplates();
  }
  
  List<ExportTemplate> _createTemplates() {
    return [
      const ExportTemplate(
        name: 'Simple',
        includedColumns: [],
        customHeaders: {},
      ),
      const ExportTemplate(
        name: 'Detailed',
        includedColumns: [],
        customHeaders: {},
      ),
      const ExportTemplate(
        name: 'Custom',
        includedColumns: [],
        customHeaders: {},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Export Data',
      icon: Icons.file_download,
      headerColor: Colors.green,
      width: 600,
      height: 600,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format selection
            const Text(
              'Export Format',
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
                  child: _buildFormatButton(
                    ExportFormat.csv,
                    'CSV',
                    Icons.table_chart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormatButton(
                    ExportFormat.excel,
                    'Excel',
                    Icons.table_view,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormatButton(
                    ExportFormat.pdf,
                    'PDF',
                    Icons.picture_as_pdf,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Template selection
            const Text(
              'Export Template',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _availableTemplates.map((template) {
                return Expanded(
                  child: _buildTemplateButton(
                    template,
                    template.name,
                    _getTemplateIcon(template.name),
                    _getTemplateColor(template.name),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Column selection
            const Text(
              'Columns to Export',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Select All'),
                      leading: Checkbox(
                        value: _selectedColumns.length == widget.columns.length,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedColumns = widget.columns.map((col) => col.dataField).toList();
                            } else {
                              _selectedColumns.clear();
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (_selectedColumns.length == widget.columns.length) {
                            _selectedColumns.clear();
                          } else {
                            _selectedColumns = widget.columns.map((col) => col.dataField).toList();
                          }
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ...widget.columns.map((column) {
                      return CheckboxListTile(
                        title: Text(column.caption),
                        subtitle: Text(column.dataField),
                        value: _selectedColumns.contains(column.dataField),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedColumns.add(column.dataField);
                            } else {
                              _selectedColumns.remove(column.dataField);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Export options
            const Text(
              'Export Options',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Include Headers'),
                  subtitle: const Text('Include column headers in export'),
                  value: _includeHeaders,
                  onChanged: (value) {
                    setState(() {
                      _includeHeaders = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Include Row Numbers'),
                  subtitle: const Text('Add row numbers to export'),
                  value: _includeRowNumbers,
                  onChanged: (value) {
                    setState(() {
                      _includeRowNumbers = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Include Summary'),
                  subtitle: const Text('Add summary statistics'),
                  value: _includeSummary,
                  onChanged: (value) {
                    setState(() {
                      _includeSummary = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _exportData,
          icon: const Icon(Icons.file_download),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatButton(
    ExportFormat format,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedFormat == format;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFormat = format;
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

  Widget _buildTemplateButton(
    ExportTemplate template,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedTemplate?.name == template.name;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTemplate = template;
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
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportData() {
    // Prepare custom headers if needed
    if (_selectedTemplate?.name == 'Custom') {
      for (final column in widget.columns) {
        if (_selectedColumns.contains(column.dataField)) {
          _customHeaders[column.dataField] = column.caption;
        }
      }
    }

    // Call the export function
    widget.onExport(
      _selectedFormat,
      _selectedTemplate ?? _availableTemplates.first,
      _selectedColumns,
      _customHeaders,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as ${_getFormatName(_selectedFormat)}...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
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
  
  IconData _getTemplateIcon(String templateName) {
    switch (templateName.toLowerCase()) {
      case 'simple':
        return Icons.list;
      case 'detailed':
        return Icons.description;
      case 'custom':
        return Icons.settings;
      default:
        return Icons.list_alt;
    }
  }
  
  Color _getTemplateColor(String templateName) {
    switch (templateName.toLowerCase()) {
      case 'simple':
        return Colors.grey;
      case 'detailed':
        return Colors.blue;
      case 'custom':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 