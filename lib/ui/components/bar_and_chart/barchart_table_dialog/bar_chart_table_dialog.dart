import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/orders_dialog/staffs_order_dialog.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/salesman_target_by_caregory_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showBarchartDialog(
    BuildContext context,
    String title,
    List<Salesmanvn> categories,
    String targetType,
    String staffProjection,
    DashboardProvider dashboardProvider,
    dynamic catId,
    {bool isDayOrRange = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: isPhonePortrait(context) || isPhoneLandscape(context)
              ? EdgeInsets.zero
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double dialogWidth = isPhonePortrait(context)
                  ? fullScreenWidth(context)
                  : fullScreenWidth(context) * 0.7;
              double maxDialogHeight = constraints.maxHeight * 0.7;
              double rowHeight = 40.0;
              double headerHeight = 40.0;
              double listHeight = categories.length * rowHeight;
              double contentHeight =
                  listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

              num totalTarget =
                  categories.fold(0, (sum, item) => sum + item.targetTotal!);
              num totalProjection = categories.fold(
                  0, (sum, item) => sum + item.projectionTotal!);
              num totalActual = categories.fold(
                  0, (sum, item) => sum + num.parse(item.orderTotal));

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: contentHeight + (headerHeight * 3.5),
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
                      // Table Header
                      Container(
                        color: const Color.fromARGB(255, 247, 247, 247),
                        height: headerHeight,
                        child: Row(
                          children: [
                             DialogTableHeaderText(
                              text: 'Name'.tr,
                              fontSize: 13,
                            ),
                            if (!isDayOrRange) ...[
                              // if (targetType == '1') ...[
                               DialogTableHeaderText(
                                text: 'Target'.tr,
                                fontSize: 13,
                              ),
                              // ],
                              if (staffProjection == '1') ...[
                                 DialogTableHeaderText(
                                  text: 'Projection'.tr,
                                  fontSize: 13,
                                ),
                              ]
                            ],
                             DialogTableHeaderText(
                              text: 'Actual'.tr,
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                      // Scrollable Content
                      Expanded(
                        // height: contentHeight,
                        child: ScrollbarTheme(
                          data: const ScrollbarThemeData(
                            thickness: WidgetStatePropertyAll(5),
                            thumbColor: WidgetStatePropertyAll(Colors.blue),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              itemCount: categories.length,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final category = categories[index];
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
                                        child: Center(
                                          child: Text(
                                            category.fullname,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isDayOrRange) ...[
                                        // if (targetType == '1') ...[
                                        Expanded(
                                          child: Center(
                                            child: InkWell(
                                              onTap: () async {
                                                if (targetType == '1') {
                                                  await dashboardProvider
                                                      .loadSalesmanTargetByCategory(
                                                          category.salesmanId,
                                                          catId);
                                                  Get.dialog(
                                                      SalesmanTargetByCategoryDialog(
                                                    title: 'Target',
                                                    provider: dashboardProvider,
                                                  ));
                                                }
                                              },
                                              child: Text(
                                                formatAmount(
                                                    category.targetTotal),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: targetType == '1'
                                                      ? category.targetTotal
                                                                  .toString() ==
                                                              '0'
                                                          ? secondaryTextColor
                                                          : primaryButtonColor
                                                      : secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ],
                                        if (staffProjection == '1') ...[
                                          Expanded(
                                            child: Center(
                                              child: InkWell(
                                                onTap: () async {
                                                  if (targetType == '1') {
                                                    await dashboardProvider
                                                        .loadSalesmanTargetByCategory(
                                                            category.salesmanId,
                                                            catId);
                                                    Get.dialog(
                                                        SalesmanTargetByCategoryDialog(
                                                      title: 'Projection',
                                                      provider:
                                                          dashboardProvider,
                                                    ));
                                                  }
                                                },
                                                child: Text(
                                                  formatAmount(
                                                      category.projectionTotal),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: targetType == '1'
                                                        ? category.projectionTotal
                                                                    .toString() ==
                                                                '0'
                                                            ? secondaryTextColor
                                                            : primaryButtonColor
                                                        : secondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
//                                       Expanded(
//   child: Center(
//     // 1. Use a Builder to create a scope for a local variable (notifier)
//     child: Builder(
//       builder: (context) {
//         // 2. Create a notifier to track loading state for THIS specific item
//         final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

//         // 3. Listen to the notifier to rebuild only when loading changes
//         return ValueListenableBuilder<bool>(
//           valueListenable: isLoadingNotifier,
//           builder: (context, isLoading, child) {
//             return InkWell(
//               onTap: () async {
//                 // Start Loading
//                 isLoadingNotifier.value = true;

//                 await dashboardProvider.fetchChartOrderData(
//                   category.salesmanId,
//                   targetType == '0' ? '' : catId,
//                 );

//                 // Stop Loading
//                 isLoadingNotifier.value = false;

//                 Get.dialog(StaffOrdersDialog(
//                   heading: 'orders',
//                   orderData: dashboardProvider.chartOrderData,
//                 ));
//               },
//               // 4. Show Indicator if loading, otherwise show Text
//               child: isLoading
//                   ? const SizedBox(
//                       height: 14,
//                       width: 14,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         // Match the color to your app theme
//                         valueColor: AlwaysStoppedAnimation<Color>(primaryButtonColor),
//                       ),
//                     )
//                   : Text(
//                       formatAmount(category.orderTotal),
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: formatAmount(category.orderTotal) == formatAmount(0)
//                             ? secondaryTextColor
//                             : primaryButtonColor,
//                       ),
//                     ),
//             );
//           },
//         );
//       },
//     ),
//   ),
// ),
                                      Expanded(
                                        child: Center(
                                          child: InkWell(
                                            onTap: () async {
                                              
                                              await dashboardProvider
                                                  .fetchChartOrderData(
                                                      category.salesmanId,
                                                      targetType == '0'
                                                          ? ''
                                                          : catId);
                                              Get.dialog(StaffOrdersDialog(
                                                heading: 'orders',
                                                orderData: dashboardProvider
                                                    .chartOrderData,
                                              ));
                                            },
                                            child: Text(
                                              formatAmount(category.orderTotal),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: formatAmount(category
                                                            .orderTotal) ==
                                                        formatAmount(0)
                                                    ? secondaryTextColor
                                                    : primaryButtonColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                            Expanded(
                                child: CustomText(
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                    content: 'Total'.tr,
                                    fontSize: 11,
                                    maxLine: 1)),
                            if (!isDayOrRange
                                //  && targetType == '1'
                                )
                              Expanded(
                                  child: CustomText(
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.center,
                                      content: formatAmount(totalTarget),
                                      fontSize: 11,
                                      maxLine: 1)),
                            if (!isDayOrRange && staffProjection == '1')
                              Expanded(
                                  child: CustomText(
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.center,
                                      content: formatAmount(totalProjection),
                                      fontSize: 11,
                                      maxLine: 1)),
                            Expanded(
                                child: CustomText(
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                    content: formatAmount(totalActual),
                                    fontSize: 11,
                                    maxLine: 1)),
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
  });
}
