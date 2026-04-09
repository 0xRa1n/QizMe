import 'package:flutter/material.dart';

class StyledMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool darkMode;

  const StyledMenuButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle lightModeStyle = OutlinedButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.grey[200],
      side: const BorderSide(color: Colors.black12, width: 1),
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
      fontWeight: FontWeight.w500,
    );

    final TextStyle darkModeTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: darkMode ? darkModeStyle : lightModeStyle,
          child: Text(
            label,
            style: darkMode ? darkModeTextStyle : lightModeTextStyle,
          ),
        ),
      ),
    );
  }
}
