import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
    String targertType,
    String staffProjection,
    DashboardProvider dashboardProvider,
    int catId,
    {bool isDayOrRange = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double dialogWidth = MediaQuery.of(context).size.width * 0.7;
              double maxDialogHeight = constraints.maxHeight * 0.7;
              double rowHeight = 40.0;
              double headerHeight = 40.0;
              double listHeight = categories.length * rowHeight;
              double contentHeight =
                  listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

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
                      // Table Header
                      Container(
                        color: const Color.fromARGB(255, 247, 247, 247),
                        height: headerHeight,
                        child:  Row(
                          children: [
                            const Expanded(
                              child: DialogTableHeaderText(
                                text: 'Name',
                                fontSize: 13,
                              ),
                            ),
                           if (!isDayOrRange) ...[
                              if (targertType == '1') ...[
                                const DialogTableHeaderText(
                                  text: 'Target',
                                  fontSize: 13,
                                ),
                              ],
                              if (staffProjection == '1') ...[
                                const DialogTableHeaderText(
                                  text: 'Projection',
                                  fontSize: 13,
                                ),
                              ]
                            ],
                            const Expanded(
                              child: DialogTableHeaderText(
                                text: 'Actual',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scrollable Content
                      Flexible(
                        child: SizedBox(
                          height: contentHeight,
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
                                    if (targertType == '1') ...[
                                      Expanded(
                                        child: Center(
                                          child: InkWell(
                                            onTap: () async {
                                              await dashboardProvider
                                                  .loadSalesmanTargetByCategory(
                                                      category.salesmanId,
                                                      catId);
                                              Get.dialog(
                                                  SalesmanTargetByCategoryDialog(
                                                title: 'Target',
                                                provider: dashboardProvider,
                                              ));
                                            },
                                            child: Text(
                                              formatAmount(
                                                  category.targetTotal),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: category.targetTotal
                                                            .toString() ==
                                                        '0'
                                                    ? secondaryTextColor
                                                    : primaryButtonColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (staffProjection == '1') ...[
                                      Expanded(
                                        child: Center(
                                          child: InkWell(
                                            onTap: () async {
                                              await dashboardProvider
                                                  .loadSalesmanTargetByCategory(
                                                      category.salesmanId,
                                                      catId);
                                              Get.dialog(
                                                  SalesmanTargetByCategoryDialog(
                                                title: 'Projection',
                                                provider: dashboardProvider,
                                              ));
                                            },
                                            child: Text(
                                              formatAmount(
                                                  category.projectionTotal),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: category.projectionTotal
                                                            .toString() ==
                                                        '0'
                                                    ? secondaryTextColor
                                                    : primaryButtonColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                    Expanded(
                                    child: Center(
                                      child: InkWell(
                                        onTap: () async {
                                          await dashboardProvider
                                              .fetchChartOrderData(
                                                  category.salesmanId, catId);
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
                                            color: formatAmount(
                                                        category.orderTotal) ==
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
