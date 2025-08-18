// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/select_customer_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:intl/intl.dart';

class CalenderBottomWidget extends StatefulWidget {
  final CalenderMapController calenderController;

  const CalenderBottomWidget({
    super.key,
    required this.calenderController,
  });

  @override
  State<CalenderBottomWidget> createState() => _CalenderBottomWidgetState();
}

class _CalenderBottomWidgetState extends State<CalenderBottomWidget> {
  bool navigatedToMap = false;
  Customer? selectedCustomer;
  final subscriptionController = Get.find<SubscriptionController>();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MyCommnonContainer(
      color: white,
      child: calenderWidget(),
    );
  }

  Widget calenderWidget() {
    final rawDayList = SessionHelper.settingsData
            ?.firstWhere(
              (setting) => setting.key == 'day_list',
              orElse: () => AllCompanySettingsData(
                key: 'day_list',
                value: '',
              ),
            )
            .value ??
        '';

    List<String> dayList =
        rawDayList.split(',').map((day) => day.trim()).toList();

    const Map<String, int> dayNameToInt = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    List<int> parsedDays = dayList
        .map((day) => dayNameToInt[day] ?? -1)
        .where((day) => day != -1)
        .toList();

    return MonthView(
      cellAspectRatio:
          AppDimensions.instance.orientation == Orientation.landscape
              ? 1.7
              : 0.8,
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        headerTextStyle: const TextStyle(
            color: black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins_Regular"),
      ),
      onPageChange: (date, page) async {
        final isOnline = await ConnectivityService().isOnline();
        if (!isOnline) {
          showCustomToastDisplay(
            context,
            'You are offline. Month change is disabled.',
            red,
            Icons.close,
          );
          // Force rebuild to keep calendar on previous month
          setState(() {});
          return;
        }
        // Allow month change
        final startOfSelectedMonth = DateTime(date.year, date.month, 1);
        setState(() {
          _currentMonth = startOfSelectedMonth;
        });
        widget.calenderController.fetchCalenderEvents(startOfSelectedMonth);
        widget.calenderController.loadCalenderEventV1;
      },
      pageTransitionCurve: Curves.easeInOutCubicEmphasized,
      borderColor: white,
      cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) {
        int eventCount = event.length;

        bool isWorkingDay = parsedDays.contains(date.weekday);
        bool isCurrentMonth = isInMonth;

        return GestureDetector(
          onTap: () async {
            if (subscriptionController.appViewDaySchedulesVisits.value ==
                "true") {
              if (isCurrentMonth && isWorkingDay && event.isNotEmpty) {
                widget.calenderController.clearSelections();
                await widget.calenderController.loadOnlyCustomerData(
                  DateFormat('yyyy-MM-dd').format(date),
                  event
                      .where((e) => e.event?.customerId != null)
                      .map((e) => e.event!.customerId!)
                      .toList(),
                );
                Get.dialog(
                  SelectCustomerDiloag(
                    dateTime: date,
                    calenderMapController: widget.calenderController,
                    eventData: event,
                  ),
                  barrierDismissible: false,
                );
                log('Date : $date');
              }
            } else {
              showUpgradePlanDialog(context);
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
                      offset: const Offset(3, 3),
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
            child: isCurrentMonth && isWorkingDay
                ? AppDimensions.instance.orientation == Orientation.portrait
                    ? Column(
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 5),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      )
                    : Row(
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(width: 10),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      )
                : Center(
                    child: MyRegularText(
                      label: date.day.toString(),
                      color: secondaryTextColor.withOpacity(0.5),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
      headerStringBuilder: (date, {secondaryDate}) {
        return NKDateUtils.formatMonth(date);
      },
      startDay: WeekDays.monday,
      controller: widget.calenderController.eventControllerv1,
      initialMonth: _currentMonth,
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
