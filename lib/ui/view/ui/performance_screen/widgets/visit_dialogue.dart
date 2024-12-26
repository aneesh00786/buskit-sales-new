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
  if (data == null) return const Text('No Visit data available.');

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
      TextStyle titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold,);
      TextStyle eventIdStyle = TextStyle(fontSize: 14, );
      TextStyle typeStyle = TextStyle(fontSize: 14,);
      TextStyle customerIdStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueGrey);
      TextStyle dateStyle = TextStyle(fontSize: 14,);
      TextStyle statusStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold,);

      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
              color: primaryColor,
            ),
            height: 60,
          ),
          Container(
            width: availableWidth,
            height: 600,
            child: ScrollableTableView(
              headerBackgroundColor: primaryColor,
              headerHeight: 50,
              headers: headers.map((label) {
                return TableViewHeader(
                  alignment: Alignment.center,
                  label: label,
                  width: 150,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              rows: rows.map((record) {
                return TableViewRow(
                  height: 60,
                  cells: record.asMap().entries.map((entry) {
                    int index = entry.key;
                    String value = entry.value;
                    TextStyle cellStyle;
                    switch (index) {
                      case 0:
                        cellStyle = titleStyle;
                        break;
                      case 1:
                        cellStyle = eventIdStyle;
                        break;
                      case 2:
                        cellStyle = typeStyle;
                        break;
                      case 3:
                        cellStyle = customerIdStyle;
                        break;
                      case 4:
                        cellStyle = dateStyle;
                        break;
                      case 5:
                        cellStyle = statusStyle;
                        break;
                      default:
                        cellStyle = TextStyle(fontSize: 14, color: Colors.black87);
                    }

                    return TableViewCell(
                      child: Text(
                        value,
                        style: cellStyle,
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
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
      );
    },
  );
}

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}


