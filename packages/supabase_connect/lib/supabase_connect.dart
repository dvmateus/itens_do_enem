library supabase_connect;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Lightweight client for interacting with the Supabase REST and storage APIs.
class SupabaseConnect {
  SupabaseConnect({
    required this.supabaseUrl,
    required this.supabaseKey,
    http.Client? httpClient,
  })  : assert(supabaseUrl.isNotEmpty, 'supabaseUrl must not be empty'),
        assert(supabaseKey.isNotEmpty, 'supabaseKey must not be empty'),
        _httpClient = httpClient ?? http.Client();

  final String supabaseUrl;
  final String supabaseKey;
  final http.Client _httpClient;

  static const String defaultSelect = '*';

  Map<String, String> get _defaultHeaders => <String, String>{
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Accept': 'application/json',
      };

  /// Fetches data from the given [table].
  ///
  /// [columns] follows the standard Supabase `select` syntax.
  /// Additional [filters] will be translated to query parameters and can be
  /// used for ordering or filtering results.
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = defaultSelect,
    Map<String, String>? filters,
  }) async {
    final query = <String, String>{'select': columns, if (filters != null) ...filters};
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table').replace(queryParameters: query);
    final response = await _httpClient.get(uri, headers: _defaultHeaders);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SupabaseConnectException(
        'Failed to fetch data from $table: HTTP ${response.statusCode}',
        response.body,
      );
    }

    final dynamic body = jsonDecode(response.body.isEmpty ? '[]' : response.body);
    if (body is List) {
      return body
          .map((dynamic e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList(growable: false);
    }
    if (body is Map) {
      return <Map<String, dynamic>>[Map<String, dynamic>.from(body as Map<dynamic, dynamic>)];
    }
    return const <Map<String, dynamic>>[];
  }

  /// Downloads a file from the Supabase storage bucket [bucket] using the
  /// provided [path].
  Future<Uint8List> download(String bucket, String path) async {
    final uri = Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$path');
    final response = await _httpClient.get(
      uri,
      headers: <String, String>{
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SupabaseConnectException(
        'Failed to download storage object $bucket/$path: HTTP ${response.statusCode}',
        response.body,
      );
    }

    return response.bodyBytes;
  }

  void close() {
    _httpClient.close();
  }
}

class SupabaseConnectException implements Exception {
  SupabaseConnectException(this.message, [this.details]);

  final String message;
  final Object? details;

  @override
  String toString() => 'SupabaseConnectException: $message${details == null ? '' : ' ($details)'}';
}
