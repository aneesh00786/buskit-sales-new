import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/checkin_checkout_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/datacolumn_and_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/detailed_order_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildCheckInOutDialogContent(
    CheckInOut? data, StaffController staffController) {
  if (data == null) return const Text('No Check-in/out data available.');
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    double availableWidth = constraints.maxWidth;
    double fontSize = 14.0;
    double padding = availableWidth / 100;
    double fixedIconSize = fontSize;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: availableWidth,
              child: DataTable(
                dataRowHeight: fontSize * 5.5,
                headingRowHeight: 45,
                headingRowColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => primaryColor,
                ),
                columnSpacing: padding * 1.5,
                headingTextStyle: const TextStyle(
                    fontSize: 14, color: white, fontWeight: FontWeight.w700),
                columns: [
                  dataColumn(label: 'Customer'),
                  dataColumn(label: 'Customer ID'),
                  dataColumn(label: 'Event ID'),
                  dataColumn(label: 'Individual visit'),
                  dataColumn(label: 'Total visit'),
                  dataColumn(label: 'Check IN'),
                ],
                rows: (staffController.checkInOutData.value == null ||
                        staffController.checkInOutData.value!.data == null ||
                        staffController.checkInOutData.value!.data!.isEmpty)
                    ? [
                        const DataRow(cells: [
                          DataCell(Text('Record Not Found')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ])
                      ]
                    : staffController.checkInOutData.value!.data!.map((check) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: (fixedIconSize / 2) + 2,
                                    backgroundColor: const Color(0xffe6ecff),
                                    child: Icon(Icons.person,
                                        size: fixedIconSize,
                                        color: Colors.blue),
                                  ),
                                  SizedBox(width: padding),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          check.fullname ?? 'N/A',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          check.mobileno ?? 'N/A',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          check.email ?? 'N/A',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(check.customerId ?? 'N/A')),
                            DataCell(Text(check.eventId ?? 'N/A')),
                            DataCell(Text(
                                check.individualVisit.toString() ?? 'N/A')),
                            DataCell(Text(check.totalVisits ?? 'N/A')),
                            DataCell(Text(
                              check.checkIn != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(check.checkIn!)
                                  : 'N/A',
                            )),
                          ],
                        );
                      }).toList(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              height: 45,
              width: 45,
              child: Center(child: dialogCloseButton1(context, red)),
            ),
          ),
        ],
      ),
    );
  });
}

Widget buildOrdersDialogueMainDash({
  required List<OrdersDash> filteredOrders,
  required BuildContext context,
}) {
  List<String> headers = [
    "Customer",
    "Customer ID",
    "Event ID",
    "Individual Visit",
    "Total Visit",
    "Chack IN",
  ];
  List<TableViewRow> rows = filteredOrders.isEmpty
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("No Records Found")),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : filteredOrders.map((order) {
          final customer = order.customer.isNotEmpty ? order.customer[0] : null;
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffe6ecff),
                      child: Icon(Icons.person, size: 14, color: Colors.blue),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer != null ? customer.businessName : 'N/A',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.fullName : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.mobileNo : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.email : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableViewCell(
                child: InkWell(
                  onTap: () {
                    showDetailedOrderDialog(context, order, false);
                  },
                  child: Text(
                    order.orderId,
                    style: const TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  order.orderCreatedAt != null
                      ? getFormattedOrderCreatAt(
                          order.orderCreatedAt.toString())
                      : 'N/A',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  formatAmount(order.orderTotal),
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: InkWell(
                  onTap: () {
                    showDetailedOrderDialog(context, order, true);
                  },
                  child: Center(
                    child: Text(
                      order.invoice.isEmpty
                          ? 'Not Found'
                          : order.invoice[0].invoiceId,
                      style: const TextStyle(color: primaryColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          order.paymentStatus == 0 ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: order.paymentStatus == 0
                              ? Colors.red
                              : Colors.green),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Icon(
                          order.paymentStatus == 0 ? Icons.close : Icons.done,
                          color: white,
                          size: 14.0),
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffffdbb8),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusName(order.orderStatus),
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w400),
                          ),
                          if (order.orderStatus == 2 &&
                              order.deliveryDate != null) ...[
                            Text(
                                NKDateUtils.commonFullDateTimeFormat(
                                    NKDateUtils.formatStringUTCDateTime(
                                        order.deliveryDate!.toIso8601String())),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                )),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double maxDialogHeight = 500;
      double rowHeight = 60;
      int maxVisibleRows = 3;
      double calculatedHeight =
          (rows.length * rowHeight).clamp(0, maxDialogHeight);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: calculatedHeight,
          maxWidth: availableWidth,
        ),
        child: Stack(
          children: [
            Container(
              width: availableWidth,
              child: Column(
                children: [
                  Container(
                    color: primaryColor,
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              headers[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        ...headers
                            .sublist(1)
                            .map(
                              (label) => Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: rows.length,
                      shrinkWrap: true,
                      physics: rows.length >= maxVisibleRows
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: rows[index].cells[0].child,
                                ),
                              ),
                              ...rows[index]
                                  .cells
                                  .sublist(1)
                                  .map(
                                    (cell) => Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: cell.child,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                height: 30,
                width: 30,
                child: Center(child: dialogCloseButton1(context, red)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceIds = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceIds,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ));
}

String _getStatusName(int status) {
  switch (status) {
    case 5:
      return 'Order Processing';
    case 10:
      return 'Packed for Delivery';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    default:
      return 'Unknown';
  }
}

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}
