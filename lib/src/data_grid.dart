import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/data_grid_model.dart';
import '../model/data_grid_filters.dart';
import '../model/data_grid_sorting.dart';
import '../model/data_grid_selection.dart';
import '../model/data_grid_pagination.dart';
import '../model/data_grid_config.dart';
import 'data_grid_controller.dart';

import 'data_grid_row.dart';
import 'selection/data_grid_selection_widgets.dart';
import 'sorting/data_grid_sort_widgets.dart';
import 'filters/data_grid_filter_widgets.dart';
import 'filters/data_grid_filter_panel.dart' hide DataGridSearchPanel;
import 'filters/data_grid_search_panel.dart';
import 'grouping/data_grid_group_widgets.dart';
import 'pagination/data_grid_pagination_widgets.dart';
import 'pagination/data_grid_virtual_scroll.dart';
import 'export/data_grid_export_dialog.dart';

/// A customizable data grid widget for displaying tabular data
class DataGrid extends StatefulWidget {
  final DataGridSource? source;
  final List<DataGridColumn> columns;
  final DataGridConfig config;
  final DataGridController? controller;
  final VoidCallback? onRowTap;
  final Function(int)? onCellTap;
  final Function(int)? onHeaderTap;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool showFilterRow;
  final bool showFilterPanel;
  final bool showSearchPanel;
  final bool showSortControls;
  final bool showGroupControls;
  final SelectionMode selectionMode;
  final EditMode editMode;
  final bool showSelectionIndicator;
  final Function(List<int>)? onSelectionChanged;
  final Function(int, String, dynamic)? onCellEdit;
  final Function(int, Map<String, dynamic>)? onRowEdit;
  final PaginationMode paginationMode;
  final VirtualScrollMode virtualScrollMode;
  final VirtualScrollConfig? virtualConfig;
  final Function(DataGridServerRequest)? onServerDataRequest;
  final bool showPaginationControls;
  final String? currentView;
  final Function(String)? onViewChanged;
  final bool useOptimizedGrid;
  final VoidCallback? onAddNew;
  final VoidCallback? onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const DataGrid({
    super.key,
    this.source,
    required this.columns,
    this.config = const DataGridConfig(),
    this.controller,
    this.onRowTap,
    this.onCellTap,
    this.onHeaderTap,
    this.emptyWidget,
    this.loadingWidget,
    this.showFilterRow = true,
    this.showFilterPanel = true,
    this.showSearchPanel = true,
    this.showSortControls = true,
    this.showGroupControls = true,
    this.selectionMode = SelectionMode.none,
    this.editMode = EditMode.none,
    this.showSelectionIndicator = true,
    this.onSelectionChanged,
    this.onCellEdit,
    this.onRowEdit,
    this.paginationMode = PaginationMode.none,
    this.virtualScrollMode = VirtualScrollMode.none,
    this.virtualConfig,
    this.onServerDataRequest,
    this.showPaginationControls = true,
    this.currentView,
    this.onViewChanged,
    this.useOptimizedGrid = true,
    this.onAddNew,
    this.onDuplicate,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.onShare,
  });

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  late DataGridController _controller;
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _filterRowScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  // Removed unused variables

  String _searchText = '';
  String? _activeFilterField; // Track which filter is currently active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DataGridController();
    if (widget.source != null) {
      _controller.setSource(widget.source!);
    }

    // Set pagination and virtual scroll modes
    _controller.setPaginationMode(widget.paginationMode);
    _controller.setVirtualScrollMode(widget.virtualScrollMode,
        config: widget.virtualConfig);

    // Set server data callback if provided
    if (widget.onServerDataRequest != null) {
      _controller.setServerDataCallback(widget.onServerDataRequest!);
    }
  }

  @override
  void didUpdateWidget(DataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != oldWidget.source && widget.source != null) {
      _controller.setSource(widget.source!);
    }
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _filterRowScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (widget.loadingWidget != null &&
            _controller.source?.isLoading == true) {
          return widget.loadingWidget!;
        }

        if (_controller.source == null || !_controller.source!.hasData) {
          return widget.emptyWidget ?? _buildEmptyWidget();
        }

        // Filter visible columns
        final visibleColumns =
            widget.columns.where((col) => col.visible).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (widget.showFilterPanel || widget.showSearchPanel) _buildFilterButtons(),
              const SizedBox(height: 8),
              const Text(
                'Customers',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff666666),
                ),
              ),
              const SizedBox(height: 8),
              _buildSearchBar(),
              _buildHeader(visibleColumns),
              // if (widget.showSelectionIndicator && _controller.selectionState.hasSelection)
              //   DataGridSelectionIndicator(
              //     selectedCount: _controller.selectionState.selectedCount,
              //     totalCount: _controller.source?.rowCount ?? 0,
              //     onClearSelection: () => _controller.clearSelection(),
              //   ),
              if (widget.showFilterRow) _buildFilterRow(visibleColumns),
              Container(height: 2, width: double.infinity, color: Colors.grey.shade300,),
              Expanded(
                child: _buildBody(visibleColumns),
              ),
              if (widget.showPaginationControls &&
                  widget.paginationMode != PaginationMode.none &&
                  _controller.source?.hasData == true)
                DataGridPaginationControls(
                  pagination: _controller.paginationState,
                  onPaginationChanged: (pagination) {
                    if (pagination.currentPage !=
                        _controller.paginationState.currentPage) {
                      _controller.goToPage(pagination.currentPage);
                    }
                    if (pagination.pageSize !=
                        _controller.paginationState.pageSize) {
                      _controller.setPageSize(pagination.pageSize);
                    }
                  },
                  totalRows: _controller.source?.rowCount ?? 0,
                  isLoading: _controller.source?.isLoading ?? false,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Add New button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0XFFF7F7F7),
              border: Border.all(
                color: const Color(0xffE3E4E3),
                width: 1,
              ),
            ),
            child: _buildActionButton(
              icon: Icons.add,
              label: 'Add New',
              onTap: widget.onAddNew,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.home_outlined),
                suffixIcon: const Icon(Icons.favorite_border_outlined),
                fillColor: const Color(0xffF7F7F7),
                filled: true,
                hintText: 'Enter customer name or phone',
                hintStyle: const TextStyle(
                  color: Color(0xff999FA7),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xffE3E4E3),
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xffE3E4E3),
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  _controller.setGlobalSearch(_searchText);
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xffDDDDDD),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Duplicate button
                _buildActionButton(
                  icon: Icons.content_copy,
                  label: 'Duplicate',
                  onTap: widget.onDuplicate,
                ),
                const SizedBox(width: 8),
                // Edit button
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: 8),
                // Delete button
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: widget.onDelete,
                ),
                const SizedBox(width: 8),
                // Print button
                _buildActionButton(
                  icon: Icons.print,
                  label: 'Print',
                  onTap: widget.onPrint,
                ),
                const SizedBox(width: 8),
                // Share button
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: _showExportDialog,
                ),
                const SizedBox(width: 8),
                // Menu button
                _buildMenuButton(),
                const SizedBox(width: 8),
                // Navigation buttons
                // _buildNavButton(
                //   icon: Icons.table_chart,
                //   label: 'Standard',
                //   isSelected: widget.currentView == 'standard',
                //   onTap: () {
                //     widget.onViewChanged?.call('standard');
                //   },
                // ),
                if (widget.useOptimizedGrid) ...[
                  const SizedBox(width: 8),
                  _buildNavButton(
                    icon: Icons.speed,
                    label: 'Optimized',
                    isSelected: widget.currentView == 'optimized',
                    onTap: () {
                      widget.onViewChanged?.call('optimized');
                    },
                  ),
                ],
                // const SizedBox(width: 8),
                // _buildExportButton(
                //   icon: Icons.download,
                //   label: 'Export',
                //   onTap: () => _showExportDialog(),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xff4B4B4B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff4B4B4B),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      position: PopupMenuPosition.under,
      tooltip: '',
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            // Handle refresh
            break;
          case 'settings':
            // Handle settings
            break;
          case 'help':
            // Handle help
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 18),
              SizedBox(width: 8),
              Text('Refresh'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help, size: 18),
              SizedBox(width: 8),
              Text('Help'),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.menu),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCSV() {
    if (_controller.source == null) return;

    final data = _controller.getDisplayData();
    if (data.isEmpty) return;

    final columns = widget.columns.where((col) => col.visible).toList();
    final headers = columns.map((col) => col.caption).join(',');

    final rows = data.map((row) {
      return columns.map((col) {
        final value = row[col.dataField];
        return '"${value?.toString().replaceAll('"', '""') ?? ''}"';
      }).join(',');
    }).join('\n');

    final csvContent = '$headers\n$rows';

    // Create and download the CSV file
    _downloadFile('data_export.csv', csvContent, 'text/csv');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => DataGridExportDialog(
        columns: widget.columns,
        data: _controller.getDisplayData(),
        onExport: (format, template, columns, headers) {
          _handleExport(format, template, columns, headers);
        },
      ),
    );
  }

  void _handleExport(ExportFormat format, ExportTemplate template,
      List<String> columns, Map<String, String> headers) {
    print('Exporting: $format, $template, $columns, $headers');

    switch (format) {
      case ExportFormat.csv:
        _exportToCsv(columns, headers);
        break;
      case ExportFormat.excel:
        _exportToExcel(columns, headers);
        break;
      case ExportFormat.pdf:
        _exportToPdf(columns, headers);
        break;
    }
  }

  void _exportToCsv(List<String> columns, Map<String, String> headers) {
    final data = _controller.getDisplayData();
    final csvData = StringBuffer();

    // Add headers
    final headerRow = columns.map((col) => headers[col] ?? col).join(',');
    csvData.writeln(headerRow);

    // Add data rows
    for (final row in data) {
      final rowData =
          columns.map((col) => row[col]?.toString() ?? '').join(',');
      csvData.writeln(rowData);
    }

    _downloadFile('data_export.csv', csvData.toString(), 'text/csv');
  }

  void _exportToExcel(List<String> columns, Map<String, String> headers) {
    // For now, export as CSV with .xlsx extension
    // In a real implementation, you would use the excel package
    _exportToCsv(columns, headers);
  }

  void _exportToPdf(List<String> columns, Map<String, String> headers) async {
    final data = _controller.getDisplayData();

    // Create PDF document
    final pdf = pw.Document();

    // Add title page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Data Export Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString()}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 40),
            ],
          );
        },
      ),
    );

    // Add data table page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Table header
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  children: columns.map((col) {
                    return pw.Expanded(
                      child: pw.Text(
                        headers[col] ?? col,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Table data
              ...data.map((row) {
                return pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey),
                    ),
                  ),
                  child: pw.Row(
                    children: columns.map((col) {
                      final value = row[col];
                      String displayValue = '';

                      if (value != null) {
                        if (value is DateTime) {
                          displayValue = value.toString().split(' ')[0];
                        } else if (value is bool) {
                          displayValue = value ? 'Yes' : 'No';
                        } else {
                          displayValue = value.toString();
                        }
                      }

                      return pw.Expanded(
                        child: pw.Text(
                          displayValue,
                          textAlign: pw.TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    // Generate PDF bytes
    final pdfBytes = await pdf.save();

    // Download the PDF
    _downloadPdfFile('data_export.pdf', pdfBytes);
  }

  void _downloadFile(String filename, String content, String mimeType) {
    // Create a blob URL and trigger download
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void _downloadPdfFile(String filename, Uint8List pdfBytes) {
    // Create a blob URL and trigger download for PDF
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Widget _buildHeader(List<DataGridColumn> columns) {
    return Container(
      height: widget.config.headerHeight,
      decoration: BoxDecoration(
        color: Colors.white, // Set header background to white
        border: widget.config.showBorders
            ? Border(
                bottom: BorderSide(
                  color: widget.config.borderColor,
                  width: widget.config.borderWidth,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          if (widget.selectionMode == SelectionMode.multiple)
            SizedBox(
              width: 50,
              child: Container(
                decoration: widget.config.showBorders
                    ? BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: widget.config.borderColor,
                            width: widget.config.borderWidth,
                          ),
                        ),
                      )
                    : null,
                child: DataGridSelectAllCheckbox(
                  isSelected: _controller.selectionState.isSelectAll,
                  isIndeterminate:
                      _controller.selectionState.selectedCount > 0 &&
                          _controller.selectionState.selectedCount <
                              (_controller.source?.rowCount ?? 0),
                  onChanged: (value) {
                    if (value == true) {
                      _controller.selectAll();
                    } else {
                      _controller.clearSelection();
                    }
                  },
                  config: widget.config,
                ),
              ),
            ),
          ...columns.map((column) {
            final currentSort = _getCurrentSortForColumn(column.dataField);
            final sortPriority = _getSortPriorityForColumn(column.dataField);
            return Expanded(
              flex: column.width?.toInt() ?? 1,
              child: Container(
                decoration: widget.config.showBorders
                    ? BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: widget.config.borderColor,
                            width: widget.config.borderWidth,
                          ),
                        ),
                      )
                    : null,
                child: GestureDetector(
                  onTap: column.sortable ? () => _onHeaderTap(column) : null,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: column.buildHeader(context),
                      ),
                      // if (widget.showSortControls && column.sortable)
                      //   Positioned(
                      //     right: column.filterable ? 24 : 4,
                      //     top: 4,
                      //     child: DataGridSortControls(
                      //       field: column.dataField,
                      //       currentSort: currentSort,
                      //       priority: sortPriority,
                      //       onSort: () => _onSortColumn(column),
                      //       onRemoveSort: () => _onRemoveSort(column.dataField),
                      //       showPriority: _controller.sortState.sorts.length > 1,
                      //     ),
                      //   ),
                      // if (column.filterable)
                      //   Positioned(
                      //     right: 4,
                      //     top: 4,
                      //     child: GestureDetector(
                      //       onTap: () => _showColumnFilter(column),
                      //       child: Container(
                      //         padding: const EdgeInsets.all(2),
                      //         decoration: BoxDecoration(
                      //           color: _hasColumnFilter(column.dataField)
                      //               ? Colors.blue
                      //               : Colors.grey,
                      //           borderRadius: BorderRadius.circular(4),
                      //         ),
                      //         child: const Icon(
                      //           Icons.filter_list,
                      //           size: 12,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterRow(List<DataGridColumn> columns) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white, // Set filter row background to white
        border: widget.config.showBorders
            ? Border(
                bottom: BorderSide(
                  color: widget.config.borderColor,
                  width: widget.config.borderWidth,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          if (widget.selectionMode == SelectionMode.multiple)
            SizedBox(
              width: 50,
              child: Container(
                decoration: widget.config.showBorders
                    ? BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: widget.config.borderColor,
                            width: widget.config.borderWidth,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ...columns.map((column) {
            return Expanded(
              flex: column.width?.toInt() ?? 1,
              child: Container(
                decoration: widget.config.showBorders
                    ? BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: widget.config.borderColor,
                            width: widget.config.borderWidth,
                          ),
                        ),
                      )
                    : null,
                child: _buildFilterCell(column),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterCell(DataGridColumn column) {
    if (!column.filterable) {
      return const SizedBox.shrink();
    }

    final hasFilter =
        _controller.filterState.columnFilters[column.dataField]?.isNotEmpty ??
            false;
    final isActive = _activeFilterField == column.dataField;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Center(
        child: GestureDetector(
          onTap: () => _showFilterDialog(column),
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasFilter ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                "assets/images/filter_grid.svg",
              )
              // Icon(
              //   Icons.filter_list,
              //   size: 16,
              //   color: hasFilter ? Colors.white : Colors.grey[600],
              // ),
              ),
        ),
      ),
    );
  }

  void _showFilterDialog(DataGridColumn column) {
    final currentFilters =
        _controller.filterState.columnFilters[column.dataField] ?? [];
    String filterValue = '';

    // Get current filter value if exists
    if (currentFilters.isNotEmpty) {
      final firstFilter = currentFilters.first;
      if (firstFilter.type == FilterType.contains ||
          firstFilter.type == FilterType.equals ||
          firstFilter.type == FilterType.startsWith ||
          firstFilter.type == FilterType.endsWith) {
        filterValue = firstFilter.value?.toString() ?? '';
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter ${column.caption}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter filter value...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController(text: filterValue),
                onChanged: (value) {
                  filterValue = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Clear filter for this column
                      final currentFilters = _controller
                              .filterState.columnFilters[column.dataField] ??
                          [];
                      for (final filter in currentFilters) {
                        _controller.removeColumnFilter(
                            column.dataField, filter);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (filterValue.isNotEmpty) {
                        final filter = DataGridFilter.text(
                          field: column.dataField,
                          type: FilterType.contains,
                          value: filterValue,
                        );
                        _controller.addColumnFilter(column.dataField, filter);
                      } else {
                        // Clear filter for this column
                        final currentFilters = _controller
                                .filterState.columnFilters[column.dataField] ??
                            [];
                        for (final filter in currentFilters) {
                          _controller.removeColumnFilter(
                              column.dataField, filter);
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<DataGridColumn> columns) {
    final source = _controller.source;
    if (source == null) return const SizedBox.shrink();

    // Show loading indicator if pagination is loading
    if (_controller.paginationState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    // Show skeleton loader for initial load
    if (source.isLoading && source.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    // Handle virtual scrolling
    if (widget.virtualScrollMode == VirtualScrollMode.basic) {
      return DataGridVirtualScroll(
        data: _controller.getDisplayData(),
        columns: columns,
        config: widget.config,
        virtualConfig: _controller.virtualConfig,
        onRowTap: (index) => _onRowTap(index),
        onCellTap: widget.onCellTap,
        onCellEdit: widget.onCellEdit,
        selectionMode: widget.selectionMode,
        editMode: widget.editMode,
        onRowSelect: (rowIndex) {
          if (widget.selectionMode == SelectionMode.single) {
            _controller.clearSelection();
            _controller.selectRow(rowIndex);
          } else if (widget.selectionMode == SelectionMode.multiple) {
            _controller.toggleRowSelection(rowIndex);
          }
        },
        isRowSelected: (index) => _controller.isRowSelected(index),
        isEditingRow: (index) => _controller.isEditingRow(index),
      );
    }

    // Handle infinite scrolling
    if (widget.virtualScrollMode == VirtualScrollMode.infinite) {
      return DataGridInfiniteScroll(
        data: _controller.getDisplayData(),
        columns: columns,
        config: widget.config,
        hasMore: _controller.paginationState.hasNextPage,
        isLoading: _controller.paginationState.isLoading,
        onLoadMore: () => _controller.nextPage(),
        onRowTap: (index) => _onRowTap(index),
        onCellTap: widget.onCellTap,
        onCellEdit: widget.onCellEdit,
        selectionMode: widget.selectionMode,
        editMode: widget.editMode,
        onRowSelect: (rowIndex) {
          if (widget.selectionMode == SelectionMode.single) {
            _controller.clearSelection();
            _controller.selectRow(rowIndex);
          } else if (widget.selectionMode == SelectionMode.multiple) {
            _controller.toggleRowSelection(rowIndex);
          }
        },
        isRowSelected: (index) => _controller.isRowSelected(index),
        isEditingRow: (index) => _controller.isEditingRow(index),
      );
    }

    // Default scrolling - wrap in both horizontal and vertical scroll
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            controller: _bodyScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _bodyScrollController,
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: double.infinity,
                child: _buildBodyContent(columns),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyContent(List<DataGridColumn> columns) {
    // Check if we have groups
    if (_controller.sortState.groups.isNotEmpty) {
      return _buildGroupedBody(columns);
    } else {
      return _buildNormalBody(columns);
    }
  }

  Widget _buildNormalBody(List<DataGridColumn> columns) {
    final displayData = _controller.getDisplayData();

    if (displayData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data to display'),
        ),
      );
    }

    return Column(
      children: displayData.asMap().entries.map((entry) {
        final index = entry.key;
        final rowData = entry.value;
        final isSelected = _controller.isRowSelected(index);
        final isAlternateRow = index % 2 == 1;

        return DataGridRow(
          rowData: rowData,
          columns: columns,
          config: widget.config,
          rowIndex: index,
          isSelected: isSelected,
          isAlternateRow: isAlternateRow,
          onRowTap: () => _onRowTap(index),
          onCellTap: widget.onCellTap,
          selectionMode: widget.selectionMode,
          editMode: widget.editMode,
          isEditing: _controller.isEditingRow(index),
          onRowSelect: (rowIndex) {
            if (widget.selectionMode == SelectionMode.single) {
              _controller.clearSelection();
              _controller.selectRow(rowIndex);
            } else if (widget.selectionMode == SelectionMode.multiple) {
              _controller.toggleRowSelection(rowIndex);
            }
          },
          onCellEdit: widget.onCellEdit,
        );
      }).toList(),
    );
  }

  Widget _buildGroupedBody(List<DataGridColumn> columns) {
    final groupedData = _controller.getGroupedData();
    if (groupedData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data to display'),
        ),
      );
    }
    return Column(
      children: groupedData.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final item = entry.value;

        if (item is DataGridGroupRow) {
          return DataGridGroupHeader(
            groupRow: item,
            isExpanded: item.group.isExpanded,
            onToggle: () => _toggleGroupExpanded(item.group.field),
          );
        } else if (item is Map<String, dynamic>) {
          final rowIndex = _controller.getDisplayData().indexOf(item);
          final isSelected = _controller.isRowSelected(rowIndex);
          final isAlternateRow = rowIndex % 2 == 1;

          return DataGridRow(
            rowData: item,
            columns: columns,
            config: widget.config,
            rowIndex: rowIndex,
            isSelected: isSelected,
            isAlternateRow: isAlternateRow,
            onRowTap: () => _onRowTap(rowIndex),
            onCellTap: widget.onCellTap,
            selectionMode: widget.selectionMode,
            editMode: widget.editMode,
            isEditing: _controller.isEditingRow(rowIndex),
            onRowSelect: (rowIndex) {
              if (widget.selectionMode == SelectionMode.single) {
                _controller.clearSelection();
                _controller.selectRow(rowIndex);
              } else if (widget.selectionMode == SelectionMode.multiple) {
                _controller.toggleRowSelection(rowIndex);
              }
            },
            onCellEdit: widget.onCellEdit,
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (widget.showFilterPanel)
            ElevatedButton.icon(
              onPressed: _showFilterPanel,
              icon: const Icon(Icons.filter_list),
              label: const Text('Advanced Filter'),
            ),
          const SizedBox(width: 12),
          if (widget.showSearchPanel)
            ElevatedButton.icon(
              onPressed: _showSearchPanel,
              icon: const Icon(Icons.search),
              label: const Text('Global Search'),
            ),
          const SizedBox(width: 12),
          if (widget.showSortControls)
            ElevatedButton.icon(
              onPressed: _showSortDialog,
              icon: const Icon(Icons.sort),
              label: const Text('Sort'),
            ),
          const SizedBox(width: 12),
          if (widget.showGroupControls)
            ElevatedButton.icon(
              onPressed: _showGroupDialog,
              icon: const Icon(Icons.group_work),
              label: const Text('Group'),
            ),
          const Spacer(),
          if (widget.showSortControls)
            DataGridSortPriorityIndicator(
              activeSorts: _controller.sortState.sorts
                  .where((s) => s.order != SortOrder.none)
                  .toList(),
              onTap: _showSortDialog,
            ),
          const SizedBox(width: 12),
          if (widget.showGroupControls)
            DataGridGroupControls(
              groups: _controller.sortState.groups,
              onConfigureGroups: _showGroupDialog,
              onClearGroups: _clearGroups,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHeaderTap(DataGridColumn column) {
    final columnIndex =
        widget.columns.indexWhere((c) => c.dataField == column.dataField);
    if (columnIndex != -1) {
      _controller.sortByColumn(columnIndex);
      if (widget.onHeaderTap != null) {
        widget.onHeaderTap!(columnIndex);
      }
    }
  }

  void _onRowTap(int rowIndex) {
    if (widget.config.selectable) {
      _controller.toggleRowSelection(rowIndex);
    }
    if (widget.onRowTap != null) {
      widget.onRowTap!();
    }
  }

  void _showColumnFilter(DataGridColumn column) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 500,
          ),
          child: DataGridFilterWidgetFactory.createFilterWidget(
            field: column.dataField,
            dataType: column.dataType,
            onFilterChanged: (filter) {
              _controller.addColumnFilter(column.dataField, filter);
              Navigator.of(context).pop();
            },
            onFilterCleared: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  bool _hasColumnFilter(String field) {
    return _controller.filterState.columnFilters[field]?.isNotEmpty ?? false;
  }

  void _showFilterPanel() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 700,
          constraints: const BoxConstraints(
            minWidth: 600,
            maxWidth: 900,
          ),
          child: DataGridFilterPanel(
            columns: widget.columns,
            filterState: _controller.filterState,
            onFilterChanged: (filterState) {
              _controller.updateFilterState(filterState);
            },
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showSearchPanel() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(
            minWidth: 500,
            maxWidth: 800,
          ),
          child: DataGridSearchPanel(
            columns: widget.columns,
            filterState: _controller.filterState,
            onFilterChanged: (filterState) {
              _controller.updateFilterState(filterState);
            },
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  // Helper methods for sorting
  SortOrder _getCurrentSortForColumn(String field) {
    final sort = _controller.sortState.sorts.firstWhere(
      (s) => s.field == field,
      orElse: () =>
          DataGridSort(field: field, order: SortOrder.none, priority: 0),
    );
    return sort.order;
  }

  int? _getSortPriorityForColumn(String field) {
    final sort = _controller.sortState.sorts.firstWhere(
      (s) => s.field == field && s.order != SortOrder.none,
      orElse: () =>
          DataGridSort(field: field, order: SortOrder.none, priority: -1),
    );
    return sort.priority >= 0 ? sort.priority : null;
  }

  void _onSortColumn(DataGridColumn column) {
    final currentSort = _getCurrentSortForColumn(column.dataField);
    final newSort = DataGridSort(
      field: column.dataField,
      order: currentSort == SortOrder.none
          ? SortOrder.ascending
          : currentSort == SortOrder.ascending
              ? SortOrder.descending
              : SortOrder.none,
      priority: _controller.sortState.sorts.length,
    );
    _controller.addSort(newSort);
  }

  void _onRemoveSort(String field) {
    _controller.removeSort(field);
  }

  void _showSortDialog() {
    final availableFields = widget.columns.map((col) => col.dataField).toList();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          constraints: const BoxConstraints(
            minWidth: 400,
            maxWidth: 500,
          ),
          child: DataGridSortDialog(
            currentSorts: _controller.sortState.sorts,
            availableFields: availableFields,
          ),
        ),
      ),
    ).then((sorts) {
      if (sorts != null) {
        // Update sorts
        _controller.clearSorts();
        for (final sort in sorts) {
          if (sort.order != SortOrder.none) {
            _controller.addSort(sort);
          }
        }
      }
    });
  }

  // Helper methods for grouping
  void _toggleGroupExpanded(String field) {
    final group = _controller.sortState.groups.firstWhere(
      (g) => g.field == field,
      orElse: () => DataGridGroup(field: field),
    );
    _controller.updateGroup(group.toggleExpanded());
  }

  void _showGroupDialog() {
    final availableFields = widget.columns.map((col) => col.dataField).toList();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          constraints: const BoxConstraints(
            minWidth: 400,
            maxWidth: 500,
          ),
          child: DataGridGroupDialog(
            currentGroups: _controller.sortState.groups,
            availableFields: availableFields,
          ),
        ),
      ),
    ).then((groups) {
      if (groups != null) {
        // Update groups
        _controller.clearGroups();
        for (final group in groups) {
          _controller.addGroup(group);
        }
      }
    });
  }

  void _clearGroups() {
    _controller.clearGroups();
  }
}
