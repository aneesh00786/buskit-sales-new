import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:flutter/material.dart';

class MyRegularSelectableText extends StatelessWidget {
  final String label;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final TextAlign? align;
  final int? maxlines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? stepGranularity;
  final TextStyle? style;
  final TextDecorationStyle? textDecorationStyle;

  const MyRegularSelectableText({
    Key? key,
    required this.label,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.align = TextAlign.center,
    this.maxlines,
    this.decoration = TextDecoration.none,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.stepGranularity,
    this.style,
    this.textDecorationStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // ThemeData theme = Get.theme;
    return label.isNotEmpty
        ? SelectableText(label.isNotEmpty ? label : '',
            textAlign: align,
            maxLines: maxlines ?? 2,
            //softWrap: true,
            //minFontSize: 12,
            //overflow: overflow,
            style: style ??
                TextStyle(
                  color: color,
                  decorationStyle: textDecorationStyle,
                  fontSize: fontSize ?? NkFontSize.regularFont(),
                  letterSpacing: letterSpacing,
                  fontWeight: fontWeight ?? NkGeneralSize.nkGeneralFontWeight(),
                  fontStyle: FontStyle.normal,
                  decoration: decoration,
                  //decorationColor: theme.de,
                  decorationThickness: 1,
                ))
        : ErrorWidget.withDetails(
            message: "PLEASE DO NOT EMPTY LIABLE",
            error: FlutterError("PLEASE DO NOT EMPTY LIABLE"),
          );
  }
}
