import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/detailed_order_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget frequentlyBoughtTable({
  required List<TopSellingProductA> topSellingProducts,
  required BuildContext context,
  required BoxConstraints constraints,
}) {
  List<String> headers = [
    'Product',
    "Last Purchase",
    "Times",
    "Price",
    "Qty",
  ];

  List<TableViewRow> rows = topSellingProducts.isEmpty
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("No Records Found")),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : topSellingProducts.map((product) {
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Text(
                  '${product.productName} - ${product.variationName}',

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ),
              TableViewCell(
                child: Text(
                  DateFormat('dd-MM-yyyy').format(product.createdAt!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ),
              TableViewCell(
                child: InkWell(
                  onTap: () {
                    showDashTimesDialogue(context, constraints, product);
                  },
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        product.quantity.toString(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  formatAmount(product.topSellingProductATotalPrice),
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Text(
                    product.getTimesData!
                        .fold<int>(
                          0,
                          (previousValue, element) =>
                              previousValue + element.quantity!,
                        )
                        .toString(),
                  ),
                ),
              ),
            ],
          );
        }).toList();

  return Column(
    children: [
      Container(
        color: const Color.fromARGB(255, 243, 242, 242),
        height: 50,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  headers[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
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

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}
