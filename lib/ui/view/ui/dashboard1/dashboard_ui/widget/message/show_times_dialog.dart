import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/build_row_content_data.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<dynamic> showDashTimesDialogue(
  BuildContext context,
  TopSellingProductA product,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.5;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 30.0;
            double listHeight = (product.getTimesData?.length ?? 0) * rowHeight;
            double contentHeight =
                listHeight > maxDialogHeight ? maxDialogHeight : listHeight;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: Container(
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
                              label:
                                  '${product.productName} - ${product.variationName}',
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
                          Expanded(child: buildHeader('Price')),
                          Expanded(child: buildHeader('Quantity')),
                          Expanded(child: buildHeader('Amount')),
                          Expanded(child: buildHeader('Purchased At')),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount: product.getTimesData!.isEmpty
                              ? 1
                              : product.getTimesData!.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (product.getTimesData!.isEmpty) {
                              return buildEmptyRow();
                            } else {
                              var timesData = product.getTimesData![index];
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
                                    Expanded(
                                        child: buildRowData(
                                            formatAmount(timesData.price))),
                                    Expanded(
                                        child: buildRowData(
                                            timesData.quantity.toString())),
                                    Expanded(
                                        child: buildRowData(timesData
                                                    .totalPrice !=
                                                null
                                            ? formatAmount(timesData.totalPrice)
                                            : 'N/A')),
                                    Expanded(
                                        child: buildRowData(
                                            DateFormat('dd-MM-yyyy')
                                                .format(timesData.createdAt!))),
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
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}


