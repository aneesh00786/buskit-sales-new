import 'dart:io';

import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/material.dart';

class NkGeneralSize {
  static double nkIconSize({double? iconSize}) => iconSize ?? AppDimensions.instance!.height * 0.05;

  static double nkCommonBorderRadius({double? borderRadius}) => borderRadius ?? 10.0;

  static FontWeight nkGeneralFontWeight({FontWeight? fontWeight}) => fontWeight ?? FontWeight.w400;

  static FontWeight nkBoldFontWeight({FontWeight? fontWeight}) => fontWeight ?? FontWeight.bold;

  static ScrollPhysics commonPysics({ScrollPhysics? physics}) =>
      Platform.isAndroid ? physics ?? const AlwaysScrollableScrollPhysics() : physics ?? const AlwaysScrollableScrollPhysics();
}
