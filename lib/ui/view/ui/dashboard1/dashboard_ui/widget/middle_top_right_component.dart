// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

Widget middleTopRightComponet({
  required BuildContext context,
}) {
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
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardContainerHeader('Revenue'),
                Padding(
                  padding: EdgeInsets.only(
                    right: fullScreenWidth(context) > 630 ? 20 : 2,
                    top: 2,
                  ),
                  child: InkWell(
                    onTap: () {
                      showRevenueChartDialog(context, 'Revenue');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor.withOpacity(0.3),
                      ),
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

            // 2. Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<ResponseModell>(
                      future: provider.futureResponseModel,
                      builder: (context, snapshot) {
                        // Handle Loading
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        }

                        // Prepare Data (Default to 0.0)
                        num bookingRevenue = 0.0;
                        num orderRevenue = 0.0;
                        var categoryPerformance = snapshot.data?.revenue;

                        if (snapshot.hasData && categoryPerformance != null) {
                          if (categoryPerformance.bookingRevenueData?.isNotEmpty == true) {
                            bookingRevenue = categoryPerformance.bookingRevenueData!.last.totalBookingRevenue ?? 0.0;
                          }
                          if (categoryPerformance.orderRevenueData?.isNotEmpty == true) {
                            orderRevenue = categoryPerformance.orderRevenueData!.last.totalOrderRevenue ?? 0.0;
                          }
                        }

                        // Render Layout
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            
                            // This Spacer pushes everything following it to the bottom
                            const Spacer(),
                            
                            // The Data Items
                            Container(
                              width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  // Booking Item
                                  InkWell(
                                    onTap: () {
                                      if (bookingRevenue == 0) {
                                        showCustomToastDisplay(
                                          context,
                                          "No Record Found",
                                          red,
                                          Icons.close,
                                        );
                                      } else {
                                        if (categoryPerformance != null) {
                                          showValueDialog(
                                            context,
                                            categoryPerformance,
                                            'Booking',
                                          );
                                        }
                                      }
                                    },
                                    child: buildLegendItem(
                                      const Color(0xff1d3d63),
                                      'Bookings : ${formatAmount(bookingRevenue)}',
                                    ),
                                  ),
                              
                                  // Order Item
                                  InkWell(
                                    onTap: () {
                                      if (orderRevenue == 0) {
                                        showCustomToastDisplay(
                                          context,
                                          "No Record Found",
                                          red,
                                          Icons.close,
                                        );
                                      } else {
                                        if (categoryPerformance != null) {
                                          showValueDialog(
                                            context,
                                            categoryPerformance,
                                            'Order',
                                          );
                                        }
                                      }
                                    },
                                    child: buildLegendItem(
                                      Colors.blue,
                                      'Orders : ${formatAmount(orderRevenue)}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Add a little bottom padding so it's not glued to the container edge
                            const SizedBox(height: 20), 
                          ],
                        );
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
          fontSize: 11.6,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
      ],
    );
  }

// Widget middleTopRightComponet({
//   required BuildContext context,
// }) {
//   return Padding(
//     padding: const EdgeInsets.all(2.0),
//     child: MyCommnonContainer(
//       boxShadow: [
//         BoxShadow(
//           color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
//           blurRadius: 5,
//           offset: const Offset(4, 4),
//         ),
//       ],
//       borderRadius: 25,
//       height: 300,
//       width: double.infinity,
//       isCommonBorder: true,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               dashboardContainerHeader('Revenue'),
//               Padding(
//                 padding: EdgeInsets.only(
//                     right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
//                 child: InkWell(
//                   onTap: () {
//                     showRevenueChartDialog(context, 'Revenue');
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: primaryColor.withOpacity(0.3)),
//                     child: const Padding(
//                       padding: EdgeInsets.all(5.0),
//                       child: Icon(
//                         Icons.open_in_new,
//                         size: 17,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Consumer<DashboardProvider>(
//                 builder: (context, provider, child) {
//                   return FutureBuilder<ResponseModell>(
//                     future: provider.futureResponseModel,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: SpinKitFadingCube(
//                             color: primaryColor,
//                             size: 20.0,
//                           ),
//                         );
//                       } else if (snapshot.hasData) {
//                         final categoryPerformance = snapshot.data!.revenue;
//                         if (categoryPerformance!.orderRevenueData!.isEmpty) {
//                           return FutureBuilder(
//                             future: Future.delayed(const Duration(seconds: 3)),
//                             builder: (context, delaySnapshot) {
//                               if (delaySnapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const SpinKitFadingCube(
//                                   color: primaryColor,
//                                   size: 20.0,
//                                 );
//                               } else {
//                                 return const Center(
//                                   child: NodataWidget(),
//                                 );
//                               }
//                             },
//                           );
//                         }
//                         final bookingRevenueLength =
//                             categoryPerformance.bookingRevenueData!.isNotEmpty
//                                 ? categoryPerformance.bookingRevenueData!
//                                     .map((e) => e.orderTotal ?? 0.0)
//                                     .reduce((a, b) => a + b)
//                                 : 0.0;
//                         final orderRevenueLast =
//                             categoryPerformance.orderRevenueData!.isNotEmpty
//                                 ? categoryPerformance
//                                     .orderRevenueData!.last.totalOrderRevenue
//                                 : 0.0;
//                         return Center(
//                           child: DoughnutDefault(
//                             categoryData: categoryPerformance,
//                             booking: "Booking : 3",
//                             order: "Order : 3",
//                             aColor: Colors.blue,
//                             bColor: const Color(0xff1d3d63),
//                             legend1: const SizedBox.shrink(),
//                             legend2: Wrap(
//                               alignment: WrapAlignment.center,
//                               crossAxisAlignment: WrapCrossAlignment.center,
//                               spacing: 8,
//                               runSpacing: 4,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         if (bookingRevenueLength != 0) {
//                                           showValueDialog(context,
//                                               categoryPerformance, 'Booking');
//                                         } else {
//                                           showCustomToastDisplay(
//                                               context,
//                                               "No Record Found",
//                                               red,
//                                               Icons.close);
//                                         }
//                                       },
//                                       child: buildLegendItem(
//                                         const Color(0xff1d3d63),
//                                         'Bookings : ${formatAmount(bookingRevenueLength)}',
//                                       ),
//                                     ),
//                                     nkSmallSizeBox(),
//                                     InkWell(
//                                       onTap: () {
//                                         if (orderRevenueLast != 0) {
//                                           showValueDialog(context,
//                                               categoryPerformance, 'Order');
//                                         } else {
//                                           showCustomToastDisplay(
//                                               context,
//                                               "No Record Found",
//                                               red,
//                                               Icons.close);
//                                         }
//                                       },
//                                       child: buildLegendItem(
//                                         Colors.blue,
//                                         'Orders : ${formatAmount(orderRevenueLast)}',
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       } else {
//                         return FutureBuilder(
//                           future: Future.delayed(const Duration(seconds: 3)),
//                           builder: (context, delaySnapshot) {
//                             if (delaySnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const SpinKitFadingCube(
//                                 color: primaryColor,
//                                 size: 20.0,
//                               );
//                             } else {
//                               return const Center(
//                                 child: NodataWidget(),
//                               );
//                             }
//                           },
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget buildLegendItem(Color color, String label) {
//   return Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       CircleAvatar(
//         radius: 6,
//         backgroundColor: color,
//       ),
//       const SizedBox(width: 5),
//       MyRegularText(
//         label: label,
//         fontSize: 10.6,
//         fontWeight: FontWeight.w600,
//         color: secondaryTextColor,
//       ),
//     ],
//   );
// }
