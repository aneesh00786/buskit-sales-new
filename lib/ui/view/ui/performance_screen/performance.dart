// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/bottom_tables/target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/bottom_tables/value_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/checkin_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/custom_perfo_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/customer_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/new_timesheet_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/new_visits_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/visit_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  bool isActive = false;
  bool isLoadingSettings = true;
  StaffController staffController = Get.put(StaffController());
  List<TextEditingController> _targetControllers = [];
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
  String? _selectedMonthName;
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  String selectedValue = "2025";
  String staffProjection = '';
  String targetType = '';

  Future<void> _loadSettings() async {

    try {
      final settingsList = await ApiWorker().fetchAllSettings(companyId);
      setState(() {
        final staffProjectionSetting = settingsList?.firstWhere(
          (setting) => setting.key == 'staffProjection',
          orElse: () =>
              AllCompanySettingsData(key: 'staffProjection', value: ''),
        );
        staffProjection = staffProjectionSetting?.value ?? '';
        final targetTypeSetting = settingsList?.firstWhere(
          (setting) => setting.key == 'targetType',
          orElse: () => AllCompanySettingsData(key: 'targetType', value: ''),
        );
        targetType = targetTypeSetting?.value ?? '';
      });
    } catch (e) {

      print("Error fetching settings: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    ApiWorker().fetchAllSettings(companyId);
    _loadSettings();
    staffController.tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: currentMonth - 1,
    );
    _selectedMonthName = DateFormat.MMMM().format(DateTime(0, currentMonth));
    staffController.loadSalesmanTargetForSelectedTab(
      currentYear: selectedValue,
      selectedTabIndex: staffController.tabController.index + 1,
      staffId: salesmanId,
    );
    staffController.tabController.addListener(() {
      if (!staffController.tabController.indexIsChanging) {
        setState(() {
          _selectedMonthName = DateFormat.MMMM()
              .format(DateTime(0, staffController.tabController.index + 1));
        });
        staffController.loadSalesmanTargetForSelectedTab(
          currentYear: selectedValue,
          selectedTabIndex: staffController.tabController.index + 1,
          staffId: salesmanId,
        );
      }
    });

    int numberOfFields = 10;
    _targetControllers = List.generate(
      numberOfFields,
      (index) => TextEditingController(),
    );
  }

  Future<void> _initializeSettings() async {
    setState(() => isLoadingSettings = true);
    await Future.wait([
      _loadSettings(),
      staffController.loadWeeklyType(),
    ]);
    setState(() => isLoadingSettings = false);
  }

  void updateControllers(int count) {
    if (_targetControllers.length < count) {
      _targetControllers.addAll(
        List.generate(
          count - _targetControllers.length,
          (index) => TextEditingController(),
        ),
      );
    } else if (_targetControllers.length > count) {
      _targetControllers
          .getRange(count, _targetControllers.length)
          .forEach((controller) => controller.dispose());
      _targetControllers = _targetControllers.sublist(0, count);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: isSmallScreen ? 29 : 38,
                        width: isSmallScreen ? 84 : 104,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4.0, top: 4.0, bottom: 1.0),
                              child: DropdownButton<String>(
                                value: selectedValue,
                                items:
                                    ['2025', '2024', '2023'].map((String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedValue = newValue;
                                    });
                                    staffController
                                        .loadSalesmanTargetForSelectedTab(
                                      currentYear: selectedValue,
                                      selectedTabIndex:
                                          staffController.tabController.index +
                                              1,
                                      staffId: salesmanId,
                                    );
                                  }
                                },
                                underline: const SizedBox(),
                                iconEnabledColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const NotificationWidget(
                  startDate: '',
                  endDate: '',
                ),
                profiloe(),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 211, 211, 211)
                        .withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 5,
                    offset: const Offset(4, 4),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color.fromARGB(255, 205, 204, 204),
                  width: 0.5,
                ),
              ),
              child: Wrap(
                spacing: 8.0,
                children: List.generate(12, (index) {
                  final monthName =
                      DateFormat.MMMM().format(DateTime(0, index + 1));
                  final isSelected =
                      staffController.tabController.index == index;

                  return GestureDetector(
                    onTap: () async {
                      bool isConnected = await ConnectivityService().isOnline();
                      if (isConnected) {
                        setState(() {
                          staffController.tabController.index = index;
                          _selectedMonthName = monthName;
                          staffController.selectedTabIndex.value = index;
                        });
                        staffController.loadSalesmanTargetForSelectedTab(
                          currentYear: selectedValue,
                          selectedTabIndex:
                              staffController.tabController.index + 1,
                          staffId: salesmanId,
                        );
                        final provider = Provider.of<CustomersProvider>(context,
                            listen: false);
                        final categoryPerformance = staffController
                            .salesmanTargetList.value.categoryPerformance;
                        final valuePerformance = staffController
                            .salesmanTargetList.value.valueTarget;
                        provider.createBarGroups(
                            categoryPerformance: categoryPerformance ?? [],
                            valuePerformance: valuePerformance ?? [],
                            staffProjection: staffProjection,
                            targetType: targetType);
                      } else {
                        showNoInternetSnackBar(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: white,
                        border: isSelected
                            ? Border.all(color: Colors.grey.shade300)
                            : null,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: CustomText(
                        content: monthName,
                        color: isSelected ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          nkMediumSizeBox(),
          Obx(() {
            if (staffController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final performanceData = staffController.salesmanTargetList.value;
            if (performanceData.navbarAndTargetContent == null) {
              return const Center(
                  child: Text(
                "No Data Available",
                style: TextStyle(color: red),
              ));
            }
            final targetContent = performanceData.navbarAndTargetContent;
            return OptionsWidget(
              options: [
                OptionData(
                    title: 'Timesheet',
                    count: targetContent?.timesheet?.toString() ?? '0',
                    svg: "assets/icons/event.png",
                    svgBgColor: const Color.fromARGB(255, 206, 252, 224),
                    onTap: targetContent?.timesheet?.toString() == '0'
                        ? () => showCustomToastDisplay(
                            context, 'Record Not Found', red, Icons.close)
                        : () {
                            Get.dialog(StaffTimeSheetDialog(
                                staffController: staffController));
                          }
                    // => _showTileDialog(
                    //     context, _selectedMonthName ?? '', 1, true),
                    ),
                OptionData(
                  title: 'Check-in/out',
                  count: targetContent?.salesmanInOut?.length.toString() ?? '0',
                  svg: "assets/icons/check-in.png",
                  svgBgColor: const Color.fromARGB(255, 215, 236, 246),
                  onTap: targetContent?.salesmanInOut?.length.toString() == '0'
                      ? () => showCustomToastDisplay(
                          context, 'Record Not Found', red, Icons.close)
                      : () => _showTileDialog(
                          context, _selectedMonthName ?? '', 2, true),
                ),
                OptionData(
                    title: 'Visits',
                    count: targetContent?.visit?.toString() ?? '0',
                    svg: "assets/icons/location.png",
                    svgBgColor: const Color.fromARGB(255, 249, 219, 193),
                    onTap: targetContent?.visit?.toString() == '0'
                        ? () => showCustomToastDisplay(
                            context, 'Record Not Found', red, Icons.close)
                        : () {
                            Get.dialog(
                              StaffRouteDialog(
                                  staffController: staffController),
                            );
                          }
                    // _showTileDialog(
                    //     context, _selectedMonthName ?? '', 3, false),
                    ),
                OptionData(
                  title: 'Customers',
                  count: targetContent?.customer?.toString() ?? '0',
                  svg: "assets/icons/customer.png",
                  svgBgColor: const Color.fromARGB(255, 211, 240, 249),
                  onTap: targetContent?.customer?.toString() == '0'
                      ? () => showCustomToastDisplay(
                          context, 'Record Not Found', red, Icons.close)
                      : () => _showTileDialog(
                          context, _selectedMonthName ?? '', 4, true),
                ),
              ],
            );
          }),
          nkMediumSizeBox(),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // border: Border.all(
                      //   color: Colors.grey,
                      //   width: 0.4,
                      // ),
                    ),
                    child: Obx(() {
                      if (staffController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final performanceData =
                          staffController.salesmanTargetList.value;
                      if (performanceData.navbarAndTargetContent == null) {
                        return const Center(
                            child: Text(
                          "No Data Available",
                          style: TextStyle(color: Colors.green),
                        ));
                      }
                      final categoryPerformance =
                          performanceData.categoryPerformance;
                      final valuePerformance = performanceData.valueTarget;
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 211, 211, 211)
                                  .withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: const Offset(4, 4),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color.fromARGB(255, 205, 204, 204),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomPerfoBarChart(
                            categoryPerformance: categoryPerformance!,
                            valuePerformance: valuePerformance!,
                            staffProjection: staffProjection,
                            targetType: targetType,
                            // staffProjection:
                            //     targetType == '1' ? staffProjection : '0',
                            // targetType: targetType == '1' ? '1' : '0',
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                nkMediumSizeBox(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 211, 211, 211)
                              .withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 5,
                          offset: const Offset(4, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 205, 204, 204),
                        width: 0.5,
                      ),
                    ),
                    child: (targetType == '1')
                        ? StaffTargetDialog(
                            staffController: staffController,
                            isProjection: staffProjection == '1' ? true : false,
                            isTarget: targetType == '1' ? true : false,
                          )
                        : StaffValueTargetDialog(
                            staffController: staffController,
                            isProjection: staffProjection == '1' ? true : false,
                            isTarget: targetType == '1' ? true : false,
                          ),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  void _showTileDialog(
      BuildContext context, String monthName, int tabStatus, bool isFull) {
    staffController.fetchSalesmanTopBarData(monthName, tabStatus).then((_) {
      showDialog(
        context: context,
        builder: (context) {
          return Obx(() {
            if (staffController.isTopDataLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            Widget dialogContent;
            switch (tabStatus) {
              case 1:
                dialogContent = buildCheckInOutDialogContent(
                    staffController.checkInOutData.value, staffController);
              case 2:
                dialogContent = buildCheckInOutDialogContent(
                    staffController.checkInOutData.value, staffController);
                break;
              case 3:
                dialogContent = buildVisitsDialogContent(
                    staffController.visitData.value, staffController);
                break;
              case 4:
                dialogContent = buildCustomersDialogContent(
                    staffController.customerDatas.value, staffController);
                break;
              default:
                dialogContent = const Text('Unknown data.');
            }

            return Padding(
              padding: isFull
                  ? const EdgeInsets.all(10)
                  : const EdgeInsets.symmetric(horizontal: 150),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: white,
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: dialogContent),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      );
    });
  }
}
