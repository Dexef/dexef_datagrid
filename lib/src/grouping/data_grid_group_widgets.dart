import 'package:flutter/material.dart';
import '../../model/data_grid_sorting.dart';
import '../utils/data_grid_dialog.dart';

/// Group header widget for grouped rows
class DataGridGroupHeader extends StatelessWidget {
  final DataGridGroupRow groupRow;
  final VoidCallback? onToggle;
  final bool isExpanded;

  const DataGridGroupHeader({
    super.key,
    required this.groupRow,
    this.onToggle,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey.shade600,
            ),
            onPressed: onToggle,
            iconSize: 20,
          ),
          Expanded(
            child: Text(
              _getGroupText(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              groupRow.summary,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGroupText() {
    final field = groupRow.group.field;
    final value = groupRow.groupValue;
    return '$field: $value';
  }
}

/// Group summary widget
class DataGridGroupSummary extends StatelessWidget {
  final String field;
  final dynamic value;
  final GroupSummaryType summaryType;
  final dynamic summaryValue;

  const DataGridGroupSummary({
    super.key,
    required this.field,
    required this.value,
    required this.summaryType,
    required this.summaryValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getSummaryIcon(),
            color: Colors.blue.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getSummaryText(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSummaryIcon() {
    switch (summaryType) {
      case GroupSummaryType.count:
        return Icons.numbers;
      case GroupSummaryType.sum:
        return Icons.add;
      case GroupSummaryType.average:
        return Icons.analytics;
      case GroupSummaryType.min:
        return Icons.keyboard_arrow_down;
      case GroupSummaryType.max:
        return Icons.keyboard_arrow_up;
      case GroupSummaryType.custom:
        return Icons.functions;
    }
  }

  String _getSummaryText() {
    switch (summaryType) {
      case GroupSummaryType.count:
        return 'Count: $summaryValue';
      case GroupSummaryType.sum:
        return 'Sum: $summaryValue';
      case GroupSummaryType.average:
        return 'Average: $summaryValue';
      case GroupSummaryType.min:
        return 'Min: $summaryValue';
      case GroupSummaryType.max:
        return 'Max: $summaryValue';
      case GroupSummaryType.custom:
        return 'Custom: $summaryValue';
    }
  }
}

/// Group controls widget
class DataGridGroupControls extends StatelessWidget {
  final List<DataGridGroup> groups;
  final VoidCallback? onConfigureGroups;
  final VoidCallback? onClearGroups;

  const DataGridGroupControls({
    super.key,
    required this.groups,
    this.onConfigureGroups,
    this.onClearGroups,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onConfigureGroups,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_work, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${groups.length} group${groups.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onClearGroups != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onClearGroups,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.clear, size: 16, color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }
}

/// Group configuration dialog
class DataGridGroupDialog extends StatefulWidget {
  final List<DataGridGroup> currentGroups;
  final List<String> availableFields;

  const DataGridGroupDialog({
    super.key,
    required this.currentGroups,
    required this.availableFields,
  });

  @override
  State<DataGridGroupDialog> createState() => _DataGridGroupDialogState();
}

class _DataGridGroupDialogState extends State<DataGridGroupDialog> {
  late List<DataGridGroup> groups;

  @override
  void initState() {
    super.initState();
    groups = List.from(widget.currentGroups);
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Group Configuration',
      icon: Icons.group_work,
      headerColor: Colors.green,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active groups
          if (groups.isNotEmpty) ...[
            const Text(
              'Active Groups',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...groups.map((group) => _buildGroupItem(group)),
            const SizedBox(height: 20),
          ],
          // Add new group
          _buildAddGroupSection(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(groups),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildGroupItem(DataGridGroup group) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          group.isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.green,
        ),
        title: Text(
          group.field,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Summary: ${_getSummaryTypeText(group.summaryType)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.blue),
              onPressed: () => _editGroup(group),
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeGroup(group.field),
              iconSize: 20,
            ),
          ],
        ),
        onTap: () => _toggleGroup(group.field),
      ),
    );
  }

  Widget _buildAddGroupSection() {
    final availableFields = widget.availableFields
        .where((field) => !groups.any((group) => group.field == field))
        .toList();

    if (availableFields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'All fields are already grouped',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Group',
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
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: null,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Select Field'),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: availableFields.map((field) {
                    return DropdownMenuItem(value: field, child: Text(field));
                  }).toList(),
                  onChanged: (field) {
                    if (field != null) {
                      _addGroup(field);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<GroupSummaryType>(
                  value: GroupSummaryType.count,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Summary Type'),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: GroupSummaryType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getSummaryTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (type) {
                    // This will be used when adding a new group
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getSummaryTypeText(GroupSummaryType type) {
    switch (type) {
      case GroupSummaryType.count:
        return 'Count';
      case GroupSummaryType.sum:
        return 'Sum';
      case GroupSummaryType.average:
        return 'Average';
      case GroupSummaryType.min:
        return 'Minimum';
      case GroupSummaryType.max:
        return 'Maximum';
      case GroupSummaryType.custom:
        return 'Custom';
    }
  }

  void _addGroup(String field) {
    setState(() {
      groups.add(DataGridGroup(
        field: field,
        summaryType: GroupSummaryType.count,
      ));
    });
  }

  void _removeGroup(String field) {
    setState(() {
      groups.removeWhere((group) => group.field == field);
    });
  }

  void _toggleGroup(String field) {
    setState(() {
      final index = groups.indexWhere((group) => group.field == field);
      if (index >= 0) {
        groups[index] = groups[index].toggleExpanded();
      }
    });
  }

  void _editGroup(DataGridGroup group) {
    showDialog(
      context: context,
      builder: (context) => _GroupEditDialog(group: group),
    ).then((updatedGroup) {
      if (updatedGroup != null) {
        setState(() {
          final index = groups.indexWhere((g) => g.field == group.field);
          if (index >= 0) {
            groups[index] = updatedGroup;
          }
        });
      }
    });
  }
}

/// Group edit dialog
class _GroupEditDialog extends StatefulWidget {
  final DataGridGroup group;

  const _GroupEditDialog({required this.group});

  @override
  State<_GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<_GroupEditDialog> {
  late DataGridGroup group;

  @override
  void initState() {
    super.initState();
    group = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return DataGridDialogWithHeader(
      title: 'Edit Group',
      icon: Icons.settings,
      headerColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Field'),
            subtitle: Text(group.field),
          ),
          ListTile(
            title: const Text('Summary Type'),
            subtitle: DropdownButton<GroupSummaryType>(
              value: group.summaryType,
              isExpanded: true,
              items: GroupSummaryType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getSummaryTypeText(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() {
                    group = group.copyWith(summaryType: type);
                  });
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Expanded'),
            subtitle: const Text('Show group expanded by default'),
            value: group.isExpanded,
            onChanged: (value) {
              setState(() {
                group = group.copyWith(isExpanded: value);
              });
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
          onPressed: () => Navigator.of(context).pop(group),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getSummaryTypeText(GroupSummaryType type) {
    switch (type) {
      case GroupSummaryType.count:
        return 'Count';
      case GroupSummaryType.sum:
        return 'Sum';
      case GroupSummaryType.average:
        return 'Average';
      case GroupSummaryType.min:
        return 'Minimum';
      case GroupSummaryType.max:
        return 'Maximum';
      case GroupSummaryType.custom:
        return 'Custom';
    }
  }
} 