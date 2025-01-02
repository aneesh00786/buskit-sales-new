import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Future<dynamic> showDashTimesDialogue(
  BuildContext context,
  BoxConstraints constraints,
  TopSellingProductA product,
  List<TopSellingProductA> topSellingProducts,
) {
  double maxDialogHeight = constraints.maxHeight * 0.9; // Maximum allowable height
  double calculatedHeight = 50.0 + topSellingProducts.length * 80.0; // Header + rows
  double dialogHeight = calculatedHeight > maxDialogHeight
      ? maxDialogHeight
      : calculatedHeight; // Use calculated height or max height

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        content: SizedBox(
          width: constraints.maxWidth * 0.9, // Width of dialog
          child: SingleChildScrollView(
            physics: dialogHeight == maxDialogHeight
                ? const ScrollPhysics() // Enable scrolling if height is max
                : const NeverScrollableScrollPhysics(), // Disable scrolling
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: dialogHeight, // Restrict height dynamically
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
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
                        Flexible(
                          child: MyRegularText(
                            label:
                                '${product.productName} - ${product.variationName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins_Regular',
                              fontWeight: FontWeight.w600,
                            ),
                            maxlines: 5,
                          ),
                        ),
                        dialogCloseButton1(context, red),
                      ],
                    ),
                  ),
                  // Table Section
                  Expanded(
                    child: frequentlyBoughtTable(
                      context: context,
                      constraints: constraints,
                      product: product,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}





Widget frequentlyBoughtTable({
  required BuildContext context,
  required BoxConstraints constraints,
  required TopSellingProductA product,
}) {
  List<String> headers = [
    'Price',
    'Quantity',
    'Amount',
    'Purchased At',
  ];
  List<TableViewRow> rows = product.getTimesData!.isEmpty
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(
                child: Center(
                  child: Text(
                    "No Records Found",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              ...List.generate(3, (_) => TableViewCell(child: SizedBox())),
            ],
          ),
        ]
      : product.getTimesData!.map((timesData) {
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Text(
                  formatAmount(timesData.price),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  timesData.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  timesData.totalPrice != null
                      ? formatAmount(timesData.totalPrice)
                      : 'N/A',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  DateFormat('dd-MM-yyyy')
                      .format(timesData.createdAt!)
                      .toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
        }).toList();

  return Column(
    children: [
      Container(
        color: const Color.fromARGB(255, 247, 247, 247),
        height: 30,
        child: Row(
          children: headers
              .map(
                (header) => Expanded(
                  child: Center(
                    child: Text(
                      header,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
              .toList(),
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
                children: rows[index]
                    .cells
                    .map(
                      (cell) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: cell.child,
                        ),
                      ),
                    )
                    .toList(),
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
