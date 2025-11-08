import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Padding buildTextFormField({
  required TextEditingController controller,
  required String hintText,
  TextInputType? keyboardType,
  required Widget prefix,
  IconButton? suffix,
  String? Function(String?)? validator,
  bool obscureText = false,
  Future<Null> Function()? onTap,

}) {
  // FocusNode to handle focus state
  FocusNode focusNode = FocusNode();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 9.0,horizontal: 12.0),
    child: Focus(
      onFocusChange: (hasFocus) {
        // You can manage state or perform actions based on focus
      },
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode,
        decoration: InputDecoration(
          prefixIcon: prefix,
          suffixIcon: suffix,
          hintText: hintText,
          // Using Container to apply BoxDecoration
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          border: InputBorder.none, // Remove border from InputDecoration
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusNode.hasFocus ? Colors.red : Colors.grey, // Change border color based on focus
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Color when focused
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: validator,
      ),
    ),
  );
}
