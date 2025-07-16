import 'package:flutter/material.dart';
import 'package:dexef_datagrid/dexef_datagrid.dart';

/// Example demonstrating the export functionality
class ExportExample extends StatefulWidget {
  final String? currentView;
  final Function(String)? onViewChanged;

  const ExportExample({
    super.key,
    this.currentView,
    this.onViewChanged,
  });

  @override
  State<ExportExample> createState() => _ExportExampleState();
}

class _ExportExampleState extends State<ExportExample> {
  late DataGridController _controller;
  late DataGridSource _source;
  late List<ExportTemplate> _templates;

  @override
  void initState() {
    super.initState();
    _controller = DataGridController();
    _source = _createDataSource();
    _controller.setSource(_source);
    _templates = _createTemplates();
  }

  DataGridSource _createDataSource() {
    final data = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 50; i++) {
      data.add({
        'id': i,
        'name': 'User $i',
        'email': 'user$i@example.com',
        'age': 20 + (i % 50),
        'salary': 30000 + (i * 1000),
        'active': i % 3 == 0,
        'joinDate': DateTime(2020, 1, 1).add(Duration(days: i)),
        'department': ['Engineering', 'Sales', 'Marketing', 'HR'][i % 4],
        'phone': '+1-555-${(1000 + i).toString().padLeft(4, '0')}',
        'website': 'https://example$i.com',
      });
    }
    
    return DataGridSource(
      data: data,
      totalCount: data.length,
    );
  }

  List<ExportTemplate> _createTemplates() {
    return [
      const ExportTemplate(
        name: 'Basic Info',
        includedColumns: ['id', 'name', 'email', 'department'],
        customHeaders: {
          'id': 'ID',
          'name': 'Full Name',
          'email': 'Email Address',
          'department': 'Department',
        },
      ),
      const ExportTemplate(
        name: 'Financial Report',
        includedColumns: ['id', 'name', 'salary', 'department'],
        customHeaders: {
          'id': 'Employee ID',
          'name': 'Employee Name',
          'salary': 'Annual Salary',
          'department': 'Department',
        },
      ),
      const ExportTemplate(
        name: 'Contact List',
        includedColumns: ['name', 'email', 'phone', 'website'],
        customHeaders: {
          'name': 'Contact Name',
          'email': 'Email',
          'phone': 'Phone Number',
          'website': 'Website',
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DataGrid(
      source: _source,
      columns: _buildColumns(),
      controller: _controller,
      config: const DataGridConfig(
        rowHeight: 48,
        headerHeight: 56,
        minColumnWidth: 120,
        showBorders: true,
        showAlternateRows: true,
        alternateRowBackgroundColor: Color(0xFFF5F5F5),
      ),
      selectionMode: SelectionMode.multiple,
      editMode: EditMode.cell,
      showFilterRow: true,
      showFilterPanel: true,
      showSearchPanel: true,
      showSortControls: true,
      showGroupControls: true,
      paginationMode: PaginationMode.client,
      virtualScrollMode: VirtualScrollMode.none,
      showPaginationControls: true,
      currentView: widget.currentView,
      onViewChanged: widget.onViewChanged,
      onSelectionChanged: (selectedRows) {
        print('Selected rows: $selectedRows');
      },
      onCellEdit: (rowIndex, field, value) {
        print('Cell edited: row=$rowIndex, field=$field, value=$value');
      },
    );
  }

  Widget _buildExportInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFeatureChip('CSV Export', Colors.green),
                _buildFeatureChip('Excel Export', Colors.blue),
                _buildFeatureChip('PDF Export', Colors.red),
                _buildFeatureChip('Custom Templates', Colors.orange),
                _buildFeatureChip('Progress Indicators', Colors.purple),
                _buildFeatureChip('Share Integration', Colors.teal),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use the export buttons in the app bar to export data in different formats.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  List<DataGridColumn> _buildColumns() {
    return [
      DataGridColumn(
        dataField: 'id',
        caption: 'ID',
        dataType: DataType.number,
        width: 60,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'name',
        caption: 'Name',
        dataType: DataType.string,
        width: 150,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'email',
        caption: 'Email',
        dataType: DataType.string,
        width: 200,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'age',
        caption: 'Age',
        dataType: DataType.number,
        width: 80,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'salary',
        caption: 'Salary',
        dataType: DataType.number,
        width: 120,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'active',
        caption: 'Active',
        dataType: DataType.boolean,
        width: 80,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'joinDate',
        caption: 'Join Date',
        dataType: DataType.date,
        width: 120,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'department',
        caption: 'Department',
        dataType: DataType.string,
        width: 120,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'phone',
        caption: 'Phone',
        dataType: DataType.string,
        width: 140,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'website',
        caption: 'Website',
        dataType: DataType.string,
        width: 150,
        sortable: true,
        filterable: true,
      ),
    ];
  }
} 