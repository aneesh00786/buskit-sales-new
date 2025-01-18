import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  CalenderMapController calenderController = Get.put(CalenderMapController());


    @override
  void initState() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    calenderController.fetchCalenderEvents(startOfMonth);

    calenderController.loadCalenderEventV1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
             NotificationWidget(startDate: '', endDate: '',),
              profiloe(),
            ],
          ),
          backgroundColor: white,
          body: Column(
            children: [
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
