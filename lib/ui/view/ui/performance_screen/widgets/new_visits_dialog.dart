// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class StaffRouteDialog extends StatefulWidget {
  final StaffController staffController;

  const StaffRouteDialog({
    super.key,
    required this.staffController,
  });

  @override
  _StaffRouteDialogState createState() => _StaffRouteDialogState();
}

class _StaffRouteDialogState extends State<StaffRouteDialog> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<List<dynamic>> visits = [];
  int appointmentCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeData();
  }

  Future<void> _initializeData() async {
    DateTime startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    await widget.staffController.loadScheduleData(
      startDate,
      endDate,
    );

    _loadVisitsForDay(_selectedDay as DateTime);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadVisitsForDay(selectedDay);
  }

  void _loadVisitsForDay(DateTime day) {
    final scheduleDataForDate =
        widget.staffController.scheduleList.firstWhereOrNull((data) {
      if (data.start == null) return false;

      DateTime startDateTime;
      if (data.start is String) {
        startDateTime = data.start!;
      } else {
        startDateTime = data.start as DateTime;
      }

      final scheduleDate =
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
      final selectedDate = DateTime(day.year, day.month, day.day);
      return scheduleDate == selectedDate;
    });

    if (scheduleDataForDate != null) {
      if (scheduleDataForDate.customer != null &&
          scheduleDataForDate.customer!.isNotEmpty) {
        visits = scheduleDataForDate.customer!.map((customer) {
          String title = 'MEETING WITH CLIENT';
          String visitDetails = 'Visit ${customer.businessName} at 9:00 AM';
          return [title, visitDetails];
        }).toList();
      } else {
        visits = [];
      }

      appointmentCount = scheduleDataForDate.customer?.length ?? 0;
    } else {
      visits = [];
      appointmentCount = 0;
    }

    setState(() {});
  }

  void _onMonthChanged(DateTime focusedDay) {
    final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    widget.staffController.loadScheduleData(
      startOfMonth,
      endOfMonth,
    );
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Obx(
        () {
          return widget.staffController.isScheduleLoading.value
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox(
                  width: isPhonePortrait(context)
                      ? fullScreenWidth(context)
                      : fullScreenWidth(context) * 0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Staff Visits',
                              style: TextStyle(
                                color: white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            dialogCloseButton1(context, red),
                          ],
                        ),
                      ),
                      Container(
                        width: isPhonePortrait(context)
                            ? fullScreenWidth(context)
                            : fullScreenWidth(context) * 0.7,
                        padding: const EdgeInsets.all(15.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: _onDaySelected,
                          calendarFormat: CalendarFormat.month,
                          onPageChanged: _onMonthChanged,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronIcon: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(Icons.chevron_left,
                                  color: Colors.white),
                            ),
                            rightChevronIcon: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(Icons.chevron_right,
                                  color: Colors.white),
                            ),
                          ),
                          daysOfWeekHeight: 50,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueGrey.shade100,
                                width: 1,
                              ),
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: black,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              Color indicatorColor = shouldShowIndicator(
                                  day, widget.staffController.scheduleList);

                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Center(
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 7,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: indicatorColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Text(
                              'Total $appointmentCount visits',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: myFont,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: isPhonePortrait(context)
                              ? fullScreenWidth(context)
                              : fullScreenWidth(context) * 0.7,
                          padding: const EdgeInsets.all(15.0),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: visits.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: 3,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: SizedBox(
                                    width: 70,
                                    child: Text('09:00 AM',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey.shade300,
                                            fontSize: 12,
                                            fontFamily: myFont))),
                                title: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          visits[index][0],
                                          style: TextStyle(
                                              color: Colors.green.shade800),
                                        ),
                                        Text(
                                          visits[index][1],
                                          style: const TextStyle(color: black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

Color shouldShowIndicator(DateTime date, List<ScheduleListData> scheduleList) {
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

  bool isParsedDay = parsedDays.contains(date.weekday);

  final scheduleForDate = scheduleList.firstWhereOrNull((schedule) {
    if (schedule.start == null) return false;

    DateTime startDateTime;
    if (schedule.start is String) {
      startDateTime = DateTime.parse(schedule.start.toString());
    } else {
      startDateTime = schedule.start as DateTime;
    }

    final scheduleDate =
        DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    return scheduleDate == selectedDate && (schedule.count ?? 0) > 0;
  });

  if (scheduleForDate == null) {
    return Colors.transparent; // No visits, no indicator
  }

  if (!isParsedDay) {
    return Colors.transparent;
  }

  if (date.isAfter(DateTime.now())) {
    return Colors.green;
  }

  bool isBeforeTodayAndCheckInNull =
      date.startOfDay.isBefore(DateTime.now().startOfDay) &&
          scheduleList.any((schedule) => schedule.checkIn == null);

  bool isTodayAndCheckInNull =
      date.startOfDay.isAtSameMomentAs(DateTime.now().startOfDay) &&
          scheduleList.any((schedule) => schedule.checkIn == null);

  if (isBeforeTodayAndCheckInNull) {
    return Colors.yellow;
  }

  if (isTodayAndCheckInNull) {
    return Colors.green;
  }

  return Colors.transparent;
}

extension DateOnlyCompare on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
}
