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
  return LayoutBuilder(
    builder: (context, constraints) {
      double availableWidth = constraints.maxWidth;
      double flexWidth = fullScreenWidth(context) > 660
          ? availableWidth * 1.4
          : availableWidth * 1.6;
      double colWidth0 = flexWidth * 1 / 12;
      double colWidth1 = flexWidth * 2.8 / 12;
      double colWidth2_2 = flexWidth * 1.2 / 12;
      double colWidth2 = flexWidth * 2 / 12;
      double colWidth3 = flexWidth * 1 / 12;
      double colWidth4 = flexWidth * 2.1 / 12;
      double colWidth5 = flexWidth * 1 / 12;

      double fontSize = 11;

      if (frequentProductLists.isEmpty) {
        return const NodataWidget();
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: flexWidth + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      SizedBox(
                        width: colWidth0,
                        child: Center(
                          child: MyRegularText(
                            label: "Sl.No.".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth1,
                        child: Center(
                          child: MyRegularText(
                            label: "Product".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth2_2,
                        child: Center(
                          child: MyRegularText(
                            label: "I/N".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth2,
                        child: Center(
                          child: MyRegularText(
                            label: "Last Purchase".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth3,
                        child: Center(
                          child: MyRegularText(
                            label: "Times".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth4,
                        child: Center(
                          child: MyRegularText(
                            label: "Amount".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: colWidth5,
                        child: Center(
                          child: MyRegularText(
                            label: "Qty".tr,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            align: TextAlign.center,
                            fontSize: 11.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children:
                          frequentProductLists.asMap().entries.map((entry) {
                        int index = entry.key;
                        var product = entry.value;

                        return SizedBox(
                          height: 35,
                          child: Row(
                            children: [
                              SizedBox(
                                width: colWidth0,
                                child: MyRegularText(
                                  label: "${index + 1}.",
                                  fontSize: fontSize,
                                  maxlines: 1,
                                  align: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth1,
                                child: MyRegularText(
                                  label:
                                      '${product.productName} - ${product.variationName}',
                                  fontSize: fontSize,
                                  maxlines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth2_2,
                                child: Center(
                                  child: MyRegularText(
                                    label: product.inNo.toString(),
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                    maxlines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth2,
                                child: Center(
                                  child: MyRegularText(
                                    // Added a safe null check just in case createdAt is ever missing
                                    label: product.createdAt != null
                                        ? TimeUtils.formatTimeInZone(
                                            product
                                                .createdAt, // Passed directly as a DateTime object!
                                            format:
                                                'dd-MM-yyyy', // Enforces the date-only format
                                          )
                                        : 'N/A',
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                    maxlines: 1,
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: colWidth2,
                              //   child: Center(
                              //     child: MyRegularText(
                              //       label: DateFormat('dd-MM-yyyy')
                              //           .format(product.createdAt.toLocal()),
                              //       color: secondaryTextColor,
                              //       fontSize: fontSize,
                              //       maxlines: 1,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth3,
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      // print('ont tapped times');
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
                                              ? ((double.tryParse(data
                                                      .totalPrice
                                                      .toString()) ??
                                                  0))
                                              : (((double.tryParse(data
                                                          .totalPrice
                                                          .toString()) ??
                                                      0) +
                                                  (double.tryParse(data.tax
                                                          .toString()) ??
                                                      0.0))),
                                        ),
                                        (data) => DateFormat('dd-MM-yyyy')
                                            .format(data.createdAt!),
                                        (data) => data.orderId.toString(),
                                        false,
                                      );
                                    },
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: MyRegularText(
                                          label:
                                              product.count.length.toString(),
                                          color: buttonTextColor,
                                          align: TextAlign.center,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth4,
                                child: Center(
                                  child: MyRegularText(
                                    label: formatAmount(product.totalPrice),
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                    maxlines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: colWidth5,
                                child: Center(
                                  child: MyRegularText(
                                    label: product.quantity.toString(),
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                    maxlines: 1,
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
              ],
            ),
          ),
        );
      }
    },
  );
}
