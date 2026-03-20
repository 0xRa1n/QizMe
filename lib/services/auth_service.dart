import 'package:qizme/utils/http.dart';

// this service is responsible for handling authentication-related HTTP requests (login, logout, etc.)
// basically, this helps create connection between the endpoint

// Without this, the repository would not know how to interact with the API for authentication.
// Without the repository, the controller would not know how what to do with the response data.
// Without the controller, nothing will happen.
class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // future map string dynamic means the function will return a map with string keys and dynamic values
    // e.g. {"token": "token"}
    final responseBody = await ApiService.postRequest("api/users/login", {
      "email": email,
      "password": password,
    });

    return {"raw": responseBody};
  }
}
