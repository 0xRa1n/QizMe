import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/services/auth_service.dart';

// this repository is responsible for providing the functions required by the controller. In this case, there is a function for logging in a user and another for initializing shared preferences.
class AuthRepository {
  Future<void> login({required String email, required String password}) async {
    final result = await AuthService.login(
      email: email,
      password: password,
    ); // the function from the service is called here
    final jsonMap = jsonDecode(result["raw"]);

    final userData = jsonMap['data'] ?? {};
    final userPrefs = userData['userPreference'] ?? {};

    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      // set values that will be used throughout the app
      // note that sharedpreferences will retain even after the app is closed (unless data is cleared)
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

  Future<void> initializePreferences() async {
    await SharedPreferences.getInstance();
  }
}
