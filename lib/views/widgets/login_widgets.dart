import 'package:flutter/material.dart';

Widget createTextField({
  required TextEditingController
  controller, // controller passed from the main login
  required String label, // label (showin inside the textfield)
  bool obscure = false, // meaning that should it be *** ?
  String? Function(String?)? validator, // for email
}) {
  return SizedBox(
    width: 350,
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        // The border when the field is selected
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF5D8A56), width: 1.0),
        ),
        // Style for the label when it floats to the top
        floatingLabelStyle: const TextStyle(color: Color(0xFF5D8A56)),
        // The default border
        border: const OutlineInputBorder(),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18.0),
      ),
      validator: validator,
    ),
  );
}
