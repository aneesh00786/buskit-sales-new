// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PerformanceWidget extends StatelessWidget {
  final String title;
  final String count;
  final String svg;
  final Color svgBgColor;

  const PerformanceWidget({
    super.key,
    required this.title,
    required this.count,
    required this.svg,
    required this.svgBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 205, 204, 204),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: svgBgColor,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Center(
              child: Image.asset(
                svg,
                width: 24,
                height: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
