import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final ValueChanged<String> onChange;
  final IconData icon;

  const CustomSearchBar({
    super.key,
    required this.text,
    required this.controller,
    required this.onChange,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChange,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
            width: 1.5,
          ),
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
class WarningDialog extends StatelessWidget {
  final String message;
  final VoidCallback onOkPressed;

  const WarningDialog({
    super.key,
    required this.message,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 50,
            ),
          ),
        ),
        Center(
          child: CustomText(
            content: message,
            fontSize: 17,
          ),
        ),
        TextButton(
          onPressed: onOkPressed,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}