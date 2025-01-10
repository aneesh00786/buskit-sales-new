import 'package:flutter/material.dart';

class CustomCartButton extends StatelessWidget {
  String text;
  Color? color;
  VoidCallback onTap;
  double? size;
  CustomCartButton({super.key, 
  required this.text,
  this.color,
  required this.onTap,
  required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:color ?? Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style:  TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size,
            fontFamily: 'Poppins_Regular',
          ),
        ),
      ),
    );
  }
}
