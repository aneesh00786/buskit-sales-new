// ignore_for_file: use_build_context_synchronously, must_be_immutable, deprecated_member_use
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineOrderDetailsDialog extends StatefulWidget {
  Map<String, dynamic> orderData;

  OfflineOrderDetailsDialog({super.key, required this.orderData});

  @override
  State<OfflineOrderDetailsDialog> createState() =>
      _OfflineOrderDetailsDialogState();
}

class _OfflineOrderDetailsDialogState extends State<OfflineOrderDetailsDialog> {
  bool isRejecting = false;
  TextEditingController rejectionController = TextEditingController();

  final subscriptionController = Get.find<SubscriptionController>();

  bool isSendingForApproval = false;

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

    double passedTotal = widget.orderData['order_price'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'OFFLINE ORDER DETAILS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Created At : ${(NKDateUtils.commonFullDateTimeFormat2(NKDateUtils.formatStringUTCDateTime(DateTime.parse(widget.orderData['createdAt'].toString()).toString())))}',
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
                              ("Name :   ${widget.orderData['businessName'] ?? ''}"),
                            ),
                            Text(
                              ("Email :   ${widget.orderData['email'] ?? ''}"),
                            ),
                            Text(
                              ("Phone :   ${widget.orderData['mobileNo'] ?? ''}"),
                            ),
                            Text(
                              ("Staff :   ${SessionHelper.loginSavedData?.fullname ?? ''}"),
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
                              'PACK TYPE',
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
                              'DISCOUNT',
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
                      rows: (widget.orderData['cart_list'] != null &&
                              (widget.orderData['cart_list'] as List)
                                  .isNotEmpty)
                          ? List.generate(
                              (widget.orderData['cart_list'] as List).length,
                              (index) {
                                final item = widget.orderData['cart_list']
                                    [index] as Map<String, dynamic>;

                                final productName =
                                    "${item['product_name']} - ${item['variant_name']}";
                                final isPack = item['packType'] == "Pack" ||
                                    item['isPack'] == true;
                                final packCount = (double.tryParse(
                                            item['pack']?.toString() ?? '1') ??
                                        1)
                                    .toInt();
                                final quantity = int.tryParse(
                                        item['quantity']?.toString() ?? '1') ??
                                    1;
                                final perPack = int.tryParse(
                                        item['perPack']?.toString() ?? '1') ??
                                    1;
                                final unitPrice = double.tryParse(
                                        item['price']?.toString() ?? '0') ??
                                    0.0;
                                final totalTax = double.tryParse(
                                        item['totalTax']?.toString() ?? '0') ??
                                    0.0;
                                final discountPrice = double.tryParse(
                                        item['discountPrice']?.toString() ??
                                            '0') ??
                                    0.0;
                                final inclTax =
                                    item['inclTax']?.toString().toLowerCase() ==
                                        'incl_tax';

                                final netTax = totalTax;

                                final rowSubtotal = unitPrice * packCount;

                                final rowTotal = rowSubtotal -
                                    discountPrice +
                                    (inclTax ? 0 : netTax);

                                final packLabel =
                                    isPack ? 'Pack ($perPack pcs)' : 'Pcs';

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Tooltip(
                                        message: productName,
                                        child: SizedBox(
                                          width: totalWidth * 0.2,
                                          child: Text(
                                            productName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Center(
                                        child: Text(formatAmount(unitPrice)))),
                                    DataCell(Center(child: Text(packLabel))),
                                    DataCell(Center(
                                        child: Text(quantity.toString()))),
                                    DataCell(Center(
                                        child:
                                            Text(formatAmount(discountPrice)))),
                                    DataCell(Center(
                                        child: Text(formatAmount(netTax)))),
                                    DataCell(
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(formatAmount(rowTotal)),
                                      ),
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
                        Text(formatAmount(passedTotal)),
                      ],
                    ),
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
                          formatAmount(passedTotal),
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
            ],
          ),
        ),
      ),
    );
  }
}

class ProductNameWithTax extends StatelessWidget {
  final String productName;
  final String variationName;
  final bool isInclTax;
  final double maxWidth;
  final TextStyle style;

  const ProductNameWithTax({
    super.key,
    required this.productName,
    required this.variationName,
    required this.isInclTax,
    required this.maxWidth,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final suffix = isInclTax ? ' (Incl. Tax)' : '';

    final fullText = '$productName - $variationName';
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );

    for (int i = fullText.length; i >= 0; i--) {
      final truncated = fullText.substring(0, i).trimRight();
      final span = TextSpan(
        text: '$truncated$suffix',
        style: style,
      );
      textPainter.text = span;
      textPainter.layout(maxWidth: maxWidth);

      if (!textPainter.didExceedMaxLines) {
        return Text.rich(
          TextSpan(
            text: truncated,
            style: style,
            children: [
              if (i != fullText.length) const TextSpan(text: '...'),
              if (isInclTax)
                TextSpan(
                  text: suffix,
                  style: style.copyWith(fontSize: 12),
                ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.clip,
        );
      }
    }

    return Text(
      suffix,
      style: style,
    );
  }
}
