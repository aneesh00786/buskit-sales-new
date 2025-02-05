import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
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
            double dialogWidth = MediaQuery.of(context).size.width * 0.8;
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
                          SizedBox(width: 50, child: buildHeader('  Sl.No.')),
                          if (isDash) ...[
                            Expanded(child: buildHeader('Customer')),
                          ],
                          Expanded(child: buildHeader('Price')),
                          Expanded(child: buildHeader('Quantity')),
                          if (isDash) ...[
                            Expanded(child: buildHeader('Tax')),
                          ],
                          Expanded(child: buildHeader('Amount')),
                          Expanded(child: buildHeader('Date')),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
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
                                    SizedBox(
                                        width: 50,
                                        child: buildRowData("  ${index + 1}.")),
                                    if (isDash) ...[
                                      Expanded(
                                          child: buildRowData(
                                              getCustomer(timesData))),
                                    ],
                                    Expanded(
                                        child:
                                            buildRowData(getPrice(timesData))),
                                    Expanded(
                                        child: buildRowData(
                                            getQuantity(timesData))),
                                    if (isDash) ...[
                                      Expanded(
                                          child:
                                              buildRowData(getTax(timesData))),
                                    ],
                                    Expanded(
                                        child: buildRowData(
                                            getTotalPrice(timesData))),
                                    Expanded(
                                        child: buildRowData(
                                            getPurchasedAt(timesData))),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
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
