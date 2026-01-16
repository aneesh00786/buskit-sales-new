// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/build_row_content_data.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

Future<dynamic> showDashTimesDialogue<T>(
  BuildContext context,
  T product,
  List<dynamic> Function(T product) getTimesData,
  String Function(dynamic timesData) getCustomer,
  String Function(dynamic timesData) getPrice,
  String Function(dynamic timesData) getTax,
  String Function(dynamic timesData) getQuantity,
  String Function(dynamic timesData) getTotalPrice,
  String Function(dynamic timesData) getPurchasedAt,
  String Function(dynamic timesData) getOrderId,
  bool isDash,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return DashTimesDialog<T>(
        product: product,
        getTimesData: getTimesData,
        getCustomer: getCustomer,
        getPrice: getPrice,
        getTax: getTax,
        getQuantity: getQuantity,
        getTotalPrice: getTotalPrice,
        getPurchasedAt: getPurchasedAt,
        getOrderId: getOrderId,
        isDash: isDash,
      );
    },
  );
}

class DashTimesDialog<T> extends StatefulWidget {
  final T product;
  final List<dynamic> Function(T product) getTimesData;
  final String Function(dynamic timesData) getCustomer;
  final String Function(dynamic timesData) getPrice;
  final String Function(dynamic timesData) getTax;
  final String Function(dynamic timesData) getQuantity;
  final String Function(dynamic timesData) getTotalPrice;
  final String Function(dynamic timesData) getPurchasedAt;
  final String Function(dynamic timesData) getOrderId;
  final bool isDash;

  const DashTimesDialog({
    super.key,
    required this.product,
    required this.getTimesData,
    required this.getCustomer,
    required this.getPrice,
    required this.getTax,
    required this.getQuantity,
    required this.getTotalPrice,
    required this.getPurchasedAt,
    required this.getOrderId,
    required this.isDash,
  });

  @override
  State<DashTimesDialog<T>> createState() => _DashTimesDialogState<T>();
}

class _DashTimesDialogState<T> extends State<DashTimesDialog<T>> {
  late List<dynamic> timesDataList;

  late LinkedScrollControllerGroup _controllers;

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;

  @override
  void initState() {
    super.initState();
    timesDataList = widget.getTimesData(widget.product);

    _controllers = LinkedScrollControllerGroup();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    _scrollController3 = _controllers.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    double rowHeight = 40.0;
    double headerHeight = 30.0;

    double maxDialogHeight = MediaQuery.of(context).size.height * 0.7;
    double listHeight = timesDataList.length * rowHeight;
    double contentHeight =
        listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

    double dialogWidth = isPhonePortrait(context)
        ? fullScreenWidth(context)
        : widget.isDash
            ? fullScreenWidth(context) * 0.9
            : fullScreenWidth(context) * 0.75;

    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
        ),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header bar
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
                    Expanded(
                      child: MyRegularText(
                        label: widget.product is TopSellingProductA
                            ? '${(widget.product as TopSellingProductA).productName} - ${(widget.product as TopSellingProductA).variationName}'
                            : widget.product is FrequantliyProductList
                                ? (widget.product as FrequantliyProductList)
                                    .productName
                                : '',
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

              // 🔹 Column headers
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController1,
                child: Container(
                  color: const Color.fromARGB(255, 247, 247, 247),
                  height: headerHeight,
                  width: isPhonePortrait(context)
                      ? fullScreenWidth(context) * 2
                      : fullScreenWidth(context) * 0.9,
                  child: Row(
                    children: [
                      if (widget.isDash) ...[
                        SizedBox(width: 50, child: buildHeader('  Sl.No.')),
                        Expanded(flex: 2, child: buildHeader('Customer')),
                        Expanded(child: buildHeader('Order Id')),
                        Expanded(child: buildHeader('Date')),
                        Expanded(child: buildHeader('Price')),
                        Expanded(child: buildHeader('Quantity')),
                        Expanded(child: buildHeader('Tax')),
                        Expanded(child: buildHeader('Amount')),
                      ],
                      if (!widget.isDash) ...[
                        SizedBox(width: 50, child: buildHeader('  Sl.No.')),
                        Expanded(child: buildHeader('Order Id')),
                        Expanded(child: buildHeader('Date')),
                        Expanded(child: buildHeader('Price')),
                        Expanded(child: buildHeader('Quantity')),
                        Expanded(child: buildHeader('Tax')),
                        Expanded(child: buildHeader('Amount')),
                      ],
                    ],
                  ),
                ),
              ),

              // 🔹 Content list
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController2,
                  child: SizedBox(
                    height: contentHeight,
                    width: isPhonePortrait(context)
                        ? fullScreenWidth(context) * 2
                        : fullScreenWidth(context) * 0.9,
                    child: ScrollbarTheme(
                      data: const ScrollbarThemeData(
                        thickness: WidgetStatePropertyAll(5),
                        thumbColor: WidgetStatePropertyAll(Colors.blue),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: ListView.builder(
                          primary: false,
                          itemCount:
                              timesDataList.isEmpty ? 1 : timesDataList.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (timesDataList.isEmpty) {
                              return buildEmptyRow();
                            } else {
                              var timesData = timesDataList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                height: rowHeight,
                                child: Row(
                                  children: [
                                    if (widget.isDash) ...[
                                      SizedBox(
                                          width: 50,
                                          child:
                                              buildRowData("  ${index + 1}.")),
                                      Expanded(
                                          flex: 2,
                                          child: buildRowData(
                                              widget.getCustomer(timesData))),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () async {
                                          bool isOnline =
                                              await ConnectivityService()
                                                  .isOnline();
                                          if (isOnline) {
                                            showDetailedOrderInvoiceDialog(
                                                context,
                                                widget.getOrderId(timesData),
                                                false);
                                          } else {
                                            showCustomToastDisplay(
                                                context,
                                                "You are Offline!",
                                                red,
                                                Icons.warning);
                                          }
                                        },
                                        child: buildRowData(
                                            widget.getOrderId(timesData),
                                            textColor: primaryColor),
                                      )),
                                      Expanded(
                                          child: buildRowData(widget
                                              .getPurchasedAt(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getPrice(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getQuantity(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getTax(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getTotalPrice(timesData))),
                                    ],
                                    if (!widget.isDash) ...[
                                      SizedBox(
                                          width: 50,
                                          child:
                                              buildRowData("  ${index + 1}.")),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          showDetailedOrderInvoiceDialog(
                                              context,
                                              widget.getOrderId(timesData),
                                              false);
                                        },
                                        child: buildRowData(
                                            widget.getOrderId(timesData),
                                            textColor: primaryColor),
                                      )),
                                      Expanded(
                                          child: buildRowData(widget
                                              .getPurchasedAt(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getPrice(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getQuantity(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getTax(timesData))),
                                      Expanded(
                                          child: buildRowData(
                                              widget.getTotalPrice(timesData))),
                                    ],
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔹 Footer totals
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController3,
                child: Container(
                  width: isPhonePortrait(context)
                      ? fullScreenWidth(context) * 2
                      : fullScreenWidth(context) * 0.9,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: rowHeight,
                  child: SizedBox(
                    width: isPhonePortrait(context)
                        ? fullScreenWidth(context) * 2
                        : double.maxFinite,
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Expanded(
                          flex: widget.isDash ? 5 : 3,
                          child: CustomText(
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                            content: 'Total',
                            fontSize: 11,
                            maxLine: 1,
                          ),
                        ),
                        Expanded(
                          child: CustomText(
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                            content: () {
                              int total = timesDataList.fold(0, (sum, item) {
                                String priceStr = widget
                                    .getQuantity(item)
                                    .replaceAll(RegExp(r'[^0-9.]'), '');
                                int price = int.tryParse(priceStr) ?? 0;
                                return sum + price;
                              });
                              return total.toString();
                            }(),
                            fontSize: 11,
                            maxLine: 1,
                          ),
                        ),
                        Expanded(
                          child: CustomText(
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                            content: () {
                              double total =
                                  timesDataList.fold(0.0, (sum, item) {
                                String priceStr = widget
                                    .getTax(item)
                                    .replaceAll(RegExp(r'[^0-9.]'), '');
                                double price = double.tryParse(priceStr) ?? 0.0;
                                return sum + price;
                              });
                              return formatAmount(total);
                            }(),
                            fontSize: 11,
                            maxLine: 1,
                          ),
                        ),
                        Expanded(
                          child: CustomText(
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                            content: () {
                              double total =
                                  timesDataList.fold(0.0, (sum, item) {
                                String priceStr = widget
                                    .getTotalPrice(item)
                                    .replaceAll(RegExp(r'[^0-9.]'), '');
                                double price = double.tryParse(priceStr) ?? 0.0;
                                return sum + price;
                              });
                              return formatAmount(total);
                            }(),
                            fontSize: 11,
                            maxLine: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildHeader(String title) {
  return Center(
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontFamily: 'Poppins_Regular',
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
