import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class CustomHeaderContainer extends StatelessWidget {
  const CustomHeaderContainer({
    super.key,
    required this.text,
    required this.fontSize,
  });
  final String text;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: lightPrimaryColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(100))
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CustomText(
                content: text,
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
