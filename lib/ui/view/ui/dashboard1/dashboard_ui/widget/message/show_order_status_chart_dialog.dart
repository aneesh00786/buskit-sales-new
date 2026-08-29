import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/doughnut_default_delivery.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/show_ordersstatus_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showOrderStatusChartDialog(
  BuildContext context,
  String title,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = isPhonePortrait(context)
                ? fullScreenWidth(context)
                : fullScreenWidth(context) * 0.8;
            double maxDialogHeight = constraints.maxHeight * 0.7;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: maxDialogHeight,
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
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.donut_large_rounded, color: Colors.white, size: 17),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
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
                                              } else {
                                                showCustomToastDisplay(
                                                    context,
                                                    "No Record Found".tr,
                                                    red,
                                                    Icons.close);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              Colors.blue.shade300,
                                              'Processing'.tr + '  : ${formatAmount(categoryPerformance.order!.totalOrders!.last.orderProcessing)}',
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
                                                    "Packed & Ready for Delivery".tr,
                                                    1);
                                              } else {
                                                showCustomToastDisplay(
                                                    context,
                                                    "No Record Found".tr,
                                                    red,
                                                    Icons.close);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xffc38a42),
                                              'Packed & Ready for Delivery'.tr + '  : ${formatAmount(categoryPerformance.order!.totalOrders!.last.outForDelivery)}',
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
                                                    "Delivered Orders".tr,
                                                    2);
                                              } else {
                                                showCustomToastDisplay(
                                                    context,
                                                    "No Record Found".tr,
                                                    red,
                                                    Icons.close);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xff33b4a8),
                                              'Delivered'.tr + '  : ${formatAmount(categoryPerformance.order!.totalOrders!.last.deliverd)}',
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
        color: const Color(0xFF0F172A),
      ),
    ],
  );
}
