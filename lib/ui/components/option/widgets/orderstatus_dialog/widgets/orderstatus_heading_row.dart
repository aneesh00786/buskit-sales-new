import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  headingRowHeight: fullScreenWidth(context) > 740 ? 45 : 75,
                  headingRowColor:
                      const WidgetStatePropertyAll(Color(0xFFF1F5F9)),
                  columnSpacing: 10,
                  headingTextStyle: TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: fontSize + 1,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700),
                  columns: [
                    DataColumn(
                        label: SizedBox(
                      width: flexWidth * 1.5,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: fullScreenWidth(context) > 740 ? 0 : 30),
                        child:  Center(
                          child: Text(
                            'Customer List'.tr,
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
                        child:  Center(
                          child: Text(
                            'Order No.'.tr,
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
                        child:  Center(
                          child: Text(
                            'Created'.tr,
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
                        child:  Center(
                          child: Text(
                            'Created By'.tr,
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
                        child:  Center(
                          child: Text(
                            'Amount'.tr,
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
                        child:  Center(
                          child: Text(
                            'Invoice'.tr,
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
                        child:  Center(
                          child: Text(
                            'Payment Status'.tr,
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
                        child:  Center(
                          child: Text(
                            'Status'.tr,
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
