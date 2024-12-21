import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/notification_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:fl_chart/fl_chart.dart';
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
  StaffController staffController = Get.put(StaffController());
  late final TabController _tabController;
  List<TextEditingController> _targetControllers = [];
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

  @override
  void initState() {
    super.initState();
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

  String selectedValue = "2024";
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
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4.0, top: 4.0, bottom: 1.0),
                              child: DropdownButton<String>(
                                value: selectedValue,
                                items: ['2024', '2023'].map((String year) {
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
                NotificationWidget(),
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
                      });
                      // Trigger data load here, before build starts
                      staffController.loadSalesmanTargetForSelectedTab(
                        currentYear: currentYear.toString(),
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
                  onTap: () {},
                ),
                OptionData(
                  title: 'Check-in/Check-out',
                  count: targetContent?.salesmanInOut?.length.toString() ?? '0',
                  svg: "assets/icons/check-in.png",
                  svgBgColor: const Color.fromARGB(255, 215, 236, 246),
                  onTap: () {},
                ),
                OptionData(
                  title: 'Visits',
                  count: targetContent?.visit?.toString() ?? '0',
                  svg: "assets/icons/location.png",
                  svgBgColor: const Color.fromARGB(255, 249, 219, 193),
                  onTap: () {},
                ),
                OptionData(
                  title: 'Customers',
                  count: targetContent?.customer?.toString() ?? '0',
                  svg: "assets/icons/customer.png",
                  svgBgColor: const Color.fromARGB(255, 211, 240, 249),
                  onTap: () {},
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
            final performanceData = staffController.salesmanTargetList.value;
            if (performanceData.navbarAndTargetContent == null) {
              return const Center(child: Text("No Data Available"));
            }
            final categoryPerformance = performanceData.categoryPerformance;
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
                          child: CustomBarChart(
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
}
class CustomBarChart extends StatefulWidget {
  final List<CategoryPerformance> categoryPerformance;

  const CustomBarChart({
    super.key,
    required this.categoryPerformance,
  });

  @override
  _CustomBarChartState createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    _createBarGroups();
  }

void _createBarGroups() {
  barGroups = widget.categoryPerformance.asMap().entries.map((entry) {
    int index = entry.key;
    CategoryPerformance perf = entry.value;
    num target = perf.actualTarget ?? 0.0;
    num projection = perf.actualProjection ?? 0.0;
    Object actual = perf.actualSales ?? 0.0;
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: double.parse(target.toString()),
          color: const Color(0xff3b6491),
          width: 8,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        BarChartRodData(
          toY: double.parse(projection.toString()),
          color: const Color(0xff15396a),
          width: 8,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        BarChartRodData(
          toY: double.parse(actual.toString()),
          color: const Color(0xff7a8f3d),
          width: 8,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
      ],
    );
  }).toList();
}
  void _showSalesmanPopup(int cid, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            provider.fetchchartCategoryPerformmenc(cid);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              content: FutureBuilder<ResponseModelCp>(
                future: provider.responseModelCp,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final categories = snapshot.data!.data;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: const BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                dialogCloseButton1(context, red)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DataTable(
                              headingRowHeight: 40,
                              dataRowHeight: 30,
                              columnSpacing: 40,
                              headingRowColor: WidgetStatePropertyAll(
                                  Colors.blueGrey.shade50),
                              border:
                                  TableBorder.all(color: Colors.grey, width: 1),
                              columns: const [
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Name',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Target',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Projection',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Actual',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              rows: categories!.map((s) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: Text(
                                          s.fullname,
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          formatAmount(s.targetTotal),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          formatAmount(s.projectionTotal),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,

                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          formatAmount(s.orderTotal),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return NodataWidget();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    Widget text = Transform.rotate(
      angle: -1.34 / 4,
      child: MyRegularText(
        label: widget.categoryPerformance[value.toInt()].category ?? '',
        fontWeight: FontWeight.w500,
        fontSize: 11,
        color: Colors.black,
      ),
    );
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: text,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return MyRegularText(
      label: value.toInt().toString(),
      fontSize: 10.6,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.blue),
                thickness: MaterialStateProperty.all(5),
                radius: Radius.circular(8),
              ),
              child: Scrollbar(
                controller:
                    Provider.of<DashboardProvider>(context, listen: false)
                        .scrollController,
                interactive: true,
                thickness: 5,
                thumbVisibility: true,
                trackVisibility: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SingleChildScrollView(
                    controller:
                        Provider.of<DashboardProvider>(context, listen: false)
                            .scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    child: SizedBox(
                      width: barGroups.length * 66.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      getLeftTitles,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: getBottomTitles,
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xffe0e0e0),
                                width: 0.9,
                              ),
                            ),
                            barTouchData: BarTouchData(
                              touchCallback: (FlTouchEvent event,
                                  BarTouchResponse? touchResponse) {
                                if (touchResponse != null &&
                                    touchResponse.spot != null &&
                                    event is FlTapUpEvent) {
                                  final int index =
                                      touchResponse.spot!.touchedBarGroupIndex;
                                  CategoryPerformance perf =
                                      widget.categoryPerformance.firstWhere(
                                    (performance) =>
                                        performance.category ==
                                        widget.categoryPerformance[index].category,
                                  );
                                  _showSalesmanPopup(perf.cid ?? 0,
                                      widget.categoryPerformance[index].category ?? '');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(color: const Color(0xff3b6491), label: 'Target'),
            _buildLegend(color: const Color(0xff15396a), label: 'Projection'),
            _buildLegend(color: const Color(0xff7a8f3d), label: 'Actuals'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          height: ResponsiveInfo.isMobileDimension(context) ? 11.5 : 11.9,
          width: ResponsiveInfo.isMobileDimension(context) ? 14.9 : 14.9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.0),
          ),
        ),
        const SizedBox(width: 2),
        MyRegularText(
          label: label,
          color: secondaryTextColor,
          fontSize: 11.6,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}