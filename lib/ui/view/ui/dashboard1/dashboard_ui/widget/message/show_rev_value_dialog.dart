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
              var displayData = title == "Order"
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

                      // Table Header
                      Container(
                        color: const Color.fromARGB(255, 247, 247, 247),
                        height: headerHeight,
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Date',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Invoice',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Status',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List Content
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: contentHeight,
                          ),
                          child: ListView.builder(
                            itemCount: displayData?.isEmpty ?? true
                                ? 1
                                : displayData?.length ?? 0,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (displayData?.isEmpty ?? true) {
                                return buildEmptyRow();
                              } else {
                                
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
                                            title == "Order"
                                                ? categoryData
                                                    .orderRevenueData![index]
                                                    .orderCreatAt
                                                : categoryData
                                                    .bookingRevenueData![index]
                                                    .orderCreatAt,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: buildRowData(
                                          (title == "Order"
                                                  ? categoryData
                                                      .orderRevenueData![index]
                                                      .orderId
                                                  : categoryData
                                                      .bookingRevenueData![
                                                          index]
                                                      .orderId)
                                              .toString(),
                                        ),
                                      ),
                                      Expanded(
                                        child: buildRowData(
                                          getStatusName(
                                            (title == "Order"
                                                    ? categoryData
                                                        .orderRevenueData![
                                                            index]
                                                        .orderStatus
                                                    : categoryData
                                                        .bookingRevenueData![
                                                            index]
                                                        .orderStatus)!
                                                .toInt(),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: buildRowData(
                                          formatAmount(
                                            title == "Order"
                                                ? categoryData
                                                    .orderRevenueData![index]
                                                    .orderTotal
                                                : categoryData
                                                    .bookingRevenueData![index]
                                                    .orderTotal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // Footer
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    title == "Order"
                                        ? formatAmount(categoryData
                                            .orderRevenueData!
                                            .map((e) => e.orderTotal ?? 0.0)
                                            .fold(0.0, (a, b) => a + b))
                                        : categoryData.bookingRevenueData !=
                                                    null &&
                                                categoryData.bookingRevenueData!
                                                    .isNotEmpty
                                            ? formatAmount(categoryData
                                                .bookingRevenueData!
                                                .map((e) => e.orderTotal ?? 0.0)
                                                .fold(0.0, (a, b) => a + b))
                                            : formatAmount(0.0),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
    },
  );
}

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
                          itemCount:
                              orderDetails.isEmpty ? 1 : orderDetails.length,
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
                                        child: buildRowData(getStatusName(
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
                          const DialogTableHeaderText(
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
