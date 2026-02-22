import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  List<Widget>? actions,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss.
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions:
            actions ??
            [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(
                    color: Color.fromARGB(255, 154, 154, 154),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  overlayColor: const Color(0xFF5D8A56),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
            ],
      );
    },
  );
}
