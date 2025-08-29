// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class RegisterPhoneNumberField extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final LoginController loginController;

  const RegisterPhoneNumberField({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.loginController,
  });

  @override
  _RegisterPhoneNumberFieldState createState() =>
      _RegisterPhoneNumberFieldState();
}

class _RegisterPhoneNumberFieldState extends State<RegisterPhoneNumberField> {
  String? _validationMessage;
  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  void _validatePhoneNumber() {
    final text = widget.textEditingController.text;
    if (text.length < 10) {
      setState(() {
        _validationMessage = 'Phone number must be 10 digits';
      });
    } else {
      setState(() {
        _validationMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.textEditingController,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Phone Number',
            counterText: '',
            errorText: _validationMessage,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            } else if (value.length < 10) {
              return 'Please enter your 10-digit phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
