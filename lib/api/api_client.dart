import 'dart:convert';
import 'package:http/http.dart' as http;

/// Skeleton API Client for backend integration
class ApiClient {
  static const String baseUrl = 'http://192.168.1.44:8000';
  
  // Singleton pattern route
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _jwtToken;

  void setToken(String token) {
    _jwtToken = token;
  }
  
  void clearToken() {
    _jwtToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  /// Generic GET request
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _headers);
    return _handleResponse(response);
  }

  /// Generic POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _headers,
      body: data != null ? jsonEncode(data) : null,
    );
    return _handleResponse(response);
  }

  /// Generic PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: _headers,
      body: data != null ? jsonEncode(data) : null,
    );
    return _handleResponse(response);
  }

  /// Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    // Basic rate limit handling wrapper can be added here (e.g. 429 status code)
    if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded. Try again later.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
         return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
