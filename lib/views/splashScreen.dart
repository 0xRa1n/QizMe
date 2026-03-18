import 'package:flutter/material.dart';
import 'login.dart';
import 'onboardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QizMeApp extends StatelessWidget {
  const QizMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  SharedPreferences? _prefs;

  Future<void> _initializePreferences() async {
    // Use the standard SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Update the state to rebuild the UI cleanly
    setState(() {
      _prefs = prefs;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();

    bool seenOnboarding = _prefs?.getBool('seenOnboarding') ?? false;
    print(seenOnboarding);

    // this sets the duration of the animation to 2.5 seconds, reducing this will make the splash screen animation faster
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // this checks if the animation is completed and navigates to the login screen
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                seenOnboarding ? const Login() : const Onboardingscreen(),
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82C47C),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final rotate = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
            ).value;

            final scale = Tween(begin: 2.0, end: 1.0)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
                  ),
                )
                .value;

            final slide = Tween(begin: -45.0, end: 0.0)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                  ),
                )
                .value;

            final opacity = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 0.8),
            ).value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotate * 2 * 3.14159,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          "Q",
                          style: TextStyle(
                            fontSize: 85,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        Positioned(
                          top: 46,
                          left: 20,
                          child: const Icon(
                            Icons.star,
                            size: 22,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(slide, 0),
                    child: const Text(
                      "izMe",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -3,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
