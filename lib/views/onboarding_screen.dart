import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qizme/views/login.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:
        Colors.white, // 1. Ensures the background behind the sheet is white
    extendBody: true, // Allows body to go behind the bottom sheet

    body: Container(
      padding: EdgeInsets.only(bottom: 8),
      child: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() => isLastPage = index == 2);
        },
        children: [
          // first page
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen =
                    constraints.maxHeight <
                    550; // this returns true if the screen height is less than 550 pixels
                final topSpace = isSmallScreen
                    ? 16.0
                    : constraints.maxHeight *
                          0.22; // 16 pixels for small screens, otherwise 22% of the screen height, the purpose of this is to add more space on larger screens to better match the design reference, while keeping it compact on smaller devices.

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: topSpace), // responsive top margin
                          Image.asset(
                            "assets/images/onboarding_1.png",
                            height: isSmallScreen
                                ? constraints.maxHeight *
                                      0.68 // 68% of screen height for small screens
                                : constraints.maxHeight *
                                      0.48, // 38% of screen height for larger screens, this helps maintain a good visual balance across different device sizes
                            fit: BoxFit.contain,
                          ),
                          const Text(
                            "Create Flashcards",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Put your memory to the ultimate test.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // second page
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen =
                    constraints.maxHeight <
                    550; // this returns true if the screen height is less than 550 pixels
                final topSpace = isSmallScreen
                    ? 16.0
                    : constraints.maxHeight *
                          0.22; // 16 pixels for small screens, otherwise 22% of the screen height, the purpose of this is to add more space on larger screens to better match the design reference, while keeping it compact on smaller devices.

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: topSpace), // responsive top margin
                          Image.asset(
                            "assets/images/onboarding_2.png",
                            height: isSmallScreen
                                ? constraints.maxHeight *
                                      0.68 // 68% of screen height for small screens
                                : constraints.maxHeight *
                                      0.48, // 38% of screen height for larger screens, this helps maintain a good visual balance across different device sizes
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            child: AutoSizeText(
                              "Check Your Knowledge",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Put your brains to the test, check your knowledge and discover what you already know.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // second page
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen =
                    constraints.maxHeight <
                    550; // this returns true if the screen height is less than 550 pixels
                final topSpace = isSmallScreen
                    ? 16.0
                    : constraints.maxHeight *
                          0.22; // 16 pixels for small screens, otherwise 22% of the screen height, the purpose of this is to add more space on larger screens to better match the design reference, while keeping it compact on smaller devices.

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: topSpace), // responsive top margin
                          Image.asset(
                            "assets/images/onboarding_3.png",
                            height: isSmallScreen
                                ? constraints.maxHeight *
                                      0.68 // 68% of screen height for small screens
                                : constraints.maxHeight *
                                      0.48, // 38% of screen height for larger screens, this helps maintain a good visual balance across different device sizes
                            fit: BoxFit.contain,
                          ),
                          const Text(
                            "View Your Progress",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "When a card is created, you can track your progress inside the application.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),

    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent, // fully transparent
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: isLastPage
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D8A56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenOnboarding', true);

                        if (!mounted) return;

                        Navigator.of(this.context).pushReplacement(
                          MaterialPageRoute(builder: (_) => Login()),
                        );
                      },

                      child: const Text(
                        "Get started",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 34),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    onDotClicked: (index) => controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    ),
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 10,
                      dotColor: Colors.black12,
                      activeDotColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black26),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => controller.jumpToPage(2),
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
      ),
    ),
  );
}
