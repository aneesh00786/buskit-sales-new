import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showRevenueChartDialog(
  BuildContext context,
  String title,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.8;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
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
                                } else if (snapshot.hasError) {
                                  return const NodataWidget();
                                } else if (snapshot.hasData) {
                                  final categoryPerformance =
                                      snapshot.data!.revenue;
                                  if (categoryPerformance!
                                      .orderRevenueData!.isEmpty) {
                                    return const NodataWidget();
                                  }

                                  final bookingRevenueLength =
                                      categoryPerformance
                                              .bookingRevenueData!.isNotEmpty
                                          ? categoryPerformance
                                              .bookingRevenueData!
                                              .last
                                              .totalBookingRevenue
                                          : 0.0;

                                  final orderRevenueLast = categoryPerformance
                                          .orderRevenueData!.isNotEmpty
                                      ? categoryPerformance.orderRevenueData!
                                          .last.totalOrderRevenue
                                      : 0.0;

                                  return Center(
                                    child: DoughnutDefault(
                                      isBig: true,
                                      categoryData: categoryPerformance,
                                      booking: "Booking : 3",
                                      order: "Order : 3",
                                      aColor: Colors.blue,
                                      bColor: const Color(0xff1d3d63),
                                      legend1: const SizedBox.shrink(),
                                      legend2: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 20,
                                        runSpacing: 4,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (bookingRevenueLength != 0) {
                                                showValueDialog(
                                                    context,
                                                    categoryPerformance,
                                                    'Booking');
                                              } else {
                                                showCustomToastDisplay(
                                                    context,
                                                    "No Record Found",
                                                    red,
                                                    Icons.close);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xff1d3d63),
                                              'Bookings'.tr + ' : ${formatAmount(bookingRevenueLength)}',
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              if (orderRevenueLast != 0) {
                                                showValueDialog(
                                                    context,
                                                    categoryPerformance,
                                                    'Order');
                                              } else {
                                                showCustomToastDisplay(
                                                    context,
                                                    "No Record Found".tr,
                                                    red,
                                                    Icons.close);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              Colors.blue,
                                              'Orders'.tr + ' : ${formatAmount(orderRevenueLast)}',
                                            ),
                                          ),
                                        ],
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
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildLegendItem(Color color, String label) {
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
        fontSize: 11.6,
        fontWeight: FontWeight.w600,
        color: secondaryTextColor,
      ),
    ],
  );
}
