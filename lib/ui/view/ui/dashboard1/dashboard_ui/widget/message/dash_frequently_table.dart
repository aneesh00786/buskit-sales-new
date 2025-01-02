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
        // double flexWidth = availableWidth * 1.2;
        double flexWidth = availableWidth - 20;
        double colWidth1 = flexWidth * 3 / 9;
        double colWidth2 = flexWidth * 2 / 9;
        double colWidth3 = flexWidth * 1 / 9;
        double colWidth4 = flexWidth * 2 / 9;
        double colWidth5 = flexWidth * 1 / 9;

        double fontSize = 11;

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
                                        showDashTimesDialogue(context,product);
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
void showTopSellingProductListDialog(
    BuildContext context, List<TopSellingProductA> topSellingProducts) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = constraints.maxWidth * 0.9;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 50.0;
            int visibleRows = topSellingProducts.length.clamp(1, 10);
            double listHeight = visibleRows * rowHeight;
            double contentHeight = listHeight > maxDialogHeight
                ? maxDialogHeight
                : listHeight;
            double colWidth1 = dialogWidth * 3 / 9;
            double colWidth2 = dialogWidth * 2 / 9;
            double colWidth3 = dialogWidth * 1 / 9;
            double colWidth5 = dialogWidth * 1 / 9;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: maxDialogHeight,
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: Color.fromARGB(255, 247, 247, 247),
                    ),
                    height: headerHeight,
                    child: Row(
                      children: [
                        SizedBox(
                          width: colWidth1,
                          child: const Center(
                            child: DialogTableHeaderText(
                              text: "Product",
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth2,
                          child: const Center(
                            child: DialogTableHeaderText(
                              text: "Last Purchase",
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth3,
                          child: const Center(
                            child: DialogTableHeaderText(
                              text: "Times",
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: const Center(
                            child: DialogTableHeaderText(
                              text: "Price",
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: colWidth5,
                          child: const Center(
                            child: DialogTableHeaderText(
                              text: "Qty",
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Scrollable List
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxDialogHeight, // Maximum height for scroll
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: topSellingProducts.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var product = topSellingProducts[index];
                            return Container(
                              height: rowHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: colWidth1,
                                      child: MyRegularText(
                                        label:
                                            '${product.productName} - ${product.variationName}',
                                        fontSize: 11,
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
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: colWidth3,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            showDashTimesDialogue(context, product);
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
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: MyRegularText(
                                          label: formatAmount(
                                              product.topSellingProductATotalPrice),
                                          color: secondaryTextColor,
                                          fontSize: 11,
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
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}



