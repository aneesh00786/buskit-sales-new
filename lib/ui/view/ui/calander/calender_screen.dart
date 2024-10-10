import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/calender_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  CalenderController calenderController = Get.put(CalenderController());

  @override
  void initState() {
    calenderController.calenderAllEvents();
    calenderController.loadCalenderEvent_v1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: white,
          body: Column(
            children: [
              CalenderTopWidget(
                calenderController: calenderController,
              ),
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
