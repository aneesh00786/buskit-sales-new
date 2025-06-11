import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:flutter/material.dart';
void showProductListDialog<T>({
  required BuildContext context,
  required List<T> productList,
  required double Function(T) getQuantity,
  required String Function(T) getProductName,
  required String Function(T) getVariationName,
  required String Function(T) getFormattedDate,
  required String Function(T) getPrice,
  required String Function(T) getInNo,
  required int Function(T) getBuyQuantity,
  required void Function(BuildContext, T) onQuantityTap,
}) {
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
            double maxDialogHeight = constraints.maxHeight * 0.95;
            double rowHeight = 40.0;
            double headerHeight = 50.0;
            double contentHeight =
                (productList.length * rowHeight) + headerHeight;
            contentHeight = contentHeight > maxDialogHeight
                ? maxDialogHeight
                : contentHeight;

            double colWidth0 = dialogWidth * 1 / 13;
            double colWidth1 = dialogWidth * 3 / 13;
            double colWidth2_2 = dialogWidth * 1.5 / 13;
            double colWidth2 = dialogWidth * 2 / 13;
            double colWidth3 = dialogWidth * 1 / 13;
            double colWidth4 = dialogWidth * 2 / 13;
            double colWidth5 = dialogWidth * 1 / 13;
            double colWidth6 = dialogWidth * 1 / 24;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: contentHeight,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: primaryColor,
                        ),
                        height: headerHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: colWidth0,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Sl.No.",
                                  fontSize: 13,
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth1,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Product",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth2_2,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "I/N",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth2,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Last Purchase",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth3,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Times",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth4,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Amount",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth5,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Qty",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth6,
                              child: const Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "",
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: dialogCloseButton1(context, red),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: contentHeight - headerHeight,
                        ),
                        child: ScrollbarTheme(
                                        data: const ScrollbarThemeData(
                                          minThumbLength: 150,
                                          thickness: WidgetStatePropertyAll(5),
                                          thumbColor: WidgetStatePropertyAll(
                                              Colors.blue),
                                        ),
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          trackVisibility: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: productList.length,
                              physics: productList.length * rowHeight <=
                                      contentHeight - headerHeight
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                T product = productList[index];
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
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: colWidth0,
                                          child: MyRegularText(
                                            label: '${index + 1}.',
                                            fontSize: 12,
                                            maxlines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            align: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth1,
                                          child: MyRegularText(
                                            label:
                                                '${getProductName(product)} - ${getVariationName(product)}',
                                            fontSize: 12,
                                            maxlines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth2_2,
                                          child: Center(
                                            child: MyRegularText(
                                              label: getInNo(product),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth2,
                                          child: Center(
                                            child: MyRegularText(
                                              label: getFormattedDate(product),
                                              color: secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth3,
                                          child: Center(
                                            child: InkWell(
                                              onTap: () =>
                                                  onQuantityTap(context, product),
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
                                                        '${getQuantity(product).toInt()}',
                                                    color: buttonTextColor,
                                                    align: TextAlign.center,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
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
                                              label: getPrice(product),
                                              color: secondaryTextColor,
                                              fontSize: 12,
                                              maxlines: 1,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth5,
                                          child: Center(
                                            child: MyRegularText(
                                              label: getBuyQuantity(product)
                                                  .toString(),
                                              color: secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: colWidth6,
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
