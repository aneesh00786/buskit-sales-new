import 'dart:developer';

import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarX_sidebar.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebar_only_icon.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 HomeController homeController =Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    SessionHelper().getLoginData().then((value) {
      setState(() {
        homeController.userDetails = value;
        log('User details updated: ${value}');
      });
    }).catchError((error) {
      log('Error fetching login data: $error');
    });

    homeController.sidebarXController
        .addListener(() {
          homeController.changePageRouting();
          log('SidebarXController listener triggered');
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        key: HomeController.homeScaffoldKey,
        extendBody: false,
        drawer: Drawer(
          child: NkSidebarXSideBar(
            key: const Key("drawer"),
            controller: homeController.sidebarXController,
            itemList: homeController.drawSidebarItems(),
            userDetails: homeController.userDetails ?? LoginData(),
          ),
        ),
        body: SafeArea(
          child: Row(
            children: [
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NkSideBarOnlyIcon(
                    headerWidget: homeController.upperSideBar(),
                    itemList: homeController.drawSidebarItems(),
                    sidebarXController: homeController.sidebarXController,
                  ),
                );
              }),
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
      ),
    );
  }
}
