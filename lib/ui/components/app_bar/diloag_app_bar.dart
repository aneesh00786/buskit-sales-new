import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common_size/nk_font_size.dart';

// ignore: must_be_immutable
class DiloagAppBar extends PreferredSize {
  Widget? appBarChild;
  Size? appBarSize;
  String title;
  Color? backgroundColor;
  void Function()? onCloseTap;

  DiloagAppBar(
      {super.key,
      this.appBarChild,
      this.appBarSize,
      required this.title,
      this.backgroundColor,
      this.onCloseTap})
      : super(
            child: Container(),
            preferredSize: appBarSize ??
                Size.fromHeight(AppDimensions.instance.height * 0.08));

  @override
  Widget get child => PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        padding: nkRegularPadding(),
        decoration: BoxDecoration(color: backgroundColor ?? primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appBarChild ??
                MyRegularText(
                  label: title,
                  fontWeight: NkGeneralSize.nkBoldFontWeight(),
                  fontSize: NkFontSize.largeFont(),
                  color: buttonTextColor,
                ),
            closeIcon
          ],
        ),
      ));

  Widget get closeIcon => InkResponse(
        onTap: onCloseTap ??
            () {
              Get.back();
            },
        child: Container(
          height: AppDimensions.instance.height * 0.05,
          decoration: BoxDecoration(
            border: Border.all(color: buttonTextColor),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                size: AppDimensions.instance.height * 0.02,
                color: buttonTextColor,
              ),
            ),
          ),
        ),
      );
}
