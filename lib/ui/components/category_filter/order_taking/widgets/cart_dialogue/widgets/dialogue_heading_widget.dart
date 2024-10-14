
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class DialogueHedingWidget extends StatelessWidget {
  const DialogueHedingWidget({
    super.key,
    required this.height,
    required this.width,
    required this.title,
  });
  final double height;
  final double width;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 50),
          child: Container(
            height: 10,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            width: double.infinity,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.01, horizontal: height * 0.04),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: CustomText(
                  content: title,
                  fontSize: width > 1200 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamilyName,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const CircleAvatar(
                radius: 15,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 14,
                ),
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}