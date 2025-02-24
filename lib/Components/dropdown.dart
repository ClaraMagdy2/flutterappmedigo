import 'package:flutter/material.dart';

Widget buildDropdownField({
  required String? value,
  required String hintText,
  required IconData prefixIcon,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  // FocusNode to handle focus state
  FocusNode focusNode = FocusNode();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 12.0),
    child: Focus(
      onFocusChange: (hasFocus) {
        // You can manage state or perform actions based on focus
      },
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          hintText: hintText,
          // Using Container with BoxDecoration for custom style
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          border: InputBorder.none, // Remove default border
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusNode.hasFocus ? Colors.red : Colors.grey, // Change color on focus
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Focused color
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

