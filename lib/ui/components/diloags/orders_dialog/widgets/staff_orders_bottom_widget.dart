// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';

class StaffOrdersBottomWidget extends StatelessWidget {
  const StaffOrdersBottomWidget({
    super.key,
    required ScrollController scrollController3,
    required this.flexWidth,
    required this.fontSize,
    required this.filteredOrders,
  }) : _scrollController3 = scrollController3;

  final ScrollController _scrollController3;
  final double flexWidth;
  final double fontSize;
  final List<OrderData> filteredOrders;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController3,
      child: SizedBox(
        width: fullScreenWidth(context) > 640
            ? fullScreenWidth(context) * 1
            : fullScreenWidth(context) * 1.1,
        child: Row(
          children: [
            Expanded(
              child: DataTable(
                  dataRowHeight: 0,
                  headingRowHeight: 30,
                  headingRowColor: const WidgetStatePropertyAll(primaryColor),
                  columnSpacing: 10,
                  columns: [
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.5,
                      child: const Center(
                        child: Text(
                          '',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 0.9,
                      child: const Center(
                        child: Text(
                          '',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1,
                      child: Center(
                        child: CustomText(
                          content: 'Total',
                          color: white,
                          fontSize: fontSize + 2,
                          fontFamily: commonFont,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1,
                      child: Center(
                        child: CustomText(
                          content: formatAmount(filteredOrders.fold<double>(
                            0.0,
                            (sum, order) => sum + (order.orderTotal ?? 0.0),
                          )),
                          color: white,
                          fontSize: fontSize + 2,
                          fontFamily: commonFont,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 0.9,
                      child: const Center(
                        child: Text(
                          '',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.2,
                      child: const Center(
                        child: Text(
                          '',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.2,
                      child: const Center(
                        child: Text(
                          '',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    const DataColumn(
                        label: Expanded(
                      child: Center(
                        child: Text(
                          '',
                        ),
                      ),
                    )),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          SizedBox(width: flexWidth * 1.5),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 0.9),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 0.9),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1.1),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1.1),
                        ),
                        const DataCell(Text('')),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
