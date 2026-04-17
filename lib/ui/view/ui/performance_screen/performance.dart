// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/visit_report_dialog.dart';
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
  String selectedValue = DateTime.now().year.toString();
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
      //
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
 
  List<String> get years => List.generate(5, (index) => (currentYear - index).toString());

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Row(
          children: [
            CustomText(
              content: "Performance & Target".tr, // Change to whatever you want
              fontWeight: FontWeight.bold,
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: isSmallScreen ? 29 : 38,
              width: isSmallScreen ? 84 : 104,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 0,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedValue = newValue;
                        });
                        staffController.loadSalesmanTargetForSelectedTab(
                          currentYear: selectedValue,
                          selectedTabIndex:
                              staffController.tabController.index + 1,
                          staffId: salesmanId,
                        );
                      }
                    },
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Row(
                          children: [
                            Icon(Icons.calendar_view_month, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(year, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    underline: Container(),
                    icon: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[600]),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          const NotificationWidget(
            startDate: '',
            endDate: '',
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   mainAxisSize: MainAxisSize.min,
          //   children: [

          //   ],
          // ),
          profiloe()
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
                        errorSnackbar(
                            "No internet connection . please check your network");
                      }
                    },
                    child: Stack(
                      children: [
                        // Main card container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                  ],
                            border: Border.all(
                              color: isSelected 
                                  ? primaryColor.withOpacity(0.3)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.calendar_month : Icons.calendar_today,
                                size: 18,
                                color: isSelected ? primaryColor : Colors.grey[600],
                              ),
                              const SizedBox(width: 10),
                              CustomText(
                                content: monthName.tr,
                                color: isSelected ? Colors.black87 : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ],
                          ),
                        ),
                        // Bottom indicator for selected tab
                        if (isSelected)
                          Positioned(
                            bottom: -2,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.5),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
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
                    title: 'Timesheet'.tr,
                    month: _selectedMonthName!.tr,
                    unfilteredCount: "0",
                    count: targetContent?.timesheet?.toString() ?? '0',
                    svg: "assets/icons/event.png",
                    svgBgColor: const Color.fromARGB(255, 206, 252, 224),
                    onTap: targetContent?.timesheet?.toString() == '0'
                        ? () => showCustomToastDisplay(
                            context, 'Record Not Found'.tr, red, Icons.close)
                        : () {
                            Get.dialog(StaffTimeSheetDialog(
                                staffController: staffController));
                          }),
                           

                // OptionData(
                //   title: 'Check-in/out',
                //   unfilteredCount: "0",
                //   count: targetContent?.salesmanInOut?.length.toString() ?? '0',
                //   svg: "assets/icons/check-in.png",
                //   svgBgColor: const Color.fromARGB(255, 215, 236, 246),
                //   onTap: targetContent?.salesmanInOut?.length.toString() == '0'
                //       ? () => showCustomToastDisplay(
                //           context, 'Record Not Found', red, Icons.close)
                //       : () => showTileDialog(
                //           context, _selectedMonthName ?? '', 2, true),
                // ),
                OptionData(
                    title: 'Visits'.tr,
                    width: 165.0,
                    month: _selectedMonthName!.tr,
                    unfilteredCount: "0",
                    count: targetContent?.visit?.toString() ?? '0',
                    svg: "assets/icons/location.png",
                    svgBgColor: const Color.fromARGB(255, 249, 219, 193),
                    onTap: targetContent?.visit?.toString() == '0'
                        ? () => showCustomToastDisplay(
                            context, 'Record Not Found'.tr, red, Icons.close)
                        : () {
                          int selectedYearInt = int.tryParse(selectedValue) ?? currentYear;
            int selectedMonthInt = staffController.tabController.index + 1;
                            Get.dialog(
              StaffRouteDialog(
                staffController: staffController,
                selectedYear: selectedYearInt,
                selectedMonth: selectedMonthInt,
              ),
            );
                          }),
                            OptionData(
                  title: 'Visit Report'.tr,
                  month: _selectedMonthName!.tr,
                  unfilteredCount: "0",
                 count: targetContent?.visitReport?.toString() ?? '0',
                  svg: "assets/icons/check-in.png",
                  svgBgColor: const Color.fromARGB(255, 211, 240, 249),
                  onTap: (){
                    showTileDialog(
                          context, _selectedMonthName ?? '', 5, true);
                  },
                ),
                OptionData(
                  title: 'Customers'.tr,
                  unfilteredCount: "0",
                  count: targetContent?.customer?.toString() ?? '0',
                  svg: "assets/icons/customer.png",
                  svgBgColor: const Color.fromARGB(255, 211, 240, 249),
                  onTap: targetContent?.customer?.toString() == '0'
                      ? () => showCustomToastDisplay(
                          context, 'Record Not Found'.tr, red, Icons.close)
                      : () => showTileDialog(
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

  void showTileDialog(BuildContext context, String monthName, int tabStatus, bool isFull) {
    
    if (tabStatus == 5) {
      int monthIndex = staffController.tabController.index + 1;

      // 1. Show the dialog immediately
      showDialog(
        context: context,
        builder: (context) {
          return Obx(() {
            // This will show the loader while isVisitReportLoading is true
            if (staffController.isVisitReportLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Once loading is false, it shows the data
            return _buildDialogContainer(
              isFull, 
              VisitReportDialog(reportData: staffController.visitReportList)
            );
          });
        },
      );

      // 2. Trigger the API call (Make sure loadVisitReports sets isVisitReportLoading to true at its start)
      staffController.loadVisitReports(selectedValue, monthIndex);
      return; 
    }

    // For all other tab statuses:
    // 1. Show the dialog immediately
    showDialog(
      context: context,
      builder: (context) {
        return Obx(() {
          if (staffController.isTopDataLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          Widget dialogContent;
          switch (tabStatus) {
            case 1: 
              dialogContent = buildCheckInOutDialogContent(
                  staffController.checkInOutData.value, staffController);
              break;
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

          return _buildDialogContainer(isFull, dialogContent);
        });
      },
    );

    // 2. Trigger the API call
    staffController.fetchSalesmanTopBarData(monthName, tabStatus);
  }
  // void showTileDialog(
  //     BuildContext context, String monthName, int tabStatus, bool isFull) {
    
    
  //   if (tabStatus == 5) {
      
  //     int monthIndex = staffController.tabController.index + 1;

     
  //     staffController.loadVisitReports(selectedValue, monthIndex).then((_) {
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return Obx(() {
              
  //             if (staffController.isVisitReportLoading.value) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
              
           
  //             return _buildDialogContainer(
  //               isFull, 
  //               VisitReportDialog(reportData: staffController.visitReportList)
  //             );
  //           });
  //         },
  //       );
  //     });
  //     return; 
  //   }

   
  //   staffController.fetchSalesmanTopBarData(monthName, tabStatus).then((_) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Obx(() {
  //           if (staffController.isTopDataLoading.value) {
  //             return const Center(child: CircularProgressIndicator());
  //           }

  //           Widget dialogContent;
  //           switch (tabStatus) {
  //             case 1: 
  //               dialogContent = buildCheckInOutDialogContent(
  //                   staffController.checkInOutData.value, staffController);
  //               break;
  //             case 2: 
  //               dialogContent = buildCheckInOutDialogContent(
  //                   staffController.checkInOutData.value, staffController);
  //               break;
  //             case 3: 
  //               dialogContent = buildVisitsDialogContent(
  //                   staffController.visitData.value, staffController);
  //               break;
  //             case 4: 
  //               dialogContent = buildCustomersDialogContent(
  //                   staffController.customerDatas.value, staffController);
  //               break;
  //             default:
  //               dialogContent = const Text('Unknown data.');
  //           }

  //           return _buildDialogContainer(isFull, dialogContent);
  //         });
  //       },
  //     );
  //   });
  // }

  
  Widget _buildDialogContainer(bool isFull, Widget content) {
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
                color: Colors.white, 
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: content),
            ),
          ),
        ],
      ),
    );
  }
}
