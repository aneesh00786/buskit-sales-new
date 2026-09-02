import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarx.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebar_only_icon.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    SessionHelper().getLoginData().then((value) {
      setState(() {
        homeController.userDetails = value;
      });
    }).catchError((error) {
    });

    homeController.sidebarXController.addListener(() {
      homeController.changePageRouting();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false,
      key: HomeController.homeScaffoldKey,
      extendBody: false,
      drawer: Drawer(
        child: NkSidebarXSideBar(
          key: const Key("drawer"),
          controller: homeController.sidebarXController,
          itemList: homeController.drawSidebarItems(context),
          userDetails: homeController.userDetails ?? LoginData(),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              height: double.infinity,
              width: 58,
              child: Obx(() {
                return NkSideBarOnlyIcon(
                  headerWidget: homeController.upperSideBar(),
                  itemList: homeController.drawSidebarItems(context),
                  sidebarXController: homeController.sidebarXController,
                );
              }),
            ),
            Expanded(
              flex: 2,
              child: Navigator(
                reportsRouteUpdateToEngine: true,
                initialRoute: AppRoutes.dashboard,
                key: Get.nestedKey(2),
                onGenerateRoute: homeController.onGenerateRoute,
              ),
            )
          ],
        ),
      ),
    );
  }
}
