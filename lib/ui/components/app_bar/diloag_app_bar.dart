import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiloagAppBar extends PreferredSize {
  final Widget? appBarChild;
  final Size? appBarSize;
  final String title;
  final Color? backgroundColor;
  final void Function()? onCloseTap;

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
        height: 55,
        padding: const EdgeInsets.all(14),
        // nkRegularPadding(),
        decoration: BoxDecoration(color: backgroundColor ?? primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appBarChild ??
                MyRegularText(
                  label: title,
                  fontWeight: NkGeneralSize.nkBoldFontWeight(),
                  fontSize: 16,
                  // NkFontSize.largeFont(),
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
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 25.8,
            height: 25.8,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: red,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(3.5),
                child: Icon(
                  Icons.close,
                  color: red,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      );
}
