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
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'AlbertSans'),
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
