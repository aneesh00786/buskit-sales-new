import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffTargetDialog extends StatefulWidget {
  final StaffController staffController;

  StaffTargetDialog({
    required this.staffController,
  });

  @override
  _StaffTargetDialogState createState() => _StaffTargetDialogState();
}

class _StaffTargetDialogState extends State<StaffTargetDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<TextEditingController> _targetControllers = [];

  final Map<String, List<TextEditingController>> _weeklyTargetControllers = {};

  final int currentMonth = DateTime.now().month;
  final int currentYear = DateTime.now().year;

  bool isWeekly = false;

  // Map to store categoryId and its updated target value
  Map<dynamic, String> updatedTargets = {};
  Map<dynamic, String> weeklyTargets = {};

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 12, vsync: this, initialIndex: currentMonth - 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadSalesmanTargetForSelectedTab();
      }
    });

    _initializeControllers();

    _loadSalesmanTargetForSelectedTab();
  }

  // Load targets based on the selected tab and initialize text controllers
  void _loadSalesmanTargetForSelectedTab() {
    final selectedMonth = _tabController.index + 1;
    final selectedMonthName =
        DateFormat.MMMM().format(DateTime(0, selectedMonth));

    widget.staffController
        .loadSalesmanTarget(
      "SALES1",
      selectedMonthName,
      currentYear.toString(),
    )
        .then((_) {
      setState(() {
        _targetControllers = widget.staffController.salesmanTargetList
            .map((data) => TextEditingController(text: data.target.toString()))
            .toList();
      });
    });
  }

  void _initializeControllers() {
    final salesmanTargetList = widget.staffController.salesmanTargetList;

    Future.delayed(Duration(seconds: 1));
    _weeklyTargetControllers.clear();
    if (salesmanTargetList.isNotEmpty) {
      for (var target in salesmanTargetList) {
        final weeklyTargets = target.weeklyTarget?.targets ?? {};
        weeklyTargets.forEach((week, value) {
          if (_weeklyTargetControllers[week] == null) {
            _weeklyTargetControllers[week] = [];
          }
          final categoryIndex = widget.staffController.salesmanTargetList
              .indexWhere((item) => item.id == target.id);
          if (categoryIndex >= 0) {
            while (_weeklyTargetControllers[week]!.length <= categoryIndex) {
              _weeklyTargetControllers[week]!.add(TextEditingController());
            }
            _weeklyTargetControllers[week]![categoryIndex] =
                TextEditingController(text: value?.toString() ?? '');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _targetControllers) {
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding:
                              const EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: Wrap(
                            spacing: 8.0,
                            children: List.generate(12, (index) {
                              final monthName = DateFormat.MMMM()
                                  .format(DateTime(0, index + 1));
                              final isSelected = _tabController.index == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _tabController.index = index;
                                  });
                                  _loadSalesmanTargetForSelectedTab();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: white,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.grey.shade300)
                                        : null,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5)),
                                  ),
                                  child: Text(
                                    monthName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
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
                              },
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  children: [
                                    _buildTableHeader('Category'),
                                    _buildTableHeader('Target'),
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
                                      _tabController.index + 1;
                                  final relevantWeeks = getWeeksForMonth(
                                      currentYear, selectedMonth);

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

  void _saveTargets() {
    final selectedMonth = _tabController.index + 1;
    final selectedMonthName =
        DateFormat.MMMM().format(DateTime(0, selectedMonth));

    updatedTargets = {
      for (int i = 0; i < _targetControllers.length; i++)
        widget.staffController.salesmanTargetList[i].id.toString():
            _targetControllers[i].text.toString()
    };

    Map<String, String> buildRequestData(
        List<int> categoryIds, List<int> relevantWeeks) {
      final Map<String, String> requestData = {};

      for (var week in relevantWeeks) {
        final weekKey = 'week$week';
        final controllers = _weeklyTargetControllers[weekKey] ?? [];

        for (var categoryIndex = 0;
            categoryIndex < categoryIds.length;
            categoryIndex++) {
          final categoryId = categoryIds[categoryIndex];
          final key = 'weekly_${categoryId}_week$week';
          final controller = categoryIndex < controllers.length
              ? controllers[categoryIndex]
              : null;
          requestData[key] = controller?.text ?? '';
        }
      }

      return requestData;
    }

    List<int> getCategoryIds() {
      return widget.staffController.salesmanTargetList
          .map((category) => category.id!)
          .toList();
    }

    final categoryIds = getCategoryIds();
    final relevantWeeks = getWeeksForMonth(currentYear, selectedMonth);
    final requestData = buildRequestData(categoryIds, relevantWeeks);

    log(requestData.toString());

    widget.staffController.updateCategoryTarget(
      "SALES1",
      selectedMonthName,
      currentYear.toString(),
      updatedTargets,
      requestData,
    );

    print('Updated Targets: $updatedTargets');
    Navigator.of(context).pop();
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomText(
        content: text,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  List<TableRow> _buildCategoryRows() {
    return List.generate(widget.staffController.salesmanTargetList.length,
        (index) {
      final targetData = widget.staffController.salesmanTargetList[index];
      return TableRow(
        children: [
          _buildTableCell(targetData.categoryName.toString()),
          _buildTableTextField(index),
        ],
      );
    });
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
        categoryIndex < widget.staffController.salesmanTargetList.length;
        categoryIndex++) {
      final target = widget.staffController.salesmanTargetList[categoryIndex];
      final rowColumns = <Widget>[
        Container(
          height: 50,
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(target.categoryName ?? '')),
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
                      : null, // Show hint only if text is empty
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTableTextField(int index) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
      child: TextField(
        controller: _targetControllers[index],
        textAlign: TextAlign.center,
        readOnly: true,
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
