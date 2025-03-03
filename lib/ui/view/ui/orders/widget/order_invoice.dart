import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderProcessInvoiceDialog extends StatefulWidget {
  OrderProcessInvoiceData? invoiceData;
  SpecificOrderData? specificData;
  final int selectedTabIndex;
  final OrderController orderController;
  OrderProcessInvoiceDialog({
    this.invoiceData,
    this.specificData,
    required this.selectedTabIndex,
    required this.orderController,
  });

  @override
  State<OrderProcessInvoiceDialog> createState() =>
      _OrderProcessInvoiceDialogState();
}

class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
  bool isRejecting = false;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  dialogCloseButton1(context, red),
                ],
              ),
              const SizedBox(height: 16),
              MyCommnonContainer(
                isCommonBorder: true,
                // color: white,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.selectedTabIndex == 5
                              ? 'INVOICE DETAILS'
                              : 'ORDER DETAILS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Created At : ${(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(widget.invoiceData!.orderCreatAt!.toIso8601String())))}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ("Name :   ${widget.invoiceData?.fullname}"),
                            ),
                            Text(
                              ("Email :   ${widget.invoiceData?.email}"),
                            ),
                            Text(
                              ("Phone :   ${widget.invoiceData?.mobileNo}"),
                            ),
                            Text(
                              ("Salesman :   ${widget.invoiceData?.salesmanName}"),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Colors.lightBlue[100],
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DataTable(
                      dataRowHeight: 40,
                      headingRowHeight: 40,
                      horizontalMargin: 20,
                      headingTextStyle: const TextStyle(
                        color: black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: totalWidth * 0.2,
                            child: const Text('ITEM NAME'),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'PRICE',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'QTY',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'TAX',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'TOTAL',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                      rows: (widget.invoiceData?.cart != null &&
                              widget.invoiceData!.cart!.isNotEmpty)
                          ? List.generate(
                              widget.invoiceData!.cart!.length,
                              (index) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: totalWidth * 0.2,
                                        child: Text(
                                          ('${widget.invoiceData!.cart![index].productName} - ${widget.invoiceData!.cart![index].variationName}'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(formatAmount(widget
                                                .invoiceData?.cart?[index].price
                                                ?.toString() ??
                                            '0')),
                                      ),
                                    ),
                                    // Quantity
                                    DataCell(
                                      Center(
                                        child: Text(
                                          (widget.invoiceData!.cart![index]
                                                      .packType ==
                                                  'Pack')
                                              ? '${(widget.invoiceData?.cart?[index].pieces ?? 0) * (widget.invoiceData?.cart?[index].quantity?.toInt() ?? 0)}'
                                                  ' (${widget.invoiceData?.cart?[index].quantity ?? 0} ${widget.invoiceData?.cart?[index].packType})'
                                              : '${widget.invoiceData?.cart?[index].quantity ?? 0}',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(formatAmount(widget
                                            .invoiceData?.cart?[index].tax)),
                                      ),
                                    ),
                                    DataCell(
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: Text.rich(
                                            TextSpan(
                                              text: formatAmount(widget
                                                  .invoiceData!
                                                  .cart![index]
                                                  .total),
                                              children: widget
                                                          .invoiceData!
                                                          .cart![index]
                                                          .inclTax ==
                                                      "incl_tax"
                                                  ? [
                                                      TextSpan(
                                                        text: "  (Incl. Tax)",
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            maxLines: 1,
                                          )),
                                    ),
                                  ],
                                );
                              },
                            )
                          : [
                              const DataRow(
                                cells: [
                                  DataCell(Text('No items available.')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                ],
                              ),
                            ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            color: black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatAmount(
                            widget.invoiceData?.cart
                                ?.fold<num>(0, (sum, item) => sum + item.total),
                          ),
                        ),
                      ],
                    ),
                    if ((widget.invoiceData?.tax != null &&
                        widget.invoiceData!.tax!
                            .any((taxItem) => taxItem.tax != null))) ...[
                      ...(widget.invoiceData!.tax!).map((taxItem) {
                        final orderTotal =
                            (widget.invoiceData?.orderTotal ?? 0);
                        final taxPercentage = taxItem.tax ?? 0.0;
                        final taxAmount = (taxPercentage * orderTotal) / 100;

                        return Row(
                          children: [
                            if (taxItem.tax_name != null) ...[
                              Text(
                                '${taxItem.tax_name ?? ''} - ${taxPercentage.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                formatAmount(taxAmount),
                              ),
                            ]
                          ],
                        );
                      }),
                    ],
                    Divider(color: Colors.grey.shade400),
                    Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatAmount(
                            widget.invoiceData?.cart
                                ?.fold<num>(0, (sum, item) => sum + item.total),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.selectedTabIndex == 6) ...[
                    const Text('Rejection Reason : '),
                    // nkMediumSizeBox(),
                    Text(widget.invoiceData!.rejectionReason.toString()),
                    nkMediumSizeBox(),
                    Text(NKDateUtils.commonDayFormat2(
                        NKDateUtils.formatStringUTCDateTime(
                            widget.invoiceData!.rejectedDate.toString()))),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
