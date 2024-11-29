import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_left_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController loginController = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        AppDimensions.instance.height;
        AppDimensions.instance.width;
      });
    });
    return Scaffold(
        backgroundColor: white,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: Row(
          children: [
            const Flexible(child: LoginLeftSideWidget()),
            Flexible(
                child: LoginRightSideWidget(
              loginController: loginController,
            )),
          ],
        ));
  }
}
// Container(
          
//          width: AppDimensions.createInstance(
//             context, 
//             BoxConstraints(
//               maxWidth: AppDimensions.instance.width,
//               maxHeight: AppDimensions.instance.height,
//             )
//           ).width,
//           height: AppDimensions.createInstance(
//             context, 
//             BoxConstraints(
//               maxWidth: AppDimensions.instance.width,
//               maxHeight: AppDimensions.instance.height,
//             )
//           ).height / 2,
//           decoration: const BoxDecoration(color: backgroundColor),
//           child: ValueListenableBuilder(
//             builder: (BuildContext context, String val, Widget? child) {
//               return SvgPicture.asset(
//                 "assets/icons/ic_login_logo.svg",
//                 width: AppDimensions.instance.width,
//                 height: AppDimensions.instance.height / 2,
//                 fit: BoxFit.contain,
//               );
//             },
//             valueListenable: changeNotify,
//           ),
//         ),