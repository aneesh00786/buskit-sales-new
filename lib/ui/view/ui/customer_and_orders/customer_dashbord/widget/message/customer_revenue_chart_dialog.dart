import 'package:busskit_salesexecutive/ui/components/bar_and_chart/default_donet_customer_dash.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showCustomerRevenueChartDialog(
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
                        child: Consumer<CustomersProvider>(
                          builder: (context, provider, child) {
                            return FutureBuilder<CustomerRevenueResponse>(
                              future: provider.customerRevenueResponseFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  final categoryPerformance = snapshot.data!;
                        
                                  final paymentCompleted = categoryPerformance
                                              .data
                                              .revenue
                                              .bookingRevenueData
                                              ?.isNotEmpty ==
                                          true
                                      ? categoryPerformance
                                          .data
                                          .revenue
                                          .bookingRevenueData!
                                          .last
                                          .totalBookingRevenue
                                      : 0;
                                  final remaCompleted = categoryPerformance
                                              .data
                                              .revenue
                                              .orderRevenueData
                                              ?.isNotEmpty ==
                                          true
                                      ? categoryPerformance
                                          .data
                                          .revenue
                                          .orderRevenueData!
                                          .last
                                          .totalOrderRevenue
                                      : 0;
                        
                                  return Center(
                                    child: DoughnutDefaultCustomerDash(
                                      isBig: true,
                                      customerData: categoryPerformance,
                                      booking: "Booking : 3",
                                      order: "Order : 3",
                                      aColor: Colors.blue.shade900,
                                      bColor: Colors.blue,
                                      legend1: const SizedBox.shrink(),
                                      legend2: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showValueDialogCusDash(
                                                  context,
                                                  categoryPerformance.data.revenue
                                                          .bookingRevenueData
                                                      as List<dynamic>,
                                                  'Booking');
                                            },
                                            child: _buildLegendItem(
                                              Colors.blue.shade900,
                                              'Bookings : ${formatAmount(paymentCompleted)}',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              showValueDialogCusDash(
                                                  context,
                                                  categoryPerformance.data.revenue
                                                          .orderRevenueData
                                                      as List<dynamic>,
                                                  'Order');
                                            },
                                            child: _buildLegendItem(
                                              Colors.blue,
                                              'Orders : ${formatAmount(remaCompleted)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                      child: Text('No data available'));
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
