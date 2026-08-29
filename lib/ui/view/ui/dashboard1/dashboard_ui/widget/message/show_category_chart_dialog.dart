import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/build_row_content_data.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showCategoryChartDialog(
    BuildContext context,
// Revenuee categoryData,
    String title,
    String staffProjection,
    String categoryTarget) {
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
                                  child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 17),
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
                        padding: const EdgeInsets.all(12.0),
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
                                  snapshot.error.toString();
                                  return const NodataWidget();
                                } else if (snapshot.hasData) {
                                  final categories = snapshot.data!.allCategory;
                                  final categoryPerformance =
                                      snapshot.data!.categoryPerformance;
                                  final monthlyPerformance =
                                      snapshot.data!.monthlyPerformance;

                                  return Center(
                                      child: CustomBarChart(
                                    categoryPerformance: categoryPerformance??[],
                                    monthlyPerformance: monthlyPerformance??[],
                                    allCategory: categories!,
                                    staffProjection: staffProjection,
                                    categoryTarget: categoryTarget,
                                    isMonthly: false,
                                    isDayOrRange: provider.selectedFilter ==
                                            FilterDateEnum.range ||
                                        provider.selectedFilter ==
                                            FilterDateEnum.today,
                                    // isScroll: false,
                                  ));
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

void showValueDialogCusDash(
    BuildContext context, List<dynamic> orderDetails, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.7;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 30.0;
            double listHeight = orderDetails.length * rowHeight;
            double contentHeight =
                listHeight > maxDialogHeight ? maxDialogHeight : listHeight;
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
                    // Header Section
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: const Row(
                        children: [
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    // Data List Section
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount:
                              orderDetails.isEmpty ? 1 : orderDetails.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (orderDetails.isEmpty) {
                              return buildEmptyRow();
                            } else {
                              var item = orderDetails[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                height: rowHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: buildRowData(
                                            getFormattedOrderCreatAt(
                                                item.orderCreatAt))),
                                    Expanded(
                                        child: buildRowData(
                                            item.orderId ?? 'N/A')),
                                    Expanded(
                                        child: buildRowData(getStatusName(
                                            item.orderStatus ?? 0).tr)),
                                    Expanded(
                                        child: buildRowData(
                                            formatAmount(item.orderTotal))),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Footer Section
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      height: rowHeight,
                      child: Row(
                        children: [
                          const DialogTableHeaderText(
                            text: 'Total',
                            fontSize: 13,
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          DialogTableHeaderText(
                            text: formatAmount(orderDetails
                                .map((e) => e.orderTotal ?? 0.0)
                                .reduce((a, b) => a + b)),
                            fontSize: 13,
                          ),
                        ],
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
