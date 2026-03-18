import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qizme/utils/http.dart';
import 'package:qizme/views/home/home.dart';
import 'package:qizme/utils/functions.dart';

class SignupAdditional extends StatefulWidget {
  const SignupAdditional({super.key});

  @override
  State<SignupAdditional> createState() => _SignupAdditionalState();
}

class _SignupAdditionalState extends State<SignupAdditional> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  SharedPreferences? _prefs;
  final bool _isLoading = false;
  bool _isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    // Using standard SharedPreferences for this refactor.
    // Replace with SharedPreferencesWithCache if that's your intended package.
    _prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _isSigningUp = false;
    });
  }

  Future<void> _signup() async {
    // a function for readabilitiy
    if (!_formKey.currentState!.validate()) {
      // returns if the email or password is invalid
      return;
    }

    setState(() {
      _isSigningUp = true; // sets the initial counter for the loading
    });

    try {
      // get the email and password from shared preferences
      final String? email = _prefs?.getString('email');
      final String? password = _prefs?.getString('password');
      // make an http request
      final responseBody = await ApiService.postRequest("api/users/register", {
        "name": _nameController.text,
        "username": _usernameController.text,
        "email": email,
        "password": password,
      });

      // parse the data from the endpoint
      final jsonMap = jsonDecode(responseBody);
      if (jsonMap['success'] == true) {
        if (!mounted) return; // checks if the current widget still exists

        // direct the user to the home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const QizMe()),
          (route) => false,
        );

        // remove email and password from shared preferences for security reasons
        await _prefs?.remove('email');
        await _prefs?.remove('password');
      }
    } on ApiException catch (apiError) {
      if (mounted) {
        final String errorMessage = apiError.message;
        final int statusCode = apiError.statusCode;

        // Now use the data in your dialog
        if (statusCode == 400) {
          showCustomDialog(
            context: context,
            title: 'Signup Failed',
            content: errorMessage,
          );
        }
      }
    } catch (exception) {
      if (mounted) {
        // making sure that the app will display the error on where it happened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${exception.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        // will be executed everytime, this terminates the loading icon
        setState(() {
          _isSigningUp = false;
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "We need more information",
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _usernameController,
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
                          labelText: 'Name',
                          labelStyle: TextStyle(fontSize: 18.0),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _nameController,
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
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 18.0),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: _isSigningUp
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF5D8A56),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: _signup,
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
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
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
