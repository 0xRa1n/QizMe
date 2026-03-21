import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:qizme/repositories/auth_repository.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/views/account/forgot_password_set_new_password.dart';

class ForgotPasswordVerifyCode extends StatefulWidget {
  const ForgotPasswordVerifyCode({super.key});

  @override
  State<ForgotPasswordVerifyCode> createState() =>
      _ForgotPasswordVerifyCodeState();
}

class _ForgotPasswordVerifyCodeState extends State<ForgotPasswordVerifyCode> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = true;
  bool _isResettingPassword = false;
  int? _code;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    await _authRepository.initializePreferences();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate() || _code == null) return;

    setState(() {
      _isResettingPassword = true;
    });

    try {
      final token = await _authRepository.verifyPasswordResetCode(code: _code!);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordSetNewPassword(token: token),
        ),
      );
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
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "We have sent you a 4-digit code to reset your password.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Can't find it? Check your spam folder.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Pinput(
                        length: 4,
                        controller: _codeController,
                        onCompleted: (inputCode) =>
                            _code = int.tryParse(inputCode),
                        validator: (value) {
                          if (value == null || value.length != 4) {
                            return 'Enter 4-digit code';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Code must be numeric';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
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
                          onPressed: _verifyCode,
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
                            'Verify code',
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
