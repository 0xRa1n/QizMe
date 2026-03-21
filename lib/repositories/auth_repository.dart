import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/services/auth_service.dart';

class AuthRepository {
  Future<void> login({required String email, required String password}) async {
    final result = await AuthService.login(email: email, password: password);
    final jsonMap = jsonDecode(result["raw"]);

    final userData = jsonMap['data'] ?? {};
    final userPrefs = userData['userPreference'] ?? {};

    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString("email", email),
      prefs.setString("name", userData['name'] ?? ""),
      prefs.setBool(
        "pushNotifications",
        userPrefs['pushNotifications'] ?? false,
      ),
      prefs.setString("appTheme", userPrefs['appTheme'] ?? "light"),
      prefs.setString("profilePicture", userData['profilePicture'] ?? ""),
    ]);
  }

  Future<void> signupAdditional({
    required String name,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email == null || password == null) {
      throw Exception('Missing signup credentials. Please restart signup.');
    }

    final result = await AuthService.signup(
      name: name,
      username: username,
      email: email,
      password: password,
    );

    final jsonMap = jsonDecode(result["raw"]);
    final data = jsonMap['data'] ?? {};

    await Future.wait([
      prefs.setString('name', data['name'] ?? name),
      prefs.setString('email', data['email'] ?? email),
      prefs.setString('username', data['username'] ?? username),
      prefs.setString('profilePicture', data['profilePicture'] ?? ''),
      prefs.remove('password'),
    ]);
  }

  Future<bool> requestPasswordResetCode({required String email}) async {
    final result = await AuthService.requestPasswordResetCode(email: email);
    final jsonMap = jsonDecode(result["raw"]);
    return jsonMap['success'];
  }

  Future<String> verifyPasswordResetCode({required int code}) async {
    final result = await AuthService.verifyPasswordResetCode(code: code);
    final jsonMap = jsonDecode(result["raw"]);
    final token = jsonMap['message']?['token'];

    if (token == null || token is! String || token.isEmpty) {
      throw Exception('Invalid reset token from server.');
    }

    return token;
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final result = await AuthService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    final jsonMap = jsonDecode(result["raw"]);

    final success = jsonMap['success'] == true;
    if (!success) {
      throw Exception(jsonMap['message'] ?? 'Reset password failed.');
    }

    return true;
  }

  Future<void> initializePreferences() async {
    await SharedPreferences.getInstance();
  }
}
