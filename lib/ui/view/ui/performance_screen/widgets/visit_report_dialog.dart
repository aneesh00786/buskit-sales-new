import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/visit_report_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/customer_event_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// visit_report_dialog.dart

import 'package:intl/intl.dart';
// Import your model file

class VisitReportDialog extends StatelessWidget {
  // Accept the list of data
  final List<VisitReportModel> reportData;

  const VisitReportDialog({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visit Report'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkResponse(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  )
                ],
              ),
            ),

            // Body
            Flexible(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Check if list is empty
                      if (reportData.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text(
                            "No visit records found for this month.".tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Table(
                            border:
                                TableBorder.all(color: const Color(0xFFE2E8F0)),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(1.5), // Date column wider
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              // Table Header
                              TableRow(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC)),
                                children: [
                                  _Cell('Working Days'.tr, isBold: true),
                                  _Cell('Visited'.tr, isBold: true),
                                  _Cell('Missed'.tr, isBold: true),
                                  _Cell('Total'.tr, isBold: true),
                                ],
                              ),
                              // Mapped Data Rows
                              ...reportData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: index.isOdd
                                        ? const Color(0xFFF8FAFC)
                                        : Colors.white,
                                  ),
                                  children: [
                                    _Cell(data.date != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(data.date!)
                                        : '-'),
                                    InkWell(
                                      onTap: () {
                                        // Only open if there are visited items and we have IDs
                                        if (data.visited > 0 &&
                                            data.eventIds != null &&
                                            data.eventIds!.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              // PASS THE DYNAMIC ID HERE
                                              return CustomerDetailsDialog(
                                                  eventIds: data.eventIds!);
                                            },
                                          );
                                        } else {
                                          // Optional: Show a snackbar if no data is available
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "No details available for this date")),
                                          );
                                        }
                                      },
                                      // We use the existing _Badge widget, but now it's wrapped
                                      child: _Badge(data.visited,
                                          const Color(0xFF16A34A)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (data.missed > 0 &&
                                            data.missedEventIds.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            // Pass MISSED IDs
                                            builder: (_) =>
                                                CustomerDetailsDialog(
                                                    eventIds:
                                                        data.missedEventIds),
                                          );
                                        }
                                      },
                                      child: _Badge(
                                          data.missed, const Color(0xFFDC2626)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Use 'totalEventIds' here
                                        if (data.total > 0 &&
                                            data.totalEventIds.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                CustomerDetailsDialog(
                                                    eventIds:
                                                        data.totalEventIds),
                                          );
                                        }
                                      },
                                      child: _Badge(
                                          data.total, const Color(0xFF2563EB)),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple helper widgets for cleaner code
class _Cell extends StatelessWidget {
  final String text;
  final bool isBold;
  const _Cell(this.text, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins_Regular',
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge(this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
