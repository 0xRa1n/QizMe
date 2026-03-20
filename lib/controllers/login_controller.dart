import 'package:flutter/foundation.dart';
import 'package:qizme/repositories/auth_repository.dart';

// this controller is responsible for managing the login process (specifically the login form state and login logic, including the loading indicator)
// basically this is the brain of the login process, and the repository is the helper
class LoginController extends ChangeNotifier {
  LoginController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  bool isLoading = true;
  bool isLoggingIn = false;

  Future<void> initialize() async {
    await _authRepository
        .initializePreferences(); // loads initial preferences from the auth repository
    isLoading = false;
    notifyListeners(); // notifies listeners that the loading state has changed
  }

  Future<void> login({required String email, required String password}) async {
    // logs in the user with the provided email and password
    isLoggingIn = true;
    notifyListeners();

    try {
      await _authRepository.login(email: email, password: password);
    } finally {
      isLoggingIn = false;
      notifyListeners();
    }
  }
}
