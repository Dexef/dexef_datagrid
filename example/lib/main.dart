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
      backgroundColor:  Colors.white,
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
    
    final customerNames = [
      'Mohamed Gamal', 'Ahmed Abd El Rahman', 'Fatima Hassan', 'Omar Khalil',
      'Aisha Mahmoud', 'Youssef Ibrahim', 'Nour El Din', 'Mariam Ali',
      'Karim Mostafa', 'Layla Ahmed', 'Hassan Mohamed', 'Zainab Omar',
      'Tarek Hussein', 'Rania Salah', 'Amr El Sayed', 'Dina Mahmoud',
      'Khaled Hassan', 'Nada Ibrahim', 'Wael Ali', 'Heba Mostafa'
    ];
    
    final phoneNumbers = [
      ['01007773678', '01000246222'],
      ['01234567890', '01123456789'],
      ['01567890123', '01456789012'],
      ['01987654321', '01876543210'],
      ['01345678901', '01234567890'],
      ['01789012345', '01678901234'],
      ['01123456789', '01012345678'],
      ['01543210987', '01432109876'],
      ['01890123456', '01789012345'],
      ['01210987654', '01109876543'],
      ['01654321098', '01543210987'],
      ['01901234567', '01890123456'],
      ['01321098765', '01210987654'],
      ['01765432109', '01654321098'],
      ['01098765432', '01987654321'],
      ['01432109876', '01321098765'],
      ['01876543210', '01765432109'],
      ['01234567890', '01123456789'],
      ['01678901234', '01567890123'],
      ['01987654321', '01876543210']
    ];
    
    final statuses = ['Regular', 'Premium', 'VIP', 'New', 'Inactive'];
    
    for (int i = 1; i <= 100; i++) {
      final customerIndex = (i - 1) % customerNames.length;
      final phoneIndex = (i - 1) % phoneNumbers.length;
      final statusIndex = (i - 1) % statuses.length;
      
      final lastPurchaseDate = DateTime(2025, 1, 5).subtract(Duration(days: (i % 30) + 1));
      final daysAgo = DateTime.now().difference(lastPurchaseDate).inDays;
      
      data.add({
        'id': i,
        'customerName': customerNames[customerIndex],
        'customerId': '#${i.toString().padLeft(3, '0')}',
        'phone1': phoneNumbers[phoneIndex][0],
        'phone2': phoneNumbers[phoneIndex][1],
        'lastPurchaseDate': lastPurchaseDate,
        'daysAgo': daysAgo,
        'orders': 10 + (i % 20),
        'totalSpent': 1500.0 + (i * 100.0),
        'status': statuses[statusIndex],
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
        rowHeight: 74,
        headerHeight: 56,
        minColumnWidth: 120,
        showBorders: false,
        showHorizontalBorders: true,
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
      // Customer column with name and ID
      DataGridColumn.custom(
        dataField: 'customerName',
        caption: 'Customer',
        width: 180,
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['customerName'] == value);
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 16, color: Color(0xff464646) , fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${rowData['customerId'].toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff999FA7),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showCustomerMenu(context, value),
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xff5D718D),
                  size: 25,
                ),
              ),
            ],
          );
        },
      ),
      // Contact column with two phone numbers
      DataGridColumn.custom(
        dataField: 'phone1',
        caption: 'Contact',
        width: 140,
        headerBuilder: (context) => const Center(
          child: Text(
            'Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['phone1'] == value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 16 , color: Color(0xff464646)),
                textAlign: TextAlign.center,
              ),
              Text(
                rowData['phone2'].toString(),
                style:const TextStyle(
                  fontSize: 14,
                  color: Color(0xff999FA7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
      // Last Purchase column with date and days ago
      DataGridColumn.custom(
        dataField: 'lastPurchaseDate',
        caption: 'Last Purchase',
        width: 140,
        headerBuilder: (context) => const Center(
          child: Text(
            'Last Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['lastPurchaseDate'] == value);
          final date = value as DateTime;
          final daysAgo = rowData['daysAgo'] as int;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day} ${_getMonthName(date.month)}, ${date.year}',
                style: const TextStyle(fontSize: 16, color: Color(0xff464646)),
                textAlign: TextAlign.center,
              ),
              Text(
                '$daysAgo days ago',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff999FA7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
      // Orders column
      DataGridColumn.custom(
        dataField: 'orders',
        caption: 'Orders',
        width: 80,
        sortable: true,
        filterable: true,
        headerBuilder: (context) => const Center(
          child: Text(
            'Orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff464646),
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Total Spent column with currency formatting
      DataGridColumn.custom(
        dataField: 'totalSpent',
        caption: 'Total Spent',
        width: 120,
        headerBuilder: (context) => const Center(
          child: Text(
            'Total Spent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final amount = value as double;
          return Center(
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xff464646),
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Status column with blue text
      DataGridColumn.custom(
        dataField: 'status',
        caption: 'Status',
        width: 100,
        headerBuilder: (context) => const Center(
          child: Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Action column with horizontal more_vert icon
      DataGridColumn.custom(
        dataField: 'action',
        caption: 'Action',
        width: 80,
        sortable: false,
        filterable: false,
        headerBuilder: (context) => const Center(
          child: Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: GestureDetector(
              onTap: () => _showActionDialog(context, value),
              child: const Icon(
                Icons.more_horiz,
                color: Colors.grey,
                size: 25,
              ),
            ),
          );
        },
      ),
    ];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _showActionDialog(BuildContext context, dynamic value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Customer Actions'),
          content: const Text('Choose an action for this customer:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit customer')),
                );
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete customer')),
                );
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View details')),
                );
              },
              child: const Text('View Details'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerMenu(BuildContext context, dynamic value) {
    final customerData = _source.data.firstWhere((row) => row['customerName'] == value);
    final customerId = customerData['customerId'];

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Customer'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Customer'),
        ),
        const PopupMenuItem(
          value: 'viewDetails',
          child: Text('View Details'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit customer $customerId')),
        );
      } else if (value == 'delete') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete customer $customerId')),
        );
      } else if (value == 'viewDetails') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View details for customer $customerId')),
        );
      }
    });
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
    
    final customerNames = [
      'Mohamed Gamal', 'Ahmed Abd El Rahman', 'Fatima Hassan', 'Omar Khalil',
      'Aisha Mahmoud', 'Youssef Ibrahim', 'Nour El Din', 'Mariam Ali',
      'Karim Mostafa', 'Layla Ahmed', 'Hassan Mohamed', 'Zainab Omar',
      'Tarek Hussein', 'Rania Salah', 'Amr El Sayed', 'Dina Mahmoud',
      'Khaled Hassan', 'Nada Ibrahim', 'Wael Ali', 'Heba Mostafa'
    ];
    
    final phoneNumbers = [
      ['01007773678', '01000246222'],
      ['01234567890', '01123456789'],
      ['01567890123', '01456789012'],
      ['01987654321', '01876543210'],
      ['01345678901', '01234567890'],
      ['01789012345', '01678901234'],
      ['01123456789', '01012345678'],
      ['01543210987', '01432109876'],
      ['01890123456', '01789012345'],
      ['01210987654', '01109876543'],
      ['01654321098', '01543210987'],
      ['01901234567', '01890123456'],
      ['01321098765', '01210987654'],
      ['01765432109', '01654321098'],
      ['01098765432', '01987654321'],
      ['01432109876', '01321098765'],
      ['01876543210', '01765432109'],
      ['01234567890', '01123456789'],
      ['01678901234', '01567890123'],
      ['01987654321', '01876543210']
    ];
    
    final statuses = ['Regular', 'Premium', 'VIP', 'New', 'Inactive'];
    
    for (int i = 1; i <= 1000; i++) {
      final customerIndex = (i - 1) % customerNames.length;
      final phoneIndex = (i - 1) % phoneNumbers.length;
      final statusIndex = (i - 1) % statuses.length;
      
      final lastPurchaseDate = DateTime(2025, 1, 5).subtract(Duration(days: (i % 30) + 1));
      final daysAgo = DateTime.now().difference(lastPurchaseDate).inDays;
      
      data.add({
        'id': i,
        'customerName': customerNames[customerIndex],
        'customerId': '#${i.toString().padLeft(3, '0')}',
        'phone1': phoneNumbers[phoneIndex][0],
        'phone2': phoneNumbers[phoneIndex][1],
        'lastPurchaseDate': lastPurchaseDate,
        'daysAgo': daysAgo,
        'orders': 10 + (i % 20),
        'totalSpent': 1500.0 + (i * 100.0),
        'status': statuses[statusIndex],
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
        rowHeight: 74,
        headerHeight: 56,
        minColumnWidth: 120,
        showBorders: false,
        showHorizontalBorders: true,
        showAlternateRows: true,
        alternateRowBackgroundColor: Color(0xFFF5F5F5),
      ),
      selectionMode: SelectionMode.multiple,
      editMode: EditMode.cell,
      showFilterRow: false,
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
      // Customer column with name and ID
      DataGridColumn.custom(
        dataField: 'customerName',
        caption: 'Customer',
        width: 180,
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['customerName'] == value);
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 16, color: Color(0xff464646) , fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${rowData['customerId'].toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff999FA7),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showCustomerMenu(context, value),
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xff5D718D),
                  size: 25,
                ),
              ),
            ],
          );
        },
      ),
      // Contact column with two phone numbers
      DataGridColumn.custom(
        dataField: 'phone1',
        caption: 'Contact',
        width: 140,
        headerBuilder: (context) => const Center(
          child: Text(
            'Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['phone1'] == value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 16 , color: Color(0xff464646)),
                textAlign: TextAlign.center,
              ),
              Text(
                rowData['phone2'].toString(),
                style:const TextStyle(
                  fontSize: 14,
                  color: Color(0xff999FA7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
      // Last Purchase column with date and days ago
      DataGridColumn.custom(
        dataField: 'lastPurchaseDate',
        caption: 'Last Purchase',
        width: 140,
        headerBuilder: (context) => const Center(
          child: Text(
            'Last Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final rowData = _source.data.firstWhere((row) => row['lastPurchaseDate'] == value);
          final date = value as DateTime;
          final daysAgo = rowData['daysAgo'] as int;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day} ${_getMonthName(date.month)}, ${date.year}',
                style: const TextStyle(fontSize: 16, color: Color(0xff464646)),
                textAlign: TextAlign.center,
              ),
              Text(
                '$daysAgo days ago',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff999FA7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
      // Orders column
      DataGridColumn.custom(
        dataField: 'orders',
        caption: 'Orders',
        width: 80,
        sortable: true,
        filterable: true,
        headerBuilder: (context) => const Center(
          child: Text(
            'Orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff464646),
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Total Spent column with currency formatting
      DataGridColumn.custom(
        dataField: 'totalSpent',
        caption: 'Total Spent',
        width: 120,
        headerBuilder: (context) => const Center(
          child: Text(
            'Total Spent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          final amount = value as double;
          return Center(
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xff464646),
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Status column with blue text
      DataGridColumn.custom(
        dataField: 'status',
        caption: 'Status',
        width: 100,
        headerBuilder: (context) => const Center(
          child: Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      // Action column with horizontal more_vert icon
      DataGridColumn.custom(
        dataField: 'action',
        caption: 'Action',
        width: 80,
        sortable: false,
        filterable: false,
        headerBuilder: (context) => const Center(
          child: Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        cellBuilder: (context, value) {
          return Center(
            child: GestureDetector(
              onTap: () => _showActionDialog(context, value),
              child: const Icon(
                Icons.more_horiz,
                color: Colors.grey,
                size: 25,
              ),
            ),
          );
        },
      ),
    ];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _showActionDialog(BuildContext context, dynamic value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Customer Actions'),
          content: const Text('Choose an action for this customer:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit customer')),
                );
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete customer')),
                );
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View details')),
                );
              },
              child: const Text('View Details'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerMenu(BuildContext context, dynamic value) {
    final customerData = _source.data.firstWhere((row) => row['customerName'] == value);
    final customerId = customerData['customerId'];

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Customer'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Customer'),
        ),
        const PopupMenuItem(
          value: 'viewDetails',
          child: Text('View Details'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit customer $customerId')),
        );
      } else if (value == 'delete') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete customer $customerId')),
        );
      } else if (value == 'viewDetails') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View details for customer $customerId')),
        );
      }
    });
  }
} 