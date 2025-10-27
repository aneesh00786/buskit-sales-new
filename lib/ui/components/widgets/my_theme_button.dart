import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyThemeButton extends StatelessWidget {
  final String? buttonText;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? fontColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final double? letterSpacing;
  final Widget? child;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? padding;
  final bool? isRoundedCorner;

  const MyThemeButton({
    super.key,
    @required this.buttonText,
    this.color = primaryButtonColor,
    this.onPressed,
    this.fontSize = 16.0,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.letterSpacing,
    this.shape,
    this.isRoundedCorner = false,
    this.fontColor = buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Get.theme;
    return isRoundedCorner ?? false
        ? MaterialButton(
            height: height ?? 42,
            minWidth: width,
            onPressed: onPressed,
            textTheme: theme.buttonTheme.textTheme,
            shape: shape ??
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        NkGeneralSize.nkCommonBorderRadius(borderRadius: 25))),
            padding: padding,
            color: color ?? theme.buttonTheme.colorScheme?.background,

            disabledColor: color,
            child: SizedBox(
              width: width,
              height: height,
              child: child ??
                  Center(
                    child: MyRegularText(
                      label: buttonText ?? "ADD NAME !!!!",
                      color: fontColor,
                      fontSize: fontSize,
                      letterSpacing: letterSpacing,
                    ),
                  ),
            ),
          )
        : MaterialButton(
            height: height ?? 42,
            minWidth: width,
            onPressed: onPressed,
            shape: shape ??
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        NkGeneralSize.nkCommonBorderRadius())),
            padding: padding,
            color: color ?? theme.buttonTheme.colorScheme?.background,

            disabledColor: color ?? theme.buttonTheme.colorScheme?.background,
            child: SizedBox(
              width: width,
              height: height,
              child: child ??
                  Center(
                    child: MyRegularText(
                      label: buttonText ?? "ADD NAME !!!!",
                      color: fontColor,
                      fontSize: fontSize,
                      letterSpacing: letterSpacing,
                    ),
                  ),
            ),
          );
  }
}
