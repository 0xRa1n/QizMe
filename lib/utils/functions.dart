import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  List<Widget>? actions,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedDarkMode = prefs.getBool('darkMode');
  final fallbackIsDark = Theme.of(context).brightness == Brightness.dark;
  final isDark = savedDarkMode ?? fallbackIsDark;

  final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Colors.black;
  final borderColor = isDark
      ? const Color(0xFF5A5A5A)
      : const Color.fromARGB(255, 154, 154, 154);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss.
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(title, style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Text(content, style: TextStyle(color: textColor)),
        ),
        actions:
            actions ??
            [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  overlayColor: const Color(0xFF5D8A56),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 18.0, color: textColor),
                ),
              ),
            ],
      );
    },
  );
}

Future<void> uploadImage({
  required BuildContext context,
  required Function(String) onImageSelected,
}) async {}
