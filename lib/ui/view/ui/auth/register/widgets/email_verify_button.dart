// ignore_for_file: library_private_types_in_public_api


import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

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
    } catch (error) {
      //
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVerified = widget.loginController.isEmailVerified.value;
      final isResendOtp = widget.loginController.isResend.value;
      return SizedBox(
        height: 40,
        width: 80,
        child: AbsorbPointer(
          absorbing: _isLoading || isVerified,
          child: ElevatedButton(
            onPressed: _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: isVerified ? Colors.green : primaryColor,
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
                : Text(
                    isResendOtp
                        ? 'Resend OTP'
                        : isVerified
                            ? 'Verified'
                            : 'Verify',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
