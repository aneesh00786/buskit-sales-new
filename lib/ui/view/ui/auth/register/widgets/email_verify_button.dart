// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:flutter/material.dart';

class VerifyButton extends StatefulWidget {
  final LoginController loginController;
  final TextEditingController textEditingController;

  const VerifyButton({
    super.key,
    required this.loginController,
    required this.textEditingController,
  });

  @override
  _VerifyButtonState createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<VerifyButton> {
  bool _isLoading = false;

  void _handleVerify() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.loginController
          .verifyEmail(widget.textEditingController.text);
      log('Verify button clicked!');
    } catch (error) {
      log('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 80,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Verify',
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
