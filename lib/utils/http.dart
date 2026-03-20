import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:qizme/constants.dart';

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
  // endpoint: 143.198.209.74
  // 10.0.2.2 for android
  // localhost for pc

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
    final url = Uri.parse('$baseUrl/$endpoint');

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
    final url = Uri.parse('$baseUrl/$endpoint');

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

  // post, but for files (extend)
  static Future<dynamic> postFileRequest(
    String endpoint,
    Map<String, String> fields,
    String filePath,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print('POST FILE URL: $url');
    print('FILE PATH: $filePath');
    print('FIELDS: $fields');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields.addAll(fields)
        ..files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            filePath,
            filename: 'profile.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // Centralized response processor to evaluate the HTTP status code
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      if (statusCode >= 200 && statusCode < 300) return response.body;
      throw ApiException(response.body, statusCode);
    }

    if (statusCode >= 200 && statusCode < 300) return response.body;
    if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(
        responseBody['error']?['message'] ?? 'Client error',
        statusCode,
      );
    }
    throw ApiException('Server Error', statusCode);
  }
}
