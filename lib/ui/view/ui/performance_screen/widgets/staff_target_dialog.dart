import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class StaffTargetDialog extends StatefulWidget {
  final StaffController staffController;
  TabController tabController;
  int currentYear;
  List<TextEditingController> tabControllers;
  StaffTargetDialog({
    required this.staffController,
    required this.tabController,
    required this.currentYear,
    required this.tabControllers,
  });

  @override
  _StaffTargetDialogState createState() => _StaffTargetDialogState();
}

class _StaffTargetDialogState extends State<StaffTargetDialog>
    with SingleTickerProviderStateMixin {
  final Map<String, List<TextEditingController>> _weeklyTargetControllers = {};
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  bool isWeekly = false;
  Map<dynamic, String> updatedTargets = {};
  Map<int, TextEditingController> categoryControllers = {};
  Map<int, TextEditingController> projectionControllers = {};

  //Map<dynamic, String> weeklyTargets = {};

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  void _loadTargets() async {
    try {
      await widget.staffController.loadSalesmanTargetForSelectedTab(
        currentYear: widget.currentYear.toString(),
        selectedTabIndex: widget.tabController.index + 1,
        staffId: salesmanId,
      );
      if (mounted) {
        setState(() => _initializeControllers());
      }
    } catch (e) {
      log("Error loading targets: $e");
    }
  }

  void _initializeControllers() {
    final salesmanTargetList =
        widget.staffController.salesmanTargetList.value.categoryPerformance ?? [];

    // Dispose existing controllers
    for (var controller in categoryControllers.values) {
      controller.dispose();
    }
    for (var controller in projectionControllers.values) {
      controller.dispose();
    }
    _weeklyTargetControllers.clear();

    // Initialize controllers
    categoryControllers.clear();
    projectionControllers.clear();
    for (var target in salesmanTargetList) {
      final targetIndex = salesmanTargetList.indexOf(target);
      categoryControllers[targetIndex] = TextEditingController(
        text: target.actualTarget?.toString() ?? '',
      );
      projectionControllers[targetIndex] = TextEditingController(
        text: target.actualProjection?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    widget.tabController.dispose();
    for (var controller in widget.tabControllers) {
      controller.dispose();
    }
    for (var controller in categoryControllers.values) {
      controller.dispose();
    }
    for (var controller in projectionControllers.values) {
      controller.dispose();
    }
    _weeklyTargetControllers.forEach((_, controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDataInitialized = _weeklyTargetControllers.isNotEmpty &&
        _weeklyTargetControllers.keys.every((week) {
          return _weeklyTargetControllers[week]!.isNotEmpty;
        });

    return Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color.fromARGB(255, 230, 229, 229),
            width: 0.4,
          ),
        ),
        child: Obx(() {
          return widget.staffController.isTargetLoading.value
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      nkSmallSizeBox(),
                      const SizedBox(height: 15),
                      if (isWeekly == false) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  children: [
                                    _buildTableHeader('Category'),
                                    _buildTableHeader('Target'),
                                    _buildTableHeader('Projection'),
                                  ],
                                ),
                                ..._buildCategoryRows(),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (isWeekly == true) ...[
                        isDataInitialized
                            ? Builder(
                                builder: (context) {
                                  // Get the weeks for the current month
                                  final selectedMonth =
                                      widget.tabController.index + 1;
                                  final relevantWeeks = getWeeksForMonth(
                                      widget.currentYear, selectedMonth);

                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    padding: const EdgeInsets.only(
                                        bottom: 8, left: 8, right: 8),
                                    child: Table(
                                      border:
                                          TableBorder.all(color: Colors.grey),
                                      columnWidths: const {
                                        0: FixedColumnWidth(150)
                                      }, // Category column width
                                      children: [
                                        // Header row
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300]),
                                          children: [
                                            _buildTableHeader('Category'),
                                            // Dynamically generate the week headers
                                            ...relevantWeeks.map((week) {
                                              return _buildTableHeader(
                                                  'Week $week');
                                            }),
                                          ],
                                        ),
                                        // Data rows
                                        ..._buildCategoryWeeklyRows(
                                            relevantWeeks),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
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
        }));
  }

  void _saveTargets() async {
    final selectedMonth = widget.tabController.index + 1;
    final selectedMonthName =
        DateFormat.MMMM().format(DateTime(0, selectedMonth));
    updatedTargets = {
      for (int i = 0; i < categoryControllers.length; i++)
        widget.staffController.salesmanTargetList.value.categoryPerformance![i]
            .cid
            .toString(): categoryControllers[i]?.text.toString() ?? ''
    };
    for (int i = 0; i < projectionControllers.length; i++) {
      final cid = widget
          .staffController.salesmanTargetList.value.categoryPerformance![i].cid
          .toString();
      updatedTargets[cid] = projectionControllers[i]?.text ?? '';
    }

    Map<String, Map<String, String>> buildWeeklyTargetData(
        List<int> categoryIds, List<int> relevantWeeks) {
      final Map<String, Map<String, String>> weeklyTargetData = {};
      for (var week in relevantWeeks) {
        final weekKey = 'week$week';
        final controllers = _weeklyTargetControllers[weekKey] ?? [];

        for (var categoryIndex = 0;
            categoryIndex < categoryIds.length;
            categoryIndex++) {
          final categoryId = categoryIds[categoryIndex];
          final controller = categoryIndex < controllers.length
              ? controllers[categoryIndex]
              : null;
          weeklyTargetData.putIfAbsent(weekKey, () => {});
          weeklyTargetData[weekKey]!['$categoryId'] = controller?.text ?? '';
        }
      }

      return weeklyTargetData;
    }

    List<int> getCategoryIds() {
      return widget
          .staffController.salesmanTargetList.value.categoryPerformance!
          .map((category) => category.cid!)
          .toList();
    }

    final categoryIds = getCategoryIds();
    final relevantWeeks = getWeeksForMonth(widget.currentYear, selectedMonth);
    final weeklyTargetData = buildWeeklyTargetData(categoryIds, relevantWeeks);
    final requestData = {
      "companyId": 1,
      "sales_id": "SALES1",
      "month": selectedMonthName,
      "year": widget.currentYear.toString(),
      "categories": updatedTargets,
      "weekly_target": isWeekly ? weeklyTargetData : {},
    };
    log('Request Data $requestData');
    final requestDataAsStrings =
        requestData.map((key, value) => MapEntry(key, value.toString()));
    try {
      final response = await widget.staffController.updateCategoryTarget(
        "SALES1",
        selectedMonthName,
        widget.currentYear.toString(),
        updatedTargets,
        requestDataAsStrings,
      );

      if (response.statusCode == 200) {
        _showAlertDialog(
          context,
          'Success',
          'Targets saved successfully!',
          'assets/images/Animation - 1726906882515.json',
        );
      } else {
        _showAlertDialog(
          context,
          'Failed',
          'Failed to save targets. Please try again!',
          'assets/images/Warning_animation.json',
        );
      }
    } catch (e) {
      _showAlertDialog(
        context,
        'Error',
        'An unexpected error occurred. Please try again!',
        'assets/images/Warning_animation.json',
      );
      log('Error saving targets: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message,
      String animationPath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(animationPath),
            ),
          ),
          content: CustomText(
            content: message,
            fontSize: 18,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomText(
          content: text,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
          color: white,
          fontSize: 15,
        ),
      ),
    );
  }

  List<TableRow> _buildCategoryRows() {
    log('Length of :${widget.staffController.salesmanTargetList.value.categoryPerformance?.length}');
    return List.generate(
      widget.staffController.salesmanTargetList.value.categoryPerformance
              ?.length ??
          0,
      (index) {
        final target = widget.staffController.salesmanTargetList.value
            .categoryPerformance?[index];
        categoryControllers[index] ??= TextEditingController(
          text: target?.actualTarget.toString() ?? '',
        );
        return TableRow(
          children: [
            _buildTableCell(target?.category ?? ''),
            _buildTableCell(target?.actualTarget.toString() ?? ''),
            _buildTableTextField(index, false, target),
          ],
        );
      },
    );
  }

  int getWeekNumber(DateTime date) {
    DateTime startOfYear = DateTime(date.year, 1, 1);
    int daysSinceStartOfYear = date.difference(startOfYear).inDays;
    int weekNumber = (daysSinceStartOfYear / 7).floor() + 1;
    return weekNumber;
  }

  List<int> getWeeksForMonth(int year, int month) {
    List<int> weeks = [];

    try {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
      DateTime currentDay = firstDayOfMonth;

      while (currentDay.isBefore(lastDayOfMonth) ||
          currentDay.isAtSameMomentAs(lastDayOfMonth)) {
        int weekNumber = getWeekNumber(currentDay);
        if (weekNumber != 0 && !weeks.contains(weekNumber)) {
          weeks.add(weekNumber);
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
    } catch (e) {
      print('Error while calculating weeks for month $month in year $year: $e');
    }

    return weeks;
  }

  List<TableRow> _buildCategoryWeeklyRows(List<int> relevantWeeks) {
    final allWeeklyRows = <TableRow>[];

    for (var categoryIndex = 0;
        categoryIndex <
            widget.staffController.salesmanTargetList.value.categoryPerformance!
                .length;
        categoryIndex++) {
      final target = widget.staffController.salesmanTargetList.value
          .categoryPerformance![categoryIndex];
      final rowColumns = <Widget>[
        Container(
          height: 50,
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(target.category ?? '')),
        ),
      ];

      for (var week in relevantWeeks) {
        final weekKey = 'week$week';
        final controllersForWeek = _weeklyTargetControllers[weekKey];

        final targetControllerForWeek = (controllersForWeek != null &&
                categoryIndex < controllersForWeek.length)
            ? controllersForWeek[categoryIndex]
            : null;

        if (targetControllerForWeek != null) {
          rowColumns.add(
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: targetControllerForWeek,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  fillColor: Colors.blueGrey.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  hintText: targetControllerForWeek.text.isEmpty
                      ? 'Week $week'
                      : null,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        } else {
          rowColumns.add(
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: TextEditingController(),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  fillColor: Colors.blueGrey.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  hintText: 'Week $week',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          );
        }
      }

      allWeeklyRows.add(TableRow(children: rowColumns));
    }

    return allWeeklyRows;
  }

  Widget _buildTableCell(String text) {
    return SizedBox(
      height: 50,
      child: Center(
        child: CustomText(
          content: text,
          textAlign: TextAlign.center,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTableTextField(
      int index, bool isReadOnly, CategoryPerformance? target) {
    projectionControllers[index] ??= TextEditingController(
      text: target?.actualProjection?.toString() ?? '',
    );

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextField(
        controller: projectionControllers[index],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
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
}
