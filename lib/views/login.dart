import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: const Color(
              0xFF5D8A56,
            ), // Approximate green from the provided image
          ),
          // Foreground Layer
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
              // Add padding and form content here
              padding: const EdgeInsets.all(30.0),
              // email
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // email input field
                  Text(
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
                      cursorColor: Colors
                          .black, // makes the cursor black instead of the default purple
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          // when clicked, it will show border black instead of the default purple
                          borderSide: BorderSide(
                            color: Color(0xFF5D8A56),
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF5D8A56),
                        ), // makes the label black instead of the default purple
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),

                  // password input field
                  const SizedBox(height: 20), // spacing
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      cursorColor: Colors
                          .black, // makes the cursor black instead of the default purple
                      obscureText: true, // makes the input asterisk
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          // when clicked, it will show border black instead of the default purple
                          borderSide: BorderSide(
                            color: Color(0xFF5D8A56),
                            width: 1.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF5D8A56),
                        ), // makes the label black instead of the default purple

                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),

                  // spacing
                  const SizedBox(height: 20), // spacing
                  // forgot password
                  SizedBox(
                    width: 350,
                    child: InkWell(
                      onTap: () {
                        print("I am clicked");
                      },
                      child: Text(
                        "Forgot password",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  // spacing
                  const SizedBox(height: 20),

                  // login button
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        // for now, transfer to home.dart
                        Navigator.pushReplacement(
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

                  // spacing
                  const SizedBox(height: 20),

                  // sign up text
                  SizedBox(
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        InkWell(
                          onTap: () {
                            print("I am clicked");
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text("Sign up"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Form content (Email, Password, Sign in) goes here
            ),
          ),
        ],
      ),
    );
  }
}
