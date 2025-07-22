import 'package:flutter/material.dart';
import '../model/data_grid_model.dart';
import '../model/data_grid_config.dart';
import 'style/style_size.dart';
import 'widgets/default_text.dart';

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
              child:DefaultText(
                text:column.caption,
                isTextTheme: true,
                themeStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: config.headerTextColor,
                    fontSize: AppFontSize().setFontSize(context,webFontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
} 