import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/visit_data_modfel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/datacolumn_and_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildVisitsDialogContent(
    VisitData? data, StaffController staffController) {
  if (data == null) return const Text('No Check-in/out data available.');

  // Prepare headers for the table
  List<String> headers = [
    "Title",
    "Event ID",
    "Type",
    "Customer ID",
    "Created At",
    "Status",
  ];

  // Prepare rows based on the visit data
  List<List<String>> rows = (staffController.visitData.value == null ||
          staffController.visitData.value!.data == null ||
          staffController.visitData.value!.data!.isEmpty)
      ? [
          ["Record Not Found", "", "", "", "", ""]
        ]
      : staffController.visitData.value!.data!.map((visit) {
          return [
            visit.title ?? 'N/A',
            visit.eventId ?? 'N/A',
            visit.type.toString() ?? 'N/A',
            visit.customerId ?? 'N/A',
            formatNullableDate(visit.checkIn),
            visit.status.toString() ?? 'N/A',
          ];
        }).toList();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      return Stack(
        children: [
          Container(
            width: availableWidth,
            height: 600,
            child: ScrollableTableView(
              headerBackgroundColor: primaryColor,
              headerHeight: 50,
              headers: headers.map((label) {
                return TableViewHeader(
                  label: label,
                  width: 150,
                );
              }).toList(),
              rows: rows.map((record) {
                return TableViewRow(
                  height: 60,
                  cells: record.map((value) {
                    return TableViewCell(
                      child: Text(value),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          // Close Button
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
      );
    },
  );
}

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}
