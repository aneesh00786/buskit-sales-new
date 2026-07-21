import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget noDataFoundWidget(String type) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double fontSize = 14.0;
      double padding = availableWidth / 100;
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: DataTable(
                      dataRowHeight: fontSize * 5.5,
                      headingRowHeight: 45,
                      headingRowColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => primaryColor,
                      ),
                      columnSpacing: padding * 1.5,
                      headingTextStyle: const TextStyle(
                          fontSize: 14,
                          color: white,
                          fontWeight: FontWeight.w700),
                      columns: [
                        const DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              'Customer List',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              '$type No.',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        const DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              'Created',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        const DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              'Created By',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        const DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              'Amount',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        const DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              'Status',
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
                      rows:  [
                        DataRow(cells: [
                          DataCell(Text('Record Not Found'.tr)),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ])
                      ]),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                height: 45,
                width: 45,
                child: Center(child: dialogCloseButton1(context, red)),
              ),
            ),
          ],
        ),
      );
    },
  );
}
