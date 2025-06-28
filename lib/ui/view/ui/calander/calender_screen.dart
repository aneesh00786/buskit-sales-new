import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  CalenderMapController calenderController = Get.put(CalenderMapController());
  HomeController homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future initialize() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    await calenderController.fetchCalenderEvents(startOfMonth);
    calenderController.loadCalenderEventV1;
    await calenderController.getRouteCredit();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              const NotificationWidget(
                startDate: '',
                endDate: '',
              ),
              profiloe(),
            ],
            automaticallyImplyLeading: false,
          ),
          backgroundColor: white,
          body: Column(
            children: [
              nkMediumSizeBox(),
              Obx(() {
                log(calenderController.isRouteCreditLoading.value.toString());
                return SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Spacer(),
                      // come back
                      // Container(
                      //   padding: EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.shade50,
                      //     borderRadius: BorderRadius.circular(5),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       CustomText(content: 'Route Credit :  '),
                      //       CustomText(
                      //         content:
                      //             calenderController.isRouteCreditLoading.value
                      //                 ? 'Loading...'
                      //                 : formatAmount(
                      //                     calenderController.routeCredit.value),
                      //         color: Colors.blue.shade600,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      nkMediumSizeBox(),
                    ],
                  ),
                );
              }),
              nkMediumSizeBox(),
              Flexible(
                child: CalenderBottomWidget(
                  calenderController: calenderController,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
