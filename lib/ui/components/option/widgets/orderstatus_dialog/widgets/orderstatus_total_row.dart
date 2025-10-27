import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

class OrderstatusTotalRow extends StatelessWidget {
  const OrderstatusTotalRow({
    super.key,
    required this.fontSize,
    required this.flexWidth,
    required this.filteredOrders,
    required this.scrollController3,
  });

  final double fontSize;
  final double flexWidth;
  final List<OrdersDash> filteredOrders;
  final ScrollController scrollController3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController3,
      child: SizedBox(
        width: isPhonePortrait(context)
            ? fullScreenWidth(context) * 2.3
            : fullScreenWidth(context) > 640
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
                  headingTextStyle: TextStyle(
                      fontSize: fontSize + 2,
                      color: white,
                      fontWeight: FontWeight.w700),
                  columns: [
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 4.5,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total',
                          maxLines: 2,
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(

                      width: flexWidth * 4.1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatAmount(filteredOrders.fold<double>(
                            0.0,
                            (sum, order) => sum + (order.orderTotal ?? 0.0),
                          )),
                          maxLines: 2,
                        ),
                      ),
                    )),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(SizedBox(width: flexWidth * 4.5)),
                        DataCell(SizedBox(width: flexWidth * 1)),
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
