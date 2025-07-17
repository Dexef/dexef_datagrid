
/// Diff result for efficient updates
class DataGridDiffResult {
  final List<DataGridDiffUpdate> updates;
  final bool hasChanges;

  const DataGridDiffResult({
    required this.updates,
    required this.hasChanges,
  });
}

/// Individual diff update
class DataGridDiffUpdate {
  final int index;
  final DiffType type;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;

  const DataGridDiffUpdate({
    required this.index,
    required this.type,
    this.oldData,
    this.newData,
  });
}

/// Diff types
enum DiffType {
  inserted,
  removed,
  changed,
  moved,
}

/// Efficient diffing utility for DataGrid updates
class DataGridDiffUtil {
  /// Compare two lists of data and return efficient updates
  static DataGridDiffResult diff(
    List<Map<String, dynamic>> oldData,
    List<Map<String, dynamic>> newData, {
    String? idField = 'id',
    bool detectMoves = true,
  }) {
    final updates = <DataGridDiffUpdate>[];
    
    // Create maps for efficient lookup
    final oldMap = <String, Map<String, dynamic>>{};
    final newMap = <String, Map<String, dynamic>>{};
    
    for (int i = 0; i < oldData.length; i++) {
      final id = oldData[i][idField]?.toString() ?? i.toString();
      oldMap[id] = oldData[i];
    }
    
    for (int i = 0; i < newData.length; i++) {
      final id = newData[i][idField]?.toString() ?? i.toString();
      newMap[id] = newData[i];
    }
    
    // Find removed items
    for (final entry in oldMap.entries) {
      if (!newMap.containsKey(entry.key)) {
        updates.add(DataGridDiffUpdate(
          index: oldData.indexWhere((item) => item[idField]?.toString() == entry.key),
          type: DiffType.removed,
          oldData: entry.value,
        ));
      }
    }
    
    // Find inserted and changed items
    for (int i = 0; i < newData.length; i++) {
      final id = newData[i][idField]?.toString() ?? i.toString();
      final oldItem = oldMap[id];
      
      if (oldItem == null) {
        // Inserted
        updates.add(DataGridDiffUpdate(
          index: i,
          type: DiffType.inserted,
          newData: newData[i],
        ));
      } else {
        // Check if changed
        if (_hasChanged(oldItem, newData[i])) {
          updates.add(DataGridDiffUpdate(
            index: i,
            type: DiffType.changed,
            oldData: oldItem,
            newData: newData[i],
          ));
        }
      }
    }
    
    // Detect moves if requested
    if (detectMoves) {
      final moves = _detectMoves(oldData, newData, idField);
      updates.addAll(moves);
    }
    
    return DataGridDiffResult(
      updates: updates,
      hasChanges: updates.isNotEmpty,
    );
  }
  
  /// Check if two data items have changed
  static bool _hasChanged(Map<String, dynamic> oldItem, Map<String, dynamic> newItem) {
    if (oldItem.length != newItem.length) return true;
    
    for (final entry in oldItem.entries) {
      final key = entry.key;
      final oldValue = entry.value;
      final newValue = newItem[key];
      
      if (oldValue != newValue) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Detect moved items
  static List<DataGridDiffUpdate> _detectMoves(
    List<Map<String, dynamic>> oldData,
    List<Map<String, dynamic>> newData,
    String? idField,
  ) {
    final moves = <DataGridDiffUpdate>[];
    
    // Create position maps
    final oldPositions = <String, int>{};
    final newPositions = <String, int>{};
    
    for (int i = 0; i < oldData.length; i++) {
      final id = oldData[i][idField]?.toString() ?? i.toString();
      oldPositions[id] = i;
    }
    
    for (int i = 0; i < newData.length; i++) {
      final id = newData[i][idField]?.toString() ?? i.toString();
      newPositions[id] = i;
    }
    
    // Find moves
    for (final entry in oldPositions.entries) {
      final id = entry.key;
      final oldPos = entry.value;
      final newPos = newPositions[id];
      
      if (newPos != null && oldPos != newPos) {
        moves.add(DataGridDiffUpdate(
          index: newPos,
          type: DiffType.moved,
          oldData: oldData[oldPos],
          newData: newData[newPos],
        ));
      }
    }
    
    return moves;
  }
  
  /// Batch updates for efficient processing
  static List<List<DataGridDiffUpdate>> batchUpdates(
    List<DataGridDiffUpdate> updates, {
    int batchSize = 10,
  }) {
    final batches = <List<DataGridDiffUpdate>>[];
    
    for (int i = 0; i < updates.length; i += batchSize) {
      final end = (i + batchSize < updates.length) ? i + batchSize : updates.length;
      batches.add(updates.sublist(i, end));
    }
    
    return batches;
  }
  
  /// Optimize updates by removing redundant operations
  static List<DataGridDiffUpdate> optimizeUpdates(List<DataGridDiffUpdate> updates) {
    final optimized = <DataGridDiffUpdate>[];
    final processedIndices = <int>{};
    
    // Sort updates by type priority: removed, inserted, changed, moved
    final sortedUpdates = List<DataGridDiffUpdate>.from(updates)
      ..sort((a, b) {
        final priorityA = _getUpdatePriority(a.type);
        final priorityB = _getUpdatePriority(b.type);
        return priorityA.compareTo(priorityB);
      });
    
    for (final update in sortedUpdates) {
      if (!processedIndices.contains(update.index)) {
        optimized.add(update);
        processedIndices.add(update.index);
      }
    }
    
    return optimized;
  }
  
  /// Get priority for update types
  static int _getUpdatePriority(DiffType type) {
    switch (type) {
      case DiffType.removed:
        return 0;
      case DiffType.inserted:
        return 1;
      case DiffType.changed:
        return 2;
      case DiffType.moved:
        return 3;
    }
  }
} 