import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/views/login.dart'; // Make sure this path is correct

Widget buildMenuButtons({
  required BuildContext context,
  required VoidCallback onAccountTap,
  required VoidCallback onSettingsTap,
  required bool darkMode, // Add darkMode parameter
}) {
  // Define styles based on the theme
  final ButtonStyle lightModeStyle = OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Match the settings style
    ),
    backgroundColor: Colors.grey[200],
    side: BorderSide(
      color: Colors.black12,
      width: 1,
    ), // Match the settings style
  );

  final ButtonStyle darkModeStyle = OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: const Color.fromARGB(255, 45, 106, 79),
    side: BorderSide.none,
  );

  final TextStyle lightModeTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Match the settings style
  );

  final TextStyle darkModeTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onAccountTap,
            style: darkMode
                ? darkModeStyle
                : lightModeStyle, // Apply conditional style
            child: Text(
              "Account",
              style: darkMode
                  ? darkModeTextStyle
                  : lightModeTextStyle, // Apply conditional text style
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSettingsTap,
            style: darkMode
                ? darkModeStyle
                : lightModeStyle, // Apply conditional style
            child: Text(
              "Settings",
              style: darkMode
                  ? darkModeTextStyle
                  : lightModeTextStyle, // Apply conditional text style
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildMenuLogout({required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          if (!context.mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Login()),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red[200],
        ),
        child: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
