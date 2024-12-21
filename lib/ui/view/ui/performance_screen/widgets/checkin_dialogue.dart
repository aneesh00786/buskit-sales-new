  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/checkin_checkout_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/datacolumn_and_row.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildCheckInOutDialogContent(CheckInOut? data,StaffController staffController) {
    if (data == null) return const Text('No Check-in/out data available.');
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double fontSize = 14.0;
      double padding = availableWidth / 100;
      double fixedIconSize = fontSize;
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: availableWidth,
                child: DataTable(
                  dataRowHeight: fontSize * 5.5,
                  headingRowHeight: 45,
                  headingRowColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => primaryColor,
                  ),
                  columnSpacing: padding * 1.5,
                  headingTextStyle: const TextStyle(
                      fontSize: 14, color: white, fontWeight: FontWeight.w700),
                  columns: [
                    dataColumn(label: 'Customer'),
                    dataColumn(label: 'Customer ID'),
                    dataColumn(label: 'Event ID'),
                    dataColumn(label: 'Individual visit'),
                    dataColumn(label: 'Total visit'),
                    dataColumn(label: 'Check IN'),
                  ],
                  rows: (staffController.checkInOutData.value == null ||
                          staffController.checkInOutData.value!.data == null ||
                          staffController.checkInOutData.value!.data!.isEmpty)
                      ? [
                          const DataRow(cells: [
                            DataCell(Text('Record Not Found')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ])
                        ]
                      : staffController.checkInOutData.value!.data!
                          .map((check) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: (fixedIconSize / 2) + 2,
                                      backgroundColor: const Color(0xffe6ecff),
                                      child: Icon(Icons.person,
                                          size: fixedIconSize,
                                          color: Colors.blue),
                                    ),
                                    SizedBox(width: padding),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            check.fullname ?? 'N/A',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            check.mobileno ?? 'N/A',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            check.email ?? 'N/A',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(check.customerId ?? 'N/A')),
                              DataCell(Text(check.eventId ?? 'N/A')),
                              DataCell(Text(
                                  check.individualVisit.toString() ?? 'N/A')),
                              DataCell(Text(check.totalVisits ?? 'N/A')),
                              DataCell(Text(
                                check.checkIn != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(check.checkIn!)
                                    : 'N/A',
                              )),
                            ],
                          );
                        }).toList(),
                ),
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
        ),
      );
    });
  }