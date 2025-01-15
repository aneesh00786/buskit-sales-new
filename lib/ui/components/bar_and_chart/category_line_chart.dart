import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/bar_chart_table_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import '../../view/ui/dashboard1/provider/dash_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class MyAppssss extends StatelessWidget {
  const MyAppssss({super.key});
  @override
  Widget build(BuildContext context) {
    return const BarChartSample();
  }
}

class BarChartSample extends StatelessWidget {
  const BarChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 65,
                color: const Color(0xffFF6384),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 55,
                color: const Color(0xffFF9F40),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 75,
                color: const Color(0xffFFCD56),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 59,
                color: const Color(0xff4BC0C0),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 49,
                color: const Color(0xff36A2EB),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 69,
                color: const Color(0xff9966FF),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 80,
                color: const Color(0xffFF6384),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 70,
                color: const Color(0xffFF9F40),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 90,
                color: const Color(0xffFFCD56),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 81,
                color: const Color(0xff4BC0C0),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 71,
                color: const Color(0xff36A2EB),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 91,
                color: const Color(0xff9966FF),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 56,
                color: const Color(0xffFF6384),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 46,
                color: const Color(0xffFF9F40),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 66,
                color: const Color(0xffFFCD56),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 55,
                color: const Color(0xff4BC0C0),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 45,
                color: const Color(0xff36A2EB),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 65,
                color: const Color(0xff9966FF),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                toY: 40,
                color: const Color(0xffFF6384),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 30,
                color: const Color(0xffFF9F40),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: 50,
                color: const Color(0xffFFCD56),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomBarChart extends StatefulWidget {
  final List<Category> allCategory;
  final List<CategoryPerformancee> categoryPerformance;
  String staffProjection;

   CustomBarChart({
    super.key,
    required this.allCategory,
    required this.categoryPerformance,
    required this.staffProjection,
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
    barGroups = widget.allCategory.asMap().entries.map((entry) {
      int index = entry.key;
      Category category = entry.value;
      CategoryPerformancee? perf = widget.categoryPerformance.firstWhere(
        (performance) => performance.category == category.category,
        orElse: () => CategoryPerformancee(
          cid: -1,
          category: category.category,
          actualProjection: 0.0,
          actualTarget: 0.0,
          actualSales: 0.0,
          salesman: [],
        ),
      );

      double target = perf.actualTarget ?? 0.0;
      double projection = perf.actualProjection ?? 0.0;
      double actual = perf.actualSales ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: target,
            color: const Color(0xff3b6491),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          if(widget.staffProjection=="1")
          BarChartRodData(
            toY: projection,
            color: const Color(0xff15396a),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          BarChartRodData(
            toY: actual,
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
            return FutureBuilder<ResponseModelCp>(
              future: provider.responseModelCp,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showBarchartDialog(context, category, categories ?? []);
                  });
                  return const SizedBox.shrink();
                } else {
                  return const AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('No data available'),
                    ),
                  );
                }
              },
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
        label: widget.allCategory[value.toInt()].category ?? '',
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

    double getRoundedUpperLimit() {
    final maxValue = barGroups
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    return (maxValue / 1000).ceil() * 1000;
  }

  double getDynamicReservedSize() {
    final maxValue = barGroups
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    int digitCount = maxValue.toInt().toString().length;
    return (digitCount * 8);
  }

    Widget getBottomTitlesDummy(double value, TitleMeta meta) {
    Widget text = Transform.rotate(
      angle: -1.34 / 4,
      child: MyRegularText(
        label: widget.allCategory[value.toInt()].category ?? '',
        fontWeight: FontWeight.w500,
        fontSize: 11,
        color: Colors.white,
      ),
    );
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: text,
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
              child: Stack(
                children: [
                  Scrollbar(
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
                                maxY: getRoundedUpperLimit(),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: getLeftTitles,
                                          reservedSize: getDynamicReservedSize(),
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
                                      CategoryPerformancee perf =
                                          widget.categoryPerformance.firstWhere(
                                        (performance) =>
                                            performance.category ==
                                            widget.allCategory[index].category,
                                      );
                                      _showSalesmanPopup(perf.cid ?? 0,
                                          widget.allCategory[index].category ?? '');
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 0, top: 3),
                      color: white,
                      width: getDynamicReservedSize(),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: getRoundedUpperLimit(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getLeftTitles,
                                reservedSize: getDynamicReservedSize(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getBottomTitlesDummy,
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
                              color: Colors.transparent,
                              width: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(color: const Color(0xff3b6491), label: 'Target'),
            if(widget.staffProjection=="1")
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
        CircleAvatar(
          radius: ResponsiveInfo.isMobileDimension(context) ? 5.45 : 6.10,
          backgroundColor: color,
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

class CustomBarChartCustomerDash extends StatefulWidget {
  final List<FullCategory> allCategory;
  final List<CategoryPerformancez> categoryPerformance;
  final String customerId;
  final dynamic year;
  const CustomBarChartCustomerDash({
    Key? key,
    required this.allCategory,
    required this.categoryPerformance,
    required this.customerId,
    required this.year,
  }) : super(key: key);

  @override
  _CustomBarChartCustomerDashState createState() =>
      _CustomBarChartCustomerDashState();
}

class _CustomBarChartCustomerDashState
    extends State<CustomBarChartCustomerDash> {
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    _createBarGroups();
  }

  void _showSalesmanPopup(dynamic cid, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<CustomersProvider>(
          builder: (context, provider, child) {
            provider.fetchChartCategoryPerformance(
                widget.customerId, cid, widget.year);

            return FutureBuilder<ProductResponse>(
              future: provider
                  .productResponse, // Ensure this is updated in provider
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitFadingCube(
                      color: primaryColor,
                      size: 20.0,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;

                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.zero,
                    titlePadding: EdgeInsets.zero,
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 45,
                            padding: const EdgeInsets.all(10),
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
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: SizedBox(
                                    width: 25.8,
                                    height: 25.8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.red,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.5),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: DataTable(
                              dataRowHeight: 35,
                              headingRowHeight: 40,
                              columnSpacing: 30,
                              columns: const [
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Product',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Invoice',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Quantity',
                                    fontSize: 13,
                                  ),
                                ),
                                DataColumn(
                                  label: DialogTableHeaderText(
                                    text: 'Price',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              rows: categories.map((s) {
                                return DataRow(
                                  cells: [
                                    DataCell(Center(
                                      child: Text(
                                        s.variationName,
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )),
                                    DataCell(Center(
                                      child: Text(
                                        '${s.orderId}',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )),
                                    DataCell(Center(
                                      child: Text(
                                        '${s.quantity}',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )),
                                    DataCell(Center(
                                      child: Text(
                                        formatAmount(s.price),
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return NodataWidget();
                }
              },
            );
          },
        );
      },
    );
  }

  void _createBarGroups() {
    barGroups = widget.allCategory.asMap().entries.map((entry) {
      int index = entry.key;
      FullCategory category = entry.value;
      CategoryPerformancez? perf = widget.categoryPerformance.firstWhere(
        (performance) => performance.category == category.categoryName,
        orElse: () => CategoryPerformancez(
          cid: -1,
          category: category.categoryName,
          totalPrice: '0',
        ),
      );
      double target = 0.0;
      try {
        target = double.tryParse(perf.totalPrice) ?? 0.0;
      } catch (e) {
        target = 0.0;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: target,
            color: const Color(0xff7a8f3d),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
        ],
      );
    }).toList();
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    Widget text = Transform.rotate(
        angle: -1.34 / 4,
        child: Text(widget.allCategory[value.toInt()].categoryName,
            // fontWeight: FontWeight.w600,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            )));
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: text,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 11 // Customize your font size here
        );
    return

        // Text(value.toInt().toString(),style: style);
        Text(value.toInt().toString(),
            // fontWeight: FontWeight.w600,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: provider.scrollController,
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
                                getTitlesWidget: getLeftTitles,
                                reservedSize: 40),
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

                              CategoryPerformancez perf = widget
                                  .categoryPerformance
                                  .firstWhere((performance) =>
                                      performance.category ==
                                      widget.allCategory[index].categoryName);

                              _showSalesmanPopup(perf.cid,
                                  widget.allCategory[index].categoryName ?? '');
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.transparent,
                            tooltipPadding: EdgeInsets.zero,
                            tooltipMargin: 8,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) {
                              return BarTooltipItem(
                                rod.toY.toString(),
                                const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
