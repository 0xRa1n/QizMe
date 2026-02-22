import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/http.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Strictly typed variables
  String? email, password, name;

  SharedPreferencesWithCache? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        // The allowList must include 'email' to prevent runtime crashes
        allowList: <String>{'email', 'name', 'pushNotifications', 'appTheme'},
      ),
    );

    // Prevent memory leaks if the widget is disposed before the Future completes
    if (!mounted) return;

    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    // Flat, readable UI structure
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
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5D8A56),
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(color: Color(0xFF5D8A56)),
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 18.0),
                      ),
                      onChanged: (input) {
                        email = input;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5D8A56),
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(color: Color(0xFF5D8A56)),
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 18.0),
                      ),
                      onChanged: (input) {
                        password = input;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 350,
                    child: InkWell(
                      onTap: () {
                        // Ensure null safety when reading the email variable
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
                    child: OutlinedButton(
                      onPressed: () async {
                        dynamic loginUser = await ApiService.postRequest(
                          "api/users/login",
                          {"email": email, "password": password},
                        );

                        Map<String, dynamic> jsonMap = jsonDecode(
                          loginUser,
                        ); // decode the result
                        await _prefs?.setString("email", email!);
                        await _prefs?.setString(
                          "name",
                          jsonMap['data']['name'],
                        );
                        await _prefs?.setBool(
                          "pushNotifications",
                          jsonMap['data']['userPreference']['pushNotifications'],
                        );
                        await _prefs?.setString(
                          "appTheme",
                          jsonMap['data']['userPreference']['appTheme'],
                        );

                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QizMe(),
                          ),
                        );
                      },
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
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
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
                            print("Sign up clicked");
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
        ],
      ),
    );
  }
}
