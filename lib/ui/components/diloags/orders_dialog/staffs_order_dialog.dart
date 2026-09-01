// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget _buildStatusBadge(int? orderStatus, String text) {
  final status = OrderHandlingClass.fromType(orderStatus ?? 0);
  final Color bg = status.statusBgColor;
  final Color textColor = status.statusTextColor;
  final Color dotColor = status.statusDotColor;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class StaffOrdersDialog extends StatefulWidget {
  final String heading;
  final List<OrderData> orderData;

  const StaffOrdersDialog({
    super.key,
    required this.heading,
    required this.orderData,
  });

  @override
  State<StaffOrdersDialog> createState() => _StaffOrdersDialogState();
}

class _StaffOrdersDialogState extends State<StaffOrdersDialog> {
  late final ScrollController verticalController;
  late final ScrollController horizontalController;

  @override
  void initState() {
    super.initState();
    verticalController = ScrollController();
    horizontalController = ScrollController();
  }

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = widget.orderData;
    final double totalAmount = filteredOrders.fold<double>(
      0.0,
      (sum, order) => sum + (order.orderTotal ?? 0.0),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = isPhonePortrait(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isPortrait ? fullScreenWidth(context) : 950,
          maxHeight: screenHeight * 0.88,
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
              // 🔹 1. Gradient Header Bar
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
                          widget.heading.tr,
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
                            '${filteredOrders.length} ${'Orders'.tr}',
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

              // 🔹 2. Table Data Body
              if (filteredOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Center(child: NodataWidget()),
                )
              else
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(const Color(0xFF94A3B8)),
                          trackColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                          thickness: WidgetStateProperty.all(6),
                          radius: const Radius.circular(8),
                        ),
                        child: Scrollbar(
                          controller: verticalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                          child: Scrollbar(
                            controller: horizontalController,
                            thumbVisibility: true,
                            trackVisibility: true,
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
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.2,
                                    ),
                                    dataRowMinHeight: 52,
                                    dataRowMaxHeight: 64,
                                    columnSpacing: 20,
                                    horizontalMargin: 16,
                                    columns: [
                                      DataColumn(
                                        label: Text('Customer List'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Order No.'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Created'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Created By'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Invoice'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Payment Status'.tr),
                                      ),
                                      DataColumn(
                                        label: Text('Status'.tr),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text('Amount'.tr),
                                      ),
                                    ],
                                    rows: filteredOrders.map((order) {
                                      final customer = order.customer != null && order.customer!.isNotEmpty
                                          ? order.customer![0]
                                          : null;

                                      String salesmanName = 'N/A';
                                      if (order.salesman != null && order.salesman!.isNotEmpty) {
                                        final s = order.salesman!.first;
                                        final fn = (s.fullname ?? '').trim();
                                        if (fn.isNotEmpty) salesmanName = fn;
                                      } else if ((order.fullname ?? '').trim().isNotEmpty) {
                                        salesmanName = '${order.fullname ?? ''} ${order.lastname ?? ''}'.trim();
                                      }

                                      String formattedDate = 'N/A';
                                      if (order.generatedDate != null && order.generatedDate.toString().isNotEmpty) {
                                        try {
                                          formattedDate = TimeUtils.formatTimeInZone(
                                            DateTime.parse(order.generatedDate.toString()),
                                            format: 'dd-MM-yyyy',
                                          );
                                        } catch (_) {
                                          formattedDate = order.generatedDate.toString().split('T').first;
                                        }
                                      }

                                      String invoiceId = order.invoice != null && order.invoice!.isNotEmpty
                                          ? order.invoice![0].invoiceId ?? ''
                                          : '';

                                      return DataRow(
                                        cells: [
                                          // 1. Customer List
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipOval(
                                                  child: Container(
                                                    height: 32,
                                                    width: 32,
                                                    color: const Color(0xFFE2E8F0),
                                                    child: customer?.imageUrl != null && customer!.imageUrl!.isNotEmpty
                                                        ? Image.network(
                                                            '${ApiConstants.baseUrl1}/uploads/${customer.imageUrl}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFF2563EB), size: 20),
                                                          )
                                                        : const Icon(Icons.person, color: Color(0xFF2563EB), size: 20),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      customer?.businessName ?? 'N/A',
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 13,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (customer?.mobileno != null && customer!.mobileno!.isNotEmpty)
                                                      Text(
                                                        customer.mobileno!,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins_Regular',
                                                          fontSize: 11,
                                                          color: Color(0xFF64748B),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // 2. Order No.
                                          DataCell(
                                            InkWell(
                                              onTap: () async {
                                                bool isOnline = await ConnectivityService().isOnline();
                                                if (isOnline) {
                                                  showDetailedOrderInvoiceDialog(context, order.orderId ?? '', false);
                                                } else {
                                                  showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                }
                                              },
                                              child: Text(
                                                order.orderId ?? 'N/A',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins_Regular',
                                                  color: Color(0xFF2563EB),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // 3. Created Date
                                          DataCell(
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                fontSize: 12.5,
                                                color: Color(0xFF0F172A),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          // 4. Created By
                                          DataCell(
                                            Text(
                                              salesmanName,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                fontSize: 12.5,
                                                color: Color(0xFF334155),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          // 5. Invoice
                                          DataCell(
                                            invoiceId.isNotEmpty
                                                ? InkWell(
                                                    onTap: () async {
                                                      bool isOnline = await ConnectivityService().isOnline();
                                                      if (isOnline) {
                                                        showDialog(
                                                          barrierDismissible: false,
                                                          context: context,
                                                          builder: (context) => InvoicePreview(
                                                            orderId: order.orderId ?? '',
                                                          ),
                                                        );
                                                      } else {
                                                        showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                      }
                                                    },
                                                    child: Text(
                                                      invoiceId,
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        color: Color(0xFF2563EB),
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  )
                                                : const Text('-', style: TextStyle(color: Color(0xFF94A3B8))),
                                          ),

                                          // 6. Payment Status
                                          DataCell(
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: order.paymentStatus == 1 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: order.paymentStatus == 1 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  order.paymentStatus == 1 ? Icons.done : Icons.close,
                                                  color: order.paymentStatus == 1 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                                  size: 13.0,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // 7. Order Status
                                          DataCell(
                                            _buildStatusBadge(
                                              order.orderStatus,
                                              getStatusName(order.orderStatus ?? 0),
                                            ),
                                          ),

                                          // 8. Amount
                                          DataCell(
                                            Text(
                                              formatAmount(order.orderTotal ?? 0.0),
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 🔹 3. Total Footer Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total'.tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      formatAmount(totalAmount),
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
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
  }
}
