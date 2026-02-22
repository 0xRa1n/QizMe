import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Define your base URL constant to avoid repeating it across functions
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // Helper method to construct standard headers
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add this once auth is active
    };
  }

  // Generic GET request function
  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.get(url, headers: _getHeaders());

      return _processResponse(response);
    } catch (e) {
      // Catch network-level exceptions (e.g., no internet connection)
      throw Exception('Network Error: $e');
    }
  }

  // Generic POST request function
  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$_baseUrl/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body), // Convert Dart Map to JSON string
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // Centralized response processor to evaluate the HTTP status code
  static dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;

    // Evaluate the piecewise function logic here
    if (statusCode >= 200 && statusCode < 300) {
      // D_json: Successfully parse the JSON payload
      return response.body;
    } else if (statusCode >= 400 && statusCode < 500) {
      // E_client: Handle client-side errors (e.g., 401 Unauthorized, 404 Not Found)
      throw Exception('Client Error $statusCode: ${response.body}');
    } else {
      // E_server: Handle server-side errors (e.g., 500 Internal Server Error)
      throw Exception('Server Error $statusCode');
    }
  }
}
