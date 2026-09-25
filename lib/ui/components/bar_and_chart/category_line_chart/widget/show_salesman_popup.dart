<<<<<<< HEAD
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
=======
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

<<<<<<< HEAD
Widget _dialogHeader(BuildContext context, String title, {int? count}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, Color(0xFF2D3748)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.category_rounded, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins_Regular',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Text(
                    '$count ${'Products'.tr}',
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ],
    ),
  );
}

=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
<<<<<<< HEAD
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dialogHeader(context, category),
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No data found',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Poppins_Regular',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
=======
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
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                  ),
                );
              } else if (snapshot.hasData) {
                final categories = snapshot.data!.data;
<<<<<<< HEAD
                final totalSum = categories.fold<double>(
                  0.0,
                  (sum, s) => sum + (num.parse(s.totalPrice)),
                );
                final verticalScrollController = ScrollController();
                final horizontalScrollController = ScrollController();

                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isPhonePortrait(context) ? fullScreenWidth(context) : 650,
                      maxHeight: fullScreenHeight(context) * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dialogHeader(context, category, count: categories.length),
                          Flexible(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Scrollbar(
                                  controller: verticalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: const Radius.circular(8),
                                  thickness: 6,
                                  notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                                  child: Scrollbar(
                                    controller: horizontalScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    radius: const Radius.circular(8),
                                    thickness: 6,
                                    notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                                    child: SingleChildScrollView(
                                      controller: verticalScrollController,
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        controller: horizontalScrollController,
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                            headingTextStyle: const TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: 0.3,
                                            ),
                                            dataRowMinHeight: 52,
                                            dataRowMaxHeight: 64,
                                            columnSpacing: 20,
                                            horizontalMargin: 16,
                                            columns: [
                                              DataColumn(label: Text('Product'.tr)),
                                              DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Invoice'.tr))),
                                              DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Quantity'.tr))),
                                              DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Price'.tr))),
                                            ],
                                            rows: categories.map((s) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(
                                                      '${s.productName} ${s.variationName}',
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: primaryColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                        ),
                                                        child: Text(
                                                          s.orderId,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                            fontFamily: 'Poppins_Regular',
                                                            color: primaryColor,
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        '${s.quantity}',
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins_Regular',
                                                          fontSize: 12.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        formatAmount(s.totalPrice),
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins_Regular',
                                                          fontSize: 12.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'Showing'.tr} ${categories.length} ${'Products'.tr}',
                                  style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${'Total'.tr}: ',
                                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                                      ),
                                      Text(
                                        formatAmount(totalSum),
                                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
=======

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
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                      ),
                    ),
                  ),
                );
              } else {
<<<<<<< HEAD
                return Center(child: Text('No data available'.tr));
=======
                return const Center(child: NodataWidget());
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
              }
            },
          );
        },
      );
    },
  );
}
