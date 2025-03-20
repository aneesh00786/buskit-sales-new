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
    "Customer/s",
    "Customer ID",
    "Address",
    "Business NO",
    "Created At",
  ];

  List<TableViewRow> rows = (staffController.customerDatas.value == null ||
          staffController.customerDatas.value!.data == null ||
          staffController.customerDatas.value!.data!.isEmpty)
      ? [
          const TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("Record Not Found")),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffe6ecff),
                      backgroundImage: customer.imageUrl != null
                          ? NetworkImage(customer.imageUrl!)
                          : null,
                      child: customer.imageUrl == null
                          ? const Icon(Icons.person, size: 20, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 8),
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
                textAlign: TextAlign.center,
                customer.customerId ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              TableViewCell(
                  child: Text(
                customer.address ?? 'N/A',
                textAlign: TextAlign.center,
              )),
              TableViewCell(
                  child: Text(
                customer.businessNo ?? 'N/A',
                textAlign: TextAlign.center,
              )),
              TableViewCell(
                child: Text(
                  formatNullableDate(customer.createAt),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: primaryColor,
            ),
            height: headerHeight,
          ),
          SizedBox(
            width: availableWidth,
            height: containerHeight,
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: primaryColor,
                  ),
                  child: Row(
                    children: headers.map((label) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
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
                          children: rows[index].cells.map((cell) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: cell.child,
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
