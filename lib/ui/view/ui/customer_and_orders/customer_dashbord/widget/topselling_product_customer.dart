import 'dart:math' as math;
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Widget topSellingProductsCustomer(
    List<FrequantliyProductList> frequentProductLists) {
  return TopSellingProductsCustomerWidget(frequentProductLists: frequentProductLists);
}

class TopSellingProductsCustomerWidget extends StatefulWidget {
  final List<FrequantliyProductList> frequentProductLists;

  const TopSellingProductsCustomerWidget({
    super.key,
    required this.frequentProductLists,
  });

  @override
  State<TopSellingProductsCustomerWidget> createState() => _TopSellingProductsCustomerWidgetState();
}

class _TopSellingProductsCustomerWidgetState extends State<TopSellingProductsCustomerWidget> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frequentProductLists.isEmpty) {
      return const NodataWidget();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        const double colWidth0 = 50; // Sl.No.
        const double colWidth2_2 = 70; // I/N
        const double colWidth2 = 98; // Last Purchase
        const double colWidth3 = 56; // Times
        const double colWidth4 = 92; // Amount
        const double colWidth5 = 56; // Qty
        const double gapTotal = 6 * 6; // 6 gaps of 6px

        double colWidth1 = math.max(180.0, availableWidth - (colWidth0 + colWidth2_2 + colWidth2 + colWidth3 + colWidth4 + colWidth5 + gapTotal + 20));
        double totalTableWidth = colWidth0 + colWidth1 + colWidth2_2 + colWidth2 + colWidth3 + colWidth4 + colWidth5 + gapTotal;

        const double fontSize = 11.5;

<<<<<<< HEAD
        return RawScrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          trackColor: const Color(0xFFF1F5F9),
          trackBorderColor: Colors.transparent,
          trackRadius: const Radius.circular(8),
          radius: const Radius.circular(8),
          thickness: 5,
          thumbColor: primaryColor.withOpacity(0.55),
          crossAxisMargin: 2,
          mainAxisMargin: 12,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
=======
        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          radius: const Radius.circular(8),
          thickness: 6,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: totalTableWidth + 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Table Header
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: colWidth0,
                          child: Center(
                            child: Text(
                              "Sl.No.".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth1,
                          child: Center(
                            child: Text(
                              "Product".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth2_2,
                          child: Center(
                            child: Text(
                              "I/N".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth2,
                          child: Center(
                            child: Text(
                              "Last Purchase".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth3,
                          child: Center(
                            child: Text(
                              "Times".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth4,
                          child: Center(
                            child: Text(
                              "Amount".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: colWidth5,
                          child: Center(
                            child: Text(
                              "Qty".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🔹 Table Body
                  Expanded(
<<<<<<< HEAD
                    child: RawScrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: false,
                      radius: const Radius.circular(8),
                      thickness: 3,
                      thumbColor: primaryColor.withOpacity(0.3),
                      crossAxisMargin: 2,
                      mainAxisMargin: 4,
=======
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      radius: const Radius.circular(8),
                      thickness: 6,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                      notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: widget.frequentProductLists.asMap().entries.map((entry) {
                            int index = entry.key;
                            var product = entry.value;
                            String variation = product.variationName ?? '';
                            String prodName = variation.isNotEmpty
                                ? '${product.productName} - $variation'
                                : (product.productName ?? '');

                            return Container(
                              height: 38,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
                              ),
                              child: Row(
                                children: [
                                  // Sl.No.
                                  SizedBox(
                                    width: colWidth0,
                                    child: Center(
                                      child: Text(
                                        "${index + 1}.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Product Name
                                  SizedBox(
                                    width: colWidth1,
                                    child: Text(
                                      prodName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // I/N
                                  SizedBox(
                                    width: colWidth2_2,
                                    child: Center(
                                      child: Text(
                                        product.inNo.toString(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Last Purchase
                                  SizedBox(
                                    width: colWidth2,
                                    child: Center(
                                      child: Text(
                                        product.createdAt != null
                                            ? TimeUtils.formatTimeInZone(
                                                product.createdAt,
                                                format: 'dd-MM-yyyy',
                                              )
                                            : 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Times
                                  SizedBox(
                                    width: colWidth3,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          showDashTimesDialogue(
                                            context,
                                            product,
                                            (p) => p.count,
                                            (data) => data.businessName,
                                            (data) => formatAmount(data.price),
                                            (data) => formatAmount(data.tax),
                                            (data) => data.quantity.toString(),
                                            (data) => formatAmount(
                                              data.inclTax == "incl_tax"
                                                  ? ((double.tryParse(data.totalPrice.toString()) ?? 0))
                                                  : (((double.tryParse(data.totalPrice.toString()) ?? 0) + (double.tryParse(data.tax.toString()) ?? 0.0))),
                                            ),
                                            (data) => DateFormat('dd-MM-yyyy').format(data.createdAt!),
                                            (data) => data.orderId.toString(),
                                            false,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            product.count.length.toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Amount
                                  SizedBox(
                                    width: colWidth4,
                                    child: Center(
                                      child: Text(
                                        formatAmount(product.totalPrice),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Qty
                                  SizedBox(
                                    width: colWidth5,
                                    child: Center(
                                      child: Text(
                                        product.quantity.toString(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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
}
