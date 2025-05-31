// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';

class RegisterTextField extends StatelessWidget {
  final String hinttext;
  final Icon? icon;
  final bool? showSuffixIcon;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  void Function(String)? onChanged;

  RegisterTextField({
    super.key,
    required this.hinttext,
    this.icon,
    required this.textEditingController,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.showSuffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hinttext,
        prefixIconColor: Colors.grey,
        prefixIcon: icon,
        suffixIcon: showSuffixIcon ?? false
            ? Icon(EneftyIcons.tick_square_outline,color: Colors.green,)
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}