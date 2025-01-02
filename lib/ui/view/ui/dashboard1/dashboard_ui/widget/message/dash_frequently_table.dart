import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget topSellingProductList(List<TopSellingProductA> topSellingProducts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double flexWidth = availableWidth * 1.2;

        // Split flexWidth based on the given ratio (3:2:1:2:1)
        double colWidth1 = flexWidth * 3 / 9;
        double colWidth2 = flexWidth * 2 / 9;
        double colWidth3 = flexWidth * 1 / 9;
        double colWidth4 = flexWidth * 2 / 9;
        double colWidth5 = flexWidth * 1 / 9;

        double fontSize = 11;

        // Sort products by quantity
        topSellingProducts.sort((a, b) => b.quantity!.compareTo(a.quantity!));

        if (topSellingProducts.isEmpty) {
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
                  // Fixed Header
                  Container(
                    height: 35,
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        SizedBox(
                          width: colWidth1,
                          child: Center(
                            child: MyRegularText(
                              label: "Product",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth2,
                          child: Center(
                            child: MyRegularText(
                              label: "Last Purchase",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth3,
                          child: Center(
                            child: MyRegularText(
                              label: "Times",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth4,
                          child: Center(
                            child: MyRegularText(
                              label: "Price",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth5,
                          child: Center(
                            child: MyRegularText(
                              label: "Qty",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: topSellingProducts.map((product) {
                          return SizedBox(
                            height: 35,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: colWidth1,
                                  child: MyRegularText(
                                    label:
                                        '${product.productName} - ${product.variationName}',
                                    fontSize: fontSize - 1,
                                    maxlines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: colWidth2,
                                  child: Center(
                                    child: MyRegularText(
                                      label: DateFormat('dd-MM-yyyy')
                                          .format(product.createdAt!),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: colWidth3,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        showDashTimesDialogue(context,constraints,product);
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
                                            label: product.quantity.toString(),
                                            color: buttonTextColor,
                                            align: TextAlign.center,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: colWidth4,
                                  child: Center(
                                    child: MyRegularText(
                                      label: formatAmount(
                                          product.topSellingProductATotalPrice),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                      maxlines: 1,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: colWidth5,
                                  child: Center(
                                    child: MyRegularText(
                                      label: "${product.buyquantity}",
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
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