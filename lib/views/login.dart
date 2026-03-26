import 'package:flutter/material.dart';
import 'package:qizme/controllers/login_controller.dart';
import 'package:qizme/views/account/signup.dart';
import 'package:qizme/views/home/home.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/views/account/forgot_password.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/views/widgets/login_widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController()
      ..addListener(
        _onControllerChanged,
      ); // this adds a listener to the controller so that the UI can be updated when the controller changes
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _controller.login(
        email: _emailController.text
            .trim(), // removes any leading or trailing whitespace from the email
        password: _passwordController.text,
      );

      if (!mounted)
        return; // if the widget is no longer mounted, do not update the UI; mounted means the widget is still being used

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QizMe()),
      ); // go to the home screen if there's no error (errors will be handled below)
    } on ApiException catch (apiError) {
      if (!mounted) return;

      if (apiError.statusCode == 400) {
        showCustomDialog(
          context: context,
          title: 'Login Failed',
          content: apiError.message,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${apiError.message}')),
        );
      }
    } catch (exception) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${exception.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    // dispose means to clean up resources when the widget is no longer in use
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use the Scaffold background for the top green part
    return Scaffold(
      backgroundColor: const Color(0xFF5D8A56),
      body: SingleChildScrollView(
        // This allows the UI to scroll when the keyboard appears
        child: Column(
          children: [
            // This creates the transparent space at the top to show the green background
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Container(
              width: double.infinity,
              // Constraints ensure the white sheet fills at least the rest of the screen
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(55.0),
                  topRight: Radius.circular(55.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 40.0,
              ),
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
                    // Email field
                    createTextField(
                      // a custom function stored at views/widgets/login_widgets.dart
                      controller: _emailController,
                      label: 'Email',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    createTextField(
                      // a custom function stored at views/widgets/login_widgets.dart
                      controller: _passwordController,
                      label: 'Password',
                      obscure: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        ),
                        child: const Text(
                          "Forgot password",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login Button
                    SizedBox(
                      width: 180,
                      height: 45,
                      child: _controller.isLoggingIn
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF5D8A56),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: _login,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
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
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signup(),
                            ),
                          ),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(color: Color(0xFF5D8A56)),
                          ),
                        ),
                      ],
                    ),
                    // Extra padding to ensure the keyboard doesn't cover the bottom-most text
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 20
                          : 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to keep code clean
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 350,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF5D8A56)),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
