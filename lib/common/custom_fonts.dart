import 'package:flutter/material.dart';

const String fontFamilyName = 'Poppins_Regular';

const String myFont = 'Poppins_Regular';
const String commonFont = 'BarlowCondensed';

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

//=============================================================================
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
      {Key? key,
      required this.text,
      this.fontSize = 12.0,
      this.align = TextAlign.center})
      : super(key: key);

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

class DialogTableHeaderTextWhite extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign align;

  const DialogTableHeaderTextWhite(
      {super.key,
      required this.text,
      this.fontSize = 12.0,
      this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        fontFamily: 'Poppins_Regular',
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  Color? color;
  String? fontFamily;
  String? content;
  double? fontSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  int? maxLine;
  TextOverflow? overflow;

  CustomText(
      {super.key,
      this.color,
      this.fontFamily,
      this.content,
      this.fontSize,
      this.fontWeight,
      this.textAlign,
      this.maxLine,
      this.overflow});

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
