import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/data_row_column.dart';
import 'package:flutter/material.dart';

class OrderStatusHeadingRow extends StatelessWidget {
  const OrderStatusHeadingRow({
    super.key,
    required this.fontSize,
    required this.flexWidth,
    required this.scrollController2,
  });

  final double fontSize;
  final double flexWidth;
  final ScrollController scrollController2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController2,
      child: SizedBox(
        width: fullScreenWidth(context) > 640
            ? fullScreenWidth(context) * 1
            : fullScreenWidth(context) * 1.1,
        child: Row(
          children: [
            Expanded(
              child: DataTable(
                  dataRowHeight: 0,
                  headingRowHeight: fullScreenWidth(context) > 740 ? 45 : 75,
                  headingRowColor: const WidgetStatePropertyAll(primaryColor),
                  columnSpacing: 10,
                  headingTextStyle: TextStyle(
                      fontSize: fontSize + 1,
                      color: white,
                      fontWeight: FontWeight.w700),
                  columns: [
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.5,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Customer List',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 0.9,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Order No.',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Created',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Created By',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Amount',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 0.9,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Invoice',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.1,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Payment Status',
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.2,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: const Center(
                          child: Text(
                            'Status',
                            maxLines: 2,
                          ),
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
                    dataRowOrderstatus(flexWidth),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}