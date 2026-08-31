// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String fontFamilyName = 'Poppins_Regular';
const String myFont = 'Poppins_Regular';
const String commonFont = 'Poppins_Regular';

const TextStyle cardHeadingTextStyle = TextStyle(
  fontFamily: fontFamilyName,
  fontWeight: FontWeight.bold,
  fontSize: 13.0,
  color: Colors.black,
);

const TextStyle bodyTextStyle = TextStyle(
  fontFamily: fontFamilyName,
  fontWeight: FontWeight.normal,
  fontSize: 12.0,
);

const TextStyle tabTextStyle = TextStyle(
  fontFamily: fontFamilyName,
  fontWeight: FontWeight.normal,
  fontSize: 10.0,
  color: Colors.black,
);

TextStyle dialogHeaderTextStyle({
  Color color = Colors.white,
  FontWeight fontWeight = FontWeight.w600,
  double fontSize = 12.0,
  String fontFamily = 'Poppins_Regular',
}) {
  return TextStyle(
    color: color,
    fontWeight: fontWeight,
    fontSize: fontSize,
    fontFamily: fontFamily,
  );
}

TextStyle dialogTableHeaderStyle({
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.w600,
  double fontSize = 12.0,
  String fontFamily = 'Poppins_Regular',
}) {
  return TextStyle(
    color: color,
    fontWeight: fontWeight,
    fontSize: fontSize,
    fontFamily: fontFamily,
  );
}

class DialogHeaderText extends StatelessWidget {
  final String text;
  final double fontSize;

  const DialogHeaderText({
    super.key,
    required this.text,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          letterSpacing: 0.5,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }
}

class DialogTableHeaderText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign align;

  const DialogTableHeaderText(
      {super.key,
      required this.text,
      this.fontSize = 12.0,
      this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  Color? color;
  String? fontFamily;
  String? content;
  double? fontSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  int? maxLine;
  TextOverflow? overflow;

  CustomText({
    super.key,
    this.color,
    this.fontFamily,
    this.content,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLine,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      content ?? '',
      style: TextStyle(
          color: color ?? Colors.black,
          fontFamily: fontFamily ?? 'Poppins_Regular',
          fontSize: fontSize,
          fontWeight: fontWeight),
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: overflow,
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  Color? color;

  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(color),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

Widget dashboardContainerHeader(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(
              Icons.space_dashboard_rounded,
              size: 14,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget filledIcon(String svgIconPath) {
  return SvgPicture.asset(
    svgIconPath,
    fit: BoxFit.scaleDown,
    height: AppDimensions.instance.height * 0.014,
    width: AppDimensions.instance.width * 0.014,
  );
}

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  color: primaryColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.add_circle_outline,
              color: primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
