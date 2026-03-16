import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_application_1/views/onboardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding =
      prefs.getBool('seenOnboarding') ??
      false; // we need to pass the variable of whether the onboarding screen has been seen before to the MyApp widget so that it can decide which screen to show first
  // by default, it is set to false, meaning that the onboarding screen has not been seen before
  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  // get if the onboarding screen has been seen before
  final bool seenOnboarding;
  const MyApp({super.key, this.seenOnboarding = false});

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
      home: seenOnboarding ? const Login() : const Onboardingscreen(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse, // <-- Allows mouse dragging
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}
