import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
//import 'package:rounded_loading_button/rounded_loading_button.dart';

class NkLoadingButton extends StatefulWidget {
  final String? buttonText;
  final VoidCallback? onPressed;

  final Color? color;
  final Color? fontColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final double? letterSpacing;
  final RoundedLoadingButtonController? btnController;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool? isRoundedCorner;

  const NkLoadingButton({
    Key? key,
    @required this.buttonText,
    this.color = primaryButtonColor,
    this.onPressed,
    this.fontSize = 16.0,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.letterSpacing,
    this.isRoundedCorner = false,
    this.fontColor = buttonTextColor,
    this.btnController,
  }) : super(key: key);

  @override
  State<NkLoadingButton> createState() => _NkLoadingButtonState();
}

class _NkLoadingButtonState extends State<NkLoadingButton> {
  RoundedLoadingButtonController? _btnController;

  @override
  void initState() {
    _btnController = widget.btnController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Get.theme;
    return widget.isRoundedCorner ?? true
        ? RoundedLoadingButton(
            height: widget.height ?? 42,
            width: widget.width ?? Get.width,
            errorColor: errorColor,
            onPressed: widget.onPressed,
            // tex: theme.buttonTheme.textTheme,
            resetAfterDuration: true,
            completionDuration: const Duration(milliseconds: 3000),
            resetDuration: const Duration(seconds: 5),
            successColor: primaryColor,
            borderRadius: NkGeneralSize.nkCommonBorderRadius(borderRadius: 25),
            color: widget.color ?? theme.buttonTheme.colorScheme?.background,
            duration: const Duration(milliseconds: 1000),
            /* focusColor: color ??
                theme.buttonTheme.colorScheme?.background.withOpacity(0.7),*/
            disabledColor: widget.color,
            controller: _btnController!,
            child: Container(
              constraints: BoxConstraints.loose(
                  Size(widget.width ?? Get.width, widget.height ?? 32)),
              child: widget.child ??
                  Center(
                    child: MyRegularText(
                      label: widget.buttonText ?? "ADD NAME !!!!",
                      color: widget.fontColor,
                      fontSize: widget.fontSize,
                      letterSpacing: widget.letterSpacing,
                    ),
                  ),
            ),
          )
        : RoundedLoadingButton(
            height: widget.height ?? 42,
            width: widget.width ?? AppDimensions.instance!.width,
            onPressed: widget.onPressed,
            errorColor: errorColor,
            successColor: primaryColor,
            resetAfterDuration: true,
            completionDuration: const Duration(milliseconds: 3000),
            resetDuration: const Duration(seconds: 5),
            duration: const Duration(milliseconds: 1000),
            borderRadius: NkGeneralSize.nkCommonBorderRadius(borderRadius: 8),
            color: widget.color ?? theme.buttonTheme.colorScheme?.background,
            /* focusColor: color ??
                theme.buttonTheme.colorScheme?.background.withOpacity(0.7),*/
            disabledColor:
                widget.color ?? theme.buttonTheme.colorScheme?.background,
            controller: _btnController!,
            child: Container(
              constraints: BoxConstraints.loose(
                  Size(widget.width ?? Get.width, widget.height ?? 32)),
              child: widget.child ??
                  Center(
                    child: MyRegularText(
                      label: widget.buttonText ?? "ADD NAME !!!!",
                      color: widget.fontColor,
                      fontSize: widget.fontSize,
                      letterSpacing: widget.letterSpacing,
                    ),
                  ),
            ),
          );
  }
}
