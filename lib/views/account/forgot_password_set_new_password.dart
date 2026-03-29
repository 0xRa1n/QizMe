import 'package:flutter/material.dart';
import 'package:qizme/repositories/auth_repository.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/utils/http.dart';
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
  final _authRepository = AuthRepository();

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
    _newPasswordReEnterController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    await _authRepository.initializePreferences();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isResettingPassword = true;
    });

    try {
      final ok = await _authRepository.resetPassword(
        token: widget.token,
        newPassword: _newPasswordReEnterController.text,
      );

      if (!mounted) {
        return;
      }

      if (ok) {
        // to-do: add a message if the password reset has been successful.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const QizMe()),
          (Route<dynamic> route) => false,
        );
      }
    } on ApiException catch (apiError) {
      if (!mounted) {
        return;
      }

      if (apiError.statusCode == 400) {
        showCustomDialog(
          context: context,
          title: 'Reset password failed',
          content: apiError.message,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset password failed: ${apiError.message}')),
        );
      }
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset password failed: ${exception.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isResettingPassword = false;
      });
    }
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                      return null;
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
                        return 'Passwords do not match';
                      }
                      return null;
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
