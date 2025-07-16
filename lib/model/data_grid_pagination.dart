/// Pagination modes for the data grid
enum PaginationMode {
  none,
  client,
  server,
}

/// Virtual scrolling modes
enum VirtualScrollMode {
  none,
  basic,
  infinite,
}

/// Represents pagination state
class DataGridPaginationState {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalRecords;
  final bool isLoading;
  final String? error;

  const DataGridPaginationState({
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.isLoading = false,
    this.error,
  });

  /// Creates an empty pagination state
  factory DataGridPaginationState.empty() {
    return const DataGridPaginationState();
  }

  /// Creates a copy with updated values
  DataGridPaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalPages,
    int? totalRecords,
    bool? isLoading,
    String? error,
  }) {
    return DataGridPaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Calculates the start index for the current page
  int get startIndex => (currentPage - 1) * pageSize;

  /// Calculates the end index for the current page
  int get endIndex => startIndex + pageSize - 1;

  /// Checks if there's a next page
  bool get hasNextPage => currentPage < totalPages;

  /// Checks if there's a previous page
  bool get hasPreviousPage => currentPage > 1;

  /// Gets the page info string
  String get pageInfo {
    if (totalRecords == 0) return 'No records';
    
    final start = startIndex + 1;
    final end = (endIndex + 1).clamp(0, totalRecords);
    return 'Showing $start-$end of $totalRecords';
  }

  /// Goes to the next page
  DataGridPaginationState nextPage() {
    if (!hasNextPage) return this;
    return copyWith(currentPage: currentPage + 1);
  }

  /// Goes to the previous page
  DataGridPaginationState previousPage() {
    if (!hasPreviousPage) return this;
    return copyWith(currentPage: currentPage - 1);
  }

  /// Goes to a specific page
  DataGridPaginationState goToPage(int page) {
    if (page < 1 || page > totalPages) return this;
    return copyWith(currentPage: page);
  }

  /// Changes the page size
  DataGridPaginationState changePageSize(int newPageSize) {
    if (newPageSize <= 0) return this;
    
    final newTotalPages = (totalRecords / newPageSize).ceil();
    // Ensure newTotalPages is at least 1 to avoid clamp issues
    final safeTotalPages = newTotalPages < 1 ? 1 : newTotalPages;
    final newCurrentPage = currentPage.clamp(1, safeTotalPages);
    
    return copyWith(
      pageSize: newPageSize,
      totalPages: safeTotalPages,
      currentPage: newCurrentPage,
    );
  }
}

/// Virtual scrolling configuration
class VirtualScrollConfig {
  final int itemHeight;
  final int visibleItemCount;
  final int bufferSize;
  final bool enableInfiniteScroll;
  final int infiniteScrollThreshold;

  const VirtualScrollConfig({
    this.itemHeight = 50,
    this.visibleItemCount = 10,
    this.bufferSize = 5,
    this.enableInfiniteScroll = false,
    this.infiniteScrollThreshold = 3,
  });

  /// Calculates the total height for virtual scrolling
  int get totalHeight => itemHeight * visibleItemCount;

  /// Calculates the buffer height
  int get bufferHeight => itemHeight * bufferSize;
}

/// Server-side data request parameters
class DataGridServerRequest {
  final int page;
  final int pageSize;
  final List<Map<String, dynamic>> sorts;
  final Map<String, dynamic> filterState;
  final Map<String, dynamic> additionalParams;
  final String? requestId; // For deduplication
  final bool forceRefresh; // Skip cache

  const DataGridServerRequest({
    required this.page,
    required this.pageSize,
    this.sorts = const [],
    this.filterState = const {},
    this.additionalParams = const {},
    this.requestId,
    this.forceRefresh = false,
  });

  /// Converts to a map for API requests
  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'pageSize': pageSize,
      'sorts': sorts,
      'filters': filterState,
      'requestId': requestId,
      'forceRefresh': forceRefresh,
      ...additionalParams,
    };
  }

  /// Creates a cache key for this request
  String get cacheKey {
    return '${page}_${pageSize}_${sorts.hashCode}_${filterState.hashCode}';
  }
}

/// Server-side data response with caching support
class DataGridServerResponse {
  final List<Map<String, dynamic>> data;
  final int totalRecords;
  final int totalPages;
  final bool hasMore;
  final String? error;
  final String? requestId;
  final DateTime? timestamp;
  final bool fromCache;

  const DataGridServerResponse({
    required this.data,
    required this.totalRecords,
    required this.totalPages,
    this.hasMore = false,
    this.error,
    this.requestId,
    this.timestamp,
    this.fromCache = false,
  });

  /// Creates from a map (API response)
  factory DataGridServerResponse.fromMap(Map<String, dynamic> map) {
    return DataGridServerResponse(
      data: List<Map<String, dynamic>>.from(map['data'] ?? []),
      totalRecords: map['totalRecords'] ?? 0,
      totalPages: map['totalPages'] ?? 1,
      hasMore: map['hasMore'] ?? false,
      error: map['error'],
      requestId: map['requestId'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
      fromCache: map['fromCache'] ?? false,
    );
  }

  /// Creates a cached response
  factory DataGridServerResponse.cached(
    DataGridServerResponse original,
    DateTime timestamp,
  ) {
    return DataGridServerResponse(
      data: original.data,
      totalRecords: original.totalRecords,
      totalPages: original.totalPages,
      hasMore: original.hasMore,
      error: original.error,
      requestId: original.requestId,
      timestamp: timestamp,
      fromCache: true,
    );
  }
}

/// Pagination cache manager
class DataGridPaginationCache {
  final Map<String, DataGridServerResponse> _cache = {};
  final Duration _cacheExpiry;
  final int _maxCacheSize;

  DataGridPaginationCache({
    Duration? cacheExpiry,
    int? maxCacheSize,
  }) : _cacheExpiry = cacheExpiry ?? const Duration(minutes: 5),
       _maxCacheSize = maxCacheSize ?? 50;

  /// Get cached response if available and not expired
  DataGridServerResponse? getCached(String cacheKey) {
    final cached = _cache[cacheKey];
    if (cached == null) return null;

    final now = DateTime.now();
    if (cached.timestamp == null || 
        now.difference(cached.timestamp!) > _cacheExpiry) {
      _cache.remove(cacheKey);
      return null;
    }

    return cached;
  }

  /// Cache a response
  void cache(String cacheKey, DataGridServerResponse response) {
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    _cache[cacheKey] = response;
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      return value.timestamp == null || 
             now.difference(value.timestamp!) > _cacheExpiry;
    });
  }
} 