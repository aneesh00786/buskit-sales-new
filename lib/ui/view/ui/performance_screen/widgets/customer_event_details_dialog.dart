
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
    _eventsFuture =
        ApiWorker().fetchCustomerEventsData(eventIds: widget.eventIds);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm:ss a');
    
    // Get today's date with the time set to midnight for accurate day comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // Made slightly wider to fit 5 columns
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    )
                  ],
                ),
              ),

              // --- Body ---
              Flexible(
                fit: FlexFit.loose,
                child: FutureBuilder<List<CustomerEventModel>?>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return SizedBox(
                          height: 100,
                          child:
                              Center(child: Text('Error: ${snapshot.error}')));
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const SizedBox(
                          height: 100,
                          child: Center(child: Text('No data found.')));
                    }

                    final dataList = snapshot.data!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(1.2), // Client Name
                          1: FlexColumnWidth(1.0), // Visit Date
                          2: FlexColumnWidth(1.0), // Check-In
                          3: FlexColumnWidth(1.0), // Check-Out
                          4: FlexColumnWidth(1.0), // Status
                        },
                        children: [
                          // --- Table Header ---
                          TableRow(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            children: const [
                              _HeaderCell('Client Name'),
                              _HeaderCell('Visit Date'),
                              _HeaderCell('Check-In'),
                              _HeaderCell('Check-Out'),
                              _HeaderCell('Status'), // New Column
                            ],
                          ),
                          // --- Data Rows ---
                          ...dataList.map((item) {
                            
                            // 1. Normalize visit date to midnight for accurate comparison
                            final visitDate = DateTime(item.visitDate.year, item.visitDate.month, item.visitDate.day);
                            
                            // 2. Determine Status Logic
                            String statusText;
                            Color statusColor;
                            if (visitDate.isAtSameMomentAs(today)) {
                              if (item.checkIn != null && item.checkOut != null) {
                                statusText = 'Completed';
                                statusColor = Colors.green;
                              } else {
                                statusText = 'Pending';
                                statusColor = Colors.orange; 
                              }
                            } else {
                              // ORIGINAL LOGIC: For past or future dates
                              if (item.checkIn != null) {
                                statusText = 'Completed';
                                statusColor = Colors.green;
                              } else if (visitDate.isBefore(today)) {
                                statusText = 'Missed';
                                statusColor = Colors.red;
                              } else {
                                // If it's in the future and no check-in yet
                                statusText = 'Active';
                                statusColor = Colors.blue; 
                              }
                            }

                            // if (item.checkIn != null) {
                            //   statusText = 'Completed';
                            //   statusColor = Colors.green;
                            // } else if (visitDate.isBefore(today)) {
                            //   statusText = 'Missed';
                            //   statusColor = Colors.red;
                            // } else {
                            //   // If it's today (or in the future) and no check-in yet
                            //   statusText = 'Active';
                            //   statusColor = Colors.blue; 
                            // }

                            return TableRow(
                              children: [
                                _DataCell(Text(item.customerName,
                                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                                _DataCell(Text(
                                    dateFormat.format(item.visitDate),
                                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                                _DataCell(
                                  item.checkIn != null
                                      ? _TimeWithLocation(
                                          time:
                                              timeFormat.format(item.checkIn!))
                                      : const SizedBox(),
                                ),
                                _DataCell(
                                  item.checkOut != null
                                      ? _TimeWithLocation(
                                          time:
                                              timeFormat.format(item.checkOut!))
                                      : const SizedBox(),
                                ),
                                _DataCell(
                                  // --- Updated Status Display (Plain Text) ---
                                  Text(
                                    statusText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Center(child: child),
    );
  }
}

// Helper for Time + Location Icon
class _TimeWithLocation extends StatelessWidget {
  final String time;
  const _TimeWithLocation({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
