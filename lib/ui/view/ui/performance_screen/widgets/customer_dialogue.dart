import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_data_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildCustomersDialogContent(
    CustomerData? data, StaffController staffController) {
  List<String> headers = [
    "Customer/s".tr,
    "Customer ID".tr,
    "Address".tr,
    "Business NO".tr,
    "Created At".tr,
  ];

  List<TableViewRow> rows = (staffController.customerDatas.value == null ||
          staffController.customerDatas.value!.data == null ||
          staffController.customerDatas.value!.data!.isEmpty)
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("Record Not Found".tr)),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : staffController.customerDatas.value!.data!.map((customer) {
          print('customer image : ${customer.imageUrl}');
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 35,
                        width: 35,
                        child: Image.network(
                          '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}',
                          // 👇 Removed condition, now safely accessing invoiceData
                          // 'https://test.thrivewoo.com/uploads/${customer.imageUrl ?? ''}',

                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.lightBlue[100],
                              child:
                                  const Icon(Icons.person, color: Colors.blue),
                            );
                          },
                        ),
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: 20,
                    //   backgroundColor: const Color(0xffe6ecff),
                    //   backgroundImage: customer.imageUrl != null
                    //       ? NetworkImage(customer.imageUrl!)
                    //       : null,
                    //   child: customer.imageUrl == null
                    //       ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    //       : null,
                    // ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer.businessName ?? 'N/A',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer.address ?? 'N/A',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 12,
                                color: Color(0xFF64748B)),
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
                style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A)),
              )),
              TableViewCell(
                  child: Text(
                customer.address ?? 'N/A',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins_Regular', color: Color(0xFF0F172A)),
              )),
              TableViewCell(
                  child: Text(
                customer.businessNo ?? 'N/A',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins_Regular', color: Color(0xFF0F172A)),
              )),
              TableViewCell(
                child: Text(
                  formatNullableDate(customer.createAt),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins_Regular', color: Color(0xFF0F172A)),
                ),
              ),
            ],
          );
        }).toList();

  return Material(
    type: MaterialType.transparency,
    child: LayoutBuilder(
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
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: headers.map((label) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFF8FAFC),
                            border: const Border(
                              bottom: BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1,
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
              top: 10,
              right: 12,
              child: InkResponse(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}
