// ignore_for_file: use_build_context_synchronously, must_be_immutable, deprecated_member_use
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
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

    final String createdAtText = NKDateUtils.commonFullDateTimeFormat2(
        NKDateUtils.formatStringUTCDateTime(
            DateTime.parse(widget.orderData['createdAt'].toString())
                .toString()));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(context),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCustomerInfoCard(createdAtText),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: DataTable(
                              dataRowHeight: 40,
                              headingRowHeight: 40,
                              horizontalMargin: 20,
                              headingRowColor:
                                  MaterialStateProperty.all(primaryColor),
                              headingTextStyle: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              dataRowColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.white,
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
                                      (widget.orderData['cart_list'] as List)
                                          .length,
                                      (index) {
                                        final item =
                                            widget.orderData['cart_list'][index]
                                                as Map<String, dynamic>;

                                        final productName =
                                            "${item['product_name']} - ${item['variant_name']}";
                                        final isPack =
                                            item['packType'] == "Pack" ||
                                                item['isPack'] == true;
                                        final packCount = (double.tryParse(
                                                    item['pack']?.toString() ??
                                                        '1') ??
                                                1)
                                            .toInt();
                                        final quantity = int.tryParse(
                                                item['quantity']?.toString() ??
                                                    '1') ??
                                            1;
                                        final perPack = int.tryParse(
                                                item['perPack']?.toString() ??
                                                    '1') ??
                                            1;
                                        final unitPrice = double.tryParse(
                                                item['price']?.toString() ??
                                                    '0') ??
                                            0.0;
                                        final totalTax = double.tryParse(
                                                item['totalTax']?.toString() ??
                                                    '0') ??
                                            0.0;
                                        final discountPrice = double.tryParse(
                                                item['discountPrice']
                                                        ?.toString() ??
                                                    '0') ??
                                            0.0;
                                        final inclTax = item['inclTax']
                                                ?.toString()
                                                .toLowerCase() ==
                                            'incl_tax';

                                        final netTax = totalTax;

                                        final rowSubtotal =
                                            unitPrice * packCount;

                                        final rowTotal = rowSubtotal -
                                            discountPrice +
                                            (inclTax ? 0 : netTax);

                                        final packLabel = isPack
                                            ? 'Pack ($perPack pcs)'
                                            : 'Pcs';

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Tooltip(
                                                message: productName,
                                                child: SizedBox(
                                                  width: totalWidth * 0.2,
                                                  child: Text(
                                                    productName,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(Center(
                                                child: Text(
                                                    formatAmount(unitPrice)))),
                                            DataCell(
                                                Center(child: Text(packLabel))),
                                            DataCell(Center(
                                                child:
                                                    Text(quantity.toString()))),
                                            DataCell(Center(
                                                child: Text(formatAmount(
                                                    discountPrice)))),
                                            DataCell(Center(
                                                child: Text(
                                                    formatAmount(netTax)))),
                                            DataCell(
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    formatAmount(rowTotal)),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTotalsCard(passedTotal),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     DIALOG HEADER – gradient bar replacing the old plain
     Spacer()+dialogCloseButton1 row. The close action is the exact
     same Navigator.of(context).pop() the plain close button used.
     -------------------------------------------------------------- */
  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_outlined,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Offline Order Details',
                    style: TextStyle(
                      fontFamily: 'Poppins_Regular',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkResponse(
            onTap: () => Navigator.of(context).pop(),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     CUSTOMER INFO CARD – bordered card with avatar + customer meta,
     replacing the plain black-text title/name/email/phone rows.
     -------------------------------------------------------------- */
  Widget _buildCustomerInfoCard(String createdAtText) {
    const labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: Color(0xFF94A3B8),
    );
    const nameStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF0F172A),
    );
    const metaStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 12.5,
      color: Color(0xFF64748B),
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CUSTOMER', style: labelStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 44,
                        width: 44,
                        color: Colors.lightBlue[100],
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.orderData['businessName'] ?? ''}',
                        style: nameStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Email: ${widget.orderData['email'] ?? ''}',
                    style: metaStyle),
                Text('Phone: ${widget.orderData['mobileNo'] ?? ''}',
                    style: metaStyle),
                Text('Staff: ${SessionHelper.loginSavedData?.fullname ?? ''}',
                    style: metaStyle),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('CREATED AT', style: labelStyle),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  createdAtText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     TOTALS CARD
     -------------------------------------------------------------- */
  Widget _buildTotalsCard(double passedTotal) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _totalRow('Subtotal', formatAmount(passedTotal)),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            _totalRow('Total', formatAmount(passedTotal), isEmphasis: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isEmphasis = false}) {
    final labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 13.5 : 12.5,
      fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
      color: isEmphasis ? const Color(0xFF0F172A) : const Color(0xFF64748B),
    );
    final valueStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 15 : 12.5,
      fontWeight: FontWeight.w700,
      color: isEmphasis ? primaryColor : const Color(0xFF0F172A),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
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
