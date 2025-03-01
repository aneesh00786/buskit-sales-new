// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../api_handler/api_worker.dart';

class StaffValueTargetDialog extends StatefulWidget {
  final StaffController staffController;
  final bool isTarget;
  final bool isProjection;
  final bool isWeekly;

  const StaffValueTargetDialog({
    super.key,
    required this.staffController,
    required this.isTarget,
    required this.isProjection,
    required this.isWeekly,
  });

  @override
  _StaffValueTargetDialogState createState() => _StaffValueTargetDialogState();
}

class _StaffValueTargetDialogState extends State<StaffValueTargetDialog>
    with SingleTickerProviderStateMixin {
  // late final TabController _tabController;
  // List<TextEditingController> _targetControllers = [];
  List<TextEditingController> _projectionControllers = [];

  List<TextEditingController> _weeklyTargetControllers = [];
  List<TextEditingController> _weeklyProjectionControllers = [];

  final int currentMonth = DateTime.now().month;
  final int currentYear = DateTime.now().year;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyType();
    _initializeState();
    log("WEEKLY ${widget.isWeekly}");

    widget.staffController.tabController.addListener(_handleTabChange);
  }

  Future<void> _loadWeeklyType() async {
    final weeklyType = await ApiWorker().getWeeklyType();
    widget.staffController.isWeekly.value = weeklyType == "true";
    log("Weekly state : $weeklyType : ${widget.staffController.isWeekly.value}");
    Future.delayed(Duration(seconds: 1));
  }

  @override
  void dispose() {
    _projectionControllers.clear();
    _weeklyProjectionControllers.clear();
    widget.staffController.salesmanValueTargetList.clear();
    super.dispose();
  }

  void _initializeState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesmanValueTarget();
    });
  }

  void _handleTabChange() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      if (!widget.staffController.tabController.indexIsChanging) {
        _loadSalesmanValueTarget();
      }
    }
  }

  void _loadSalesmanValueTarget() async {
    // setState(() {
    _isLoading = true;
    // });
    log("WEEKLY 2 ${widget.isWeekly}");
    await widget.staffController
        .loadSalesmanValueTarget(
      SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
      currentYear.toString(),
      widget.isWeekly
          ? DateFormat.MMMM().format(
              DateTime(0, widget.staffController.tabController.index + 1))
          : null,
    )
        .then((_) {
      setState(() {
        if (widget.staffController.salesmanValueTargetList.isNotEmpty) {
          final salesData =
              widget.staffController.salesmanValueTargetList.first;
          final weeklyTargetProjection =
              salesData.weeklyTargetProjection?.toJson() ?? {};

          _projectionControllers = List.generate(
            12,
            (index) => TextEditingController(text: '0'),
          );

          for (int i = 0;
              i < widget.staffController.salesmanValueTargetList.length;
              i++) {
            _projectionControllers[i].text = widget
                .staffController.salesmanValueTargetList[i].projection
                .toString();
          }

          final relevantWeeks = getWeeksForMonth(
              int.parse(salesData.year.toString()),
              widget.staffController.tabController.index + 1);

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

  // void _loadSalesmanValueTarget() async {
  //   setState(() {
  //     _isLoading = true; // Show loading state
  //   });

  //   await widget.staffController.loadSalesmanValueTarget(
  //     SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
  //     currentYear.toString(),
  //     widget.isWeekly
  //         ? DateFormat.MMMM().format(
  //             DateTime(0, widget.staffController.tabController.index + 1))
  //         : null,
  //   );

  //   if (mounted) {
  //     final salesData =
  //         widget.staffController.salesmanValueTargetList.isNotEmpty
  //             ? widget.staffController.salesmanValueTargetList.first
  //             : null;

  //     if (salesData != null) {
  //       final weeklyTargetProjection =
  //           salesData.weeklyTargetProjection?.toJson() ?? {};

  //       // Initialize controllers only once
  //       if (_projectionControllers.isEmpty) {
  //         _projectionControllers = List.generate(
  //           12,
  //           (index) => TextEditingController(text: '0'),
  //         );
  //       }

  //       for (int i = 0;
  //           i < widget.staffController.salesmanValueTargetList.length;
  //           i++) {
  //         _projectionControllers[i].text = widget
  //             .staffController.salesmanValueTargetList[i].projection
  //             .toString();
  //       }

  //       final relevantWeeks = getWeeksForMonth(
  //         int.parse(salesData.year.toString()),
  //         widget.staffController.tabController.index + 1,
  //       );

  //       if (_weeklyProjectionControllers.isEmpty) {
  //         _weeklyProjectionControllers = List.generate(
  //           relevantWeeks.length,
  //           (index) => TextEditingController(text: '0'),
  //         );
  //       }

  //       for (var i = 0; i < relevantWeeks.length; i++) {
  //         final weekKey = "week${relevantWeeks[i]}";
  //         final weekData = weeklyTargetProjection[weekKey];

  //         int projection = 0;
  //         if (weekData is Map<String, dynamic>) {
  //           projection = weekData["projection"] ?? 0;
  //         }

  //         _weeklyProjectionControllers[i].text = projection.toString();
  //       }
  //     }

  //     setState(() {
  //       _isLoading = false; // Hide loading state when done
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return _isLoading || widget.staffController.isValueTargetLoading.value
        ? SizedBox(
            // width: MediaQuery.of(context).size.width * 0.7,
            height: 150,
            child: const Center(
              child: CircularProgressIndicator(
                  // color: red,
                  ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
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
                if (!widget.isWeekly) ...[
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
                if (widget.isWeekly) ...[
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

  List<TableRow> _buildCategoryRows() {
    if (widget.staffController.salesmanValueTargetList.isEmpty) {
      return List.generate(12, (index) {
        final monthName = _getMonthName(index + 1);
        return TableRow(
          children: [
            _buildTableCell(monthName),
            _buildTableCell(widget
                    .staffController.salesmanValueTargetList[index].target
                    .toString() ??
                ''),
            if (widget.isProjection)
              _buildTableTextField(index, _projectionControllers[index]),
          ],
        );
      });
    } else {
      return List.generate(
          widget.staffController.salesmanValueTargetList.length, (index) {
        final targetData =
            widget.staffController.salesmanValueTargetList[index];
        return TableRow(
          children: [
            _buildTableCell(targetData.month.toString()),
            // _buildTableTextField(index, _targetControllers[index]),
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(widget
                    .staffController.salesmanValueTargetList[index].target
                    .toString()),
              ),
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
        .format(DateTime(0, widget.staffController.tabController.index + 1));

    final salesData = widget.staffController.salesmanValueTargetList.firstWhere(
      (data) => data.month == selectedMonth,
    );

    final weeklyTargetProjection =
        salesData.weeklyTargetProjection?.toJson() ?? {};

    final relevantWeeks = getWeeksForMonth(int.parse(salesData.year.toString()),
        widget.staffController.tabController.index + 1);

    for (var i = 0; i < relevantWeeks.length; i++) {
      final week = relevantWeeks[i];
      final weekKey = "week$week";
      final weekData = weeklyTargetProjection[weekKey];

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
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);
    DateTime currentDay = firstDay;

    while (
        currentDay.isBefore(lastDay) || currentDay.isAtSameMomentAs(lastDay)) {
      int weekNumber =
          (currentDay.difference(DateTime(year, 1, 1)).inDays / 7).floor() + 1;
      if (!weeks.contains(weekNumber)) {
        weeks.add(weekNumber);
      }
      currentDay = currentDay.add(const Duration(days: 1));
    }
    return weeks;
  }

  void _saveTargets() async {
    Map<String, dynamic> monthTarget = {};
    Map<String, dynamic> weeklyTarget = {};

    if (widget.staffController.salesmanValueTargetList.isNotEmpty) {
      for (int i = 0;
          i < widget.staffController.salesmanValueTargetList.length;
          i++) {
        final targetData = widget.staffController.salesmanValueTargetList[i];
        final targetValue =
            widget.staffController.salesmanValueTargetList[i].target.toString();
        final projectionValue = _projectionControllers[i].text.trim();

        monthTarget[targetData.month.toString()] = [
          {
            "target": targetValue.isEmpty ? "0" : targetValue,
            "projection": projectionValue.isEmpty ? "0" : projectionValue,
          }
        ];
      }
    }

    if (widget.staffController.salesmanValueTargetList.isEmpty) {
      for (int i = 0; i < 12; i++) {
        final monthName = _getMonthName(i + 1);
        final targetValue =
            widget.staffController.salesmanValueTargetList[i].target.toString();
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
        .format(DateTime(0, widget.staffController.tabController.index + 1));

    final salesData = widget.staffController.salesmanValueTargetList.firstWhere(
      (data) => data.month == selectedMonth,
    );

    final weeklyTargetProjection =
        salesData.weeklyTargetProjection?.toJson() ?? {};

    final relevantWeeks = getWeeksForMonth(int.parse(salesData.year.toString()),
        widget.staffController.tabController.index + 1);

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
      await widget.staffController.updateValueBasedTarget(
        SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
        currentYear.toString(),
        _getMonthName(widget.staffController.tabController.index + 1),
        widget.staffController.isWeekly.value ? {} : monthTarget,
        widget.staffController.isWeekly.value ? weeklyTarget : {},
      );

      widget.staffController.loadSalesmanTargetForSelectedTab(
        currentYear: widget.staffController.selectedDate.year.toString(),
        selectedTabIndex: widget.staffController.tabController.index + 1,
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

    // if (widget.staffController.salesmanValueTargetList.isNotEmpty) {
    //   for (int i = 0;
    //       i < widget.staffController.salesmanValueTargetList.length;
    //       i++) {
    //     final targetData = widget.staffController.salesmanValueTargetList[i];
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

    // if (widget.staffController.salesmanValueTargetList.isEmpty) {
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
    //   await widget.staffController.updateValueBasedTarget(
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
    //   await widget.staffController.loadStaffDataList;
    //   Navigator.of(context).pop();
    // }




    

  // List<TableRow> _buildCategoryWeeklyRows() {
  //   final allWeeklyRows = <TableRow>[];

  //   final selectedMonth = DateFormat.MMMM()
  //       .format(DateTime(0, widget.staffController.tabController.index + 1));

  //   final salesData = widget.staffController.salesmanValueTargetList.firstWhere(
  //     (data) => data.month == selectedMonth,
  //   );

  //   final weeklyTargetProjection =
  //       salesData.weeklyTargetProjection?.toJson() ?? {};

  //   final relevantWeeks = getWeeksForMonth(int.parse(salesData.year.toString()),
  //       widget.staffController.tabController.index + 1);

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
  //   await widget.staffController
  //       .loadSalesmanValueTarget(
  //     SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
  //     currentYear.toString(),
  //     widget.isWeekly
  //         ? DateFormat.MMMM().format(
  //             DateTime(0, widget.staffController.tabController.index + 1))
  //         : null,
  //   )
  //       .then((_) {
  //     setState(() {
  //       if (widget.staffController.salesmanValueTargetList.isEmpty) {
  //         _targetControllers =
  //             List.generate(12, (index) => TextEditingController(text: '0'));
  //         _projectionControllers =
  //             List.generate(12, (index) => TextEditingController(text: '0'));
  //       } else {
  //         _targetControllers = widget.staffController.salesmanValueTargetList
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
