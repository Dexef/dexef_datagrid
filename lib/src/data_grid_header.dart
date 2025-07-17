import 'package:flutter/material.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_config.dart';

/// DataGrid header widget for building column headers
class DataGridHeader extends StatelessWidget {
  final DataGridColumn column;
  final DataGridConfig config;
  final VoidCallback? onTap;
  final Widget? child;

  const DataGridHeader({
    super.key,
    required this.column,
    required this.config,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                column.caption,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: config.headerTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
} 