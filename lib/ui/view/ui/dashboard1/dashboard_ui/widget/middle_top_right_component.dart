  // ignore_for_file: deprecated_member_use

  import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

Widget middleTopRightComponet(
  {
    required BuildContext context,
  }
) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        width: double.infinity,
        isCommonBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardContainerHeader('Revenue'),
                Padding(
                  padding: EdgeInsets.only(
                      right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
                  child: InkWell(
                    onTap: () {
                      showRevenueChartDialog(context, 'Revenue');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor.withOpacity(0.3)),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.open_in_new,
                          size: 17,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<ResponseModell>(
                      future: provider.futureResponseModel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        } else if (snapshot.hasData) {
                          final categoryPerformance = snapshot.data!.revenue;
                          if (categoryPerformance!.orderRevenueData!.isEmpty) {
                            return FutureBuilder(
                              future:
                                  Future.delayed(const Duration(seconds: 3)),
                              builder: (context, delaySnapshot) {
                                if (delaySnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SpinKitFadingCube(
                                    color: primaryColor,
                                    size: 20.0,
                                  );
                                } else {
                                  return const Center(
                                    child: NodataWidget(),
                                  );
                                }
                              },
                            );
                          }
                          final bookingRevenueLength =
                              categoryPerformance.bookingRevenueData!.isNotEmpty
                                  ? categoryPerformance.bookingRevenueData!
                                      .map((e) => e.orderTotal ?? 0.0)
                                      .reduce((a, b) => a + b)
                                  : 0.0;
                          final orderRevenueLast =
                              categoryPerformance.orderRevenueData!.isNotEmpty
                                  ? categoryPerformance
                                      .orderRevenueData!.last.totalOrderRevenue
                                  : 0.0;
                          return Center(
                            child: DoughnutDefault(
                              categoryData: categoryPerformance,
                              booking: "Booking : 3",
                              order: "Order : 3",
                              aColor: Colors.blue,
                              bColor: const Color(0xff1d3d63),
                              legend1: const SizedBox.shrink(),
                              legend2: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showValueDialog(context,
                                              categoryPerformance, 'Booking');
                                        },
                                        child: buildLegendItem(
                                          const Color(0xff1d3d63),
                                          'Bookings : ${formatAmount(bookingRevenueLength)}',
                                        ),
                                      ),
                                      nkSmallSizeBox(),
                                      InkWell(
                                        onTap: () {
                                          showValueDialog(context,
                                              categoryPerformance, 'Order');
                                        },
                                        child: buildLegendItem(
                                          Colors.blue,
                                          'Orders : ${formatAmount(orderRevenueLast)}',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return FutureBuilder(
                            future: Future.delayed(const Duration(seconds: 3)),
                            builder: (context, delaySnapshot) {
                              if (delaySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SpinKitFadingCube(
                                  color: primaryColor,
                                  size: 20.0,
                                );
                              } else {
                                return const Center(
                                  child: NodataWidget(),
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
        MyRegularText(
          label: label,
          fontSize: 10.6,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
      ],
    );
  }