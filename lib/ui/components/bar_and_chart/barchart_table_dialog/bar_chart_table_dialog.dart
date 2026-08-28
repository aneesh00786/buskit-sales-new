import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/orders_dialog/staffs_order_dialog.dart';
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
        final ScrollController verticalController = ScrollController();

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double dialogWidth = isPhonePortrait(context)
                  ? fullScreenWidth(context)
                  : 620;
              double maxDialogHeight = constraints.maxHeight * 0.75;
              double rowHeight = 44.0;
              double headerHeight = 42.0;

              num totalTarget =
                  categories.fold(0, (sum, item) => sum + (item.targetTotal ?? 0));
              num totalProjection = categories.fold(
                  0, (sum, item) => sum + (item.projectionTotal ?? 0));
              num totalActual = categories.fold(
                  0, (sum, item) => sum + (num.tryParse(item.orderTotal.toString()) ?? 0));

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
                      color: Colors.black.withOpacity(0.18),
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
                      // 🔹 Gradient Header
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
                                    child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 17),
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

                      // 🔹 Table Header
                      Container(
                        color: const Color(0xFFF1F5F9),
                        height: headerHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Name'.tr,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  fontFamily: 'Poppins_Regular',
                                ),
                              ),
                            ),
                            if (!isDayOrRange) ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Target'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    fontFamily: 'Poppins_Regular',
                                  ),
                                ),
                              ),
                              if (staffProjection == '1') ...[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Projection'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Poppins_Regular',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Actual'.tr,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  fontFamily: 'Poppins_Regular',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔹 Scrollable Content
                      Flexible(
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(const Color(0xFF94A3B8)),
                            trackColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                            thickness: WidgetStateProperty.all(5),
                            radius: const Radius.circular(8),
                          ),
                          child: Scrollbar(
                            controller: verticalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              controller: verticalController,
                              itemCount: categories.length,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final displayName = '${category.fullname} ${category.lastname}'.trim();
                                final hasTarget = (category.targetTotal ?? 0) > 0;
                                final hasProjection = (category.projectionTotal ?? 0) > 0;
                                final actualNum = num.tryParse(category.orderTotal.toString()) ?? 0;
                                final hasActual = actualNum > 0;

                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFF1F5F9),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  height: rowHeight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          displayName.isNotEmpty ? displayName : category.fullname,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins_Regular',
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      if (!isDayOrRange) ...[
                                        Expanded(
                                          flex: 2,
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
                                                formatAmount(category.targetTotal),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Poppins_Regular',
                                                  fontWeight: hasTarget ? FontWeight.w600 : FontWeight.w500,
                                                  color: targetType == '1' && hasTarget
                                                      ? const Color(0xFF2563EB)
                                                      : const Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (staffProjection == '1') ...[
                                          Expanded(
                                            flex: 2,
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
                                                      provider: dashboardProvider,
                                                    ));
                                                  }
                                                },
                                                child: Text(
                                                  formatAmount(category.projectionTotal),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Poppins_Regular',
                                                    fontWeight: hasProjection ? FontWeight.w600 : FontWeight.w500,
                                                    color: targetType == '1' && hasProjection
                                                        ? const Color(0xFF2563EB)
                                                        : const Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () async {
                                              await dashboardProvider
                                                  .fetchChartOrderData(
                                                      category.salesmanId,
                                                      targetType == '0'
                                                          ? ''
                                                          : catId);
                                              Get.dialog(StaffOrdersDialog(
                                                heading: 'ORDER',
                                                orderData: dashboardProvider
                                                    .chartOrderData,
                                              ));
                                            },
                                            child: Text(
                                              formatAmount(category.orderTotal),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Poppins_Regular',
                                                fontWeight: hasActual ? FontWeight.w700 : FontWeight.w500,
                                                color: hasActual
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFF334155),
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

                      // 🔹 Total Footer Row
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: headerHeight,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Total'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  fontFamily: 'Poppins_Regular',
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (!isDayOrRange) ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formatAmount(totalTarget),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    fontFamily: 'Poppins_Regular',
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (staffProjection == '1')
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatAmount(totalProjection),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Poppins_Regular',
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                            ],
                            Expanded(
                              flex: 2,
                              child: Text(
                                formatAmount(totalActual),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  fontFamily: 'Poppins_Regular',
                                  color: Color(0xFF0F172A),
                                ),
                              ),
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
  });
}
