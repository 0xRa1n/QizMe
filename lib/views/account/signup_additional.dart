import 'package:flutter/material.dart';
import 'package:qizme/repositories/auth_repository.dart';
import 'package:qizme/utils/functions.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/views/home/home.dart';

class SignupAdditional extends StatefulWidget {
  const SignupAdditional({super.key});

  @override
  State<SignupAdditional> createState() => _SignupAdditionalState();
}

class _SignupAdditionalState extends State<SignupAdditional> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _authRepository.initializePreferences(); // initialize preferences
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return; // validates the form fields

    setState(() { // the purpose of this is to show the loading indicator
      _isSigningUp = true;
    });

    try {
      await _authRepository.signupAdditional(
        name: _nameController.text.trim(), // trims the name and username before sending to the server
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil( // navigates to the QizMe screen and removes all previous screens from the stack
        context,
        MaterialPageRoute(builder: (context) => const QizMe()),
        (route) => false,
      );
    } on ApiException catch (apiError) {
      if (!mounted) return;

      if (apiError.statusCode == 400) {
        showCustomDialog(
          context: context,
          title: 'Signup Failed',
          content: apiError.message,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${apiError.message}')),
        );
      }
    } catch (exception) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup Failed: ${exception.toString()}')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSigningUp = false; // stops the loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
