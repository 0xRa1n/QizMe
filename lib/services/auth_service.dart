import 'package:qizme/utils/http.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final responseBody = await ApiService.postRequest("api/users/login", {
      "email": email,
      "password": password,
    });

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final responseBody = await ApiService.postRequest("api/users/register", {
      "name": name,
      "username": username,
      "email": email,
      "password": password,
    });

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> requestPasswordResetCode({
    required String email,
  }) async {
    final responseBody = await ApiService.postRequest(
      "api/users/forgotPassword",
      {"email": email},
    );

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> verifyPasswordResetCode({
    required int code,
  }) async {
    final responseBody = await ApiService.postRequest("api/users/verifyCode", {
      "code": code,
    });

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final responseBody = await ApiService.postRequest(
      "api/users/resetPassword",
      {"token": token, "newPassword": newPassword},
    );

    return {"raw": responseBody};
  }
}
