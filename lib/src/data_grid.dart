import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dexef_datagrid/src/style/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
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
import 'widgets/default_text.dart';
import 'style/style_size.dart';

// Conditional imports for web-specific functionality
import 'export/data_grid_export_web.dart'
    if (dart.library.io) 'export/data_grid_export_mobile.dart';

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
  final VoidCallback? onRefresh;
  /// Whether to show an "add new row" button at the end of the data rows.
  final bool showAddNewRow;
  /// Whether to show a summary row with totals for numeric columns.
  final bool showSummaryRow;
  // Optional: جلب كل البيانات من API عند التصدير/الطباعة (بدون الاعتماد على الصفحة الحالية)
  final Future<List<Map<String, dynamic>>> Function()? fetchAllDataForExport;

  const DataGrid({
    super.key,
    this.source,
    required this.columns,
    this.config = const DataGridConfig(
      rowHeight: 40,
      headerHeight: 56,
      minColumnWidth: 120,
      showBorders: false,
      showHorizontalBorders: true,
      showAlternateRows: true,
      alternateRowBackgroundColor: Color(0xFFF5F5F5),
    ),
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
    this.onRefresh,
    this.showAddNewRow = false,
    this.showSummaryRow = false,
    this.fetchAllDataForExport,
  });

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  late DataGridController _controller;
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _filterRowScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  // Removed unused variables

  String _searchText = '';
  bool _autoEditNewRow = false;
  bool _isAddingNewRow = false;
  Map<String, dynamic> _newRowData = {};
  int _lastKnownPage = 1;
  int _extraRowsOnPage = 0;
  int _extraRowsAddedOnPage = -1;
  bool _justAddedRow = false;
  int _visibleRowCount = 30;
  bool _isLoadingMoreRows = false;

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

    _bodyScrollController.addListener(_onBodyScroll);
  }

  void _onBodyScroll() {
    if (_isLoadingMoreRows) return;
    final maxScroll = _bodyScrollController.position.maxScrollExtent;
    final currentScroll = _bodyScrollController.position.pixels;
    // When near the bottom, load more rows
    if (currentScroll >= maxScroll - 100) {
      final totalRows = _controller.getDisplayData().length;
      if (_visibleRowCount < totalRows) {
        setState(() {
          _isLoadingMoreRows = true;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _visibleRowCount = (_visibleRowCount + 30).clamp(0, totalRows);
              _isLoadingMoreRows = false;
            });
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(DataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != oldWidget.source && widget.source != null) {
      // Reset extra rows only on real refresh, not when we just added a row
      if (!_justAddedRow) {
        _extraRowsOnPage = 0;
        _extraRowsAddedOnPage = -1;
        _visibleRowCount = 30;
      }
      _justAddedRow = false;
      // Use _lastKnownPage saved from the previous build frame
      final pageToRestore = _lastKnownPage;
      _controller.setSource(widget.source!);
      // Restore the page the user was on
      if (widget.paginationMode == PaginationMode.client) {
        final maxPage = _controller.paginationState.totalPages;
        _controller.goToPage(pageToRestore.clamp(1, maxPage));
      }
    }
  }

  @override
  void dispose() {
    _bodyScrollController.removeListener(_onBodyScroll);
    _headerScrollController.dispose();
    _filterRowScrollController.dispose();
    _bodyScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        // Save current page so didUpdateWidget can restore it
        _lastKnownPage = _controller.paginationState.currentPage;

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
              
              DefaultText(
                text: 'Customers',
                isTextTheme: true,
                themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xff666666),
                      fontSize:
                          AppFontSize().setFontSize(context, webFontSize: 18),
                      fontFamily: 'DexPro',
                    ),
              ),
              _buildSearchBar(onRefresh: widget.onRefresh),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final checkboxExtra = widget.selectionMode == SelectionMode.multiple ? 54.0 : 0.0;
                    final gapCount = visibleColumns.length - 1 + (widget.selectionMode == SelectionMode.multiple ? 1 : 0);
                    final totalGaps = gapCount * 4.0;
                    final totalColumnWidth = visibleColumns.fold<double>(
                      0, (sum, col) => sum + (col.width ?? widget.config.minColumnWidth));
                    final totalMinWidth = totalColumnWidth + checkboxExtra + totalGaps + 8;
                    final contentWidth = math.max(availableWidth, totalMinWidth);

                    Widget gridContent = SizedBox(
                      width: contentWidth,
                      child: Column(
                        children: [
                          _buildHeader(visibleColumns),
                          const SizedBox(height: 8,),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                  Expanded(child: _buildBody(visibleColumns)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (contentWidth > availableWidth) {
                      return Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: gridContent,
                        ),
                      );
                    }

                    return gridContent;
                  },
                ),
              ),
              if (widget.showSummaryRow && _controller.source?.hasData == true)
                _buildSummaryRow(visibleColumns),
              if (widget.showPaginationControls &&
                  widget.paginationMode != PaginationMode.none &&
                  _controller.source?.hasData == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DataGridPaginationControls(
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
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(List<DataGridColumn> visibleColumns) {
    final source = _controller.source;
    if (source == null) return const SizedBox.shrink();

    // Use filtered/searched data for summary calculation
    final displayedData = _controller.getAllDisplayData(onlyVisibleFields: false);

    // Calculate totals for numeric columns
    final Map<String, double> totals = {};
    for (final col in visibleColumns) {
      if (col.dataType == DataType.number) {
        double sum = 0;
        for (final row in displayedData) {
          final value = row[col.dataField];
          if (value is num) {
            sum += value.toDouble();
          }
        }
        totals[col.dataField] = sum;
      }
    }

    if (totals.isEmpty) return const SizedBox.shrink();

    final checkboxExtra = widget.selectionMode == SelectionMode.multiple ? 54.0 : 0.0;

    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4 , vertical: 8),
      child: Row(
        children: [
          if (widget.selectionMode == SelectionMode.multiple) ...[
            SizedBox(width: 50),
            const SizedBox(width: 4),
          ],
          ...visibleColumns.asMap().entries.expand((entry) {
            final index = entry.key;
            final col = entry.value;
            final total = totals[col.dataField];
            return [
              if (index > 0)
                const SizedBox(width: 4),
              Expanded(
                flex: col.width?.toInt() ?? 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: total != null
                      ? Text(
                          total == total.roundToDouble()
                              ? total.toInt().toString()
                              : total.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff464646),
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar({
    required VoidCallback? onRefresh,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      child: Row(
        children: [
          // Add New button
          Container(
            width: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0XFFF7F7F7),
              border: Border.all(
                color: const Color(0xffE3E4E3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: _buildActionButton(
              icon: Icons.add,
              label: 'Add New',
              onTap: widget.onAddNew,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 38,
              child: Theme(
                data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme()),
                child: TextField(
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                      height: 1.0, fontSize: 12), // stable line height
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true, // ignore default paddings
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12), // control height
                    prefixIcon: const Icon(Icons.search, size: 16),
                    // prefixIconConstraints: const BoxConstraints(
                    //   minWidth: 36,
                    //   minHeight: 44,
                    //   maxHeight: 54,
                    // ),
                    filled: true,
                    fillColor: const Color(0xffF7F7F7),
                    hintText: 'Enter customer name or phone',
                    hintStyle:
                        const TextStyle(color: Color(0xff999FA7), fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xffE3E4E3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xffE3E4E3)),
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
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(12),
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
                    isActive: false),
                const SizedBox(width: 8),
                // Edit button
                _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    onTap: widget.onEdit,
                    isActive: false),
                const SizedBox(width: 8),
                // Delete button
                _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    onTap: widget.onDelete,
                    isActive: true),
                const SizedBox(width: 8),
                // Print button
                _buildActionButton(
                    icon: Icons.print,
                    label: 'Print',
                    onTap: widget.onPrint ?? _printAllRows,
                    isActive: false),
                const SizedBox(width: 8),
                // Share button
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: _showExportDialog,
                ),
                const SizedBox(width: 8),
                // Menu button
                _buildMenuButton(onRefresh: onRefresh),
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
            DefaultText(
              text: label,
              isTextTheme: true,
              themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
    bool isActive = true,
  }) {
    return Tooltip(
      message: label,
      child: MouseRegion(
        cursor:
            isActive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
              DefaultText(
                text: label,
                isTextTheme: true,
                themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xff4B4B4B),
                      fontSize:
                          AppFontSize().setFontSize(context, webFontSize: 12),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMenuButton({
    required VoidCallback? onRefresh,
  }) {
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
            widget.onRefresh!();
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
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 18),
              const SizedBox(width: 8),
              DefaultText(
                text: 'Refresh',
                fontColor: Colors.black,
              ),
              // Text('Refresh'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 18),
              const SizedBox(width: 8),
              DefaultText(
                text: 'Settings',
                fontColor: Colors.black,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              const Icon(Icons.help, size: 18),
              const SizedBox(width: 8),
              DefaultText(
                text: 'Help',
                fontColor: Colors.black,
              ),
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
            DefaultText(
              text: label,
              isTextTheme: true,
              themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize:
                        AppFontSize().setFontSize(context, webFontSize: 12),
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
    // استخدم كل البيانات الكاملة للتصدير (ليس الصفحة الحالية)
    // إذا توفّرت دالة fetchAllDataForExport سيتم استخدامها لجلب كل الصفحات من الAPI
    final List<Map<String, dynamic>> data = (() {
      // ملاحظة: هذا الاستدعاء متزامن هنا، لذا سنستخدم النسخة المتوفرة محلياً
      // مسار الجلب الكامل موجود في _exportToExcel/_exportToPdf (غير متزامن)
      // هنا نستخدم البيانات الكاملة المتاحة بعد الفلترة/الفرز بدون تقسيم صفحات UI
      return _controller.getAllDisplayData(onlyVisibleFields: true);
    })();
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

  void _exportToExcel(List<String> columns, Map<String, String> headers) async {
    try {
      List<Map<String, dynamic>> data;
      if (widget.fetchAllDataForExport != null) {
        try {
          data = await widget.fetchAllDataForExport!();
        } catch (_) {
          data = _controller.getAllDisplayData(onlyVisibleFields: true);
        }
      } else {
        data = _controller.getAllDisplayData(onlyVisibleFields: true);
      }

      // Create Excel workbook using the excel package
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Add headers
      final headerRow = columns.map((col) => headers[col] ?? col).toList();
      sheet.appendRow(headerRow);

      // Add data rows
      for (final row in data) {
        final rowData = columns.map((col) {
          final value = row[col];
          if (value == null) return '';
          if (value is DateTime) {
            return value.toString().split(' ')[0]; // Format date as YYYY-MM-DD
          }
          return value.toString();
        }).toList();
        sheet.appendRow(rowData);
      }

      // Save Excel file as bytes
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        _downloadExcelFile('data_export.xlsx', Uint8List.fromList(excelBytes));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel export completed! Rows: ${data.length}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to generate Excel file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToPdf(List<String> columns, Map<String, String> headers) async {
    // نحافظ على نفس تصميم الـ PDF تماماً
    // استبدال مصدر البيانات ليكون القائمة الكاملة (من API) بدلاً من الصفحة الحالية
    List<Map<String, dynamic>> data;
    if (widget.fetchAllDataForExport != null) {
      try {
        data = await widget.fetchAllDataForExport!();
      } catch (e) {
        // في حال فشل الجلب الكامل، نfallback لبيانات الجدول المتاحة بدون تقسيم صفحات UI
        data = _controller.getAllDisplayData(onlyVisibleFields: true);
      }
    } else {
      // في حالة عدم توفير دالة جلب كامل من التطبيق، نستخدم جميع البيانات المتاحة محلياً
      data = _controller.getAllDisplayData(onlyVisibleFields: true);
    }

    // Create PDF document (نفس التصميم)
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
                  fontSize: 20,
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

    // Add data table pages using MultiPage (نفس عناصر التصميم لكن مع صفحات متعددة تلقائياً)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            // Table header (كما هو)
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
            // Table data (القائمة الكاملة)
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
          ];
        },
      ),
    );

    // Generate PDF bytes
    final pdfBytes = await pdf.save();

    // Download the PDF
    _downloadPdfFile('data_export.pdf', pdfBytes);
  }

  void _downloadFile(String filename, String content, String mimeType) {
    // Use platform-specific export
    final bytes = utf8.encode(content);
    DataGridExportPlatform.downloadFile(filename, bytes, mimeType);
  }

  void _downloadPdfFile(String filename, Uint8List pdfBytes) {
    // Use platform-specific export
    DataGridExportPlatform.downloadPdfFile(filename, pdfBytes);
  }

  void _downloadExcelFile(String filename, Uint8List excelBytes) {
    // Use platform-specific export with correct MIME type for Excel
    DataGridExportPlatform.downloadFile(filename, excelBytes,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Widget _buildHeader(List<DataGridColumn> columns) {
    return SizedBox(
      height: widget.config.headerHeight,
      child: Row(
        children: [
          if (widget.selectionMode == SelectionMode.multiple)
            const SizedBox(width: 54),
          ...columns.asMap().entries.expand((entry) {
            final index = entry.key;
            final column = entry.value;
            return [
              if (index > 0)
                const SizedBox(width: 4),
              Expanded(
                flex: column.width?.toInt() ?? 1,
                child: GestureDetector(
                  onTap: column.sortable ? () => _onHeaderTap(column) : null,
                  child: Align(
                    alignment: Alignment.center,
                    child: column.buildHeader(context),
                  ),
                ),
              ),
            ];
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
    // final isActive = _activeFilterField == column.dataField;

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
              DefaultText(
                text: 'Filter ${column.caption}',
                isTextTheme: true,
                themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize:
                          AppFontSize().setFontSize(context, webFontSize: 14),
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
                    child: DefaultText(
                      text: 'Clear',
                      fontColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: DefaultText(
                      text: 'Cancel',
                      fontColor: Colors.black,
                    ),
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
                    child: DefaultText(
                      text: 'Apply',
                      fontColor: Colors.black,
                    ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            DefaultText(
              text: 'Loading data...',
              fontColor: Colors.black,
            ),
          ],
        ),
      );
    }

    // Show skeleton loader for initial load
    if (source.isLoading && source.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            DefaultText(
              text: 'Loading data...',
              fontColor: Colors.black,
            ),
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

  Widget _buildShimmerRows(List<DataGridColumn> columns, int count) {
    return _ShimmerEffect(
      config: widget.config,
      columns: columns,
      rowCount: count,
      selectionMode: widget.selectionMode,
    );
  }

  Widget _buildNormalBody(List<DataGridColumn> columns) {
    final displayData = _controller.getDisplayData();

    if (displayData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultText(
            text: 'No data to display',
            fontColor: Colors.black,
          ),
        ),
      );
    }

    final shouldAutoEdit = _autoEditNewRow;
    if (shouldAutoEdit) {
      _autoEditNewRow = false;
    }

    // Compute pagination offset so indices map to the full filtered data
    final paginationOffset = widget.paginationMode == PaginationMode.client
        ? _controller.paginationState.startIndex
        : 0;

    // Limit rows for infinite scroll loading
    final visibleData = widget.paginationMode == PaginationMode.none
        ? displayData.take(_visibleRowCount).toList()
        : displayData;

    final rows = visibleData.asMap().entries.map<Widget>((entry) {
        final pageIndex = entry.key;
        final rowData = entry.value;
        final filteredIndex = paginationOffset + pageIndex;
        final isSelected = _controller.isRowSelected(filteredIndex);
        final isAlternateRow = pageIndex % 2 == 1;
        final isLastRow = pageIndex == visibleData.length - 1;

        return DataGridRow(
          rowData: rowData,
          columns: columns,
          config: widget.config,
          rowIndex: filteredIndex,
          isSelected: isSelected,
          isAlternateRow: isAlternateRow,
          onRowTap: () => _onRowTap(filteredIndex),
          onCellTap: widget.onCellTap,
          selectionMode: widget.selectionMode,
          editMode: widget.editMode,
          isEditing: _controller.isEditingRow(filteredIndex),
          onRowSelect: (rowIndex) {
            if (widget.selectionMode == SelectionMode.single) {
              _controller.clearSelection();
            }
            _controller.toggleRowSelection(rowIndex);
          },
          onCellEdit: widget.onCellEdit != null ? (rowIndex, field, value) {
            // Convert filtered index to source data index
            final sourceIndex = _controller.getSourceDataIndex(rowIndex);
            widget.onCellEdit!(sourceIndex, field, value);
          } : null,
          autoEditFirstCell: shouldAutoEdit && isLastRow,
        );
      }).toList();

    // Show extra rows added on this page (beyond normal page size)
    final currentPage = _controller.paginationState.currentPage;
    if (_extraRowsOnPage > 0 && _extraRowsAddedOnPage == currentPage) {
      final allData = _controller.getAllDisplayData(onlyVisibleFields: false);
      final pageEnd = paginationOffset + displayData.length;
      for (int i = 0; i < _extraRowsOnPage; i++) {
        final extraIdx = pageEnd + i;
        if (extraIdx < allData.length) {
          final rowData = allData[extraIdx];
          final isAlternateRow = (displayData.length + i) % 2 == 1;
          rows.add(DataGridRow(
            rowData: rowData,
            columns: columns,
            config: widget.config,
            rowIndex: extraIdx,
            isAlternateRow: isAlternateRow,
            onRowTap: () => _onRowTap(extraIdx),
            onCellTap: widget.onCellTap,
            selectionMode: widget.selectionMode,
            editMode: widget.editMode,
            isEditing: _controller.isEditingRow(extraIdx),
            onRowSelect: (rowIndex) {
              if (widget.selectionMode == SelectionMode.single) {
                _controller.clearSelection();
              }
              _controller.toggleRowSelection(rowIndex);
            },
            onCellEdit: widget.onCellEdit != null ? (rowIndex, field, value) {
              final sourceIndex = _controller.getSourceDataIndex(rowIndex);
              widget.onCellEdit!(sourceIndex, field, value);
            } : null,
          ));
        }
      }
    } else if (_extraRowsOnPage > 0 && _extraRowsAddedOnPage != currentPage) {
      // Navigated to a different page - clear extra rows
      _extraRowsOnPage = 0;
      _extraRowsAddedOnPage = -1;
    }

    // Show shimmer loading rows when loading more data
    final hasMoreToLoad = widget.paginationMode == PaginationMode.none &&
        _visibleRowCount < displayData.length;
    if (_isLoadingMoreRows && widget.paginationMode == PaginationMode.none) {
      rows.add(_buildShimmerRows(columns, 5));
    }

    // Only show add row button when not loading more rows
    if (widget.showAddNewRow && widget.onAddNew != null && !hasMoreToLoad && !_isLoadingMoreRows) {
      if (_isAddingNewRow) {
        rows.add(_buildNewRowEditor(columns));
      } else {
        rows.add(_buildAddNewRowButton());
      }
    }

    return Column(children: rows);
  }

  Widget _buildAddNewRowButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isAddingNewRow = true;
          _newRowData = {};
          for (final col in widget.columns.where((c) => c.visible)) {
            switch (col.dataType) {
              case DataType.boolean:
                _newRowData[col.dataField] = false;
              case DataType.number:
                _newRowData[col.dataField] = 0;
              case DataType.date:
                _newRowData[col.dataField] = DateTime.now();
              default:
                _newRowData[col.dataField] = '';
            }
          }
        });
      },
      child: Container(
        height: widget.config.rowHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: widget.config.showHorizontalBorders
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            if (widget.selectionMode == SelectionMode.multiple) ...[
              Container(
                width: 6,
                height: widget.config.rowHeight,
                color: const Color(0xff2196F3),
              ),
              SizedBox(
                width: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: widget.config.showBorders
                          ? BorderSide(
                              color: widget.config.borderColor,
                              width: widget.config.borderWidth,
                            )
                          : BorderSide.none,
                      bottom: BorderSide(
                        color: widget.config.borderColor,
                        width: widget.config.borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Click here to add a new row',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRowEditor(List<DataGridColumn> columns) {
    return DataGridRow(
      rowData: _newRowData,
      columns: columns,
      config: widget.config,
      rowIndex: -1,
      editMode: widget.editMode != EditMode.none ? widget.editMode : EditMode.cell,
      autoEditFirstCell: true,
      selectionMode: widget.selectionMode,
      showSelectionCheckbox: false,
      onCellEdit: (rowIndex, field, value) {
        // Accumulate values while navigating between cells
        _newRowData[field] = value;
      },
      onRowEditComplete: () {
        // Save current page before anything changes (onAddNew resets pagination)
        final pageToKeep = _controller.paginationState.currentPage;

        // Check if any meaningful data was entered
        bool hasData = false;
        for (final col in columns) {
          final v = _newRowData[col.dataField];
          if (v is String && v.trim().isNotEmpty) { hasData = true; break; }
          if (v is num && v != 0) { hasData = true; break; }
        }

        if (hasData) {
          // Calculate where to insert: account for already-added extra rows
          final insertIndex = widget.paginationMode == PaginationMode.client
              ? _controller.paginationState.startIndex + _controller.getDisplayData().length + _extraRowsOnPage
              : _controller.source?.data.length ?? 0;

          // Flag so didUpdateWidget doesn't clear extra rows
          _justAddedRow = true;

          // Add the row (appended at end by onAddNew)
          widget.onAddNew?.call();

          // Move the row from the end to the correct position
          if (_controller.source != null) {
            final data = _controller.source!.data;
            final lastIndex = data.length - 1;
            if (insertIndex < lastIndex && insertIndex >= 0) {
              final newRow = data.removeAt(lastIndex);
              data.insert(insertIndex, newRow);
            }
          }

          // Update cell values at the inserted position
          if (widget.onCellEdit != null && _controller.source != null) {
            final actualIndex = insertIndex < _controller.source!.data.length
                ? insertIndex
                : _controller.source!.data.length - 1;
            for (final entry in _newRowData.entries) {
              widget.onCellEdit!(actualIndex, entry.key, entry.value);
            }
          }

          // Track this as an extra row on the current page
          _extraRowsOnPage++;
          _extraRowsAddedOnPage = pageToKeep;
        }

        // Restore page so didUpdateWidget uses the correct value
        _lastKnownPage = pageToKeep;
        setState(() {
          _isAddingNewRow = false;
        });
      },
    );
  }

  Widget _buildGroupedBody(List<DataGridColumn> columns) {
    final groupedData = _controller.getGroupedData();
    if (groupedData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultText(
            text: 'No data to display',
            fontColor: Colors.black,
          ),
        ),
      );
    }
    return Column(
      children: groupedData.asMap().entries.map<Widget>((entry) {
        // final index = entry.key;
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
              label: DefaultText(
                text: 'Advanced Filter',
                fontColor: Colors.black,
              ),
            ),
          const SizedBox(width: 12),
          if (widget.showSearchPanel)
            ElevatedButton.icon(
              onPressed: _showSearchPanel,
              icon: const Icon(Icons.search),
              label: DefaultText(
                text: 'Global Search',
                fontColor: Colors.black,
              ),
            ),
          const SizedBox(width: 12),
          if (widget.showSortControls)
            ElevatedButton.icon(
              onPressed: _showSortDialog,
              icon: const Icon(Icons.sort),
              label: DefaultText(
                text: 'Sort',
                fontColor: Colors.black,
              ),
            ),
          const SizedBox(width: 12),
          if (widget.showGroupControls)
            ElevatedButton.icon(
              onPressed: _showGroupDialog,
              icon: const Icon(Icons.group_work),
              label: DefaultText(
                text: 'Group',
                fontColor: Colors.black,
              ),
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
            DefaultText(
              text: 'No data available',
              fontColor: Colors.grey[600],
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

  void _printAllRows() {
    if (_controller.source == null) return;
    final data = _controller.getAllDisplayData(onlyVisibleFields: true);
    final firstTwenty = data.take(20).toList();
    debugPrint(
        'Printing first ${firstTwenty.length} of ${data.length} customers');
    for (final row in firstTwenty) {
      debugPrint(row.toString());
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Printed first ${firstTwenty.length} rows to console')),
    );
  }
}

/// Shimmer loading effect widget for rows
class _ShimmerEffect extends StatefulWidget {
  final DataGridConfig config;
  final List<DataGridColumn> columns;
  final int rowCount;
  final SelectionMode selectionMode;

  const _ShimmerEffect({
    required this.config,
    required this.columns,
    required this.rowCount,
    required this.selectionMode,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleColumns = widget.columns.where((c) => c.visible).toList();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(widget.rowCount, (rowIndex) {
            return Container(
              height: widget.config.rowHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                border: widget.config.showHorizontalBorders
                    ? const Border(
                        bottom:
                            BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  if (widget.selectionMode == SelectionMode.multiple) ...[
                    Container(
                      width: 6,
                      height: widget.config.rowHeight,
                    ),
                    SizedBox(
                      width: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: widget.config.showBorders
                                ? BorderSide(
                                    color: widget.config.borderColor,
                                    width: widget.config.borderWidth,
                                  )
                                : BorderSide.none,
                            bottom: BorderSide(
                              color: widget.config.borderColor,
                              width: widget.config.borderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  ...visibleColumns.map((col) {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            right: widget.config.showBorders
                                ? BorderSide(
                                    color: widget.config.borderColor,
                                    width: widget.config.borderWidth,
                                  )
                                : BorderSide.none,
                            bottom: BorderSide(
                              color: widget.config.borderColor,
                              width: widget.config.borderWidth,
                            ),
                          ),
                        ),
                        child: _buildShimmerBar(_animation.value),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildShimmerBar(double animationValue) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment(animationValue - 1, 0),
          end: Alignment(animationValue, 0),
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFE0E0E0),
            Color(0xFFEEEEEE),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
