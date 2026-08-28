import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class StaffOrdersTableRow extends StatelessWidget {
  const StaffOrdersTableRow({
    super.key,
    required ScrollController scrollController2,
    required this.flexWidth,
    required this.fontSize,
  }) : _scrollController2 = scrollController2;

  final ScrollController _scrollController2;
  final double flexWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController2,
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
                  headingRowColor: const WidgetStatePropertyAll(Color(0xFFF1F5F9)),
                  columnSpacing: 10,
                  columns: [
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.5,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child: Center(
                          child: CustomText(
                            content: 'Customer List',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Order No.',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Created',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Amount',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Invoice',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Payment Status',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                        child: Center(
                          child: CustomText(
                            content: 'Status',
                            color: const Color(0xFF0F172A),
                            fontSize: fontSize + 2,
                            fontFamily: commonFont,
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
                    DataRow(
                      cells: [
                        DataCell(
                          SizedBox(width: flexWidth * 1.5),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 0.9),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1.35),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1.35),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 0.9),
                        ),
                        DataCell(
                          SizedBox(width: flexWidth * 1.2),
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
