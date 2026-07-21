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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: const Color(0xFF6C63FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('Visit Report'.tr, style: TextStyle(color: Colors.white, fontSize: 20)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
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
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text("No visit records found for this month."),
                      )
                    else
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(1.5), // Date column wider
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          // Table Header
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade100),
                            children:  [
                              _Cell('Working Days'.tr, isBold: true),
                              _Cell('Visited'.tr, isBold: true),
                              _Cell('Missed'.tr, isBold: true),
                              _Cell('Total'.tr, isBold: true),
                            ],
                          ),
                          // Mapped Data Rows
                          ...reportData.map((data) {
                            return TableRow(
                              children: [
                                _Cell(data.date != null 
                                  ? DateFormat('dd/MM/yyyy').format(data.date!) 
                                  : '-'),
                               InkWell(
        onTap: () {
          // Only open if there are visited items and we have IDs
          if (data.visited > 0 && data.eventIds != null && data.eventIds!.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                // PASS THE DYNAMIC ID HERE
                return CustomerDetailsDialog(eventIds: data.eventIds!);
              },
            );
          } else {
            // Optional: Show a snackbar if no data is available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No details available for this date")),
            );
          }
        },
        // We use the existing _Badge widget, but now it's wrapped
        child: _Badge(data.visited, Colors.green),
      ),
                              InkWell(
      onTap: () {
        if (data.missed > 0 && data.missedEventIds.isNotEmpty) {
          showDialog(
            context: context,
            // Pass MISSED IDs
            builder: (_) => CustomerDetailsDialog(eventIds: data.missedEventIds),
          );
        }
      },
      child: _Badge(data.missed, Colors.redAccent),
    ),
                               InkWell(
      onTap: () {
        // Use 'totalEventIds' here
        if (data.total > 0 && data.totalEventIds.isNotEmpty) {
          showDialog(
            context: context,
            builder: (_) => CustomerDetailsDialog(eventIds: data.totalEventIds),
          );
        }
      },
      child: _Badge(data.total, Colors.blueAccent),
    ),
                              ],
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}