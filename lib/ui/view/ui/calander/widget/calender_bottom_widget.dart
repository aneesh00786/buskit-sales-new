import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/select_customer_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalenderBottomWidget extends StatelessWidget {
  final CalenderMapController calenderController;

  const CalenderBottomWidget({super.key, required this.calenderController});

  @override
  Widget build(BuildContext context) {
    return MyCommnonContainer(
      color: white,
      child: calenderWidget(),
    );
  }

  Widget calenderWidget() {
    return MonthView(
      cellAspectRatio:
          AppDimensions.instance.orientation == Orientation.landscape
              ? 2.0
              : 0.78,
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        headerTextStyle: TextStyle(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      pageTransitionCurve: Curves.easeInOutCubicEmphasized,
      borderColor: white,
      cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) {
        int eventCount = event.length;
        return GestureDetector(
          onTap: () {
            if (event.isNotEmpty) {
              calenderController.clearSelections();
              Get.dialog(SelectCustomerDiloag(
                dateTime: date,
                calenderMapController: calenderController,
                eventData: event,
              ));
              log('Date : $date');
            }
          },
          child: MyCommnonContainer(
            borderRadiusGeometry: BorderRadius.circular(15),
            border: Border.all(color: black.withOpacity(0.1)),
            boxShadow: isInMonth
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: Offset(3, 3),
                      spreadRadius: 1,
                    )
                  ]
                : [],
            color: isToday
                ? primaryColor
                : !isInMonth
                    ? secondaryTextColor.withOpacity(0.08)
                    : white,
            padding: nkRegularPadding(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyRegularText(
                  label: date.day.toString(),
                  color: isToday
                      ? buttonTextColor
                      : !isInMonth
                          ? secondaryTextColor.withOpacity(0.5)
                          : null,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                if (eventCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: MyRegularText(
                      label: eventCount.toString(),
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      headerStringBuilder: (date, {secondaryDate}) {
        return NKDateUtils.formatMonth(date);
      },
      startDay: WeekDays.monday,
      controller: calenderController.eventControllerv1,
      initialMonth: DateTime.now(),
      maxMonth: DateTime(DateTime.now().year, 12, 31),
      minMonth: DateTime(DateTime.now().year, 1, 1),
    );
  }
}
