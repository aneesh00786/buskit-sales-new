import 'package:flutter/material.dart';

const String fontFamilyName = 'Poppins_Regular';
const String myFont = 'Poppins_Regular';

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
  // color: Colors.grey,
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
//
class DialogHeaderText extends StatelessWidget {
  final String text;
  final double fontSize;

  const DialogHeaderText({
    Key? key,
    required this.text,
    this.fontSize = 12.0,
  }) : super(key: key);

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
          color: color != null ? color : Colors.black,
          fontFamily: fontFamily != null ? fontFamily : 'Poppins_Regular',
          fontSize: fontSize,
          fontWeight: fontWeight),
      textAlign: textAlign != null ? textAlign : null,
      maxLines: maxLine == null ? null : maxLine,
      overflow: overflow,
    );
  }
}

Widget dialogCloseButton(BuildContext context, Color color) {
  return CircleAvatar(
    backgroundColor: Colors.transparent,
    child: SizedBox(
      width: 25.8,
      height: 25.8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color, // Use the passed color here
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: color, // Use the passed color here
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).pop(); // Use the passed context here
            },
          ),
        ),
      ),
    ),
  );
}

//=============================================================================
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  Color? color;

  CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(color),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
