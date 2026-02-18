import 'dart:convert';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_event_details_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerDetailsDialog extends StatefulWidget {
  final String eventIds; 

  const CustomerDetailsDialog({super.key, required this.eventIds});

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
 
  late Future<List<CustomerEventModel>?> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = ApiWorker().fetchCustomerEventsData(eventIds: widget.eventIds);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm:ss a');

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // --- Header ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Customer Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5)),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    )
                  ],
                ),
              ),

              // --- Body ---
              Expanded(
                child: FutureBuilder<List<CustomerEventModel>?>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data found.'));
                    }

                    final dataList = snapshot.data!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(1.2), // Name
                          1: FlexColumnWidth(1),   // Date
                          2: FlexColumnWidth(1.2), // CheckIn
                          3: FlexColumnWidth(1.2), // CheckOut
                          // Removed index 4 (Status) to match your 4-column children below
                        },
                        children: [
                          // --- Table Header ---
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade100),
                            children: const [
                              _HeaderCell('Client Name'),
                              _HeaderCell('Visit Date'),
                              _HeaderCell('Check-In'),
                              _HeaderCell('Check-Out'),
                            ],
                          ),
                          // --- Data Rows ---
                          ...dataList.map((item) {
                            return TableRow(
                              children: [
                                // Client Name
                                _DataCell(Text(item.customerName, textAlign: TextAlign.center)),

                                // Visit Date
                                _DataCell(Text(dateFormat.format(item.visitDate), textAlign: TextAlign.center)),

                                // Check-In
                                _DataCell(
                                  item.checkIn != null
                                      ? _TimeWithLocation(time: timeFormat.format(item.checkIn!))
                                      : const SizedBox(),
                                ),

                                // Check-Out
                                _DataCell(
                                  item.checkOut != null
                                      ? _TimeWithLocation(time: timeFormat.format(item.checkOut!))
                                      : const SizedBox(),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper for Header Cells
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// Helper for Data Cells
class _DataCell extends StatelessWidget {
  final Widget child;
  const _DataCell(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Center(child: child),
    );
  }
}

// Helper for Time + Location Icon (Yellow Background)
class _TimeWithLocation extends StatelessWidget {
  final String time;
  const _TimeWithLocation({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Light yellow background
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
