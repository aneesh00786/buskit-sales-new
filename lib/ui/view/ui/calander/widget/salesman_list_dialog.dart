
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/select_customer_diloag.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/widget/circle_image.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesmanListDialog extends StatefulWidget {
  final DateTime dateTime;
  final CalenderMapController calenderMapController;
  final List<CalendarEventData<EventData>> eventData;

  const SalesmanListDialog({
    super.key,
    required this.dateTime,
    required this.calenderMapController,
    required this.eventData,
  });

  @override
  State<SalesmanListDialog> createState() => _SalesmanListDialogState();
}

class _SalesmanListDialogState extends State<SalesmanListDialog> {
  late Map<String, int> salesmanVisits;
  late Map<String, List<String>> salesmanCustomers;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
    widget.calenderMapController.salesmanList.clear();
  }

  void _initializeData() async {
    widget.calenderMapController.isSalesmanLoading.value = true;

    salesmanVisits = {};
    salesmanCustomers = {};
    Set<String> processedSalesmen = {};

    for (var event in widget.eventData) {
      String salesmanId = event.event?.salesmanId ?? "Unknown";
      String customerId = event.event?.customerId ?? "Unknown";

      if (salesmanId != "Unknown") {
        salesmanVisits[salesmanId] = (salesmanVisits[salesmanId] ?? 0) + 1;

        salesmanCustomers.putIfAbsent(salesmanId, () => []);
        if (customerId != "Unknown") {
          salesmanCustomers[salesmanId]?.add(customerId);
        }

        if (!processedSalesmen.contains(salesmanId)) {
          processedSalesmen.add(salesmanId);
          await widget.calenderMapController.loadSalesmanOfCustomer(salesmanId);
        }
      }
    }

    widget.calenderMapController.isSalesmanLoading.value = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(widget.dateTime);

    return Dialog(
      insetPadding: isPhonePortrait(context) || isPhoneLandscape(context)
          ? EdgeInsets.zero
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: isPhonePortrait(context)
              ? fullScreenWidth(context)
              : fullScreenWidth(context) * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DiloagAppBar(title: "Salesman Visits for $formattedDate"),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () {
                    if (widget.calenderMapController.isSalesmanLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (salesmanVisits.isEmpty) {
                      return const Center(child: Text("No data available"));
                    }

                    var salesmanList =
                        widget.calenderMapController.salesmanList;

                    return Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        // Table Headers
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade200),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Salesman',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Visits',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        for (var i = 0; i < salesmanVisits.length; i++)
                          TableRow(
                            children: [
                              SizedBox(
                                height: 78,
                                child: InkWell(
                                  onTap: () async {
                                    Get.back();

                                    String salesmanId =
                                        salesmanVisits.keys.elementAt(i);
                                    List<String> customerIds =
                                        salesmanCustomers[salesmanId] ?? [];

                                    Get.dialog(SelectCustomerDiloag(
                                      dateTime: widget.dateTime,
                                      calenderMapController:
                                          widget.calenderMapController,
                                      eventData: widget.eventData,
                                      customerIds: customerIds,
                                      salesmanId: salesmanId, // NEW: pass this
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        salesmanList.length > i
                                            ? CircularImage(
                                                imageUrl:
                                                    '${ApiConstants.baseUrl1}${salesmanList[i].idimagePath ?? ''}',
                                                size: 40,
                                              )
                                            : const CircleAvatar(
                                                radius: 20,
                                                child: Icon(Icons.person),
                                              ),
                                        // const CircleAvatar(
                                        //   radius: 20,
                                        //   child: Icon(Icons.person),
                                        // ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Display name from EventData
                                            Text(
                                              (() {
                                                // Find the first event for this salesman
                                                final event = widget.eventData
                                                    .firstWhere(
                                                      (e) =>
                                                          e.event?.salesmanId ==
                                                          salesmanVisits.keys
                                                              .elementAt(i),
                                                      orElse: () => widget
                                                          .eventData.first,
                                                    )
                                                    .event;
                                                if (event != null) {
                                                  final first =
                                                      event.salesmanFirstname ??
                                                          '';
                                                  final last =
                                                      event.salesmanLastname ??
                                                          '';
                                                  return ('$first $last')
                                                          .trim()
                                                          .isNotEmpty
                                                      ? ('$first $last')
                                                      : 'Unknown';
                                                }
                                                return 'Unknown';
                                              })(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            // Display mobile from EventData
                                            Text(
                                              (() {
                                                final event = widget.eventData
                                                    .firstWhere(
                                                      (e) =>
                                                          e.event?.salesmanId ==
                                                          salesmanVisits.keys
                                                              .elementAt(i),
                                                      orElse: () => widget
                                                          .eventData.first,
                                                    )
                                                    .event;
                                                return event
                                                        ?.salesmanMobileno ??
                                                    'No Contact';
                                              })(),
                                            ),
                                            // Display email from EventData
                                            Text(
                                              (() {
                                                final event = widget.eventData
                                                    .firstWhere(
                                                      (e) =>
                                                          e.event?.salesmanId ==
                                                          salesmanVisits.keys
                                                              .elementAt(i),
                                                      orElse: () => widget
                                                          .eventData.first,
                                                    )
                                                    .event;
                                                return event?.salesmanEmail ??
                                                    'No Email';
                                              })(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 78,
                                child: Center(
                                  child: Text(
                                    salesmanVisits.values
                                        .elementAt(i)
                                        .toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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
