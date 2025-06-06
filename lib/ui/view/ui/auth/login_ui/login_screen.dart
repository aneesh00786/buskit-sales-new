import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_left_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    loginController.initializeTabController(this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          ),
        ],
      ),
    );
  }
}
