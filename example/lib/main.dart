import 'package:flutter/material.dart';
import 'package:dexef_datagrid/dexef_datagrid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        body: DataGridExample(),
      ),
    );
  }
}

class DataGridExample extends StatefulWidget {
  final String? currentView;
  final Function(String)? onViewChanged;
  final VoidCallback? onAddNew;
  final VoidCallback? onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onRefresh;

  const DataGridExample({
    super.key,
    this.currentView,
    this.onViewChanged,
    this.onAddNew,
    this.onDuplicate,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.onShare,
    this.onRefresh,
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
      'Mohamed Gamal',
      'Ahmed Abd El Rahman',
      'Fatima Hassan',
      'Omar Khalil',
      'Aisha Mahmoud',
      'Youssef Ibrahim',
      'Nour El Din',
      'Mariam Ali',
      'Karim Mostafa',
      'Layla Ahmed',
      'Hassan Mohamed',
      'Zainab Omar',
      'Tarek Hussein',
      'Rania Salah',
      'Amr El Sayed',
      'Dina Mahmoud',
      'Khaled Hassan',
      'Nada Ibrahim',
      'Wael Ali',
      'Heba Mostafa'
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

      final lastPurchaseDate =
          DateTime(2025, 1, 5).subtract(Duration(days: (i % 30) + 1));
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
        'email': '${customerNames[customerIndex].split(' ').first.toLowerCase()}$i@example.com',
        'country': ['Egypt', 'Saudi Arabia', 'UAE', 'Jordan', 'Morocco', 'Qatar'][i % 6],
        'balance': 500.0 + (i * 75.0) - ((i % 7) * 120.0),
        'active': i % 2 == 0,
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
        headerHeight: 40,
        minColumnWidth: 120,
        showBorders: true,
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
      showSummaryRow: true,
      currentView: widget.currentView,
      onViewChanged: widget.onViewChanged,
      onSelectionChanged: (selectedRows) {
        print('Selected rows: $selectedRows');
      },
      onCellEdit: (rowIndex, field, value) {
        print('Cell edited: row=$rowIndex, field=$field, value=$value');
        setState(() {
          _source.data[rowIndex][field] = value;
        });
      },
      showAddNewRow: true,
      onAddNew: () {
        setState(() {
          _source.data.add({
            'id': _source.data.length + 1,
            'customerName': '',
            'customerId': '#${(_source.data.length + 1).toString().padLeft(3, '0')}',
            'phone1': '',
            'phone2': '',
            'lastPurchaseDate': DateTime.now(),
            'daysAgo': 0,
            'orders': 0,
            'totalSpent': 0.0,
            'status': 'New',
            'email': '',
            'country': '',
            'balance': 0.0,
            'active': false,
          });
          _source = DataGridSource(
            data: _source.data,
            totalCount: _source.data.length,
          );
          _controller.setSource(_source);
        });
      },
      onDuplicate: widget.onDuplicate,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onPrint: widget.onPrint,
      onShare: widget.onShare,
      onRefresh: widget.onRefresh,
    );
  }

  Widget _buildHeaderCell(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'DexPro',
          color: Color(0xff464646),
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  static const _avatarColors = [
    Color(0xff4CAF50),
    Color(0xff2196F3),
    Color(0xffFF9800),
    Color(0xff9C27B0),
    Color(0xffE91E63),
    Color(0xff00BCD4),
    Color(0xffFF5722),
    Color(0xff607D8B),
  ];

  Widget _buildInitialsCircle(String name) {
    if (name.trim().isEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.person, size: 18, color: Colors.grey),
        ),
      );
    }
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
    final color = _avatarColors[name.hashCode.abs() % _avatarColors.length];
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'DexPro',
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  List<DataGridColumn> _buildColumns() {
    return [
      DataGridColumn.custom(
        dataField: 'customerName',
        caption: 'Customer',
        width: 160,
        filterable: true,
        hintText: 'Enter name...',
        headerBuilder: (context) => _buildHeaderCell('Customer'),
        cellBuilder: (context, value) {
          return Row(
            children: [
              const SizedBox(width: 8),
              _buildInitialsCircle(value.toString()),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'DexPro',
                    color: Color(0xff464646),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        editCellBuilder: (context, value, editor) {
          return Row(
            children: [
              const SizedBox(width: 8),
              _buildInitialsCircle(value.toString()),
              const SizedBox(width: 8),
              Expanded(child: editor),
            ],
          );
        },
      ),
      DataGridColumn.custom(
        dataField: 'phone1',
        caption: 'Contact',
        dataType: DataType.string,
        width: 92,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Contact'),
        cellBuilder: (context, value) => _buildDataCell(value.toString()),
      ),
      DataGridColumn.custom(
        dataField: 'email',
        caption: 'Email',
        dataType: DataType.string,
        width: 120,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Email'),
        cellBuilder: (context, value) => _buildDataCell(value.toString()),
      ),
      DataGridColumn.custom(
        dataField: 'country',
        caption: 'Country',
        dataType: DataType.list,
        listItems: const [
          'Egypt',
          'Saudi Arabia',
          'UAE',
          'Jordan',
          'Morocco',
          'Qatar',
        ],
        width: 80,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Country'),
        cellBuilder: (context, value) {
          const countryColors = {
            'Egypt': Color(0xFF5AACD4),
            'Saudi Arabia': Color(0xFF9B59B6),
            'UAE': Color(0xFF2ECC71),
            'Jordan': Color(0xFFE8A838),
            'Morocco': Color(0xFF3A7BD5),
            'Qatar': Color(0xFF1ABC9C),
          };
          final str = value?.toString() ?? '';
          final color = countryColors[str];
          if (color == null || str.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            color: color,
            alignment: Alignment.center,
            child: Text(
              str,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      DataGridColumn.custom(
        dataField: 'balance',
        caption: 'Balance',
        dataType: DataType.number,
        width: 80,
        filterable: true,
        sortable: true,
        headerBuilder: (context) => _buildHeaderCell('Balance'),
        cellBuilder: (context, value) {
          final balance = value as double;
          return _buildDataCell('\$${balance.toStringAsFixed(2)}');
        },
      ),
      DataGridColumn.custom(
        dataField: 'lastPurchaseDate',
        caption: 'Last Purchase',
        dataType: DataType.date,
        width: 100,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Last Purchase'),
        cellBuilder: (context, value) {
          final date = value as DateTime;
          return _buildDataCell(
            '${date.day} ${_getMonthName(date.month)}, ${date.year}',
          );
        },
      ),
      DataGridColumn.custom(
        dataField: 'orders',
        caption: 'Orders',
        dataType: DataType.number,
        width: 60,
        editable: false,
        sortable: true,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Orders'),
        cellBuilder: (context, value) => _buildDataCell(value.toString()),
      ),
      DataGridColumn.custom(
        dataField: 'totalSpent',
        caption: 'Total Spent',
        dataType: DataType.number,
        width: 80,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Total Spent'),
        cellBuilder: (context, value) {
          final amount = value as double;
          return _buildDataCell('\$${amount.toStringAsFixed(2)}');
        },
      ),
      DataGridColumn.custom(
        dataField: 'status',
        caption: 'Status',
        dataType: DataType.list,
        listItems: const ['Regular', 'Premium', 'VIP', 'New', 'Inactive'],
        width: 80,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Status'),
        cellBuilder: (context, value) {
          const statusColors = {
            'Regular': Color(0xFF5AACD4),
            'Premium': Color(0xFF9B59B6),
            'VIP': Color(0xFF2ECC71),
            'New': Color(0xFFE8A838),
            'Inactive': Color(0xFF3A7BD5),
          };
          final str = value?.toString() ?? '';
          final color = statusColors[str];
          if (color == null || str.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            color: color,
            alignment: Alignment.center,
            child: Text(
              str,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      DataGridColumn.custom(
        dataField: 'active',
        caption: 'Active',
        dataType: DataType.boolean,
        width: 60,
        editable: true,
        filterable: true,
        headerBuilder: (context) => _buildHeaderCell('Active'),
        cellBuilder: (context, value) {
          final isActive = value == true;
          return Center(
            child: isActive
                ? const Icon(Icons.done, color: Colors.green, size: 24)
                : const SizedBox.shrink(),
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

}
