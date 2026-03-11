// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Required for time formatting

class StaffRouteDialog extends StatefulWidget {
  final StaffController staffController;
  final int selectedYear;
  final int selectedMonth;

  const StaffRouteDialog({
    super.key,
    required this.staffController,
    required this.selectedYear,
    required this.selectedMonth,
  });

  @override
  _StaffRouteDialogState createState() => _StaffRouteDialogState();
}

class _StaffRouteDialogState extends State<StaffRouteDialog> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Store raw customer objects/maps here
  List<dynamic> visits = [];
  int appointmentCount = 0;
  int checkInCount = 0;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    if (widget.selectedYear == now.year && widget.selectedMonth == now.month) {
      _focusedDay = now; // Set to today's exact date
    } else {
      // Otherwise, find the first working day of that specific month
      _focusedDay = _getFirstWorkingDay(widget.selectedYear, widget.selectedMonth);
    }
    _selectedDay = _focusedDay;
    _initializeData();
  }
  DateTime _getFirstWorkingDay(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    // Grab the valid working days from SessionHelper
    final rawDayList = SessionHelper.settingsData?.firstWhere(
          (setting) => setting.key == 'day_list',
          orElse: () => AllCompanySettingsData(
            key: 'day_list',
            value: '',
          ),
        ).value ?? '';

    if (rawDayList.isEmpty) return firstDayOfMonth;

    List<String> dayList = rawDayList.split(',').map((day) => day.trim()).toList();

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

    if (parsedDays.isEmpty) return firstDayOfMonth;

    // Loop through the first 7 days to find the first valid working day
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = firstDayOfMonth.add(Duration(days: i));
      if (parsedDays.contains(currentDay.weekday)) {
        return currentDay;
      }
    }

    return firstDayOfMonth; // Fallback
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
    // 1. Find the schedule object for the selected day
    final scheduleDataForDate =
        widget.staffController.scheduleList.firstWhereOrNull((data) {
      if (data.start == null) return false;

      DateTime startDateTime;
      // Handle both String and DateTime types safely
      if (data.start is String) {
        startDateTime = DateTime.parse(data.start.toString());
      } else {
        startDateTime = data.start as DateTime;
      }

      final scheduleDate =
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
      final selectedDate = DateTime(day.year, day.month, day.day);
      return scheduleDate == selectedDate;
    });

    // 2. Extract Customer List and Counts
    if (scheduleDataForDate != null) {
      // Access the customer list (dynamic access to handle model variations)
      final customerList = scheduleDataForDate.customer;

      if (customerList != null && customerList.isNotEmpty) {
        visits = customerList;
        appointmentCount = visits.length;

        // Calculate Check-In Count based on the 'check_in' field not being null
        checkInCount = visits.where((customer) {
          try {
            // Check for 'checkIn' (camelCase) or 'check_in' (snake_case)
            final val =
                (customer as dynamic).toJson()['check_in'] ?? customer.checkIn;
            return val != null;
          } catch (e) {
            // Fallback if toJson() isn't available, try direct property access
            try {
              return (customer as dynamic).checkIn != null;
            } catch (e2) {
              return false;
            }
          }
        }).length;
      } else {
        visits = [];
        appointmentCount = 0;
        checkInCount = 0;
      }
    } else {
      visits = [];
      appointmentCount = 0;
      checkInCount = 0;
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
      
      // Clear the underlying data for the list
      visits = [];
      appointmentCount = 0;
      checkInCount = 0;
      
      // Optional: Clear the selected day so the user doesn't see a random day 
      // highlighted from the previous month's selection.
      _selectedDay = null; 
    });
  }

  // void _onMonthChanged(DateTime focusedDay) {
  //   final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  //   final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
  //   widget.staffController.loadScheduleData(
  //     startOfMonth,
  //     endOfMonth,
  //   );
  //   setState(() {
  //     _focusedDay = focusedDay;
  //   });
  // }

  // Helper to format time strings (e.g., "2026-02-02T09:00:00" -> "9:00 AM")
  String _formatTime(dynamic timeVal) {
    if (timeVal == null) return '';
    try {
      DateTime dt;
      if (timeVal is String) {
        dt = DateTime.parse(timeVal).toLocal();
      } else if (timeVal is DateTime) {
        dt = timeVal.toLocal();
      } else {
        return '';
      }
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return '';
    }
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
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox(
                  width: isPhonePortrait(context)
                      ? fullScreenWidth(context)
                      : fullScreenWidth(context) * 0.7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- TITLE BAR ---
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

                      // --- CALENDAR ---
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
                          daysOfWeekHeight: 40,
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
                                color: black, fontWeight: FontWeight.w600),
                            selectedTextStyle: const TextStyle(
                                color: white, fontWeight: FontWeight.w600),
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
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  if (indicatorColor != Colors.transparent)
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

                      const SizedBox(height: 5),

                      // --- TABLE HEADERS (New Implementation) ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                          top:
                              BorderSide(color: Colors.grey.shade200, width: 1),
                        )),
                        child: Row(
                          children: [
                            // Header: Customer
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  const Text("Customer",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: myFont,
                                          fontSize: 13)),
                                  const SizedBox(width: 5),
                                  if (appointmentCount > 0)
                                    _buildBadge(
                                        appointmentCount, Colors.redAccent),
                                ],
                              ),
                            ),
                            // Header: Check-In
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  const Text("Check-In",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: myFont,
                                          fontSize: 13)),
                                  const SizedBox(width: 5),
                                  if (checkInCount > 0)
                                    _buildBadge(checkInCount, Colors.redAccent),
                                ],
                              ),
                            ),
                            // Header: Check-Out
                            const Expanded(
                              flex: 2,
                              child: Text("Check-Out",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: myFont,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                      ),

                      // --- LIST VIEW ---
                      Flexible(
                        child: Container(
                          width: isPhonePortrait(context)
                              ? fullScreenWidth(context)
                              : fullScreenWidth(context) * 0.7,
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          // Use ConstrainedBox or Flexible to let ListView take remaining space
                          child: visits.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                      child: Text("No visits scheduled.",
                                          style:
                                              TextStyle(color: Colors.grey))),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: visits.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                          height: 1, color: Colors.transparent),
                                  itemBuilder: (context, index) {
                                    final item = visits[index];

                                    dynamic data = item is Map
                                        ? item
                                        : (item as dynamic).toJson();

                                    String name = data['business_name'] ??
                                        data['businessName'] ??
                                        '';
                                    String address = data['address'] ?? '';
                                    String town = data['town'] ?? '';
                                    String? rawImgUrl =
                                        data['image_url'] ?? data['imageUrl'];

                                    // 2. Construct the URL
                                    // If it already starts with http, use it. Otherwise, prepend your base URL.
                                    String finalImageUrl = '';
                                    if (rawImgUrl != null &&
                                        rawImgUrl.isNotEmpty) {
                                      if (rawImgUrl.startsWith('http')) {
                                        finalImageUrl = rawImgUrl;
                                      } else {
                                        finalImageUrl =
                                        '${ApiConstants.imageBaseUrl}$rawImgUrl';
                                            // 'https://test.thrivewoo.com/uploads/$rawImgUrl';
                                      }
                                    }

                                    String checkIn = _formatTime(
                                        data['check_in'] ?? data['checkIn']);
                                    // If check_out exists in customer object:
                                    String checkOut = _formatTime(
                                        data['check_out'] ?? data['checkOut']);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // COLUMN 1: Avatar + Details
                                          Expanded(
                                            flex: 5,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipOval(
                                                  child: Container(
                                                    height: 35,
                                                    width: 35,
                                                    color: Colors.blue
                                                        .shade50, // Background if image loads slowly
                                                    child: Image.network(
                                                      finalImageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: Colors
                                                              .lightBlue[100],
                                                          child: const Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.blue,
                                                              size: 20),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                // CircleAvatar(
                                                //   radius: 18,
                                                //   backgroundColor: Colors.blue.shade100,
                                                //   backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                                                //       ? NetworkImage(imgUrl) // Or use your specific image provider
                                                //       : null,
                                                //   child: (imgUrl == null || imgUrl.isEmpty)
                                                //       ? const Icon(Icons.person, color: Colors.blue, size: 20)
                                                //       : null,
                                                // ),
                                                const SizedBox(width: 10),
                                                // Text Details
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black87),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        address,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: 11,
                                                            fontFamily: myFont),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        town,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: 11,
                                                            fontFamily: myFont),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // COLUMN 2: Check-In Time
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                checkIn,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),

                                          // COLUMN 3: Check-Out Time
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                checkOut,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ... Keep your existing extensions (DateTimeExtension, etc.) and shouldShowIndicator function exactly as they were ...
extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

Color shouldShowIndicator(DateTime date, List<ScheduleListData> scheduleList) {
  // ... [Paste your existing shouldShowIndicator logic here] ...
  // Note: Ensure this function is present in the file as it was in your original code.
  // For brevity, I am not repeating the full logic block here unless you need it duplicated.
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

// // ignore_for_file: library_private_types_in_public_api, deprecated_member_use

// import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/common/height_width.dart';
// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:table_calendar/table_calendar.dart';

// class StaffRouteDialog extends StatefulWidget {
//   final StaffController staffController;

//   const StaffRouteDialog({
//     super.key,
//     required this.staffController,
//   });

//   @override
//   _StaffRouteDialogState createState() => _StaffRouteDialogState();
// }

// class _StaffRouteDialogState extends State<StaffRouteDialog> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   List<List<dynamic>> visits = [];
//   int appointmentCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = _focusedDay;
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     DateTime startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
//     DateTime endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

//     await widget.staffController.loadScheduleData(
//       startDate,
//       endDate,
//     );

//     _loadVisitsForDay(_selectedDay as DateTime);
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = selectedDay;
//       _focusedDay = focusedDay;
//     });
//     _loadVisitsForDay(selectedDay);
//   }

//   void _loadVisitsForDay(DateTime day) {
//     final scheduleDataForDate =
//         widget.staffController.scheduleList.firstWhereOrNull((data) {
//       if (data.start == null) return false;

//       DateTime startDateTime;
//       if (data.start is String) {
//         startDateTime = data.start!;
//       } else {
//         startDateTime = data.start as DateTime;
//       }

//       final scheduleDate =
//           DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
//       final selectedDate = DateTime(day.year, day.month, day.day);
//       return scheduleDate == selectedDate;
//     });

//     if (scheduleDataForDate != null) {
//       if (scheduleDataForDate.customer != null &&
//           scheduleDataForDate.customer!.isNotEmpty) {
//         visits = scheduleDataForDate.customer!.map((customer) {
//           String title = 'MEETING WITH CLIENT';
//           String visitDetails = 'Visit ${customer.businessName} at 9:00 AM';
//           return [title, visitDetails];
//         }).toList();
//       } else {
//         visits = [];
//       }

//       appointmentCount = scheduleDataForDate.customer?.length ?? 0;
//     } else {
//       visits = [];
//       appointmentCount = 0;
//     }

//     setState(() {});
//   }

//   void _onMonthChanged(DateTime focusedDay) {
//     final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
//     final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
//     widget.staffController.loadScheduleData(
//       startOfMonth,
//       endOfMonth,
//     );
//     setState(() {
//       _focusedDay = focusedDay;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Obx(
//         () {
//           return widget.staffController.isScheduleLoading.value
//               ? SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 )
//               : SizedBox(
//                   width: isPhonePortrait(context)
//                       ? fullScreenWidth(context)
//                       : fullScreenWidth(context) * 0.7,
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 45,
//                         padding: const EdgeInsets.all(10),
//                         decoration: const BoxDecoration(
//                           color: primaryColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Staff Visits',
//                               style: TextStyle(
//                                 color: white,
//                                 fontSize: 16,
//                                 fontFamily: 'Poppins_Regular',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             dialogCloseButton1(context, red),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: isPhonePortrait(context)
//                             ? fullScreenWidth(context)
//                             : fullScreenWidth(context) * 0.7,
//                         padding: const EdgeInsets.all(15.0),
//                         child: TableCalendar(
//                           firstDay: DateTime.utc(2020, 1, 1),
//                           lastDay: DateTime.utc(2030, 12, 31),
//                           focusedDay: _focusedDay,
//                           selectedDayPredicate: (day) {
//                             return isSameDay(_selectedDay, day);
//                           },
//                           onDaySelected: _onDaySelected,
//                           calendarFormat: CalendarFormat.month,
//                           onPageChanged: _onMonthChanged,
//                           headerStyle: HeaderStyle(
//                             formatButtonVisible: false,
//                             titleCentered: true,
//                             leftChevronIcon: Container(
//                               decoration: BoxDecoration(
//                                 color: primaryColor,
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: const Icon(Icons.chevron_left,
//                                   color: Colors.white),
//                             ),
//                             rightChevronIcon: Container(
//                               decoration: BoxDecoration(
//                                 color: primaryColor,
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: const Icon(Icons.chevron_right,
//                                   color: Colors.white),
//                             ),
//                           ),
//                           daysOfWeekHeight: 50,
//                           daysOfWeekStyle: DaysOfWeekStyle(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.blueGrey.shade100,
//                                 width: 1,
//                               ),
//                             ),
//                           ),
//                           calendarStyle: CalendarStyle(
//                             todayDecoration: BoxDecoration(
//                               color: primaryColor.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             selectedDecoration: const BoxDecoration(
//                               color: primaryColor,
//                               shape: BoxShape.circle,
//                             ),
//                             todayTextStyle: const TextStyle(
//                               color: black,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             selectedTextStyle: const TextStyle(
//                               color: white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           calendarBuilders: CalendarBuilders(
//                             defaultBuilder: (context, day, focusedDay) {
//                               Color indicatorColor = shouldShowIndicator(
//                                   day, widget.staffController.scheduleList);

//                               return Stack(
//                                 alignment: Alignment.topRight,
//                                 children: [
//                                   Center(
//                                     child: Text(
//                                       '${day.day}',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     right: 10,
//                                     top: 7,
//                                     child: Container(
//                                       width: 8,
//                                       height: 8,
//                                       decoration: BoxDecoration(
//                                         color: indicatorColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Row(
//                           children: [
//                             Text(
//                               'Total $appointmentCount visits',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 fontFamily: myFont,
//                               ),
//                             ),
//                             const Spacer(),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           width: isPhonePortrait(context)
//                               ? fullScreenWidth(context)
//                               : fullScreenWidth(context) * 0.7,
//                           padding: const EdgeInsets.all(15.0),
//                           child: ListView.separated(
//                             shrinkWrap: true,
//                             itemCount: visits.length,
//                             separatorBuilder: (context, index) => SizedBox(
//                               height: 3,
//                               child: Container(
//                                 height: 3,
//                                 decoration: BoxDecoration(
//                                     color: Colors.blueGrey.shade100,
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                             itemBuilder: (context, index) {
//                               return ListTile(
//                                 leading: SizedBox(
//                                     width: 70,
//                                     child: Text('09:00 AM',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blueGrey.shade300,
//                                             fontSize: 12,
//                                             fontFamily: myFont))),
//                                 title: Row(
//                                   children: [
//                                     Container(
//                                       width: 6,
//                                       height: 70,
//                                       decoration: BoxDecoration(
//                                           color: Colors.blueGrey.shade100,
//                                           borderRadius:
//                                               BorderRadius.circular(10)),
//                                     ),
//                                     const SizedBox(width: 15),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           visits[index][0],
//                                           style: TextStyle(
//                                               color: Colors.green.shade800),
//                                         ),
//                                         Text(
//                                           visits[index][1],
//                                           style: const TextStyle(color: black),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//         },
//       ),
//     );
//   }
// }

// extension DateTimeExtension on DateTime {
//   bool isSameDate(DateTime other) {
//     return year == other.year && month == other.month && day == other.day;
//   }
// }

// Color shouldShowIndicator(DateTime date, List<ScheduleListData> scheduleList) {
//   final rawDayList = SessionHelper.settingsData
//           ?.firstWhere(
//             (setting) => setting.key == 'day_list',
//             orElse: () => AllCompanySettingsData(
//               key: 'day_list',
//               value: '',
//             ),
//           )
//           .value ??
//       '';

//   List<String> dayList =
//       rawDayList.split(',').map((day) => day.trim()).toList();

//   const Map<String, int> dayNameToInt = {
//     'Monday': DateTime.monday,
//     'Tuesday': DateTime.tuesday,
//     'Wednesday': DateTime.wednesday,
//     'Thursday': DateTime.thursday,
//     'Friday': DateTime.friday,
//     'Saturday': DateTime.saturday,
//     'Sunday': DateTime.sunday,
//   };

//   List<int> parsedDays = dayList
//       .map((day) => dayNameToInt[day] ?? -1)
//       .where((day) => day != -1)
//       .toList();

//   bool isParsedDay = parsedDays.contains(date.weekday);

//   final scheduleForDate = scheduleList.firstWhereOrNull((schedule) {
//     if (schedule.start == null) return false;

//     DateTime startDateTime;
//     if (schedule.start is String) {
//       startDateTime = DateTime.parse(schedule.start.toString());
//     } else {
//       startDateTime = schedule.start as DateTime;
//     }

//     final scheduleDate =
//         DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
//     final selectedDate = DateTime(date.year, date.month, date.day);

//     return scheduleDate == selectedDate && (schedule.count ?? 0) > 0;
//   });

//   if (scheduleForDate == null) {
//     return Colors.transparent; // No visits, no indicator
//   }

//   if (!isParsedDay) {
//     return Colors.transparent;
//   }

//   if (date.isAfter(DateTime.now())) {
//     return Colors.green;
//   }

//   bool isBeforeTodayAndCheckInNull =
//       date.startOfDay.isBefore(DateTime.now().startOfDay) &&
//           scheduleList.any((schedule) => schedule.checkIn == null);

//   bool isTodayAndCheckInNull =
//       date.startOfDay.isAtSameMomentAs(DateTime.now().startOfDay) &&
//           scheduleList.any((schedule) => schedule.checkIn == null);

//   if (isBeforeTodayAndCheckInNull) {
//     return Colors.yellow;
//   }

//   if (isTodayAndCheckInNull) {
//     return Colors.green;
//   }

//   return Colors.transparent;
// }

// extension DateOnlyCompare on DateTime {
//   DateTime get startOfDay => DateTime(year, month, day);
// }
