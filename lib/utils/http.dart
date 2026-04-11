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

  static Map<String, String> _getDebugHostHeader(Uri resolvedUrl) {
    final base = Uri.parse(baseUrl);
    final shouldForceLocalhostHost =
        resolvedUrl.host == '10.0.2.2' && base.host == 'localhost';

    if (!shouldForceLocalhostHost) return {};

    final port = base.hasPort ? ':${base.port}' : '';
    return {'host': 'localhost$port'};
  }

  // Generic GET request function
  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');
    final headers = {..._getHeaders(), ..._getDebugHostHeader(url)};

    try {
      final response = await http.get(url, headers: headers);

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
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');
    final headers = {..._getHeaders(), ..._getDebugHostHeader(url)};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body), // Convert Dart Map to JSON string
      );

      return _processResponse(response);
    } on ApiException {
      // Re-throw the ApiException so it can be caught by the UI layer
      rethrow;
    } catch (e) {
      // print('POST Request Error: $e');
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
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');
    // print('POST FILE URL: $url');
    // print('FILE PATH: $filePath');
    // print('FIELDS: $fields');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(_getDebugHostHeader(url))
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

  static Future<dynamic> postMultipartRequest(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, String>? files,
  }) async {
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(_getDebugHostHeader(url))
        ..fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final path = entry.value.trim();
          if (path.isEmpty) continue;

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              path,
              filename: path.split(RegExp(r'[\\/]')).last,
              contentType: _inferImageMediaType(path),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // Generic POST request function
  static Future<dynamic> putRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');
    final headers = {..._getHeaders(), ..._getDebugHostHeader(url)};

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body), // Convert Dart Map to JSON string
      );

      return _processResponse(response);
    } on ApiException {
      // Re-throw the ApiException so it can be caught by the UI layer
      rethrow;
    } catch (e) {
      // print('POST Request Error: $e');
      // Catch other exceptions (like SocketException for no network) and wrap them
      throw Exception(
        'Network Error: Please check your connection and try again.',
      );
    }
  }

  // Generic DELETE request function
  static Future<dynamic> deleteRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$resolvedBaseUrl/$endpoint');
    final headers = {..._getHeaders(), ..._getDebugHostHeader(url)};

    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode(body), // Convert Dart Map to JSON string
      );

      return _processResponse(response);
    } on ApiException {
      // Re-throw the ApiException so it can be caught by the UI layer
      rethrow;
    } catch (e) {
      // print('POST Request Error: $e');
      // Catch other exceptions (like SocketException for no network) and wrap them
      throw Exception(
        'Network Error: Please check your connection and try again.',
      );
    }
  }

  // Centralized response processor to evaluate the HTTP status code
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      // If parsing fails but status is success, return raw string (e.g., for plain text responses)
      if (statusCode >= 200 && statusCode < 300) return response.body;
      throw ApiException(response.body, statusCode);
    }

    if (statusCode >= 200 && statusCode < 300) return responseBody;

    if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(
        responseBody['error']?['message'] ?? 'Client error',
        statusCode,
      );
    }
    throw ApiException('Server Error', statusCode);
  }

  static MediaType _inferImageMediaType(String path) {
    final normalized = path.toLowerCase();

    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (normalized.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (normalized.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    if (normalized.endsWith('.heif')) {
      return MediaType('image', 'heif');
    }

    // Default to jpeg for .jpg/.jpeg and unknown camera outputs.
    return MediaType('image', 'jpeg');
  }
}
