import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/login.dart'; // Make sure this path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QizMe',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'AlbertSans', // Set the default font family here
        textTheme: const TextTheme(
          // You can define specific text styles if needed
          bodyMedium: TextStyle(fontFamily: 'AlbertSans'),
          // For TextFormFields, you might need to style inputDecorationTheme
        ),
      ),
      home: const Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}
