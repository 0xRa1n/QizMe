import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:qizme/views/splashScreen.dart';

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
