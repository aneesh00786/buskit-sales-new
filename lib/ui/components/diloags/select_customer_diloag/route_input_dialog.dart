// Inside route_input_dialog.dart (or wherever you placed this class)


import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// route_input_dialog.dart

import 'package:calendar_view/calendar_view.dart';

// Make sure to import your ApiWorker and other necessary files

class RouteInputDialog extends StatefulWidget {
  final CalenderMapController controller;
  final String currentAddress;
  final LatLng currentLatLng;

  // New required fields to perform the logic
  final List<String> customerIds;
  final List<CalendarEventData<EventData>> eventData;

  const RouteInputDialog({
    super.key,
    required this.controller,
    required this.currentAddress,
    required this.currentLatLng,
    required this.customerIds,
    required this.eventData,
  });

  @override
  State<RouteInputDialog> createState() => _RouteInputDialogState();
}

class _RouteInputDialogState extends State<RouteInputDialog> {
  final TextEditingController _startTextController = TextEditingController();
  final TextEditingController _endTextController = TextEditingController();
  LatLng? startLocation;
  LatLng? endLocation;
  bool isLoading = false; // To show loading state during API call

  @override
  void initState() {
    super.initState();
    _startTextController.text = widget.currentAddress;
    _endTextController.text = widget.currentAddress;
    startLocation = widget.currentLatLng;
    endLocation = widget.currentLatLng;
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.9;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(minHeight: 350),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Aligns button to the right
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text("Set your trip’s start and end points",
            //         style:
            //             TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //     IconButton(
            //       icon: const Icon(Icons.close, size: 28),
            //       onPressed: () => Navigator.pop(context),
            //     )
            //   ],
            // ),
            const SizedBox(height: 10),

// --- Start Location Header & Field ---
            const Text(
              "Set your trip’s start location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              hint: "Start Location",
              icon: Icons.my_location,
              iconColor: Colors.blue,
              controller: _startTextController,
              onLocationSelected: (latLng, address) => startLocation = latLng,
            ),
            const SizedBox(height: 20),
            const Text(
              "Set your trip’s end location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              hint: "Destination Location",
              icon: Icons.location_on,
              iconColor: Colors.red,
              controller: _endTextController,
              onLocationSelected: (latLng, address) => endLocation = latLng,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        // 1. Validation
                        if (startLocation == null || endLocation == null)
                          return;

                        setState(() => isLoading = true);

                        try {
                          widget.controller.currentLatLng.value = startLocation;
                          widget.controller.searchedLatLng.value = endLocation;

                          // 3. Prepare Data for API
                          final selectedIds = widget
                              .controller.selectedCustomers
                              .map((c) => c.customerId)
                              .toSet();

                          List<String> addresses = widget
                              .controller.selectedCustomers
                              .map((customer) => customer.address.toString())
                              .toList();

                          var creditResponse =
                              await ApiWorker().debitRouteCredits(
                            amount: addresses.length * 3,
                            details: 'TESTING',
                            addresses: addresses,
                          );

                          await widget.controller.updateCredit(
                            creditResponse.credit.toString(),
                          );

                          {
                            final selectedCustomerIds = widget
                                .controller.selectedCustomers
                                .map((c) => c.customerId)
                                .toSet();

                            final selectedEventIds = widget.eventData
                                .where((event) =>
                                    event.event != null &&
                                    selectedCustomerIds.contains(
                                        event.event!.customerId.toString()))
                                .map((event) => event.event!.eventId)
                                .whereType<String>()
                                .toList();

                            if (mounted) Navigator.pop(context);

                            widget.controller.showSelectedCustomerRoute(
                              context,
                              widget.customerIds,
                              selectedEventIds,
                              // Pass the text from your text fields here
                              startAddress: _startTextController.text,
                              endAddress: _endTextController.text,
                            );
                          }

                          widget.controller.fetchDistanceAndTime();
                        } catch (e) {
                          print("Error in RouteInputDialog: $e");
                          setState(() => isLoading = false);
                          // Optionally show toast error here
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Show Route",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required String hint,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required Function(LatLng, String) onLocationSelected,
  }) {
    // ... (Keep existing _buildLocationField implementation exactly as is) ...
    // Copy the exact code from the previous step here
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Expanded(
            child: Autocomplete<Map<String, dynamic>>(
              initialValue: TextEditingValue(text: controller.text),
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return await widget.controller
                    .fetchAutoCompletePlaces(textEditingValue.text);
              },
              displayStringForOption: (Map<String, dynamic> option) {
                return option['description'] ?? '';
              },
              onSelected: (Map<String, dynamic> selection) async {
                controller.text = selection['description'];
                final placeId = selection['place_id'];
                if (placeId != null) {
                  LatLng? coords =
                      await widget.controller.getLatLngFromPlaceId(placeId);
                  if (coords != null) {
                    onLocationSelected(coords, selection['description']);
                  }
                }
              },
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                if (textController.text != controller.text) {
                  textController.text = controller.text;
                }
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (val) {
                    controller.text = val;
                  },
                  onChanged: (val) {
                    controller.text = val;
                  },
                  decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      isDense: true,
                      suffixIcon: textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 20, color: Colors.grey),
                              onPressed: () {
                                textController.clear();
                                controller.clear();
                              },
                            )
                          : null),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      constraints: const BoxConstraints(maxHeight: 250),
                      color: Colors.white,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined,
                                size: 22, color: Colors.grey),
                            title: Text(option['description'],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
