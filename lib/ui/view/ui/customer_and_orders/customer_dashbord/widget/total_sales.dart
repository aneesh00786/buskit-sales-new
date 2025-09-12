// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/default_donet_customer_dash.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget totalSalse(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<CustomerRevenueResponse>(
          future: provider.customerRevenueResponseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final categoryPerformance = snapshot.data!;

              final paymentCompleted = categoryPerformance
                          .data.revenue.bookingRevenueData?.isNotEmpty ==
                      true
                  ? categoryPerformance
                      .data.revenue.bookingRevenueData!.last.totalBookingRevenue
                  : 0;

              final remaCompleted = categoryPerformance
                          .data.revenue.orderRevenueData?.isNotEmpty ==
                      true
                  ? categoryPerformance
                      .data.revenue.orderRevenueData!.last.totalOrderRevenue
                  : 0;

              return MyCommnonContainer(
                height: double.infinity,
                width: double.infinity,
                isCommonBorder: false,
                padding: nkRegularPadding(),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Expanded(
                          child: Center(
                            child: DoughnutDefaultCustomerDash(
                              customerData: categoryPerformance,
                              booking: "Booking : 3",
                              order: "Order : 3",
                              aColor: Colors.blue.shade900,
                              bColor: Colors.blue,
                              legend1: const SizedBox.shrink(),
                              legend2: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (paymentCompleted == 0) {
                                        showCustomToastDisplay(
                                            context,
                                            "No Record Found",
                                            red,
                                            Icons.close);
                                      } else {
                                        if (categoryPerformance.data.revenue
                                            .bookingRevenueData!.isNotEmpty) {
                                          showValueDialogCusDash(
                                              context,
                                              categoryPerformance.data.revenue
                                                      .bookingRevenueData
                                                  as List<dynamic>,
                                              'Booking');
                                        }
                                      }
                                    },
                                    child: _buildLegendItem(
                                      Colors.blue.shade900,
                                      'Bookings : ${formatAmount(paymentCompleted)}',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      if (remaCompleted == 0) {
                                        showCustomToastDisplay(
                                            context,
                                            "No Record Found",
                                            red,
                                            Icons.close);
                                      } else {
                                        if (categoryPerformance.data.revenue
                                            .orderRevenueData!.isNotEmpty) {
                                          showValueDialogCusDash(
                                              context,
                                              categoryPerformance.data.revenue
                                                      .orderRevenueData
                                                  as List<dynamic>,
                                              'Order');
                                        }
                                      }
                                    },
                                    child: _buildLegendItem(
                                      Colors.blue,
                                      'Orders : ${formatAmount(remaCompleted)}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: -10,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: fullScreenWidth(context) > 630 ? 20 : 2,
                            top: 2),
                        child: InkWell(
                          onTap: () {
                            showCustomerRevenueChartDialog(
                              context,
                              "Revenue",
                            );
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
                    )
                  ],
                ),
              );
            } else {
              return const Center(child: NodataWidget());
            }
          },
        );
      },
    ),
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
