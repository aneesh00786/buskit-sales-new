// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// ignore: library_prefixes

Widget middleTopLeftComponet({
  required String staffProjection,
  required String targetType,
  required BuildContext context,
  double? cardHeight,
}) {
  String displayText = '';
  if (staffProjection == "1" && targetType == "1") {
    displayText = "Category Target / Projection / Actuals".tr;
  } else if (staffProjection == "1" && targetType == "0") {
    displayText = "Category Target / Projection / Actuals".tr;
  } else if (staffProjection == "0" && targetType == "1") {
    displayText = "Category Target / Actuals".tr;
  } else {
    displayText = "Category Actuals";
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
    child: Container(
      height: cardHeight ?? double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: dashboardContainerHeader(displayText, icon: Icons.bar_chart_rounded),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showCategoryChartDialog(
                    context,
                    displayText,
                    staffProjection,
                    targetType,
                  );
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFEEF2FF),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.open_in_new,
                      size: 15,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: nkRegularPadding(),
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<model1.ResponseModell>(
                    future: provider.futureResponseModel,
                    builder: (context, snapshot) {
                      final categories = snapshot.data?.allCategory;
                      final categoryPerformance =
                          snapshot.data?.categoryPerformance;
                      final monthlyPerformance =
                          snapshot.data?.monthlyPerformance;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SpinKitFadingCube(
                            color: primaryColor,
                            size: 20.0,
                          ),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
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
                      } else if (snapshot.hasData) {
                        return Center(
                          child: CustomBarChart(
                            categoryPerformance: categoryPerformance ?? [],
                            monthlyPerformance: monthlyPerformance ?? [],
                            allCategory: categories ?? [],
                            staffProjection: staffProjection,
                            categoryTarget: targetType,
                            isMonthly: false,
                            isDayOrRange: provider.selectedFilter ==
                                    FilterDateEnum.range ||
                                provider.selectedFilter == FilterDateEnum.today,
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
}
