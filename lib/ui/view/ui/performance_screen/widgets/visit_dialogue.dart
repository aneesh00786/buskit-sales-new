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
    double maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
    double headerHeight = 60;
    double rowHeight = 60;
    double contentHeight = headerHeight + (rows.length * rowHeight);
    double containerHeight = contentHeight.clamp(0, maxDialogHeight);

    return Stack(
      children: [
        Container(
          width: availableWidth,
          height: containerHeight,
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: primaryColor,
                ),
                height: headerHeight,
                child: Row(
                  children: headers.map((label) {
                    return Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Rows
              Flexible(
                child: ListView.builder(
                  itemCount: rows.length,
                  shrinkWrap: true,
                  physics: contentHeight > maxDialogHeight
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: rows[index].asMap().entries.map((entry) {
                          int columnIndex = entry.key;
                          String cellValue = entry.value;
                          TextStyle cellStyle;

                          // Assign specific styles based on column index
                          switch (columnIndex) {
                            case 0:
                              cellStyle = TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              );
                              break;
                            case 3:
                              cellStyle = TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              );
                              break;
                            case 5:
                              cellStyle = TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              );
                              break;
                            default:
                              cellStyle = TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              );
                          }

                          return Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                cellValue,
                                style: cellStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Close Button
        Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            height: 30,
            width: 30,
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


