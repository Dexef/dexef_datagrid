import 'package:flutter/material.dart';
import '../../model/data_grid_pagination.dart';
import '../utils/data_grid_dialog.dart';

/// Pagination controls widget
class DataGridPaginationControls extends StatelessWidget {
  final DataGridPaginationState pagination;
  final Function(DataGridPaginationState) onPaginationChanged;
  final int totalRows;
  final bool isLoading;

  const DataGridPaginationControls({
    super.key,
    required this.pagination,
    required this.onPaginationChanged,
    required this.totalRows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = pagination.totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
      ),
      child: Row(
        children: [
          // Page number buttons at the start
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildPageButtons(totalPages, pagination.currentPage),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons(int totalPages, int currentPage) {
    List<Widget> buttons = [];

    // Calculate which pages to show
    int startPage = 1;
    int endPage = totalPages;

    // Show maximum 5 page buttons
    if (totalPages > 5) {
      if (currentPage <= 3) {
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      final isCurrentPage = i == currentPage;
      buttons.add(
        GestureDetector(
          onTap: isLoading ? null : () => onPaginationChanged(pagination.goToPage(i)),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentPage ? Colors.blue : Colors.white,
              border: Border.all(
                color: isCurrentPage ? Colors.blue : Colors.grey.shade300,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$i',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.black87,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}

/// Pagination settings dialog
class DataGridPaginationSettingsDialog extends StatefulWidget {
  final DataGridPaginationState pagination;
  final Function(DataGridPaginationState) onPaginationChanged;

  const DataGridPaginationSettingsDialog({
    super.key,
    required this.pagination,
    required this.onPaginationChanged,
  });

  @override
  State<DataGridPaginationSettingsDialog> createState() => _DataGridPaginationSettingsDialogState();
}

class _DataGridPaginationSettingsDialogState extends State<DataGridPaginationSettingsDialog> {
  late DataGridPaginationState _pagination;
  late int _pageSize;
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pagination = widget.pagination;
    _pageSize = _pagination.pageSize;
    _pageIndex = _pagination.currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Pagination Settings',
      icon: Icons.settings,
      headerColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page size selection
          const Text(
            'Page Size',
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
                child: _buildPageSizeButton(10),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPageSizeButton(25),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPageSizeButton(50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPageSizeButton(100),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Custom page size
          const Text(
            'Custom Page Size',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter custom page size',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final size = int.tryParse(value);
              if (size != null && size > 0) {
                setState(() {
                  _pageSize = size;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          // Page index
          const Text(
            'Go to Page',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter page number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final page = int.tryParse(value);
              if (page != null && page > 0) {
                setState(() {
                  _pageIndex = page;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applySettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildPageSizeButton(int size) {
    final isSelected = _pageSize == size;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () {
          setState(() {
            _pageSize = size;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Text(
            '$size',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _applySettings() {
    final newPagination = _pagination
        .changePageSize(_pageSize)
        .goToPage(_pageIndex);
    widget.onPaginationChanged(newPagination);
    Navigator.of(context).pop();
  }
}

/// Virtual scrolling indicator
class DataGridVirtualScrollIndicator extends StatelessWidget {
  final int visibleStart;
  final int visibleEnd;
  final int totalRows;
  final double scrollPosition;
  final double scrollExtent;

  const DataGridVirtualScrollIndicator({
    super.key,
    required this.visibleStart,
    required this.visibleEnd,
    required this.totalRows,
    required this.scrollPosition,
    required this.scrollExtent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = scrollExtent > 0 ? scrollPosition / scrollExtent : 0.0;
    final visibleRatio = totalRows > 0 ? (visibleEnd - visibleStart) / totalRows : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Virtual Scrolling',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Showing rows ${visibleStart + 1}-$visibleEnd of $totalRows',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).toInt()}% scrolled',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
              Text(
                '${(visibleRatio * 100).toInt()}% visible',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 