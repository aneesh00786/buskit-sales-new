import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:flutter/material.dart';

Widget buildInputField(
    TextEditingController controller, String labelText, String icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, 
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 18.0),
          labelText: labelText,
          labelStyle:
              TextStyle(color: const Color(0xFF0F172A)),
          prefixIcon: filledIcon(icon),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.blue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
                color: Colors.grey.shade400, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.red, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ),
  );
}