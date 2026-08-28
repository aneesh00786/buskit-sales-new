import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget _buildStatusBadge(int? orderStatus, String text) {
  Color bg = const Color(0xFFF1F5F9);
  Color textColor = const Color(0xFF0F172A);
  Color dotColor = const Color(0xFF0F172A);

  if (orderStatus == 2 || text.toLowerCase().contains('deliver')) {
    bg = const Color(0xFFDCFCE7);
    textColor = const Color(0xFF064E3B);
    dotColor = const Color(0xFF059669);
  } else if (orderStatus == 7 || text.toLowerCase().contains('estimate')) {
    bg = const Color(0xFFFEF3C7);
    textColor = const Color(0xFF78350F);
    dotColor = const Color(0xFFD97706);
  } else if (orderStatus == 0 || text.toLowerCase().contains('booking') || text.toLowerCase().contains('pre') || text.toLowerCase().contains('process')) {
    bg = const Color(0xFFDBEAFE);
    textColor = const Color(0xFF1E3A8A);
    dotColor = const Color(0xFF2563EB);
  } else if (orderStatus == 4 || text.toLowerCase().contains('draft')) {
    bg = const Color(0xFFF1F5F9);
    textColor = const Color(0xFF0F172A);
    dotColor = const Color(0xFF475569);
  } else if (orderStatus == 3 || text.toLowerCase().contains('cancel')) {
    bg = const Color(0xFFFEE2E2);
    textColor = const Color(0xFF7F1D1D);
    dotColor = const Color(0xFFDC2626);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: dotColor.withOpacity(0.35), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text.tr,
          style: TextStyle(
            fontFamily: 'Poppins_Regular',
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

void showValueDialog(
    BuildContext context, Revenuee categoryData, String title) {
  var displayData = title == "Order"
      ? categoryData.orderRevenueData
      : categoryData.bookingRevenueData;
  showValueDialogCusDash(context, displayData as List<dynamic>? ?? [], title);
}

void showValueDialogCusDash(
    BuildContext context, List<dynamic> orderDetails, String title) {
  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();

  final double totalSum = orderDetails.isNotEmpty
      ? orderDetails.map((e) => (e.orderTotal ?? 0.0) as num).fold<double>(0.0, (a, b) => a + b.toDouble())
      : 0.0;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: screenHeight * 0.88,
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
                      Row(
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
                          Text(
                            title.tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35)),
                            ),
                            child: Text(
                              '${orderDetails.length} ${'Records'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 17),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 Data Body
                if (orderDetails.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Center(child: NodataWidget()),
                  )
                else
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          controller: verticalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                          child: Scrollbar(
                            controller: horizontalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            radius: const Radius.circular(8),
                            thickness: 6,
                            notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                            child: SingleChildScrollView(
                              controller: verticalController,
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                controller: horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                    headingTextStyle: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.3,
                                    ),
                                    dataRowMinHeight: 46,
                                    dataRowMaxHeight: 56,
                                    columnSpacing: 20,
                                    horizontalMargin: 16,
                                    columns: [
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Date'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Invoice'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Status'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    ],
                                    rows: orderDetails.map((item) {
                                      String formattedDate = 'N/A';
                                      if (item.orderGeneratedDate != null && item.orderGeneratedDate.toString().isNotEmpty) {
                                        formattedDate = TimeUtils.formatTimeInZone(
                                          DateTime.tryParse(item.orderGeneratedDate.toString()) ?? DateTime.now(),
                                          format: 'dd-MM-yyyy',
                                        );
                                      } else if (item.orderCreatAt != null) {
                                        formattedDate = getFormattedOrderCreatAt(item.orderCreatAt);
                                      }

                                      String orderId = item.orderId ?? 'N/A';
                                      int orderStatus = item.orderStatus ?? 0;
                                      String statusText = getStatusName(orderStatus);

                                      return DataRow(
                                        cells: [
                                          // Date
                                          DataCell(Center(child: Text(formattedDate, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)))),
                                          // Invoice / Order ID
                                          DataCell(
                                            Center(
                                              child: InkWell(
                                                onTap: () async {
                                                  bool isOnline = await ConnectivityService().isOnline();
                                                  if (isOnline) {
                                                    showDetailedOrderInvoiceDialog(context, orderId, false);
                                                  } else {
                                                    showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                  ),
                                                  child: Text(
                                                    orderId,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins_Regular',
                                                      color: primaryColor,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Status
                                          DataCell(Center(child: _buildStatusBadge(orderStatus, statusText))),
                                          // Amount
                                          DataCell(Center(child: Text(formatAmount(item.orderTotal), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)))),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // 🔹 Summary Footer
                if (orderDetails.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'Showing'.tr} ${orderDetails.length} ${'Records'.tr}',
                          style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${'Total'.tr}: ',
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Text(
                                formatAmount(totalSum),
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
