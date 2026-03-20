import 'package:flutter/material.dart';
import 'package:qizme/controllers/login_controller.dart';
import 'package:qizme/views/account/signup.dart';
import 'package:qizme/views/home/home.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/views/account/forgot_password.dart';
import 'package:qizme/utils/http.dart';

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
    // if (_controller.isLoading) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
    //     ),
    //   );
    // }

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
                      child: _controller.isLoggingIn
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Signup(),
                                ),
                              );
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
