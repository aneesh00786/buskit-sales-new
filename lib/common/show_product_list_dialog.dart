import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class ProductListDialog<T> extends StatefulWidget {
  final List<T> productList;
  final double Function(T) getQuantity;
  final String Function(T) getProductName;
  final String Function(T) getVariationName;
  final String Function(T) getFormattedDate;
  final String Function(T) getPrice;
  final String Function(T) getInNo;
  final int Function(T) getBuyQuantity;
  final void Function(BuildContext, T) onQuantityTap;

  const ProductListDialog({
    super.key,
    required this.productList,
    required this.getQuantity,
    required this.getProductName,
    required this.getVariationName,
    required this.getFormattedDate,
    required this.getPrice,
    required this.getInNo,
    required this.getBuyQuantity,
    required this.onQuantityTap,
  });

  @override
  State<ProductListDialog<T>> createState() => _ProductListDialogState<T>();
}

class _ProductListDialogState<T> extends State<ProductListDialog<T>> {
  final ScrollController _verticalScrollController = ScrollController();

  late LinkedScrollControllerGroup _controllers;

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;

  @override
  void initState() {
    super.initState();

    _controllers = LinkedScrollControllerGroup();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    // Any initialization you need can go here
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double dialogWidth = isPhonePortrait(context)
              ? fullScreenWidth(context) * 2
              : fullScreenWidth(context) * 0.9;
          double maxDialogHeight = constraints.maxHeight * 0.95;
          double rowHeight = 40.0;
          double headerHeight = isPhonePortrait(context) ? 70 : 50.0;
          double contentHeight =
              (widget.productList.length * rowHeight) + headerHeight;
          contentHeight =
              contentHeight > maxDialogHeight ? maxDialogHeight : contentHeight;

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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController1,
                      child: Container(
                        width: isPhonePortrait(context)
                            ? fullScreenWidth(context) * 2
                            : dialogWidth,
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
                              child: Center(
                                child: _customHeaderPadding(
                                  DialogTableHeaderTextWhite(
                                    text: "Sl.No.".tr,
                                    fontSize: 13,
                                    align: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth1,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "Product".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth2_2,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "I/N".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth2,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "Last Purchase".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth3,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "Times".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth4,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "Amount".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: colWidth5,
                              child: _customHeaderPadding(
                                 Center(
                                  child: DialogTableHeaderTextWhite(
                                    text: "Qty".tr,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: colWidth6),
                          ],
                        ),
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
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController2,
                    child: SizedBox(
                      width: isPhonePortrait(context)
                          ? fullScreenWidth(context) * 2
                          : dialogWidth,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: contentHeight - headerHeight,
                          ),
                          child: ScrollbarTheme(
                            data: const ScrollbarThemeData(
                              thickness: WidgetStatePropertyAll(5),
                              thumbColor: WidgetStatePropertyAll(Colors.blue),
                            ),
                            child: Scrollbar(
                              controller: _verticalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: ListView.builder(
                                controller: _verticalScrollController,
                                shrinkWrap: true,
                                itemCount: widget.productList.length,
                                physics:
                                    widget.productList.length * rowHeight <=
                                            contentHeight - headerHeight
                                        ? const NeverScrollableScrollPhysics()
                                        : const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  T product = widget.productList[index];
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
                                                  '${widget.getProductName(product)} - ${widget.getVariationName(product)}',
                                              fontSize: 12,
                                              maxlines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: colWidth2_2,
                                            child: Center(
                                              child: MyRegularText(
                                                label: widget.getInNo(product),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: colWidth2,
                                            child: Center(
                                              child: MyRegularText(
                                                label: widget
                                                    .getFormattedDate(product),
                                                color: secondaryTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: colWidth3,
                                            child: Center(
                                              child: InkWell(
                                                onTap: () {
                                                  widget.onQuantityTap(
                                                      context, product);
                                                  setState(() {}); // refresh UI
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: MyRegularText(
                                                      label:
                                                          '${widget.getQuantity(product).toInt()}',
                                                      color: buttonTextColor,
                                                      align: TextAlign.center,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
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
                                                label: widget.getPrice(product),
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
                                                label: widget
                                                    .getBuyQuantity(product)
                                                    .toString(),
                                                color: secondaryTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: colWidth6),
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _customHeaderPadding(Widget child) {
    return Padding(
      padding: EdgeInsets.only(top: isPhonePortrait(context) ? 30 : 0),
      child: child,
    );
  }
}

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
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return ProductListDialog<T>(
        productList: productList,
        getQuantity: getQuantity,
        getProductName: getProductName,
        getVariationName: getVariationName,
        getFormattedDate: getFormattedDate,
        getPrice: getPrice,
        getInNo: getInNo,
        getBuyQuantity: getBuyQuantity,
        onQuantityTap: onQuantityTap,
      );
    },
  );
}
