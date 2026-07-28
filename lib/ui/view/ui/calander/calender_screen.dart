import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  bool showChatbotMobile = false;
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
      double screenWidth = MediaQuery.of(context).size.width;
      bool isMobile = screenWidth < 600;

      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CustomText(content: 'Calender'.tr,fontWeight: FontWeight.bold,),
              ),
              Spacer(),
              if (!isMobile) const ChatbotTopBarButton(routeName: '/attendance'),
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.info_outline, color: primaryColor),
                  onPressed: () {
                    setState(() {
                      showChatbotMobile = !showChatbotMobile;
                    });
                  },
                ),
              const SizedBox(width: 8),
              const NotificationWidget(
                startDate: '',
                endDate: '',
              ),
              profiloe(),
            ],
            automaticallyImplyLeading: false,
            bottom: (isMobile && showChatbotMobile)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(50.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, bottom: 8.0, top: 4.0),
                        child: const ChatbotTopBarButton(routeName: "/attendance"),
                      ),
                    ),
                  )
                : null,
          ),
          backgroundColor: white,
          body: Column(
            children: [
              nkMediumSizeBox(),
              Obx(() {
                log(calenderController.routeCredit.value.toString());
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
