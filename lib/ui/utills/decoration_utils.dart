import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class DecorationUtils {
  BuildContext context;

  DecorationUtils(this.context);

  InputDecoration getUnderlineInputDecoration({
    String? labelText = "",
    bool isRequire = false,
    bool isEnable = true,
    final Color? enableColor,
    final Color? disabledColor,
    bool? alignLabelWithHint,
    final Color? focusedColor,
    final Color? labelTextColor,
    final FloatingLabelBehavior? floatingLabelBehavior,
    icon,
    final Widget? prefixIcon,
    final Widget? suffixIcon,
    final BorderRadius? borderRadius,
    final Color? fillColor,
    final Color? hintColor,
    final EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      fillColor: isRequire ? fillColor ?? textFieldBgColor : textFieldBgColor,
      filled: (isEnable) ? true : true,
      alignLabelWithHint: alignLabelWithHint,
      suffixIcon: suffixIcon,
      icon: icon,
      border: InputBorder.none,
      prefixIcon: prefixIcon,
      contentPadding: contentPadding ?? const EdgeInsets.all(8.0),
      labelText: labelText,
      counterText: "",
      labelStyle: TextStyle(
        color: labelTextColor ?? Colors.blueGrey[300],
      ),
      hintStyle: TextStyle(
        color: hintColor ?? Colors.grey,
      ),
      floatingLabelBehavior:
          floatingLabelBehavior ?? FloatingLabelBehavior.never,
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: enableColor ?? textFieldBgColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: disabledColor ?? textFieldBgColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: focusedColor ?? textFieldBgColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
    );
  }
}
