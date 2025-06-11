import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/build_row_content_data.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

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
  List<dynamic> timesDataList = getTimesData(product);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = isDash
                ? fullScreenWidth(context) * 0.9
                : fullScreenWidth(context) * 0.75;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 30.0;
            double listHeight = timesDataList.length * rowHeight;
            double contentHeight =
                listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              label: product is TopSellingProductA
                                  ? '${product.productName} - ${product.variationName}'
                                  : product is FrequantliyProductList
                                      ? product.productName
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
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: Row(
                        children: [
                          if (isDash) ...[
                            SizedBox(width: 50, child: buildHeader('  Sl.No.')),
                            Expanded(flex: 2, child: buildHeader('Customer')),
                            Expanded(child: buildHeader('Order Id')),
                            Expanded(child: buildHeader('Date')),
                            Expanded(child: buildHeader('Price')),
                            Expanded(child: buildHeader('Quantity')),
                            Expanded(child: buildHeader('Tax')),
                            Expanded(child: buildHeader('Amount')),
                          ],
                          if (!isDash) ...[
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
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
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
                                        if (isDash) ...[
                                          SizedBox(
                                              width: 50,
                                              child:
                                                  buildRowData("  ${index + 1}.")),
                                          Expanded(
                                              flex: 2,
                                              child: buildRowData(
                                                  getCustomer(timesData))),
                                          Expanded(
                                              child: InkWell(
                                            onTap: () {
                                              showDetailedOrderInvoiceDialog(
                                                  context,
                                                  getOrderId(timesData),
                                                  false);
                                            },
                                            child: buildRowData(
                                                getOrderId(timesData),
                                                textColor: primaryColor),
                                          )),
                                          Expanded(
                                              child: buildRowData(
                                                  getPurchasedAt(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getPrice(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getQuantity(timesData))),
                                          Expanded(
                                              child:
                                                  buildRowData(getTax(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getTotalPrice(timesData))),
                                        ],
                                        if (!isDash) ...[
                                          SizedBox(
                                              width: 50,
                                              child:
                                                  buildRowData("  ${index + 1}.")),
                                          Expanded(
                                              child: InkWell(
                                            onTap: () {
                                              showDetailedOrderInvoiceDialog(
                                                  context,
                                                  getOrderId(timesData),
                                                  false);
                                            },
                                            child: buildRowData(
                                                getOrderId(timesData),
                                                textColor: primaryColor),
                                          )),
                                          Expanded(
                                              child: buildRowData(
                                                  getPurchasedAt(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getPrice(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getQuantity(timesData))),
                                          Expanded(
                                              child:
                                                  buildRowData(getTax(timesData))),
                                          Expanded(
                                              child: buildRowData(
                                                  getTotalPrice(timesData))),
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
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      height: rowHeight,
                      child: Row(
                        children: [
                          const SizedBox(width: 50),
                          Expanded(
                            flex: isDash ? 5 : 3,
                            child: CustomText(
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                              content: 'Total',
                              fontSize: 11,
                              maxLine: 1,
                            ),
                          ),
                          // Expanded(
                          //   child: CustomText(
                          //     fontWeight: FontWeight.w600,
                          //     textAlign: TextAlign.center,
                          //     content: () {
                          //       double total =
                          //           timesDataList.fold(0.0, (sum, item) {
                          //         String priceStr = getPrice(item)
                          //             .replaceAll(RegExp(r'[^0-9.]'), '');
                          //         double price =
                          //             double.tryParse(priceStr) ?? 0.0;
                          //         return sum + price;
                          //       });
                          //       return formatAmount(total);
                          //     }(),
                          //     fontSize: 11,
                          //     maxLine: 1,
                          //   ),
                          // ),
                          Expanded(
                            child: CustomText(
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                              content: () {
                                int total = timesDataList.fold(0, (sum, item) {
                                  String priceStr = getQuantity(item)
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
                                  String priceStr = getTax(item)
                                      .replaceAll(RegExp(r'[^0-9.]'), '');
                                  double price =
                                      double.tryParse(priceStr) ?? 0.0;
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
                                  String priceStr = getTotalPrice(item)
                                      .replaceAll(RegExp(r'[^0-9.]'),
                                          '');
                                  double price =
                                      double.tryParse(priceStr) ?? 0.0;
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
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
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
