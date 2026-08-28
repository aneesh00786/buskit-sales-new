import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/default_donet_customer_dash.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showCustomerRevenueChartDialog(
  BuildContext context,
  String title,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 620,
            maxHeight: screenHeight * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Color(0xFF2D3748)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.pie_chart_outline_rounded, color: Colors.white, size: 17),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            title.tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<CustomersProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<CustomerRevenueResponse>(
                          future: provider.customerRevenueResponseFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}', style: const TextStyle(fontFamily: 'Poppins_Regular', color: Colors.red)),
                              );
                            } else if (snapshot.hasData) {
                              final categoryPerformance = snapshot.data!;
                              final paymentCompleted = categoryPerformance.data.revenue.bookingRevenueData?.isNotEmpty == true
                                  ? categoryPerformance.data.revenue.bookingRevenueData!.last.totalBookingRevenue
                                  : 0;
                              final remaCompleted = categoryPerformance.data.revenue.orderRevenueData?.isNotEmpty == true
                                  ? categoryPerformance.data.revenue.orderRevenueData!.last.totalOrderRevenue
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (paymentCompleted == 0) {
                                            showCustomToastDisplay(context, "No Record Found".tr, red, Icons.close);
                                          } else {
                                            if (categoryPerformance.data.revenue.bookingRevenueData!.isNotEmpty) {
                                              showValueDialogCusDash(
                                                context,
                                                categoryPerformance.data.revenue.bookingRevenueData as List<dynamic>,
                                                'Booking',
                                              );
                                            }
                                          }
                                        },
                                        child: _buildLegendItem(
                                          Colors.blue.shade900,
                                          'Bookings : ${formatAmount(paymentCompleted)}',
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      InkWell(
                                        onTap: () {
                                          if (remaCompleted == 0) {
                                            showCustomToastDisplay(context, "No Record Found".tr, red, Icons.close);
                                          } else {
                                            if (categoryPerformance.data.revenue.orderRevenueData!.isNotEmpty) {
                                              showValueDialogCusDash(
                                                context,
                                                categoryPerformance.data.revenue.orderRevenueData as List<dynamic>,
                                                'Order',
                                              );
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
                              );
                            } else {
                              return const Center(child: NodataWidget());
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
        ),
      );
    },
  );
}

Widget _buildLegendItem(Color color, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}
