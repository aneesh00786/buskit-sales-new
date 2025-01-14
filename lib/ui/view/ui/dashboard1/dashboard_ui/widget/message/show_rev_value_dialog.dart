import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/build_row_content_data.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

void showValueDialog(
    BuildContext context, Revenuee categoryData, String title) {
  showDialog(
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
            var displayData = title == "Revenue"
                ? categoryData.orderRevenueData
                : categoryData.bookingRevenueData;

            double listHeight = (displayData?.length ?? 0) * rowHeight;
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
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: const Row(
                        children: [
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount: displayData?.isEmpty ?? true
                              ? 1
                              : displayData?.length ?? 0,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (displayData?.isEmpty ?? true) {
                              return buildEmptyRow();
                            } else {
                              var item = displayData![index];
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
                                            getFormattedOrderCreatAt(
                                                title == "Revenue"
                                                    ? categoryData
                                                        .orderRevenueData![
                                                            index]
                                                        .orderCreatAt
                                                    : categoryData
                                                        .bookingRevenueData![
                                                            index]
                                                        .orderCreatAt
                                                // item.orderCreatAt,
                                                ))),
                                    Expanded(
                                        child: buildRowData((title == "Revenue"
                                                    ? categoryData
                                                        .orderRevenueData![
                                                            index]
                                                        .orderId
                                                    : categoryData
                                                        .bookingRevenueData![
                                                            index]
                                                        .orderId)
                                                .toString()
                                            // item.orderId ?? 'N/A'
                                            )),
                                    Expanded(
                                        child: buildRowData(getStatusName(
                                            (title == "Revenue"
                                                    ? categoryData
                                                        .orderRevenueData![
                                                            index]
                                                        .orderStatus
                                                    : categoryData
                                                        .bookingRevenueData![
                                                            index]
                                                        .orderStatus)!
                                                .toInt()
                                            // item.orderStatus!.toInt()
                                            ))),
                                    Expanded(
                                        child: buildRowData(formatAmount(
                                            title == "Revenue"
                                                ? categoryData
                                                    .orderRevenueData![index]
                                                    .orderTotal
                                                : categoryData
                                                    .bookingRevenueData![index]
                                                    .total
                                            // item.orderTotal
                                            ))),
                                  ],
                                ),
                              );
                            }
                          },
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
                          const DialogTableHeaderText(
                            text: 'Total',
                            fontSize: 13,
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          DialogTableHeaderText(
                            text: formatAmount(categoryData.orderRevenueData!
                                .map((e) => e.orderTotal ?? 0.0)
                                .reduce((a, b) => a + b)),
                            fontSize: 13,
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

// void showValueDialog(
//     BuildContext context, Revenuee categoryData, String title) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//             double dialogWidth = MediaQuery.of(context).size.width * 0.5;
//             double maxDialogHeight = constraints.maxHeight * 0.7;
//             double rowHeight = 40.0;
//             double headerHeight = 30.0;
//             double listHeight =
//                 (categoryData.orderRevenueData?.length ?? 0) * rowHeight;
//             double contentHeight =
//                 listHeight > maxDialogHeight ? maxDialogHeight : listHeight;
//             return ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxHeight: maxDialogHeight,
//               ),
//               child: SizedBox(
//                 width: dialogWidth,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: const BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           topRight: Radius.circular(10),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               title,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontFamily: 'Poppins_Regular',
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           dialogCloseButton1(context, red),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       color: const Color.fromARGB(255, 247, 247, 247),
//                       height: headerHeight,
//                       child: const Row(
//                         children: [
//                           Expanded(
//                               child: DialogTableHeaderText(
//                             text: 'Date',
//                             fontSize: 13,
//                           )),
//                           Expanded(
//                               child: DialogTableHeaderText(
//                             text: 'Invoice',
//                             fontSize: 13,
//                           )),
//                           Expanded(
//                               child: DialogTableHeaderText(
//                             text: 'Status',
//                             fontSize: 13,
//                           )),
//                           Expanded(
//                               child: DialogTableHeaderText(
//                             text: 'Amount',
//                             fontSize: 13,
//                           )),
//                         ],
//                       ),
//                     ),
//                     Flexible(
//                       child: SizedBox(
//                         height: contentHeight,
//                         child: ListView.builder(
//                           itemCount: categoryData.orderRevenueData?.isEmpty ?? true
//                               ? 1
//                               : categoryData.orderRevenueData?.length ?? 0,
//                           physics: const ClampingScrollPhysics(),
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             if (categoryData.orderRevenueData?.isEmpty ?? true) {
//                               return buildEmptyRow();
//                             } else {
//                               var item = categoryData.orderRevenueData![index];
//                               return Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(
//                                       color: Colors.grey.shade300,
//                                       width: 0.5,
//                                     ),
//                                   ),
//                                 ),
//                                 height: rowHeight,
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                         child: buildRowData(
//                                             getFormattedOrderCreatAt(
//                                                 item.orderCreatAt))),
//                                     Expanded(
//                                         child: buildRowData(
//                                             item.orderId ?? 'N/A')),
//                                     Expanded(
//                                         child: buildRowData(
//                                             getStatusName(
//                                                 item.orderStatus!.toInt()))),
//                                     Expanded(
//                                         child: buildRowData(
//                                             formatAmount(item.orderTotal))),
//                                   ],
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                     Container(
//                       decoration: const BoxDecoration(
//                         border: Border(
//                           top: BorderSide(
//                             color: Colors.grey,
//                             width: 0.5,
//                           ),
//                         ),
//                       ),
//                       height: rowHeight,
//                       child: Row(
//                         children: [
//                           DialogTableHeaderText(
//                             text: 'Total',
//                             fontSize: 13,
//                           ),
//                           const Expanded(child: SizedBox.shrink()),
//                           const Expanded(child: SizedBox.shrink()),
//                           DialogTableHeaderText(
//                             text: formatAmount(categoryData
//                                 .orderRevenueData!
//                                 .map((e) => e.orderTotal ?? 0.0)
//                                 .reduce((a, b) => a + b)),
//                             fontSize: 13,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     },
//   );
// }

void showValueDialogCusDash(
    BuildContext context, List<dynamic> orderDetails, String title) {
  showDialog(
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
            double listHeight = orderDetails.length * rowHeight;
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
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),
                    // Header Section
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: const Row(
                        children: [
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    // Data List Section
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount: orderDetails.isEmpty ? 1 : orderDetails.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (orderDetails.isEmpty) {
                              return buildEmptyRow();
                            } else {
                              var item = orderDetails[index];
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
                                            getFormattedOrderCreatAt(
                                                item.orderCreatAt))),
                                    Expanded(
                                        child: buildRowData(
                                            item.orderId ?? 'N/A')),
                                    Expanded(
                                        child: buildRowData(
                                            getStatusName(
                                                item.orderStatus ?? 0))),
                                    Expanded(
                                        child: buildRowData(
                                            formatAmount(item.orderTotal))),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Footer Section
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
                          DialogTableHeaderText(
                            text: 'Total',
                            fontSize: 13,
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          DialogTableHeaderText(
                            text: formatAmount(orderDetails
                                .map((e) => e.orderTotal ?? 0.0)
                                .reduce((a, b) => a + b)),
                            fontSize: 13,
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


