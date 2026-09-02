import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/checkin_checkout_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildCheckInOutDialogContent(
    CheckInOut? data, StaffController staffController) {
  List<String> headers = [
    "Customer",
    "Customer ID",
    "Event ID",
    "Individual Visit",
    "Total Visit",
    "Check IN",
  ];

  List<TableViewRow> rows = (staffController.checkInOutData.value == null ||
          staffController.checkInOutData.value!.data == null ||
          staffController.checkInOutData.value!.data!.isEmpty)
      ? [
          const TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("Record Not Found.tr")),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : staffController.checkInOutData.value!.data!.map((check) {
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xffe6ecff),
                      child: Icon(Icons.person, size: 20, color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            check.fullname ?? 'N/A',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            check.mobileno ?? 'N/A',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 12,
                                color: Color(0xFF64748B)),
                          ),
                          Text(
                            check.email ?? 'N/A',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 12,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableViewCell(
                child: Text(
                  check.customerId ?? 'N/A',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A)),
                ),
              ),
              TableViewCell(
                  child: Text(check.eventId ?? 'N/A',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Color(0xFF0F172A)))),
              TableViewCell(
                  child: Text(
                check.individualVisit?.toString() ?? 'N/A',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins_Regular', color: Color(0xFF0F172A)),
              )),
              TableViewCell(
                  child: Text(
                check.totalVisits?.toString() ?? 'N/A',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins_Regular', color: Color(0xFF0F172A)),
              )),
              TableViewCell(
                child: Text(
                  check.checkIn != null
                      ? DateFormat('dd/MM/yyyy').format(check.checkIn!)
                      : 'N/A',
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
        double rowHeight = 80;
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
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              headers[0],
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        ...headers.sublist(1).map((label) {
                          return Expanded(
                            flex: 1,
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
                        }),
                      ],
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: rows[index].cells[0].child,
                                ),
                              ),
                              ...rows[index]
                                  .cells
                                  .sublist(1)
                                  .map((cell) => Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: cell.child,
                                        ),
                                      )),
                            ],
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
