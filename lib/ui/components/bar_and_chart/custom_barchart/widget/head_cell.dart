import 'package:flutter/material.dart';

class HeaderCell extends StatelessWidget {
  final String label;
  final TextAlign align;

  const HeaderCell({
    required this.label,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFFAEAEB2),
        letterSpacing: 0.8,
        fontFamily: 'Poppins_Regular',
      ),
    );
  }
}