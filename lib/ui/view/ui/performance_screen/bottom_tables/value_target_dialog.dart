// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffValueTargetDialog extends StatefulWidget {
  final StaffController staffController;
  final bool isTarget;
  final bool isProjection;

  const StaffValueTargetDialog({
    super.key,
    required this.staffController,
    required this.isTarget,
    required this.isProjection,
  });

  @override
  _StaffValueTargetDialogState createState() => _StaffValueTargetDialogState();
}

class _StaffValueTargetDialogState extends State<StaffValueTargetDialog>
    with SingleTickerProviderStateMixin {
  List<TextEditingController> _projectionControllers = [];
  List<TextEditingController> _weeklyProjectionControllers = [];
  StaffController staffController = Get.put(StaffController());
  final int currentMonth = DateTime.now().month;
  final int currentYear = DateTime.now().year;
  bool _isLoading = true;
  @override
  @override
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    staffController.loadWeeklyType();
    staffController.isWeekly.listen((value) {
      log("WEEKLY value updated: $value");
      _loadSalesmanValueTarget();
    });
    _initializeState();
    staffController.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _projectionControllers.clear();
    _weeklyProjectionControllers.clear();
    staffController.salesmanValueTargetList.clear();
    for (var controller in _weeklyProjectionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
   void _initializeControllers() {
    final selectedMonth = DateFormat.MMMM()
        .format(DateTime(0, staffController.tabController.index + 1));

    final salesData = staffController.salesmanValueTargetList.firstWhere(
      (data) => data.month == selectedMonth,
      orElse: () => SalesmanValueTargetData(
        month: selectedMonth,
        year: DateTime.now().year.toString(),
        weeklyTargetProjection: WeeklyTargetProjection(weeks: {}),
        actualTotal: '0',
        companyId: SessionHelper.loginSavedData?.company_id ?? 0,
        projection: 0,
        target: 0,
        id: 0,
        orderTotal: '0',
        salesId: SessionHelper.loginSavedData?.salesmanId ?? '',
      ),
    );

    final weeklyTargetProjection =
        salesData.weeklyTargetProjection?.toJson() ?? {};
    final relevantWeeks = getWeeksForMonth(
        int.parse(salesData.year.toString()),
        staffController.tabController.index + 1,
    );
    if (_weeklyProjectionControllers.isEmpty) {
      _weeklyProjectionControllers = List.generate(
        relevantWeeks.length,
        (index) {
          final week = relevantWeeks[index];
          final weekKey = "week$week";
          final weekData = weeklyTargetProjection[weekKey];
          String initialText = (weekData != null && weekData['projection'] != null)
              ? weekData['projection'].toString()
              : '0';
          return TextEditingController(text: initialText);
        },
      );
    }
  }


  void _initializeState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesmanValueTarget();
    });
  }

  void _handleTabChange() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      if (!staffController.tabController.indexIsChanging) {
        _loadSalesmanValueTarget();
      }
    }
  }

  void _loadSalesmanValueTarget() async {
    // setState(() {
    _isLoading = true;
    // });
    log("WEEKLY 2345 ${staffController.isWeekly.value}");
    await staffController
        .loadSalesmanValueTarget(
      SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
      currentYear.toString(),
      staffController.isWeekly.value
          ? DateFormat.MMMM()
              .format(DateTime(0, staffController.tabController.index + 1))
          : null,
    )
        .then((_) {
      setState(() {
        if (staffController.salesmanValueTargetList.isNotEmpty) {
          final salesData = staffController.salesmanValueTargetList.first;
          final weeklyTargetProjection =
              salesData.weeklyTargetProjection?.toJson() ?? {};

          _projectionControllers = List.generate(
            12,
            (index) => TextEditingController(text: '0'),
          );

          for (int i = 0;
              i < staffController.salesmanValueTargetList.length;
              i++) {
            _projectionControllers[i].text = widget
                .staffController.salesmanValueTargetList[i].projection
                .toString();
          }
          final relevantWeeks = getWeeksForMonth(
              int.parse(salesData.year.toString()),
              staffController.tabController.index + 1);

          _weeklyProjectionControllers = List.generate(
            relevantWeeks.length,
            (index) => TextEditingController(text: '0'),
          );

          log("Weekly Target Projection: $weeklyTargetProjection");
          log("Relevant Weeks: $relevantWeeks");

          for (var i = 0; i < relevantWeeks.length; i++) {
            final weekKey = "week${relevantWeeks[i]}";
            final weekData = weeklyTargetProjection[weekKey];

            log("Week $weekKey Data: $weekData");

            int projection = 0;
            if (weekData is Map<String, dynamic>) {
              projection = weekData["projection"] ?? 0;
            }

            log("Week $weekKey Projection: $projection");

            _weeklyProjectionControllers[i].text = projection.toString();
          }
        }
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading || staffController.isValueTargetLoading.value
        ? const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(12.0),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target by value',
                        style: TextStyle(
                          color: white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins_Regular',
                        ),
                      ),
                      // dialogCloseButton1(context, red)
                    ],
                  ),
                ),
                nkSmallSizeBox(),
                if (!staffController.isWeekly.value) ...[
                  Container(
                    // width: MediaQuery.of(context).size.width * 0.7,
                    width: double.maxFinite,
                    padding:
                        const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          children: [
                            _buildTableHeader('Month'),
                            _buildTableHeader('Target'),
                            if (widget.isProjection)
                              _buildTableHeader('Projection'),
                          ],
                        ),
                        ..._buildCategoryRows(),
                      ],
                    ),
                  ),
                ],
                if (staffController.isWeekly.value) ...[
                  Container(
                    padding:
                        const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          children: [
                            _buildTableHeader('Week'),
                            _buildTableHeader('Target'),
                            _buildTableHeader('Projection'),
                          ],
                        ),
                        ..._buildCategoryWeeklyRows(),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      // backgroundColor: red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                    ),
                    onPressed: _saveTargets,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  // List<TableRow> _buildCategoryRows() {
  //   if (staffController.salesmanValueTargetList.isEmpty) {
  //     return List.generate(12, (index) {
  //       final monthName = _getMonthName(index + 1);
  //       return TableRow(
  //         children: [
  //           _buildTableCell(monthName),
  //           _buildTableCell(widget
  //                   .staffController.salesmanValueTargetList[index].target
  //                   .toString()),
  //           if (widget.isProjection)
  //             _buildTableTextField(index, _projectionControllers[index]),
  //         ],
  //       );
  //     });
  //   } else {
  //     return List.generate(
  //         staffController.salesmanValueTargetList.length, (index) {
  //       final targetData =
  //           staffController.salesmanValueTargetList[index];
  //       return TableRow(
  //         children: [
  //           _buildTableCell(targetData.month.toString()),
  //           Container(
  //             height: 50,
  //             padding: const EdgeInsets.all(8.0),
  //             child: Center(
  //               child: Text(widget
  //                   .staffController.salesmanValueTargetList[index].target
  //                   .toString()),
  //             ),
  //           ),
  //           if (widget.isProjection)
  //             _buildTableTextField(index, _projectionControllers[index]),
  //         ],
  //       );
  //     });
  //   }
  // }
  List<TableRow> _buildCategoryRows() {
    while (_projectionControllers.length < 12) {
      _projectionControllers.add(TextEditingController());
    }
    if (staffController.salesmanValueTargetList.isEmpty) {
      log('This item is getting Worked');
      return List.generate(12, (index) {
        final monthName = _getMonthName(index + 1);
        return TableRow(
          children: [
            _buildTableCell(monthName),
            _buildTableCell('__'),
            if (widget.isProjection)
              _buildTableTextField(index, _projectionControllers[index]),
          ],
        );
      });
    } else {
      return List.generate(12, (index) {
        final monthName = _getMonthName(index + 1);
        final targetData =
            index < staffController.salesmanValueTargetList.length
                ? staffController.salesmanValueTargetList[index]
                : null;

        return TableRow(
          children: [
            _buildTableCell(monthName),
            _buildTableCell(
              targetData?.target?.toString() ?? '',
            ),
            if (widget.isProjection)
              _buildTableTextField(index, _projectionControllers[index]),
          ],
        );
      });
    }
  }

  Widget _buildTableTextField(int index, TextEditingController textController) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          fillColor: Colors.blueGrey.shade50,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }

  List<TableRow> _buildCategoryWeeklyRows() {
    final allWeeklyRows = <TableRow>[];

    final selectedMonth = DateFormat.MMMM()
        .format(DateTime(0, staffController.tabController.index + 1));

    final salesData = staffController.salesmanValueTargetList.firstWhere(
      (data) => data.month == selectedMonth,
      orElse: () => SalesmanValueTargetData(
        month: selectedMonth,
        year: DateTime.now().year.toString(),
        weeklyTargetProjection: WeeklyTargetProjection(weeks: {}),
        actualTotal: '0',
        companyId: SessionHelper.loginSavedData?.company_id ?? 0,
        projection: 0,
        target: 0,
        id: 0,
        orderTotal: '0',
        salesId: SessionHelper.loginSavedData?.salesmanId ?? '',
      ),
    );

    final weeklyTargetProjection =
        salesData.weeklyTargetProjection?.toJson() ?? {};

    final relevantWeeks = getWeeksForMonth(
      int.parse(salesData.year.toString()),
      staffController.tabController.index + 1,
    );

    for (var i = 0; i < relevantWeeks.length; i++) {
      final week = relevantWeeks[i];
      final weekKey = "week$week";
      final weekData = weeklyTargetProjection[weekKey];

      log('Targets: $weekData');
      int target = 0;
      if (weekData is Map<String, dynamic>) {
        target = weekData["value"] ?? 0;
      }

      allWeeklyRows.add(
        TableRow(
          children: [
            _buildTableCell("Week $week"),
            _buildTableCell("$target"),
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _weeklyProjectionControllers[i],
                textAlign: TextAlign.center,
                onChanged: (newValue) {
                  log("Updated projection for Week $week: $newValue");
                  setState(() {}); 
                },
                decoration: InputDecoration(
                  fillColor: Colors.blueGrey.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return allWeeklyRows;
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  List<int> getWeeksForMonth(int year, int month) {
    List<int> weeks = [];
    DateTime firstDay = DateTime(year, month, 2);
    DateTime lastDay = DateTime(year, month + 1, 2);
    DateTime currentDay = firstDay;
    while (
        currentDay.isBefore(lastDay) || currentDay.isAtSameMomentAs(lastDay)) {
      int weekNumber =
          (currentDay.difference(DateTime(year, 1, 1)).inDays / 7).floor() + 1;
      if (!weeks.contains(weekNumber)) {
        weeks.add(weekNumber);
      }
      currentDay = currentDay.add(const Duration(days: 1)).toLocal();
    }
    return weeks;
  }

  void _saveTargets() async {
    Map<String, dynamic> monthTarget = {};
    Map<String, dynamic> weeklyTarget = {};

    if (staffController.salesmanValueTargetList.isNotEmpty) {
      for (int i = 0; i < staffController.salesmanValueTargetList.length; i++) {
        final targetData = staffController.salesmanValueTargetList[i];
        final targetValue =
            staffController.salesmanValueTargetList[i].target.toString();
        log('');
        final projectionValue = _projectionControllers[i].text.trim();

        monthTarget[targetData.month.toString()] = [
          {
            "target": targetValue.isEmpty ? "0" : targetValue,
            "projection": projectionValue.isEmpty ? "0" : projectionValue,
          }
        ];
      }
    }

    if (staffController.salesmanValueTargetList.isEmpty) {
      for (int i = 0; i < 12; i++) {
        final monthName = _getMonthName(i + 1);
        final targetValue =
            staffController.salesmanValueTargetList[i].target.toString();
        final projectionValue = _projectionControllers[i].text.trim();

        monthTarget[monthName] = [
          {
            "target": targetValue.isEmpty ? "0" : targetValue,
            "projection": projectionValue.isEmpty ? "0" : projectionValue,
          }
        ];
      }
    }

    final selectedMonth = DateFormat.MMMM()
        .format(DateTime(0, staffController.tabController.index + 1));

    final salesData = staffController.salesmanValueTargetList.firstWhere(
      (data) => data.month == selectedMonth,
    );

    final weeklyTargetProjection =
        salesData.weeklyTargetProjection?.toJson() ?? {};

    final relevantWeeks = getWeeksForMonth(int.parse(salesData.year.toString()),
        staffController.tabController.index + 1);

    for (var i = 0; i < relevantWeeks.length; i++) {
      final week = relevantWeeks[i];
      final weekKey = "week$week";
      final weekData = weeklyTargetProjection[weekKey];

      int target = 0;
      if (weekData is Map<String, dynamic>) {
        target = weekData["value"] ?? 0; // key is value
      }

      int projection = 0;
      if (i < _weeklyProjectionControllers.length) {
        projection =
            int.tryParse(_weeklyProjectionControllers[i].text.trim()) ?? 0;
      }

      weeklyTarget[weekKey] = {
        weekKey: target,
        "${weekKey}_projection": projection,
      };
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await staffController.updateValueBasedTarget(
        SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
        currentYear.toString(),
        _getMonthName(staffController.tabController.index + 1),
        staffController.isWeekly.value ? {} : monthTarget,
        staffController.isWeekly.value ? weeklyTarget : {},
      );

      staffController.loadSalesmanTargetForSelectedTab(
        currentYear: staffController.selectedDate.year.toString(),
        selectedTabIndex: staffController.tabController.index + 1,
        staffId: SessionHelper.loginSavedData?.salesmanId ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Targets and Projections updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating targets: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


 // Map<String, dynamic> monthTarget = {};

    // if (staffController.salesmanValueTargetList.isNotEmpty) {
    //   for (int i = 0;
    //       i < staffController.salesmanValueTargetList.length;
    //       i++) {
    //     final targetData = staffController.salesmanValueTargetList[i];
    //     final targetValue = _targetControllers[i].text.trim();
    //     final projectionValue = _projectionControllers[i].text.trim();

    //     monthTarget[targetData.month.toString()] = [
    //       {
    //         "target": targetValue.isEmpty ? "0" : targetValue,
    //         "projection": projectionValue.isEmpty ? "0" : projectionValue,
    //       }
    //     ];
    //   }
    // }

    // if (staffController.salesmanValueTargetList.isEmpty) {
    //   for (int i = 0; i < 12; i++) {
    //     final monthName = _getMonthName(i + 1);
    //     final targetValue = _targetControllers[i].text.trim();
    //     final projectionValue = _targetControllers[i].text.trim();

    //     monthTarget[monthName] = [
    //       {
    //         "target": targetValue.isEmpty ? "0" : targetValue,
    //         "projection": projectionValue.isEmpty ? "0" : projectionValue,
    //       }
    //     ];
    //   }
    // }

    // setState(() {
    //   _isLoading = true;
    // });

    // try {
    //   await staffController.updateValueBasedTarget(
    //     widget.staffData.salesmanId.toString(),
    //     currentYear.toString(),
    //     monthTarget,
    //   );

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Targets updated successfully!')),
    //   );
    // } catch (error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error updating targets: $error')),
    //   );
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   await staffController.loadStaffDataList;
    //   Navigator.of(context).pop();
    // }




    

  // List<TableRow> _buildCategoryWeeklyRows() {
  //   final allWeeklyRows = <TableRow>[];

  //   final selectedMonth = DateFormat.MMMM()
  //       .format(DateTime(0, staffController.tabController.index + 1));

  //   final salesData = staffController.salesmanValueTargetList.firstWhere(
  //     (data) => data.month == selectedMonth,
  //   );

  //   final weeklyTargetProjection =
  //       salesData.weeklyTargetProjection?.toJson() ?? {};

  //   final relevantWeeks = getWeeksForMonth(int.parse(salesData.year.toString()),
  //       staffController.tabController.index + 1);

  //   for (var week in relevantWeeks) {
  //     final weekKey = "week$week";
  //     final weekData = weeklyTargetProjection[weekKey];

  //     log("weekdata : $weekKey $weekData");

  //     int target = 0;
  //     int projection = 0;

  //     if (weekData is Map<String, dynamic>) {
  //       target = weekData["value"] ?? 0;
  //       projection = weekData["projection"] ?? 0;
  //     }

  //     allWeeklyRows.add(
  //       TableRow(
  //         children: [
  //           _buildTableCell("Week $week"),
  //           _buildTableCell("$target"),
  //           // _buildTableCell("$projection"),
  //           Container(
  //             height: 50,
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextField(
  //               // controller: textController,
  //               textAlign: TextAlign.center,
  //               decoration: InputDecoration(
  //                 hintText: projection.toString(),
  //                 fillColor: Colors.blueGrey.shade50,
  //                 filled: true,
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                   borderSide: BorderSide.none,
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(vertical: 5),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return allWeeklyRows;
  // }






  // void _loadSalesmanValueTarget() async {
  //   await staffController
  //       .loadSalesmanValueTarget(
  //     SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
  //     currentYear.toString(),
  //     widget.isWeekly
  //         ? DateFormat.MMMM().format(
  //             DateTime(0, staffController.tabController.index + 1))
  //         : null,
  //   )
  //       .then((_) {
  //     setState(() {
  //       if (staffController.salesmanValueTargetList.isEmpty) {
  //         _targetControllers =
  //             List.generate(12, (index) => TextEditingController(text: '0'));
  //         _projectionControllers =
  //             List.generate(12, (index) => TextEditingController(text: '0'));
  //       } else {
  //         _targetControllers = staffController.salesmanValueTargetList
  //             .map(
  //                 (data) => TextEditingController(text: data.target.toString()))
  //             .toList();

  //         _projectionControllers = widget
  //             .staffController.salesmanValueTargetList
  //             .map((data) =>
  //                 TextEditingController(text: data.projection.toString()))
  //             .toList();
  //       }
  //       _isLoading = false;
  //     });
  //   });
  // }
