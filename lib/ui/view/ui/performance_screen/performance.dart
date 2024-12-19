import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/notification_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/option_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
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
  StaffController staffController = Get.put(StaffController());
  late final TabController _tabController;
  List<TextEditingController> _targetControllers = [];
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

  @override
  void initState() {
    super.initState();
    final dashboardProvider =
        Provider.of<CustomersProvider>(context, listen: false);
    dashboardProvider.fetchCustomerData();
    _tabController =
        TabController(length: 12, vsync: this, initialIndex: currentMonth - 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        staffController.loadSalesmanTargetForSelectedTab(
          currentYear: currentYear.toString(),
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

  @override
  void dispose() {
    for (var controller in _targetControllers) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        actions: [
          NotificationWidget(),
          profiloe(),
        ],
      ),
      body: Column(
        children: [
          OptionsWidget(options: defaultOption(context)),
          nkMediumSizeBox(),
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
                      });
                      staffController.loadSalesmanTargetForSelectedTab(
                          currentYear: currentYear.toString(),
                          selectedTabIndex: _tabController.index + 1,
                          staffId: salesmanId);
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
                    child: Consumer<DashboardProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<model1.ResponseModell>(
                          future: provider.futureResponseModel,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SpinKitFadingCube(
                                  color: primaryColor,
                                  size: 20.0,
                                ),
                              );
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(
                                child: NodataWidget(),
                              );
                            } else if (snapshot.hasData) {
                              final categories = snapshot.data!.allCategory;
                              final categoryPerformance =
                                  snapshot.data!.categoryPerformance;
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 211, 211, 211)
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
                                  child: CustomBarChart(
                                    categoryPerformance: categoryPerformance!,
                                    allCategory: categories!,
                                  ),
                                ),
                              );
                            } else {
                              return const NodataWidget();
                            }
                          },
                        );
                      },
                    ),
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
}
