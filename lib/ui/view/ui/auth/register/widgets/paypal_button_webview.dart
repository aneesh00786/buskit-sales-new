import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';
class PayPalButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final String label;

  const PayPalButton({
    super.key,
    required this.onPressed,
    this.height = 50,
    this.color = const Color(0xFFFFCC00),
    this.label = 'Pay with PayPal',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/images/2-2-paypal-logo-transparent-png.png',
          height: height * 0.6,
        ),
        label: CustomText(
          content: label,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
