import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/doughnut_default_delivery.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/show_ordersstatus_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

void showOrderStatusChartDialog(
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
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            size: 50, color: Colors.red),
                                        SizedBox(height: 10),
                                        Text(
                                            "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding.",
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final categoryPerformance =
                                      snapshot.data!.delivery;

                                  if (categoryPerformance == null ||
                                      categoryPerformance
                                          .order!.totalOrders!.isEmpty) {
                                    return const NodataWidget();
                                  }

                                  return Center(
                                    child: DoughnutDefaultDelivery(
                                      isBig: true,
                                      deliveryData: categoryPerformance,
                                      aColor: Colors.blue.shade300,
                                      bColor: const Color(0xffc38a42),
                                      cColor: const Color(0xff33b4a8),
                                      legend2: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 18,
                                        runSpacing: 4,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (categoryPerformance
                                                      .order!
                                                      .totalOrders!
                                                      .last
                                                      .orderProcessing !=
                                                  0) {
                                                showValueOrderDialog(
                                                    context,
                                                    categoryPerformance,
                                                    "Processing Orders",
                                                    5);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              Colors.blue.shade300,
                                              "Processing : ${formatAmount(categoryPerformance.order!.totalOrders!.last.orderProcessing)}",
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (categoryPerformance
                                                      .order!
                                                      .totalOrders!
                                                      .last
                                                      .outForDelivery !=
                                                  0) {
                                                showValueOrderDialog(
                                                    context,
                                                    categoryPerformance,
                                                    "Packed & Ready for Delivery",
                                                    1);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xffc38a42),
                                              "Packed & Ready for Delivery : ${formatAmount(categoryPerformance.order!.totalOrders!.last.outForDelivery)}",
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (categoryPerformance
                                                      .order!
                                                      .totalOrders!
                                                      .last
                                                      .deliverd !=
                                                  0) {
                                                showValueOrderDialog(
                                                    context,
                                                    categoryPerformance,
                                                    "Delivered Orders",
                                                    2);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xff33b4a8),
                                              "Delivered : ${formatAmount(categoryPerformance.order!.totalOrders!.last.deliverd)}",
                                            ),
                                          ),
                                        ],
                                      ),
                                      legend1: const SizedBox.shrink(),
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
                    )
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
