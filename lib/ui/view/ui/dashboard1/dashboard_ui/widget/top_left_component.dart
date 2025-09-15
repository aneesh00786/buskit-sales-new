// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
// ignore: library_prefixes

Widget middleTopLeftComponet({
  required String staffProjection,
  required String targetType,
  required BuildContext context,
}) {
  String displayText = '';
  if (staffProjection == "1" && targetType == "1") {
    displayText = "Category Target / Projection / Actuals";
  } else if (staffProjection == "1" && targetType == "0") {
    displayText = "Category Target / Projection / Actuals";
  } else if (staffProjection == "0" && targetType == "1") {
    displayText = "Category Target / Actuals";
  } else {
    displayText = "Category Actuals";
  }

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
              Flexible(
                fit: FlexFit.tight,
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        right: 20, left: 20, top: 5, bottom: 5),
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontFamily: fontFamilyName,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(right: 5, top: 2),
                child: InkWell(
                  onTap: () {
                    showCategoryChartDialog(
                      context,
                      // "Category ${targetType == '1' ? "Target / " : ''}${staffProjection == '1' ? "Projection / " : ''}Actuals",
                      displayText,
                      staffProjection,
                      targetType,
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
            ],
          ),
          nkMediumSizeBox(),
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
                            isMonthly: targetType == '0' ? true : false,
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
