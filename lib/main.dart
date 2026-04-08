import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:qizme/views/splash_screen.dart';

void main() async {
  runApp(MyApp());
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
        brightness: Brightness.light,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'AlbertSans', color: Colors.black),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor:
              Colors.black, // sets the cursor to black (the blinking like)
          selectionColor:
              Colors.grey, // sets the selected to color grey (highlighted)
          selectionHandleColor: Colors
              .green, // sets the selection handle (line with green at the bottom) to green
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'AlbertSans',
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'AlbertSans', color: Colors.white),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Colors.grey[700],
          selectionHandleColor: Colors.green,
        ),
      ),
      themeMode:
          ThemeMode.system, // Automatically switch based on system settings
      home: SplashScreen(),
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
