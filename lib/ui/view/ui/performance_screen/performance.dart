import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/checkin_checkout_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_data_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/visit_data_modfel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/checkin_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/custom_perfo_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/customer_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/datacolumn_and_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/visit_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  bool isActive = false;
  StaffController staffController = Get.put(StaffController());
  late final TabController _tabController;
  List<TextEditingController> _targetControllers = [];
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
  String? _selectedMonthName;
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  String selectedValue = "2024";
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 12, vsync: this, initialIndex: currentMonth - 1);
    _selectedMonthName = DateFormat.MMMM().format(DateTime.now());
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        staffController.loadSalesmanTargetForSelectedTab(
          currentYear: selectedValue,
          selectedTabIndex: _tabController.index + 1,
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
                                items: ['2025','2024', '2023'].map((String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: TextStyle(
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
                                          _tabController.index + 1,
                                      staffId: salesmanId,
                                    );
                                  }
                                },
                                underline: SizedBox(),
                                iconEnabledColor: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                NotificationWidget(
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
                    offset: Offset(4, 4),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color.fromARGB(255, 205, 204, 204),
                  width: 0.5,
                ),
              ),
              child: Wrap(
                spacing: 8.0,
                children: List.generate(12, (index) {
                  final monthName =
                      DateFormat.MMMM().format(DateTime(0, index + 1));
                  final isSelected = _tabController.index == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tabController.index = index;
                        _selectedMonthName = monthName;
                      });
                      staffController.loadSalesmanTargetForSelectedTab(
                        currentYear: selectedValue,
                        selectedTabIndex: _tabController.index + 1,
                        staffId: salesmanId,
                      );
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
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
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
            if (staffController.isTargetLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final performanceData = staffController.salesmanTargetList.value;
            if (performanceData.navbarAndTargetContent == null) {
              return const Center(child: Text("No Data Available"));
            }
            final targetContent = performanceData.navbarAndTargetContent;
            return OptionsWidget(
              options: [
                OptionData(
                  title: 'Timesheet',
                  count: targetContent?.timesheet?.toString() ?? '0',
                  svg: "assets/icons/event.png",
                  svgBgColor: const Color.fromARGB(255, 206, 252, 224),
                  onTap: () =>
                      _showTileDialog(context, _selectedMonthName ?? '', 1),
                ),
                OptionData(
                  title: 'Check-in/out',
                  count: targetContent?.salesmanInOut?.length.toString() ?? '0',
                  svg: "assets/icons/check-in.png",
                  svgBgColor: const Color.fromARGB(255, 215, 236, 246),
                  onTap: () =>
                      _showTileDialog(context, _selectedMonthName ?? '', 2),
                ),
                OptionData(
                  title: 'Visits',
                  count: targetContent?.visit?.toString() ?? '0',
                  svg: "assets/icons/location.png",
                  svgBgColor: const Color.fromARGB(255, 249, 219, 193),
                  onTap: () =>
                      _showTileDialog(context, _selectedMonthName ?? '', 3),
                ),
                OptionData(
                  title: 'Customers',
                  count: targetContent?.customer?.toString() ?? '0',
                  svg: "assets/icons/customer.png",
                  svgBgColor: const Color.fromARGB(255, 211, 240, 249),
                  onTap: () =>
                      _showTileDialog(context, _selectedMonthName ?? '', 4),
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
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.4,
                      ),
                    ),
                    child: Obx(() {
                      if (staffController.isTargetLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final performanceData =
                          staffController.salesmanTargetList.value;
                      if (performanceData.navbarAndTargetContent == null) {
                        return const Center(child: Text("No Data Available"));
                      }
                      final categoryPerformance =
                          performanceData.categoryPerformance;
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 211, 211, 211)
                                  .withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: Offset(4, 4),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color.fromARGB(255, 205, 204, 204),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomPerfoBarChart(
                            categoryPerformance: categoryPerformance!,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                nkMediumSizeBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 211, 211, 211)
                              .withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 5,
                          offset: Offset(4, 4),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromARGB(255, 205, 204, 204),
                        width: 0.5,
                      ),
                    ),
                    child: StaffTargetDialog(
                      staffController: staffController,
                      currentYear: currentYear,
                      tabController: _tabController,
                      tabControllers: _targetControllers,
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

  void _showTileDialog(BuildContext context, String monthName, int tabStatus) {
    staffController.fetchSalesmanTopBarData(monthName, tabStatus).then((_) {
      showDialog(
        context: context,
        builder: (context) {
          return Obx(() {
            if (staffController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            Widget dialogContent;
            switch (tabStatus) {
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    child: Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: white,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: dialogContent),
                      ),
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

// Widget _buildTimesheetDialogContent(TimesheetData? data) {
//   if (data == null) return const Text('No Timesheet data available.');
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text('Timesheet Details:', style: TextStyle(fontWeight: FontWeight.bold)),
//       ...data.entries.map((entry) => Text('${entry.name}: ${entry.value}')),
//     ],
//   );
// }
}
