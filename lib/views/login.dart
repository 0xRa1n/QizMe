import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/utils/http.dart';
import 'package:flutter_application_1/views/home.dart';
import 'package:flutter_application_1/utils/functions.dart';
import 'package:flutter_application_1/views/account/forgotPassword.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SharedPreferences? _prefs;
  bool _isLoading = true;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    // Using standard SharedPreferences for this refactor.
    // Replace with SharedPreferencesWithCache if that's your intended package.
    _prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    // a function for readabilitiy
    if (!_formKey.currentState!.validate()) {
      // returns if the email or password is invalid
      return;
    }

    setState(() {
      _isLoggingIn = true; // sets the initial counter for the loading
    });

    try {
      // make an http request
      final responseBody = await ApiService.postRequest("api/users/login", {
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      // parse the data from the endpoint
      final jsonMap = jsonDecode(responseBody);

      final userData = jsonMap['data'];
      final userPrefs = userData['userPreference'];

      // set the static values to the current session
      await Future.wait([
        _prefs!.setString("email", _emailController.text),
        _prefs!.setString("name", userData['name']),
        _prefs!.setBool("pushNotifications", userPrefs['pushNotifications']),
        _prefs!.setString("appTheme", userPrefs['appTheme']),
      ]);

      if (!mounted) return; // checks if the current widget still exists

      // direct the user to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QizMe()),
      );
    } on ApiException catch (apiError) {
      if (mounted) {
        final String errorMessage = apiError.message;
        final int statusCode = apiError.statusCode;

        // Now use the data in your dialog
        if (statusCode == 400) {
          showCustomDialog(
            context: context,
            title: 'Login Failed',
            content: errorMessage,
          );
        }
      }
    } catch (exception) {
      if (mounted) {
        // making sure that the app will display the error on where it happened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${exception.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        // will be executed everytime, this terminates the loading icon (see line 106)
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // this will be initialized FIRST (the initial value of this is true, making the loading icon appear). Then. after the request has been made, it will change the counter of this to false (line 91)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: const Color(0xFF5D8A56),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(55.0),
                  topRight: Radius.circular(55.0),
                ),
              ),
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "QizMe",
                      style: TextStyle(
                        fontFamily: "YoungSerif",
                        fontWeight: FontWeight.bold,
                        fontSize: 64.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF5D8A56),
                              width: 1.0,
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color(0xFF5D8A56),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 18.0),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.black,
                        obscureText: true,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF5D8A56),
                              width: 1.0,
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color(0xFF5D8A56),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 18.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot password",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: _isLoggingIn
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF5D8A56),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: _login,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 154, 154, 154),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                overlayColor: const Color(0xFF5D8A56),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          InkWell(
                            onTap: () {
                              // TODO: Navigate to Sign Up page
                              debugPrint("Sign up clicked");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text("Sign up"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
