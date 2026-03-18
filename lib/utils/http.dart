import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() {
    return jsonEncode({
      'error': {'message': message, 'statusCode': statusCode},
    });
  }
}

class ApiService {
  // Define your base URL constant to avoid repeating it across functions
  static const String _baseUrl = 'http://143.198.209.74:8000';

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
    } on ApiException {
      // Re-throw the ApiException so it can be caught by the UI layer
      rethrow;
    } catch (e) {
      // Catch other exceptions (like SocketException for no network) and wrap them
      throw Exception(
        'Network Error: Please check your connection and try again.',
      );
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
    } on ApiException {
      // Re-throw the ApiException so it can be caught by the UI layer
      rethrow;
    } catch (e) {
      // Catch other exceptions (like SocketException for no network) and wrap them
      throw Exception(
        'Network Error: Please check your connection and try again.',
      );
    }
  }

  // Centralized response processor to evaluate the HTTP status code
  static dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final responseBody = jsonDecode(response.body);

    // Evaluate the piecewise function logic here
    if (statusCode >= 200 && statusCode < 300) {
      // D_json: Successfully parse the JSON payload
      return response.body;
    } else if (statusCode >= 400 && statusCode < 500) {
      // E_client: Handle client-side errors by throwing our custom exception
      final errorMessage =
          responseBody['error']['message'] ??
          'An unknown client error occurred.';
      throw ApiException(errorMessage, statusCode);
    } else {
      // E_server: Handle server-side errors
      throw ApiException('Server Error', statusCode);
    }
  }
}
