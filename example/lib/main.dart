import 'package:flutter/material.dart';
import 'package:dexef_datagrid/dexef_datagrid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentView = 'standard';

  void _onViewChanged(String view) {
    setState(() {
      _currentView = view;
    });
  }

  void _onExport() {
    // This will be handled by the DataGrid widgets themselves
    // The export dialog will be shown directly from the DataGrid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentView == 'standard' 
        ? DataGridExample(
            currentView: _currentView,
            onViewChanged: _onViewChanged,
            onExport: _onExport,
          )
        : OptimizedDataGridExample(
            currentView: _currentView,
            onViewChanged: _onViewChanged,
            onExport: _onExport,
          ),
    );
  }
}

class DataGridExample extends StatefulWidget {
  final String? currentView;
  final Function(String)? onViewChanged;
  final VoidCallback? onExport;

  const DataGridExample({
    super.key,
    this.currentView,
    this.onViewChanged,
    this.onExport,
  });

  @override
  State<DataGridExample> createState() => _DataGridExampleState();
}

class _DataGridExampleState extends State<DataGridExample> {
  late DataGridController _controller;
  late DataGridSource _source;

  @override
  void initState() {
    super.initState();
    _controller = DataGridController();
    _source = _createDataSource();
    _controller.setSource(_source);
  }

  DataGridSource _createDataSource() {
    final data = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 100; i++) {
      data.add({
        'id': i,
        'name': 'User $i',
        'email': 'user$i@example.com',
        'age': 20 + (i % 50),
        'salary': 30000 + (i * 1000),
        'active': i % 3 == 0,
        'joinDate': DateTime(2020, 1, 1).add(Duration(days: i)),
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
    return DataGrid(
      source: _source,
      columns: _buildColumns(),
      useOptimizedGrid: false,
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
    ];
  }
}

class OptimizedDataGridExample extends StatefulWidget {
  final String? currentView;
  final Function(String)? onViewChanged;
  final VoidCallback? onExport;

  const OptimizedDataGridExample({
    super.key,
    this.currentView,
    this.onViewChanged,
    this.onExport,
  });

  @override
  State<OptimizedDataGridExample> createState() => _OptimizedDataGridExampleState();
}

class _OptimizedDataGridExampleState extends State<OptimizedDataGridExample> {
  late DataGridController _controller;
  late DataGridSource _source;

  @override
  void initState() {
    super.initState();
    _controller = DataGridController();
    _source = _createDataSource();
    _controller.setSource(_source);
  }

  DataGridSource _createDataSource() {
    final data = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 1000; i++) {
      data.add({
        'id': i,
        'name': 'User $i',
        'email': 'user$i@example.com',
        'age': 20 + (i % 50),
        'salary': 30000 + (i * 1000),
        'active': i % 3 == 0,
        'joinDate': DateTime(2020, 1, 1).add(Duration(days: i)),
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
    ];
  }
} 