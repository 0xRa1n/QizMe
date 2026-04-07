import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCardSet extends StatefulWidget {
  final bool darkMode; // Add darkMode property

  const AddCardSet({
    super.key,
    required this.darkMode, // Require it in the constructor
  });

  @override
  State<AddCardSet> createState() => _AddCardSetState();
}

class _AddCardSetState extends State<AddCardSet> {
  Future<String> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  final TextEditingController _cardSetNameController = TextEditingController();

  // get the text
  String get cardSetName => _cardSetNameController.text;

  Future<void> _createCardSet() async {
    final email = await _loadEmail();
    if (email.isEmpty) {
      if (!mounted) return;
      showCustomDialog(
        context: context,
        title: 'Error',
        content: 'Could not find user email. Please log in again.',
      );
      return;
    }
    // call the service to create the card set
    try {
      final result = await CardService.createCardSet(
        email: email,
        name: cardSetName,
      );
      final jsonMap = result["raw"];

      if (jsonMap['success'] == true) {
        if (!mounted) {
          return;
        }

        showCustomDialog(
          context: context,
          title: 'Card Set Created',
          content: 'Your card set has been created successfully.',
        );

        // Clear the text field after successful creation
        _cardSetNameController.clear();
      }
    } on ApiException catch (apiError) {
      if (!mounted) {
        return;
      }

      if (apiError.statusCode == 400) {
        showCustomDialog(
          context: context,
          title: 'Create card set failed',
          content: apiError.message,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Create card set Failed: ${apiError.message}'),
          ),
        );
      }
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Create card set failed: ${exception.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme
    final bool isDark = widget.darkMode;
    final Color containerColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFD9D9D9);
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color hintColor = isDark ? Colors.white38 : Colors.black38;
    final Color textFieldFillColor = isDark
        ? const Color(0xFF2C2C2C)
        : Colors.white;
    final Color borderColor = isDark ? Colors.white54 : Colors.black54;

    // The main Scaffold is in home.dart, so we only return the body content here.
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity, // This line is crucial for expansion
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              CrossAxisAlignment.center, // This line centers the children
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card set name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _cardSetNameController,
                    style: TextStyle(
                      color: textColor,
                    ), // Set text color for input
                    decoration: InputDecoration(
                      hintText: 'Enter a card set name',
                      hintStyle: TextStyle(color: hintColor, fontSize: 14.0),
                      filled: true,
                      fillColor: textFieldFillColor,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _createCardSet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF557A46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
