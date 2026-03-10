import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/visit_data_modfel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildVisitsDialogContent(
    VisitData? data, StaffController staffController) {
  if (data == null) return const Text('No Visit data available.');
  List<String> headers = [
    "Date",
    "Customer",
    "Status",
  ];

  List<List<String>> rows = (staffController.visitData.value == null ||
          staffController.visitData.value!.data == null ||
          staffController.visitData.value!.data!.isEmpty)
      ? [
          ["Record Not Found", "", "", "", "", ""]
        ]
      : staffController.visitData.value!.data!.map((visit) {
          String formattedDate = 'N/A';
          if (visit.start != null) {
            try {
              DateTime parsedDate = DateTime.parse(visit.start.toString());
              formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            } catch (e) {
              formattedDate = 'Invalid Date';
            }
          }

          return [
            formattedDate,
            visit.businessName ?? 'N/A',
            visit.status!=null?visit.status.toString():'__',
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
          SizedBox(
            width: availableWidth,
            height: containerHeight,
            child: Column(
              children: [

                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
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
                            switch (columnIndex) {
                              case 0:
                                cellStyle = const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                );
                                break;
                              case 3:
                                cellStyle = const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey,
                                );
                                break;
                              case 5:
                                cellStyle = const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                );
                                break;
                              default:
                                cellStyle = const TextStyle(
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
