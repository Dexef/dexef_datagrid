import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomersAllPage extends StatefulWidget {
  const CustomersAllPage({super.key});

  @override
  State<CustomersAllPage> createState() => _CustomersAllPageState();
}

class _CustomersAllPageState extends State<CustomersAllPage> {
  // Toggle to test with local mock data
  static const bool _useMock = true;
  static const bool _debugLogging = true;

  final CustomersApi _api = CustomersApi(
    baseUrl: 'https://your.api', // TODO: replace with your API base URL
    endpoint: '/customers', // TODO: replace with your endpoint path
    authHeadersBuilder: () async {
      // TODO: return any required headers (e.g., Authorization)
      return <String, String>{
        // 'Authorization': 'Bearer <token>',
        'Content-Type': 'application/json',
      };
    },
    debugLogging: _debugLogging,
  );

  Future<List<Map<String, dynamic>>>? _future;

  bool get _hasPlaceholders => _api.baseUrl.contains('your.api');

  @override
  void initState() {
    super.initState();
    _future = _fetchAllCustomers();
  }

  Future<void> _printAllCustomers() async {
    try {
      final data = await _future;
      if (data != null) {
        _logPrint(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Printed ${data.length} customers to console')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllCustomers() async {
    if (_useMock) {
      final data = await _mockAllCustomers(count: 250);
      _logPrint(data);
      return data;
    }

    if (_hasPlaceholders) {
      throw const FormatException(
          'API configuration not set: update baseUrl/endpoint/headers and JSON paths.');
    }

    const int pageSize = 200;

    // 1) Page-number based
    try {
      final results = await _api.fetchAllPageNumber(
        pageParam: 'page',
        pageSizeParam: 'pageSize',
        pageSize: pageSize,
        itemsJsonPath: const ['data', 'items'], // adjust to your API
        totalPagesJsonPath: const ['data', 'totalPages'],
      );
      _logPrint(results);
      return results;
    } catch (e) {
      if (_debugLogging)
        debugPrint('Page-number pagination attempt failed: $e');
    }

    // 2) Offset/limit based
    try {
      final results = await _api.fetchAllOffsetLimit(
        offsetParam: 'offset',
        limitParam: 'limit',
        limit: pageSize,
        itemsJsonPath: const ['data', 'items'],
        totalCountJsonPath: const ['data', 'total'],
      );
      _logPrint(results);
      return results;
    } catch (e) {
      if (_debugLogging)
        debugPrint('Offset/limit pagination attempt failed: $e');
    }

    // 3) Cursor-based
    try {
      final results = await _api.fetchAllCursor(
        cursorParam: 'cursor',
        nextCursorJsonPath: const ['data', 'nextCursor'],
        itemsJsonPath: const ['data', 'items'],
        pageSizeParam: 'limit',
        pageSize: pageSize,
      );
      _logPrint(results);
      return results;
    } catch (e) {
      if (_debugLogging) debugPrint('Cursor pagination attempt failed: $e');
    }

    // 4) Link headers (RFC 5988)
    final results = await _api.fetchAllViaLinkHeaders(
      itemsJsonPath: const ['data', 'items'],
      pageSizeParam: 'limit',
      pageSize: pageSize,
    );
    _logPrint(results);
    return results;
  }

  Future<List<Map<String, dynamic>>> _mockAllCustomers(
      {int count = 100}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final customers = <Map<String, dynamic>>[];
    for (int i = 1; i <= count; i++) {
      customers.add({
        'id': i,
        'name': 'Customer $i',
        'email': 'customer$i@example.com',
        'phone': '+1-555-${(1000 + i).toString().padLeft(4, '0')}',
        'status': ['Regular', 'Premium', 'VIP', 'New', 'Inactive'][i % 5],
      });
    }
    return customers;
  }

  void _logPrint(List<Map<String, dynamic>> customers) {
    if (!_debugLogging) return;
    // ignore: avoid_print
    print('Fetched ${customers.length} customers');
    for (final c in customers) {
      // ignore: avoid_print
      print(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPlaceholders && !_useMock) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Customers')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'Configure API in example/lib/customers_all.dart',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Set baseUrl, endpoint, headers, and JSON paths to your API.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        actions: [
          IconButton(
            tooltip: 'Print All',
            onPressed: _printAllCustomers,
            icon: const Icon(Icons.print),
          ),
          if (_useMock)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text(
                  'MOCK DATA',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load customers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _future = _fetchAllCustomers();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final customers = snapshot.data ?? const <Map<String, dynamic>>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline),
                    const SizedBox(width: 8),
                    Text('Total customers: ${customers.length}'),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _future = _fetchAllCustomers();
                        });
                      },
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    final title =
                        (c['name'] ?? c['customerName'] ?? '—').toString();
                    final subtitle =
                        (c['email'] ?? c['phone'] ?? c['id'] ?? '').toString();
                    return ListTile(
                      dense: true,
                      title: Text(title),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomersApi {
  CustomersApi({
    required this.baseUrl,
    required this.endpoint,
    required this.authHeadersBuilder,
    this.debugLogging = false,
  });

  final String baseUrl;
  final String endpoint;
  final Future<Map<String, String>> Function() authHeadersBuilder;
  final bool debugLogging;

  Uri _buildUri(String path, Map<String, dynamic> query) {
    final uri = Uri.parse('$baseUrl$path');
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    });
  }

  Future<http.Response> _get(String path, Map<String, dynamic> query) async {
    final headers = await authHeadersBuilder();
    final uri = _buildUri(path, query);
    if (debugLogging) debugPrint('GET $uri');
    final resp = await http.get(uri, headers: headers);
    if (debugLogging) {
      debugPrint('← ${resp.statusCode} ${resp.reasonPhrase}');
      final body = resp.body;
      debugPrint(
          'Body (${body.length} chars): ${body.length > 1000 ? body.substring(0, 1000) + '…' : body}');
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw HttpException('${resp.statusCode}: ${resp.body}');
    }
    return resp;
  }

  static dynamic _deepRead(dynamic json, List<String> path) {
    dynamic value = json;
    for (final key in path) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }
    return value;
  }

  List<Map<String, dynamic>> _itemsFromResponse({
    required http.Response response,
    required List<String> itemsJsonPath,
  }) {
    final decoded = jsonDecode(response.body);
    dynamic items = _deepRead(decoded, itemsJsonPath);
    if (items is List) {
      return items.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    if (decoded is List) {
      return decoded.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    throw const FormatException('Unable to read items from response');
  }

  Future<List<Map<String, dynamic>>> fetchAllPageNumber({
    required String pageParam,
    required String pageSizeParam,
    required int pageSize,
    required List<String> itemsJsonPath,
    List<String>? totalPagesJsonPath,
    List<String>? hasNextJsonPath,
    List<String>? nextPageJsonPath,
  }) async {
    final all = <Map<String, dynamic>>[];
    int page = 1;
    int? totalPages;

    while (true) {
      final resp = await _get(endpoint, {
        pageParam: page,
        pageSizeParam: pageSize,
      });
      final items =
          _itemsFromResponse(response: resp, itemsJsonPath: itemsJsonPath);
      all.addAll(items);

      final decoded = jsonDecode(resp.body);
      if (totalPagesJsonPath != null) {
        totalPages ??= _deepRead(decoded, totalPagesJsonPath) as int?;
        if (totalPages != null && page >= totalPages) break;
      }
      if (hasNextJsonPath != null) {
        final hasNext = _deepRead(decoded, hasNextJsonPath) as bool?;
        if (hasNext == false) break;
      }
      if (nextPageJsonPath != null) {
        final nextPage = _deepRead(decoded, nextPageJsonPath) as int?;
        if (nextPage == null) break;
        page = nextPage;
        continue;
      }
      page += 1;

      if (items.isEmpty) break; // safety
    }

    return all;
  }

  Future<List<Map<String, dynamic>>> fetchAllOffsetLimit({
    required String offsetParam,
    required String limitParam,
    required int limit,
    required List<String> itemsJsonPath,
    List<String>? totalCountJsonPath,
  }) async {
    final all = <Map<String, dynamic>>[];
    int offset = 0;
    int? totalCount;

    while (true) {
      final resp = await _get(endpoint, {
        offsetParam: offset,
        limitParam: limit,
      });
      final items =
          _itemsFromResponse(response: resp, itemsJsonPath: itemsJsonPath);
      all.addAll(items);

      final decoded = jsonDecode(resp.body);
      if (totalCountJsonPath != null && totalCount == null) {
        totalCount = _deepRead(decoded, totalCountJsonPath) as int?;
      }

      if (items.isEmpty) break;
      offset += items.length;
      if (totalCount != null && offset >= totalCount) break;
    }

    return all;
  }

  Future<List<Map<String, dynamic>>> fetchAllCursor({
    required String cursorParam,
    required List<String> nextCursorJsonPath,
    required List<String> itemsJsonPath,
    String? pageSizeParam,
    int? pageSize,
  }) async {
    final all = <Map<String, dynamic>>[];
    String? cursor;

    while (true) {
      final resp = await _get(endpoint, {
        if (cursor != null) cursorParam: cursor,
        if (pageSizeParam != null && pageSize != null) pageSizeParam: pageSize,
      });
      final items =
          _itemsFromResponse(response: resp, itemsJsonPath: itemsJsonPath);
      all.addAll(items);

      final decoded = jsonDecode(resp.body);
      cursor = _deepRead(decoded, nextCursorJsonPath) as String?;
      if (cursor == null || items.isEmpty) break;
    }

    return all;
  }

  Future<List<Map<String, dynamic>>> fetchAllViaLinkHeaders({
    required List<String> itemsJsonPath,
    String? pageSizeParam,
    int? pageSize,
  }) async {
    final all = <Map<String, dynamic>>[];
    String? nextUrlPath;

    while (true) {
      final resp = await _get(nextUrlPath ?? endpoint, {
        if (nextUrlPath == null && pageSizeParam != null && pageSize != null)
          pageSizeParam: pageSize,
      });
      final items =
          _itemsFromResponse(response: resp, itemsJsonPath: itemsJsonPath);
      all.addAll(items);

      final link = resp.headers['link'] ?? resp.headers['Link'];
      if (link == null) break;
      nextUrlPath = _parseNextFromLinkHeader(link);
      if (nextUrlPath == null) break;
    }

    return all;
  }

  String? _parseNextFromLinkHeader(String linkHeader) {
    final parts = linkHeader.split(',');
    for (final p in parts) {
      final seg = p.trim();
      final relNext = seg.contains('rel="next"');
      if (relNext) {
        final start = seg.indexOf('<');
        final end = seg.indexOf('>');
        if (start != -1 && end != -1 && end > start) {
          final url = seg.substring(start + 1, end);
          try {
            final u = Uri.parse(url);
            return u.path + (u.hasQuery ? '?${u.query}' : '');
          } catch (_) {
            return url; // fallback
          }
        }
      }
    }
    return null;
  }
}

class HttpException implements Exception {
  const HttpException(this.message);
  final String message;
  @override
  String toString() => 'HttpException: $message';
}
