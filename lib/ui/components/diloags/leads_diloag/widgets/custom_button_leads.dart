import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class CustomButtonLeads extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const CustomButtonLeads({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
