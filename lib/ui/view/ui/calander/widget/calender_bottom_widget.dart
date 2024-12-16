import 'dart:developer';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';

class CalenderBottomWidget extends StatefulWidget {
  final CalenderMapController calenderController;

  CalenderBottomWidget({
    super.key,
    required this.calenderController,
  });

  @override
  State<CalenderBottomWidget> createState() => _CalenderBottomWidgetState();
}

class _CalenderBottomWidgetState extends State<CalenderBottomWidget> {
  bool navigatedToMap = false;
  Customer? selectedCustomer;

  @override
  void initState() {
    widget.calenderController.fetchCalenderEvents();
    widget.calenderController.loadCalenderEvent_v1;
    super.initState();
  }
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
          fontFamily: "Poppins_Regular"
        ),
      ),
      pageTransitionCurve: Curves.easeInOutCubicEmphasized,
      borderColor: white,
      cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) {
        int eventCount = event.length;
        return GestureDetector(
          onTap: () {
            if (event.isNotEmpty) {
              widget.calenderController.clearSelections();
              Get.dialog(SelectCustomerDiloag(
                dateTime: date,
                calenderMapController: widget.calenderController,
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
                CustomText(
                  content: date.day.toString(),
                  color: isToday
                      ? buttonTextColor
                      : !isInMonth
                          ? secondaryTextColor.withOpacity(0.5)
                          : null,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                if (eventCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: (date.isBefore(DateTime.now()) &&
                                !date.isSameDate(DateTime.now())) &&
                            event.any((e) => e.event!.checkIn == null)
                        ? const Color(0xffCCCC00)
                        : Colors.green,
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
      controller: widget.calenderController.eventControllerv1,
      initialMonth: DateTime.now(),
      maxMonth: DateTime(DateTime.now().year, 12, 31),
      minMonth: DateTime(DateTime.now().year, 1, 1),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
