import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showSalesmanPopup(
    {required dynamic cid,
    required String category,
    required BuildContext context,
    required String customerId,
    required dynamic year}) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          provider.fetchChartCategoryPerformance(customerId, cid, year);

          return FutureBuilder<ProductResponse>(
            future: provider.productResponse,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitFadingCube(
                    color: primaryColor,
                    size: 20.0,
                  ),
                );
              } else if (snapshot.hasError ||
                  snapshot.data?.data.isEmpty == true) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.zero,
                  titlePadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 45,
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
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            dialogCloseButton1(context, red),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No data found',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                final categories = snapshot.data!.data;

                return AlertDialog(
                  insetPadding:
                      isPhonePortrait(context) || isPhoneLandscape(context)
                          ? EdgeInsets.zero
                          : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Container(
                    height: 45,
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
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins_Regular',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        dialogCloseButton1(context, red),
                      ],
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  titlePadding: EdgeInsets.zero,
                  content: ScrollbarTheme(
                    data: const ScrollbarThemeData(
                      thickness: WidgetStatePropertyAll(5),
                      thumbColor: WidgetStatePropertyAll(Colors.blue),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  // ignore: deprecated_member_use
                                  dataRowHeight: 50,
                                  headingRowHeight: 40,
                                  columnSpacing: 30,
                                  headingRowColor: WidgetStatePropertyAll(
                                      Colors.grey.shade300),
                                  border: TableBorder.all(color: Colors.grey),
                                  columns:  [
                                    DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Product'.tr,
                                        fontSize: 13,
                                      ),
                                    ),
                                    DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Invoice'.tr,
                                        fontSize: 13,
                                      ),
                                    ),
                                    DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Quantity'.tr,
                                        fontSize: 13,
                                      ),
                                    ),
                                    DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Price'.tr,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    ...categories.map((s) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Center(
                                            child: Text(
                                              '${s.productName} ${s.variationName}',
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              s.orderId,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              '${s.quantity}',
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              formatAmount(s.totalPrice),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          )),
                                        ],
                                      );
                                    }),
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 50),
                                            child:  Text(
                                              'Total'.tr,
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const DataCell(SizedBox.shrink()),
                                        const DataCell(SizedBox.shrink()),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              formatAmount(
                                                  categories.fold<double>(
                                                0.0,
                                                (sum, s) =>
                                                    sum +
                                                    (num.parse(s.totalPrice)),
                                              )),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: NodataWidget());
              }
            },
          );
        },
      );
    },
  );
}
