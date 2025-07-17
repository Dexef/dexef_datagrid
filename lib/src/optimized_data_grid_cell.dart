import 'package:flutter/material.dart';
import '../model/data_grid_config.dart';
import '../model/data_grid_model.dart';
import 'selection/data_grid_selection_widgets.dart';

/// Optimized DataGridCell with performance enhancements:
/// - RepaintBoundary for efficient repaints
/// - Lazy loading for images and complex widgets
/// - Efficient rendering for different data types
class OptimizedDataGridCell extends StatelessWidget {
  final dynamic value;
  final DataGridColumn column;
  final DataGridConfig config;
  final bool isSelected;
  final bool isAlternateRow;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isEditing;
  final String? errorMessage;

  const OptimizedDataGridCell({
    super.key,
    required this.value,
    required this.column,
    required this.config,
    this.isSelected = false,
    this.isAlternateRow = false,
    this.onTap,
    this.onDoubleTap,
    this.isEditing = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final width = column.width ?? config.minColumnWidth;
    
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: DataGridCellSelectionHighlight(
            isSelected: isSelected,
            hasError: errorMessage != null,
            child: Container(
              height: config.rowHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: config.showBorders
                    ? Border(
                        right: BorderSide(
                          color: config.borderColor,
                          width: config.borderWidth,
                        ),
                        bottom: BorderSide(
                          color: config.borderColor,
                          width: config.borderWidth,
                        ),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: _buildOptimizedCellContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedCellContent(BuildContext context) {
    // Handle different data types with optimized rendering
    switch (column.dataType) {
      case DataType.string:
        return _buildTextWidget();
      case DataType.number:
        return _buildNumberWidget();
      case DataType.date:
        return _buildDateWidget();
      case DataType.boolean:
        return _buildBooleanWidget();
      case DataType.custom:
        return column.buildCell(context, value);
    }
  }

  Widget _buildLazyImageWidget() {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeInImage.assetNetwork(
      placeholder: 'assets/placeholder.png', // You can use a local asset
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
  }

  Widget _buildBooleanWidget() {
    final boolValue = value is bool ? value : value.toString().toLowerCase() == 'true';
    
    return RepaintBoundary(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: boolValue ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
        child: boolValue
            ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildDateWidget() {
    if (value == null) return const SizedBox.shrink();
    
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }
    
    if (date == null) return Text(value.toString());
    
    return Text(
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildNumberWidget() {
    if (value == null) return const SizedBox.shrink();
    
    final number = double.tryParse(value.toString());
    if (number == null) return Text(value.toString());
    
    return Text(
      number.toStringAsFixed(2),
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildTextWidget() {
    if (value == null) return const SizedBox.shrink();
    
    return Text(
      value.toString(),
      style: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return Colors.blue.withOpacity(0.2);
    }
    
    if (isAlternateRow && config.showAlternateRows) {
      return config.alternateRowBackgroundColor;
    }
    
    return config.rowBackgroundColor;
  }
} 