import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showValueCollectionDialog(
    BuildContext context, Collection collection, String title) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = isPhonePortrait(context)
                ? fullScreenWidth(context)
                : fullScreenWidth(context) * 0.7;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 40.0;
            final completedOrders = collection.payment?.completedOrders ?? [];
            double listHeight = completedOrders.length * rowHeight;
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
                                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 17),
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
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child:  Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              'Sl.No.'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Poppins_Regular',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Business Name'.tr,
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Order Date'.tr,
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice ID'.tr,
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status'.tr,
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Total Amount'.tr,
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ScrollbarTheme(
                          data: const ScrollbarThemeData(
                            minThumbLength: 150,
                            thickness: WidgetStatePropertyAll(5),
                            thumbColor: WidgetStatePropertyAll(Colors.blue),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              itemCount: completedOrders.isEmpty
                                  ? 1
                                  : completedOrders.length,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (completedOrders.isEmpty) {
                                  return Container(
                                      height: rowHeight,
                                      alignment: Alignment.center,
                                      child: const NodataWidget());
                                }
                                final order = completedOrders[index];
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
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          '   ${index + 1}.',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            order.businessName ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
  child: Center(
    child: Text(
      // Safely ensure the DateTime is not null before formatting
      order.orderCreatAt != null
          ? TimeUtils.formatTimeInZone(
              order.orderCreatAt!,
              // Optional: If this specific screen needs a certain format, add it here!
              format: 'dd/MM/yyyy',
            )
          : 'N/A',
      style: const TextStyle(
        fontSize: 13,
        color: secondaryTextColor,
      ),
    ),
  ),
),
                                      // Expanded(
                                      //   child: Center(
                                      //     child: Text(
                                      //       getFormattedOrderCreatAt(
                                      //           order.orderCreatAt ?? ''),
                                      //       style: const TextStyle(
                                      //         fontSize: 13,
                                      //         color: secondaryTextColor,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              showInvoicePreviewOnline(
                                                context,
                                                order.orderId ?? '',
                                              );
                                            },
                                            child: Text(
                                              order.invoiceId ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            getStatusName(
                                                order.orderStatus ?? 0).tr,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            formatAmount(
                                                order.receivedAmount ?? 0.0),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: secondaryTextColor,
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
                    ),
                    // Static Total Row
                    Container(
                      padding: EdgeInsets.all(10),
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
                           DialogTableHeaderText(
                            text: 'Total'.tr,
                            fontSize: 11,
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          DialogTableHeaderText(
                            text: formatAmount(completedOrders
                                .map((e) => e.receivedAmount ?? 0.0)
                                .reduce((a, b) => a + b)),
                            fontSize: 11,
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
