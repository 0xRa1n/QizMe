import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/utils/functions.dart';

class AddCardSet extends StatefulWidget {
  const AddCardSet({super.key});

  @override
  State<AddCardSet> createState() => _AddCardSetState();
}

class _AddCardSetState extends State<AddCardSet> {
  final TextEditingController _cardSetNameController = TextEditingController();

  // get the text
  String get cardSetName => _cardSetNameController.text;
  Future<void> _createCardSet() async {
    // call the service to create the card set
    try {
      final result = await CardService.createCardSet(name: cardSetName);
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
          title: 'Login Failed',
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF8F9FA,
        ), // Slightly off-white background
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFFEBEBEB), // Light grey header matching the image
        //   elevation: 0,
        //   leading: Padding(
        //     padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         border: Border.all(color: Colors.black, width: 1.5),
        //       ),
        //       child: IconButton(
        //         padding: EdgeInsets.zero,
        //         icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        //         onPressed: () {
        //           // Navigation logic to pop the route
        //         },
        //       ),
        //     ),
        //   ),
        //   title: const Text(
        //     'Add Card Sets',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 18.0,
        //     ),
        //   ),
        //   centerTitle: false,
        // ),
        body: Padding(
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
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.black54, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card set name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _cardSetNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter a card set name',
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontSize: 14.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(color: Colors.black38),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(color: Colors.black38),
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
        ),
      ),
    );
  }
}
