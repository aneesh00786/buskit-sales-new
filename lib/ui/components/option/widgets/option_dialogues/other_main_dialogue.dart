import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/detailed_order_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildDialogueMainDash({
  required List<OrdersDash> filteredOrders,
  required BuildContext context,
  required String headers1,
  required String headers2,
  required String headers3,
  required String headers4,
  required String headers5,
  required String headers6,
}) {
  List<String> headers = [
    headers1,
    headers2,
    headers3,
    headers4,
    headers5,
    headers6,
    ''
  ];

  List<TableViewRow> rows = filteredOrders.isEmpty
      ? [
          const TableViewRow(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffe6ecff),
                      child: Icon(Icons.person, size: 14, color: Colors.blue),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          customer != null ? customer.businessName : 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          customer != null ? customer.fullName : 'N/A',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          customer != null ? customer.mobileNo : 'N/A',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          customer != null ? customer.email : 'N/A',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TableViewCell(
                child: Center(
                  child: InkWell(
                      onTap: () {
                        showDetailedOrderDialog(context, order, false);
                      },
                      child: Center(
                          child: Text(order.orderId,
                              style: const TextStyle(fontSize: 14)))),
                ),
              ),
              TableViewCell(
                child: Text(
                  order.orderCreatedAt != null
                      ? getFormattedOrderCreatAt(
                          order.orderCreatedAt.toString())
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  order.salesmanId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  formatAmount(order.orderTotal),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffffdbb8),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        _getStatusName(order.orderStatus),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
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
