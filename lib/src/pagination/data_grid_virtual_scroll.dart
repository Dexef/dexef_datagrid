import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../model/data_grid_pagination.dart';
import '../../model/data_grid_model.dart';
import '../../model/data_grid_config.dart';
import '../../model/data_grid_selection.dart';

import '../data_grid_row.dart';

/// Virtual scrolling widget for large datasets
class DataGridVirtualScroll extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataGridColumn> columns;
  final DataGridConfig config;
  final VirtualScrollConfig virtualConfig;
  final Function(int)? onRowTap;
  final Function(int)? onCellTap;
  final Function(int, String, dynamic)? onCellEdit;
  final SelectionMode selectionMode;
  final EditMode editMode;
  final Function(int)? onRowSelect;
  final bool Function(int)? isRowSelected;
  final bool Function(int)? isEditingRow;

  const DataGridVirtualScroll({
    super.key,
    required this.data,
    required this.columns,
    required this.config,
    required this.virtualConfig,
    this.onRowTap,
    this.onCellTap,
    this.onCellEdit,
    this.selectionMode = SelectionMode.none,
    this.editMode = EditMode.none,
    this.onRowSelect,
    this.isRowSelected,
    this.isEditingRow,
  });

  @override
  State<DataGridVirtualScroll> createState() => _DataGridVirtualScrollState();
}

class _DataGridVirtualScrollState extends State<DataGridVirtualScroll> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _visibleIndices = [];
  double _scrollOffset = 0.0;
  int _lastDataLength = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _updateVisibleIndices();
  }

  @override
  void didUpdateWidget(DataGridVirtualScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate if data length changed
    if (widget.data.length != _lastDataLength) {
      _lastDataLength = widget.data.length;
      _updateVisibleIndices();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollOffset = _scrollController.offset;
    _updateVisibleIndices();
  }

  void _updateVisibleIndices() {
    if (widget.data.isEmpty) return;

    final itemHeight = widget.virtualConfig.itemHeight.toDouble();
    final visibleCount = widget.virtualConfig.visibleItemCount;
    final bufferSize = widget.virtualConfig.bufferSize;

    // Calculate visible range with improved precision
    final startIndex = (_scrollOffset / itemHeight).floor() - bufferSize;
    final endIndex = startIndex + visibleCount + (2 * bufferSize);

    final newVisibleIndices = <int>[];
    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= 0 && i < widget.data.length) {
        newVisibleIndices.add(i);
      }
    }

    // Only update if indices actually changed
    if (!listEquals(_visibleIndices, newVisibleIndices)) {
      setState(() {
        _visibleIndices.clear();
        _visibleIndices.addAll(newVisibleIndices);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final totalHeight = widget.data.length * widget.virtualConfig.itemHeight;
    final visibleHeight = widget.virtualConfig.totalHeight;

    return SizedBox(
      height: visibleHeight.toDouble(),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: totalHeight.toDouble(),
          child: Stack(
            children: _buildVisibleItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVisibleItems() {
    return _visibleIndices.map((index) {
      final rowData = widget.data[index];
      final isSelected = widget.isRowSelected?.call(index) ?? false;
      final isEditing = widget.isEditingRow?.call(index) ?? false;
      final isAlternateRow = index % 2 == 1;

      return Positioned(
        top: index * widget.virtualConfig.itemHeight.toDouble(),
        left: 0,
        right: 0,
        height: widget.virtualConfig.itemHeight.toDouble(),
        child: DataGridRow(
          rowData: rowData,
          columns: widget.columns,
          config: widget.config,
          rowIndex: index,
          isSelected: isSelected,
          isAlternateRow: isAlternateRow,
          onRowTap: widget.onRowTap != null ? () => widget.onRowTap!(index) : null,
          onCellTap: widget.onCellTap,
          selectionMode: widget.selectionMode,
          editMode: widget.editMode,
          isEditing: isEditing,
          onRowSelect: widget.onRowSelect,
          onCellEdit: widget.onCellEdit,
        ),
      );
    }).toList();
  }
}

/// Infinite scroll widget
class DataGridInfiniteScroll extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataGridColumn> columns;
  final DataGridConfig config;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final Function(int)? onRowTap;
  final Function(int)? onCellTap;
  final Function(int, String, dynamic)? onCellEdit;
  final SelectionMode selectionMode;
  final EditMode editMode;
  final Function(int)? onRowSelect;
  final bool Function(int)? isRowSelected;
  final bool Function(int)? isEditingRow;

  const DataGridInfiniteScroll({
    super.key,
    required this.data,
    required this.columns,
    required this.config,
    this.hasMore = false,
    this.isLoading = false,
    this.onLoadMore,
    this.onRowTap,
    this.onCellTap,
    this.onCellEdit,
    this.selectionMode = SelectionMode.none,
    this.editMode = EditMode.none,
    this.onRowSelect,
    this.isRowSelected,
    this.isEditingRow,
  });

  @override
  State<DataGridInfiniteScroll> createState() => _DataGridInfiniteScrollState();
}

class _DataGridInfiniteScrollState extends State<DataGridInfiniteScroll> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.hasMore && !widget.isLoading) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      if (currentScroll >= maxScroll - 200) { // 200px threshold
        widget.onLoadMore?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.data.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.data.length) {
          // Loading indicator at the end
          return DataGridInfiniteScrollLoader(
            isLoading: widget.isLoading,
          );
        }

        final rowData = widget.data[index];
        final isSelected = widget.isRowSelected?.call(index) ?? false;
        final isEditing = widget.isEditingRow?.call(index) ?? false;
        final isAlternateRow = index % 2 == 1;

        return SizedBox(
          width: widget.columns.fold<double>(0, (sum, col) => sum + (col.width ?? widget.config.minColumnWidth)),
          child: DataGridRow(
            rowData: rowData,
            columns: widget.columns,
            config: widget.config,
            rowIndex: index,
            isSelected: isSelected,
            isAlternateRow: isAlternateRow,
            onRowTap: widget.onRowTap != null ? () => widget.onRowTap!(index) : null,
            onCellTap: widget.onCellTap,
            selectionMode: widget.selectionMode,
            editMode: widget.editMode,
            isEditing: isEditing,
            onRowSelect: widget.onRowSelect,
            onCellEdit: widget.onCellEdit,
          ),
        );
      },
    );
  }
} 

/// Loading widget for infinite scroll
class DataGridInfiniteScrollLoader extends StatelessWidget {
  final bool isLoading;

  const DataGridInfiniteScrollLoader({
    super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Loading more data...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 