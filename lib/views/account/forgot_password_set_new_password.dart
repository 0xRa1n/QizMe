// ignore: file_names
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:qizme/utils/http.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/views/home/home.dart';

class ForgotPasswordSetNewPassword extends StatefulWidget {
  final String token;

  const ForgotPasswordSetNewPassword({super.key, required this.token});

  @override
  State<ForgotPasswordSetNewPassword> createState() =>
      _ForgotPasswordSetNewPasswordState();
}

class _ForgotPasswordSetNewPasswordState
    extends State<ForgotPasswordSetNewPassword> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _newPasswordReEnterController = TextEditingController();

  bool _isLoading = true;
  bool _isResettingPassword = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    // Using standard SharedPreferences for this refactor.
    // Replace with SharedPreferencesWithCache if that's your intended package.

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resetPassword() async {
    // a function for readabilitiy
    if (!_formKey.currentState!.validate()) {
      // returns if the email or password is invalid
      return;
    }

    setState(() {
      _isResettingPassword = true; // sets the initial counter for the loading
    });

    try {
      // make an http request
      final responseBody = await ApiService.postRequest(
        "api/users/resetPassword",
        {
          "token": widget.token,
          "newPassword": _newPasswordReEnterController.text,
        },
      );

      final jsonMap = jsonDecode(responseBody);
      final apiResponse = jsonMap['success'];

      if (!mounted) return;
      // replace this to a next page
      if (apiResponse) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const QizMe()),
          (Route<dynamic> route) => false,
        );
      }
    } on ApiException catch (apiError) {
      if (mounted) {
        final String errorMessage = apiError.message;
        final int statusCode = apiError.statusCode;

        // Now use the data in your dialog
        if (statusCode == 400) {
          showCustomDialog(
            context: context,
            title: 'Reset password failed',
            content: errorMessage,
          );
        } else if (statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reset password failed: $errorMessage')),
          );
        }
      }
    } catch (exception) {
      if (mounted) {
        // making sure that the app will display the error on where it happened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset password failed: ${exception.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        // will be executed everytime, this terminates the loading icon (see line 106)
        setState(() {
          _isResettingPassword = false;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                const Center(
                  child: Text(
                    "QizMe",
                    style: TextStyle(
                      fontFamily: "YoungSerif",
                      fontWeight: FontWeight.bold,
                      fontSize: 64.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    "Forgot password",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _newPasswordController,
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
                      labelText: 'New password',
                      labelStyle: TextStyle(fontSize: 18.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null; // Return null if valid
                    },
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: 350,
                  child: TextFormField(
                    obscureText: true,
                    controller: _newPasswordReEnterController,
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
                      labelText: 'Re-Enter new password',
                      labelStyle: TextStyle(fontSize: 18.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please re-enter your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match'; // The validation message
                      }
                      return null; // Return null if valid
                    },
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: 210,
                  height: 40,
                  child: _isResettingPassword
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5D8A56),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: _resetPassword,
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
                            'Set new password',
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
    );
  }
}
