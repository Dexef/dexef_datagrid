import 'package:flutter/material.dart';
import 'package:dexef_datagrid/dexef_datagrid.dart';

/// Example demonstrating the optimized DataGrid with performance enhancements
class OptimizedDataGridExample extends StatefulWidget {
  final String? currentView;
  final Function(String)? onViewChanged;

  const OptimizedDataGridExample({
    super.key,
    this.currentView,
    this.onViewChanged,
  });

  @override
  State<OptimizedDataGridExample> createState() => _OptimizedDataGridExampleState();
}

class _OptimizedDataGridExampleState extends State<OptimizedDataGridExample> {
  late DataGridController _controller;
  late DataGridSource _source;
  
  // Performance tracking
  int _rowCount = 1000;
  final bool _useOptimizedGrid = true;
  final bool _showPerformanceInfo = true;

  @override
  void initState() {
    super.initState();
    _controller = DataGridController();
    _source = _createLargeDataSource();
    _controller.setSource(_source);
  }

  DataGridSource _createLargeDataSource() {
    final data = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= _rowCount; i++) {
      data.add({
        'id': i,
        'name': 'User $i',
        'email': 'user$i@example.com',
        'age': 20 + (i % 50),
        'salary': 30000 + (i * 1000),
        'active': i % 3 == 0,
        'joinDate': DateTime(2020, 1, 1).add(Duration(days: i)),
        'avatar': 'https://picsum.photos/32/32?random=$i',
        'phone': '+1-555-${(1000 + i).toString().padLeft(4, '0')}',
        'website': 'https://example$i.com',
        'department': ['Engineering', 'Sales', 'Marketing', 'HR'][i % 4],
      });
    }
    
    return DataGridSource(
      data: data,
      totalCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showPerformanceInfo) _buildPerformanceInfo(),
        Expanded(
          child: _useOptimizedGrid ? _buildOptimizedGrid() : _buildStandardGrid(),
        ),
      ],
    );
  }

  Widget _buildPerformanceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  'Optimized Grid',
                  _useOptimizedGrid,
                  'RepaintBoundary, Lazy Loading, Diffing',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPerformanceCard(
                  'Standard Grid',
                  !_useOptimizedGrid,
                  'Basic rendering, No optimizations',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Data: $_rowCount rows | Grid: ${_useOptimizedGrid ? "Optimized" : "Standard"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String title, bool isActive, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey[200],
        border: Border.all(
          color: isActive ? color : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedGrid() {
    return OptimizedDataGrid(
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
      virtualScrollMode: VirtualScrollMode.basic,
      showPaginationControls: true,
      currentView: widget.currentView,
      onViewChanged: widget.onViewChanged,
      useOptimizedGrid: true, // Set to false to hide the optimized grid button
      onSelectionChanged: (selectedRows) {
        print('Selected rows: $selectedRows');
      },
      onCellEdit: (rowIndex, field, value) {
        print('Cell edited: row=$rowIndex, field=$field, value=$value');
      },
      // onAddNew: () {
      //   print('Add new item');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Add New button clicked')),
      //   );
      // },
      // onDuplicate: () {
      //   print('Duplicate selected items');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Duplicate button clicked')),
      //   );
      // },
      // onEdit: () {
      //   print('Edit selected items');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Edit button clicked')),
      //   );
      // },
      // onDelete: () {
      //   print('Delete selected items');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Delete button clicked')),
      //   );
      // },
      // onPrint: () {
      //   print('Print data');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Print button clicked')),
      //   );
      // },
      // onShare: () {
      //   print('Share data');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Share button clicked')),
      //   );
      // },
    );
  }

  Widget _buildStandardGrid() {
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
      onAddNew: () {
        print('Add new item');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add New button clicked')),
        );
      },
      onDuplicate: () {
        print('Duplicate selected items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate button clicked')),
        );
      },
      onEdit: () {
        print('Edit selected items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit button clicked')),
        );
      },
      onDelete: () {
        print('Delete selected items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete button clicked')),
        );
      },
      onPrint: () {
        print('Print data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print button clicked')),
        );
      },
      onShare: () {
        print('Share data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share button clicked')),
        );
      },
    );
  }

  List<DataGridColumn> _buildColumns() {
    return [
      const DataGridColumn(
        dataField: 'id',
        caption: 'ID',
        dataType: DataType.number,
        width: 60,
        sortable: true,
        filterable: true,
      ),
      DataGridColumn(
        dataField: 'avatar',
        caption: 'Avatar',
        dataType: DataType.custom,
        width: 60,
        sortable: false,
        filterable: false,
        cellBuilder: (context, value) {
          if (value == null || value.toString().isEmpty) {
            return const SizedBox.shrink();
          }
          return FadeInImage.assetNetwork(
            placeholder: 'assets/placeholder.png',
            image: value.toString(),
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            imageErrorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 16,
                  color: Colors.grey,
                ),
              );
            },
          );
        },
      ),
      const DataGridColumn(
        dataField: 'name',
        caption: 'Name',
        dataType: DataType.string,
        width: 150,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'email',
        caption: 'Email',
        dataType: DataType.string,
        width: 200,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'age',
        caption: 'Age',
        dataType: DataType.number,
        width: 80,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'salary',
        caption: 'Salary',
        dataType: DataType.number,
        width: 120,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'active',
        caption: 'Active',
        dataType: DataType.boolean,
        width: 80,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'joinDate',
        caption: 'Join Date',
        dataType: DataType.date,
        width: 120,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'phone',
        caption: 'Phone',
        dataType: DataType.string,
        width: 140,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'website',
        caption: 'Website',
        dataType: DataType.string,
        width: 150,
        sortable: true,
        filterable: true,
      ),
      const DataGridColumn(
        dataField: 'department',
        caption: 'Department',
        dataType: DataType.string,
        width: 120,
        sortable: true,
        filterable: true,
      ),
    ];
  }

  void _addMoreData() {
    setState(() {
      _rowCount += 100;
      _source = _createLargeDataSource();
      _controller.setSource(_source);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added 100 more rows. Total: $_rowCount'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 