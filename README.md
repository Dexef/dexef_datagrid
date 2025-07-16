# Dexef DataGrid

A customizable data grid widget for Flutter applications with sorting, selection, and various column types.

## Features

- 📊 **Customizable Data Grid**: Display tabular data with customizable styling
- 🔄 **Sorting**: Click column headers to sort data
- ✅ **Row Selection**: Select single or multiple rows
- 🎨 **Multiple Column Types**: Text, number, date, boolean, and custom columns
- 🌙 **Dark Mode Support**: Built-in dark theme configuration
- 📱 **Responsive**: Adapts to different screen sizes
- ⚡ **Performance**: Optimized for large datasets
- 🎯 **Action Columns**: Add custom actions to each row

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dexef_datagrid: ^1.0.0
```

## Quick Start

```dart
import 'package:dexef_datagrid/dexef_datagrid.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data
    final data = [
      {'id': 1, 'name': 'John Doe', 'age': 30, 'active': true},
      {'id': 2, 'name': 'Jane Smith', 'age': 28, 'active': false},
    ];

    final model = DataGridModel.fromList(data);
    final controller = DataGridController();

    return DataGrid(
      model: model,
      controller: controller,
      columns: [
        DataGridColumn.number(key: 'id', header: 'ID', width: 80),
        DataGridColumn.text(key: 'name', header: 'Name', width: 150),
        DataGridColumn.number(key: 'age', header: 'Age', width: 80),
        DataGridColumn.boolean(key: 'active', header: 'Active', width: 80),
      ],
    );
  }
}
```

## Column Types

### Text Column
```dart
DataGridColumn.text(
  key: 'name',
  header: 'Name',
  width: 150,
)
```

### Number Column
```dart
DataGridColumn.number(
  key: 'salary',
  header: 'Salary',
  width: 120,
)
```

### Date Column
```dart
DataGridColumn.date(
  key: 'joinDate',
  header: 'Join Date',
  width: 120,
)
```

### Boolean Column
```dart
DataGridColumn.boolean(
  key: 'active',
  header: 'Active',
  width: 80,
)
```

### Action Column
```dart
DataGridColumn.action(
  key: 'actions',
  header: 'Actions',
  width: 100,
  actionBuilder: (value, rowIndex) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => editRow(rowIndex),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => deleteRow(rowIndex),
        ),
      ],
    );
  },
)
```

### Custom Column
```dart
DataGridColumn.custom(
  key: 'status',
  header: 'Status',
  width: 100,
  cellBuilder: (value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value == 'active' ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value.toString().toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  },
)
```

## Configuration

### Basic Configuration
```dart
final config = DataGridConfig(
  headerBackgroundColor: Colors.blue,
  headerTextColor: Colors.white,
  rowHeight: 50.0,
  showBorders: true,
  sortable: true,
  selectable: true,
);
```

### Dark Mode Configuration
```dart
final config = DataGridConfig.darkConfig;
```

### Custom Configuration
```dart
final config = DataGridConfig(
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
```

## Controller Usage

The `DataGridController` provides methods to manage the grid state:

```dart
final controller = DataGridController();

// Set data model
controller.setModel(model);

// Row selection
controller.selectRow(0);
controller.deselectRow(0);
controller.clearSelection();
controller.toggleRowSelection(0);

// Get selected data
final selectedRows = controller.selectedRows;
final selectedData = controller.getSelectedRowData();

// Check if row is selected
final isSelected = controller.isRowSelected(0);

// Column management
controller.setColumnWidth('name', 200.0);
controller.setColumnVisibility('id', false);
```

## Event Handling

```dart
DataGrid(
  model: model,
  controller: controller,
  columns: columns,
  onRowTap: () {
    print('Row tapped');
  },
  onCellTap: (rowIndex) {
    print('Cell tapped at row $rowIndex');
  },
  onHeaderTap: (columnIndex) {
    print('Header tapped at column $columnIndex');
  },
)
```

## Complete Example

See the `example/main.dart` file for a complete working example that demonstrates:

- Different column types
- Row selection
- Sorting
- Dark mode toggle
- Action buttons
- Custom styling

## API Reference

### DataGridModel
- `DataGridModel.fromList(List<Map<String, dynamic>> data)`
- `DataGridModel.fromObjects<T>(List<T> objects, Map<String, String> fieldMappings)`
- `getValue(int rowIndex, String column)`
- `getRow(int rowIndex)`
- `rowCount`
- `columnCount`

### DataGridController
- `setModel(DataGridModel model)`
- `selectRow(int rowIndex)`
- `deselectRow(int rowIndex)`
- `clearSelection()`
- `toggleRowSelection(int rowIndex)`
- `sortByColumn(int columnIndex)`
- `setColumnWidth(String column, double width)`
- `setColumnVisibility(String column, bool visible)`
- `getDisplayData()`
- `getVisibleColumns()`
- `isRowSelected(int rowIndex)`
- `getSelectedRowData()`

### DataGridConfig
- `headerBackgroundColor`
- `headerTextColor`
- `rowBackgroundColor`
- `alternateRowBackgroundColor`
- `borderColor`
- `borderWidth`
- `rowHeight`
- `headerHeight`
- `headerTextStyle`
- `cellTextStyle`
- `showBorders`
- `showAlternateRows`
- `sortable`
- `selectable`
- `resizableColumns`
- `minColumnWidth`
- `maxColumnWidth`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
