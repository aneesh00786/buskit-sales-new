import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.maxFinite,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              primaryColor.withOpacity(0.7),
              primaryColor.withOpacity(0.5),
              primaryColor.withOpacity(0.7),
            ])
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/loginImage 7.png",height: 220,),
              SizedBox(height: 50,),
              CustomText(content: 'Welcome!',color: white,fontWeight: FontWeight.w600,fontSize: 50,),
        CustomText(content: 'Please login to your account to continue..!',color: white,fontWeight: FontWeight.w400,fontSize: 20,)
            ],
          ),
        ),
      ],
    );
  }
}
