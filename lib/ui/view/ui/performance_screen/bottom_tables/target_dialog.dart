// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffTargetDialog extends StatefulWidget {
  final StaffController staffController;
  final bool isTarget;
  final bool isProjection;
  const StaffTargetDialog({
    super.key,
    required this.staffController,
    required this.isTarget,
    required this.isProjection,
  });
  @override
  _StaffTargetDialogState createState() => _StaffTargetDialogState();
}

class _StaffTargetDialogState extends State<StaffTargetDialog>
    with SingleTickerProviderStateMixin {
  List<TextEditingController> _targetControllers = [];
  List<TextEditingController> _projectionControllers = [];
  final Map<String, List<TextEditingController>> _weeklyTargetControllers = {};
  final Map<String, List<TextEditingController>> _weeklyProjectionControllers =
      {};
  Map<dynamic, String> updatedTargets = {};
  Map<dynamic, String> updatedProjection = {};
  Map<dynamic, String> weeklyTargets = {};
  final int currentMonth = DateTime.now().month;
  final int currentYear = DateTime.now().year;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _initializeState();
    _loadSalesmanTargetForSelectedTab();
  }

  void _initializeState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.staffController.tabController.addListener(() {
        if (!widget.staffController.tabController.indexIsChanging) {
          _loadSalesmanTargetForSelectedTab();
          _initializeControllers();
        }
      });
    });

    widget.staffController.loadWeeklyType().then((_) {
      setState(() {
        isLoading = false;
      });
      _loadSalesmanTargetForSelectedTab();
      _initializeControllers();
    });
  }

  @override
  void didUpdateWidget(covariant StaffTargetDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staffController.tabController !=
        widget.staffController.tabController) {
      widget.staffController.tabController.addListener(() {
        if (!widget.staffController.tabController.indexIsChanging) {
          _loadSalesmanTargetForSelectedTab();
          _initializeControllers();
        }
      });
    }
  }

  void _loadSalesmanTargetForSelectedTab() {
    final selectedMonth = widget.staffController.tabController.index + 1;
    final selectedMonthName =
        DateFormat.MMMM().format(DateTime(0, selectedMonth));

    widget.staffController
        .loadSalesmanTargetTableData(
      SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
      selectedMonthName,
      currentYear.toString(),
    )
        .then((_) {
      setState(() {
        _targetControllers = widget.staffController.salesmanTargetTableList
            .map((data) => TextEditingController(text: data.target.toString()))
            .toList();

        _projectionControllers = widget.staffController.salesmanTargetTableList
            .map((data) =>
                TextEditingController(text: data.projection.toString()))
            .toList();

        _initializeControllers();
      });
    });
  }

  void _initializeControllers() {
    final salesmanTargetTableList =
        widget.staffController.salesmanTargetTableList;
    Future.delayed(const Duration(seconds: 1));
    _weeklyTargetControllers.clear();
    _weeklyProjectionControllers.clear();
    if (salesmanTargetTableList.isNotEmpty) {
      for (var target in salesmanTargetTableList) {
        final weeklyTargets = target.weeklyTarget?.targets ?? {};
        weeklyTargets.forEach((week, value) {
          if (_weeklyTargetControllers[week] == null) {
            _weeklyTargetControllers[week] = [];
          }
          final categoryIndex = widget.staffController.salesmanTargetTableList
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
      for (var projection in salesmanTargetTableList) {
        final weeklyTargets = projection.weeklyProjection?.targets ?? {};
        weeklyTargets.forEach((week, value) {
          if (_weeklyProjectionControllers[week] == null) {
            _weeklyProjectionControllers[week] = [];
          }
          final categoryIndex = widget.staffController.salesmanTargetTableList
              .indexWhere((item) => item.id == projection.id);
          if (categoryIndex >= 0) {
            while (
                _weeklyProjectionControllers[week]!.length <= categoryIndex) {
              _weeklyProjectionControllers[week]!.add(TextEditingController());
            }
            _weeklyProjectionControllers[week]![categoryIndex] =
                TextEditingController(text: value?.toString() ?? '');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _targetControllers) {
      controller.dispose();
    }
    for (var controller in _projectionControllers) {
      controller.dispose();
    }
    _weeklyTargetControllers.forEach((_, controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    });
    _weeklyProjectionControllers.forEach((_, controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    });
    widget.staffController.salesmanTargetTableList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final isDataInitialized = _weeklyTargetControllers.isNotEmpty &&
        _weeklyTargetControllers.keys.every((week) {
          return _weeklyTargetControllers[week]!.isNotEmpty;
        });

    if (widget.staffController.isWeekly.value && !isDataInitialized) {
      _initializeControllers();
    }
    return Obx(() {
      return widget.staffController.isTargetLoading.value
          ? const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, Color(0xFF2D3748)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target by Category'.tr,
                            style: const TextStyle(
                              color: white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins_Regular',
                            ),
                          ),
                        ],
                      ),
                    ),
                    nkSmallSizeBox(),
                    if (widget.staffController.isWeekly.value == false) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(
                                color: const Color(0xFFE2E8F0), width: 0.6),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(
                              decoration:
                                  const BoxDecoration(color: Color(0xFFF8FAFC)),
                              children: [
                                _buildTableHeader('Category'.tr),
                                _buildTableHeader('Monthly Target'.tr),
                                if (widget.isProjection)
                                  _buildTableHeader('Projection'.tr),
                              ],
                            ),
                            ..._buildCategoryRows(),
                          ],
                        ),
                      ),
                    ],
                    if (widget.staffController.isWeekly.value == true) ...[
                      Builder(
                        builder: (context) {
                          final relevantWeeks = widget.staffController.weekList;
                          return SizedBox(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1.5,
                                padding: const EdgeInsets.only(
                                    bottom: 8, left: 8, right: 8),
                                child: Table(
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: const Color(0xFFE2E8F0),
                                        width: 0.6),
                                  ),
                                  columnWidths: const {
                                    0: FixedColumnWidth(150)
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC)),
                                      children: [
                                        _buildTableHeader('Category'),
                                        ...relevantWeeks.map((week) {
                                          return _buildTableHeader(
                                              week.replaceAll('week', "Week "));
                                        }),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC)),
                                      children: [
                                        _buildTableHeader(''),
                                        ...relevantWeeks.map((week) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    _buildTableHeader('Target'),
                                              ),
                                              if (widget.isProjection) ...[
                                                Expanded(
                                                  child: _buildTableHeader(
                                                      'Projection'),
                                                ),
                                              ],
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                    ..._buildCategoryWeeklyRows(relevantWeeks),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 32),
                        ),
                        onPressed: _saveTargets,
                        child: Text(
                          'Save'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins_Regular',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
    });
  }

  void _saveTargets() async {
    final selectedMonth = widget.staffController.tabController.index + 1;
    final selectedMonthName =
        DateFormat.MMMM().format(DateTime(0, selectedMonth));

    Map<String, String> buildTargetRequestData(
        List<int> categoryIds, List<String> relevantWeeks) {
      final Map<String, String> weeklyTargetRequest = {};

      for (var week in relevantWeeks) {
        final weekKey = week;
        final controllers = _weeklyTargetControllers[weekKey] ?? [];

        for (var categoryIndex = 0;
            categoryIndex < categoryIds.length;
            categoryIndex++) {
          final categoryId = categoryIds[categoryIndex];
          final key = 'weekly_${categoryId}_$week';
          final controller = categoryIndex < controllers.length
              ? controllers[categoryIndex]
              : null;
          weeklyTargetRequest[key] = controller?.text ?? '';
        }
      }

      return weeklyTargetRequest;
    }

    Map<String, String> buildProjectionRequestData(
        List<int> categoryIds, List<String> relevantWeeks) {
      final Map<String, String> weeklyTargetRequest = {};

      for (var week in relevantWeeks) {
        final weekKey = week;
        final controllers = _weeklyProjectionControllers[weekKey] ?? [];

        for (var categoryIndex = 0;
            categoryIndex < categoryIds.length;
            categoryIndex++) {
          final categoryId = categoryIds[categoryIndex];
          final key = 'projection_category_${categoryId}_$week';
          final controller = categoryIndex < controllers.length
              ? controllers[categoryIndex]
              : null;
          weeklyTargetRequest[key] = controller?.text ?? '';
        }
      }

      return weeklyTargetRequest;
    }

    List<int> getCategoryIds() {
      return widget.staffController.salesmanTargetTableList
          .map((category) => category.id!)
          .toList();
    }

    final categoryIds = getCategoryIds();
    final relevantWeeks = widget.staffController.weekList;
    updatedTargets = {};
    updatedProjection = {};

    for (var categoryIndex = 0;
        categoryIndex < categoryIds.length;
        categoryIndex++) {
      final categoryId = categoryIds[categoryIndex].toString();
      updatedTargets[categoryId] =
          _targetControllers[categoryIndex].text.toString();
      updatedProjection[categoryId] =
          _projectionControllers[categoryIndex].text.toString();
      for (var week in relevantWeeks) {
        final weekKey = week;
        final weeklyTargetControllers = _weeklyTargetControllers[weekKey] ?? [];
        final weeklyProjectionControllers =
            _weeklyProjectionControllers[weekKey] ?? [];

        if (categoryIndex < weeklyTargetControllers.length) {
          updatedTargets['weekly_${categoryId}_$week'] =
              weeklyTargetControllers[categoryIndex].text.toString();
        }

        if (categoryIndex < weeklyProjectionControllers.length) {
          updatedProjection['projection_category_${categoryId}_$week'] =
              weeklyProjectionControllers[categoryIndex].text.toString();
        }
      }
    }
    Map<String, dynamic> formattedData = {
      for (var key in updatedTargets.keys)
        key: [
          {
            "target": updatedTargets[key] ?? "0",
            "projection": updatedProjection[key] ?? "0"
          }
        ]
    };
    final weeklyTargetRequest =
        buildTargetRequestData(categoryIds, relevantWeeks);
    final weeklyProjectionRequest =
        buildProjectionRequestData(categoryIds, relevantWeeks);
    setState(() {
      isLoading = true;
    });
    try {
      await widget.staffController.updateCategoryTarget(
        SessionHelper.loginSavedData?.salesmanId ?? 'unknown',
        selectedMonthName,
        currentYear.toString(),
        widget.staffController.isWeekly.value ? {} : formattedData,
        widget.staffController.isWeekly.value ? weeklyTargetRequest : {},
        widget.staffController.isWeekly.value ? weeklyProjectionRequest : {},
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
        isLoading = false;
      });
    }
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }

  List<TableRow> _buildCategoryRows() {
    return List.generate(widget.staffController.salesmanTargetTableList.length,
        (index) {
      final targetData = widget.staffController.salesmanTargetTableList[index];
      return TableRow(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : const Color(0xFFF8FAFC),
        ),
        children: [
          _buildTableCell(targetData.categoryName.toString()),
          _buildTableTextField(index),
          if (widget.isProjection) _buildTableTextFieldProjection(index),
        ],
      );
    });
  }

  List<TableRow> _buildCategoryWeeklyRows(List<String> relevantWeeks) {
    final allWeeklyRows = <TableRow>[];

    for (var categoryIndex = 0;
        categoryIndex < widget.staffController.salesmanTargetTableList.length;
        categoryIndex++) {
      final target =
          widget.staffController.salesmanTargetTableList[categoryIndex];
      final rowColumns = <Widget>[
        Container(
          height: 50,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              target.categoryName ?? '',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Poppins_Regular',
              ),
            ),
          ),
        ),
      ];

      for (var week in relevantWeeks) {
        final weekKey = week;

        _weeklyTargetControllers.putIfAbsent(weekKey, () => []);
        _weeklyProjectionControllers.putIfAbsent(weekKey, () => []);

        while (_weeklyTargetControllers[weekKey]!.length <= categoryIndex) {
          _weeklyTargetControllers[weekKey]!.add(TextEditingController());
        }
        while (_weeklyProjectionControllers[weekKey]!.length <= categoryIndex) {
          _weeklyProjectionControllers[weekKey]!.add(TextEditingController());
        }

        final targetControllerForWeek =
            _weeklyTargetControllers[weekKey]![categoryIndex];
        final projectionControllerForWeek =
            _weeklyProjectionControllers[weekKey]![categoryIndex];

        rowColumns.add(
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: false,
                    controller: targetControllerForWeek,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins_Regular',
                    ),
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      hintText: '0',
                      hintStyle: const TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'Poppins_Regular',
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isProjection) ...{
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: projectionControllerForWeek,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: 'Poppins_Regular',
                      ),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        hintText: '0',
                        hintStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontFamily: 'Poppins_Regular',
                        ),
                      ),
                      onChanged: (value) {
                        projectionControllerForWeek.value =
                            projectionControllerForWeek.value.copyWith(
                          text: value,
                          selection:
                              TextSelection.collapsed(offset: value.length),
                        );
                      },
                    ),
                  ),
                ),
              },
            ],
          ),
        );
      }
      allWeeklyRows.add(TableRow(
        decoration: BoxDecoration(
          color: categoryIndex.isEven ? Colors.white : const Color(0xFFF8FAFC),
        ),
        children: rowColumns,
      ));
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
            color: Color(0xFF0F172A),
            fontFamily: 'Poppins_Regular',
          ),
        ),
      ),
    );
  }

  Widget _buildTableTextField(int index) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          _targetControllers[index].text,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: 'Poppins_Regular',
          ),
        ),
      ),
    );
  }

  Widget _buildTableTextFieldProjection(int index) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _projectionControllers[index],
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontFamily: 'Poppins_Regular',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Enter value',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.normal,
          ),
          prefixIcon:
              const Icon(Icons.edit_outlined, size: 16, color: primaryColor),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }
}
