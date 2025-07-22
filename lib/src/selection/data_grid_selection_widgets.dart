import 'package:flutter/material.dart';
import '../../model/data_grid_config.dart';

/// Checkbox column widget for multi-selection
class DataGridCheckboxColumn extends StatelessWidget {
  final int rowIndex;
  final bool isSelected;
  final bool isSelectAll;
  final bool isIndeterminate;
  final ValueChanged<bool?>? onChanged;
  final DataGridConfig config;

  const DataGridCheckboxColumn({
    super.key,
    required this.rowIndex,
    required this.isSelected,
    this.isSelectAll = false,
    this.isIndeterminate = false,
    this.onChanged,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      decoration: config.showBorders
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: config.borderColor,
                  width: config.borderWidth,
                ),
              ),
            )
          : null,
      child: Center(
        child: Checkbox(
          value: isSelected,
          tristate: isSelectAll,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Select all checkbox widget
class DataGridSelectAllCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isIndeterminate;
  final ValueChanged<bool?>? onChanged;
  final DataGridConfig config;

  const DataGridSelectAllCheckbox({
    super.key,
    required this.isSelected,
    this.isIndeterminate = false,
    this.onChanged,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: config.headerHeight,
      decoration: config.showBorders
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: config.borderColor,
                  width: config.borderWidth,
                ),
              ),
            )
          : null,
      child: Center(
        child: Checkbox(
          value: isSelected,
          tristate: true,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Selection indicator widget
class DataGridSelectionIndicator extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback? onClearSelection;

  const DataGridSelectionIndicator({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount of $totalCount selected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          if (onClearSelection != null)
            TextButton(
              onPressed: onClearSelection,
              child: const Text('Clear Selection'),
            ),
        ],
      ),
    );
  }
}

/// Row selection highlight widget
class DataGridRowSelectionHighlight extends StatelessWidget {
  final bool isSelected;
  final bool isFocused;
  final Widget child;

  const DataGridRowSelectionHighlight({
    super.key,
    required this.isSelected,
    this.isFocused = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    
    if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
    } else if (isFocused) {
      backgroundColor = Theme.of(context).focusColor.withOpacity(0.1);
    }

    return Container(
      color: backgroundColor,
      child: child,
    );
  }
}

/// Cell selection highlight widget
class DataGridCellSelectionHighlight extends StatelessWidget {
  final bool isSelected;
  final bool isFocused;
  final bool hasError;
  final Widget child;

  const DataGridCellSelectionHighlight({
    super.key,
    required this.isSelected,
    this.isFocused = false,
    this.hasError = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    double? borderWidth;
    
    if (hasError) {
      borderColor = Colors.red;
      borderWidth = 2;
    } else if (isSelected) {
      borderColor = Colors.transparent;
      // borderColor = Theme.of(context).primaryColor;
      // borderWidth = 2;
      borderWidth = 0 ;
    } else if (isFocused) {
      borderColor = Theme.of(context).focusColor;
      borderWidth = 1;
    }

    return Container(
      decoration: borderColor != null
          ? BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: borderWidth!,
              ),
            )
          : null,
      child: child,
    );
  }
} 