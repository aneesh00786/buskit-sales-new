import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_data_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildCustomersDialogContent(
    CustomerData? data, StaffController staffController) {
  List<String> headers = [
    "Business Info",
    "Customer ID",
    "Address",
    "Business NO",
    "Created At",
    "Status",
  ];

  List<TableViewRow> rows = (staffController.customerDatas.value == null ||
          staffController.customerDatas.value!.data == null ||
          staffController.customerDatas.value!.data!.isEmpty)
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("Record Not Found")),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : staffController.customerDatas.value!.data!.map((customer) {
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffe6ecff),
                      backgroundImage: customer.imageUrl != null
                          ? NetworkImage(customer.imageUrl!)
                          : null,
                      child: customer.imageUrl == null
                          ? Icon(Icons.person, size: 20, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // Name and Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer.businessName ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer.address ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableViewCell(
                  child: Text(
                customer.customerId ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              TableViewCell(child: Text(customer.address ?? 'N/A')),
              TableViewCell(child: Text(customer.businessNo ?? 'N/A')),
              TableViewCell(
                child: Text(
                  formatNullableDate(customer.createAt),
                ),
              ),
              TableViewCell(child: Text(customer.status.toString() ?? 'N/A')),
            ],
          );
        }).toList();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
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
                  label: label,
                  padding: EdgeInsets.all(10),
                  width: 150,
                  textStyle: TextStyle(color: white),
                );
              }).toList(),
              rows: rows,
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
