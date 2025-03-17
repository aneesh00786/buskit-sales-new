import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CartTotalWidget extends StatelessWidget {
  String title;
  double content;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color1;
  Color? color2;
   CartTotalWidget({
    super.key,
    required this.content,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.color1,
    this.color2,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            content: title,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: fontFamilyName,
            color: color1 ?? Colors.black,
          ),
          CustomText(
            content: formatAmount(content.toStringAsFixed(2)),
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: fontFamilyName,
            color: color2 ?? Colors.black,
          ),
        ],
      ),
    );
  }
}