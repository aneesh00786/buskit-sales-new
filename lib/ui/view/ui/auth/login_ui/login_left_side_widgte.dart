import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginLeftSideWidget extends StatefulWidget {
  const LoginLeftSideWidget({Key? key}) : super(key: key);

  @override
  State<LoginLeftSideWidget> createState() => _LoginLeftSideWidgetState();
}

class _LoginLeftSideWidgetState extends State<LoginLeftSideWidget> {
  ValueNotifier<String> changeNotify = ValueNotifier(Assets.iconsIcLoginLogo);
  @override
  Widget build(BuildContext context) {
    return Container(
 width: AppDimensions.createInstance(
        context, 
        BoxConstraints(
          maxWidth: AppDimensions.instance.width,
          maxHeight: AppDimensions.instance.height,
        )
      ).width,
      height: AppDimensions.createInstance(
        context, 
        BoxConstraints(
          maxWidth: AppDimensions.instance.width,
          maxHeight: AppDimensions.instance.height,
        )
      ).height / 2,
      decoration: const BoxDecoration(color: backgroundColor),
      child: ValueListenableBuilder(
        builder: (BuildContext context, String val, Widget? child) {
          return SvgPicture.asset(
            "assets/icons/ic_login_logo.svg",
            width: AppDimensions.instance.width,
            height: AppDimensions.instance.height / 2,
            fit: BoxFit.contain,
          );
        },
        valueListenable: changeNotify,
      ),
    );
  }
}
