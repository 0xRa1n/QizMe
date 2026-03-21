import 'package:flutter/material.dart';
import 'package:qizme/repositories/auth_repository.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/views/account/forgot_password_verify_code.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    await _authRepository.initializePreferences();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isResettingPassword = true;
    });

    try {
      final ok = await _authRepository.requestPasswordResetCode(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;

      if (ok) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ForgotPasswordVerifyCode(),
          ),
        );
      }
    } on ApiException catch (apiError) {
      if (!mounted) return;

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
      print(exception);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset password failed: ${exception.toString()}'),
        ),
      );
    } finally {
      if (!mounted) return;

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
                const SizedBox(height: 12),
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
                      floatingLabelStyle: TextStyle(color: Color(0xFF5D8A56)),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: 180,
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
                            'Send code',
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
