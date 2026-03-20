import 'package:flutter/material.dart';
import 'login.dart';
import 'onboarding_screen.dart';
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
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();

    // this sets the duration of the animation to 2.5 seconds, reducing this will make the splash screen animation faster
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    // this function makes sures that after the animation is completed, the user is navigated to the appropriate screen based on whether they have seen the onboarding or not (important for also checking for the boolean seenOnboarding in shared preferences)
    //
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreens();
    });
  }

  Future<void> _initializeScreens() async {
    final prefs = await SharedPreferences.getInstance();
    // get the boolean value of seenOnboarding from shared preferences, if it doesn't exist, default to false
    _seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) {
      return;
    } // safety check to ensure the widget is still in the widget tree before trying to navigate

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // if the animation is completed and the widget is still in the widget tree, navigate to the appropriate screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _seenOnboarding
                ? const Login()
                : const Onboardingscreen(), // if the seenOnboarding boolean is true, navigate to the login screen, otherwise navigate to the onboarding screen
          ),
        );
      }
    });

    _controller.forward(); // starts the animation
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
