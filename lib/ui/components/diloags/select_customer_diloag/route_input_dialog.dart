
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:calendar_view/calendar_view.dart';


class RouteInputDialog extends StatefulWidget {
  final CalenderMapController controller;
  final String currentAddress;
  final LatLng currentLatLng;
  final List<String> customerIds;
  final List<CalendarEventData<EventData>> eventData;

 
  static String? savedStartText;
  static String? savedEndText;
  static LatLng? savedStartLatLng;
  static LatLng? savedEndLatLng;

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
  bool isLoading = false;
  int dailyCreditCount = 0; // State variable to show count in UI

  @override
  void initState() {
    super.initState();
    _loadDailyCredit(); // Fetch initial count

    // 1. Initialize START location
    if (RouteInputDialog.savedStartText != null &&
        RouteInputDialog.savedStartText!.isNotEmpty) {
      _startTextController.text = RouteInputDialog.savedStartText!;
      startLocation = RouteInputDialog.savedStartLatLng;
    } else {
      _startTextController.text = widget.currentAddress;
      startLocation = widget.currentLatLng;
    }

    // 2. Initialize END location
    if (RouteInputDialog.savedEndText != null &&
        RouteInputDialog.savedEndText!.isNotEmpty) {
      _endTextController.text = RouteInputDialog.savedEndText!;
      endLocation = RouteInputDialog.savedEndLatLng;
    } else {
      _endTextController.text = widget.currentAddress;
      endLocation = widget.currentLatLng;
    }
  }

 
  Future<void> _loadDailyCredit() async {
    
    try {
      
      int count = await widget.controller.getCurrentDailyCount(); 
      if (mounted) {
        setState(() {
          dailyCreditCount = count;
        });
      }
    } catch (e) {
      print("Error loading credit: $e");
    }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    'Daily Route Credit -'.tr + ' \u200E$dailyCreditCount/3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: dailyCreditCount >= 3 ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
               
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 10),
             Text(
              "Set your trip’s start location".tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              hint: "Start Location".tr,
              icon: Icons.my_location,
              iconColor: Colors.blue,
              controller: _startTextController,
              onLocationSelected: (latLng, address) => startLocation = latLng,
            ),
            const SizedBox(height: 20),
             Text(
              "Set your trip’s end location".tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              hint: "Destination Location".tr,
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
                onPressed: isLoading ? null : () => _handleShowRoute(),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    :  Text("Show Route".tr,
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

  Future<void> _handleShowRoute() async {
   
    if (startLocation == null || endLocation == null) return;

   
    bool isStartChanged = startLocation != RouteInputDialog.savedStartLatLng;
    bool isEndChanged = endLocation != RouteInputDialog.savedEndLatLng;
    bool needsCredit = isStartChanged || isEndChanged;

    
    if (needsCredit && dailyCreditCount == 2) {
      bool confirm = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Warning".tr),
          content: Text(
              "You already generated routes twice and only one more route generation can be done today.".tr),
          actions: [
            TextButton(
              onPressed: (){
                Get.back(closeOverlays: true);
                Get.back();
              },
              // onPressed: () => Navigator.pop(ctx, false), 
              child: Text("Cancel".tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true), 
              child: Text("OK".tr),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return; 
    }

    setState(() => isLoading = true);

    
    if (needsCredit) {
      
      var limitResult = await widget.controller.checkAndIncrementDailyLimit();

      if (limitResult == -1 || limitResult == false) {
        setState(() => isLoading = false);
        showCustomToastDisplay(
            context,
            "Daily limit reached. You cannot search new custom routes today.".tr,
            Colors.red,
            Icons.block);
        return;
      }

      // Update the UI count immediately
      if (limitResult is int) {
        setState(() {
          dailyCreditCount = limitResult;
        });
      }
    }

    // 5. Proceed with API Logic
    try {
      // Save new defaults
      RouteInputDialog.savedStartText = _startTextController.text;
      RouteInputDialog.savedEndText = _endTextController.text;
      RouteInputDialog.savedStartLatLng = startLocation;
      RouteInputDialog.savedEndLatLng = endLocation;

      widget.controller.currentLatLng.value = startLocation;
      widget.controller.searchedLatLng.value = endLocation;

      // Prepare Data
      final selectedIds = widget.controller.selectedCustomers
          .map((c) => c.customerId)
          .toSet();

      List<String> addresses = widget.controller.selectedCustomers
          .map((customer) => customer.address.toString())
          .toList();

      var creditResponse = await ApiWorker().debitRouteCredits(
        amount: addresses.length * 3,
        details: 'TESTING',
        addresses: addresses,
      );

      await widget.controller.updateCredit(
        creditResponse.credit.toString(),
      );

      {
        final selectedCustomerIds = widget.controller.selectedCustomers
            .map((c) => c.customerId)
            .toSet();

        final selectedEventIds = widget.eventData
            .where((event) =>
                event.event != null &&
                selectedCustomerIds.contains(event.event!.customerId.toString()))
            .map((event) => event.event!.eventId)
            .whereType<String>()
            .toList();

        if (mounted) Navigator.pop(context);

        widget.controller.showSelectedCustomerRoute(
          context,
          widget.customerIds,
          selectedEventIds,
          startAddress: _startTextController.text,
          endAddress: _endTextController.text,
        );
      }
    } catch (e) {
      print("Error in RouteInputDialog: $e");
      setState(() => isLoading = false);
    }
  }


  Widget _buildLocationField({
    required String hint,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required Function(LatLng, String) onLocationSelected,
  }) {
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



// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:calendar_view/calendar_view.dart';

// class RouteInputDialog extends StatefulWidget {
//   final CalenderMapController controller;
//   final String currentAddress;
//   final LatLng currentLatLng;
//   final List<String> customerIds;
//   final List<CalendarEventData<EventData>> eventData;

//   // Static variables to remember the last searched/saved location
//   static String? savedStartText;
//   static String? savedEndText;
//   static LatLng? savedStartLatLng;
//   static LatLng? savedEndLatLng;

//   const RouteInputDialog({
//     super.key,
//     required this.controller,
//     required this.currentAddress,
//     required this.currentLatLng,
//     required this.customerIds,
//     required this.eventData,
//   });

//   @override
//   State<RouteInputDialog> createState() => _RouteInputDialogState();
// }

// class _RouteInputDialogState extends State<RouteInputDialog> {
//   final TextEditingController _startTextController = TextEditingController();
//   final TextEditingController _endTextController = TextEditingController();
//   LatLng? startLocation;
//   LatLng? endLocation;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();

//     // 1. Initialize START location
//     // If we have a saved static value from a previous search, use it.
//     if (RouteInputDialog.savedStartText != null && RouteInputDialog.savedStartText!.isNotEmpty) {
//       _startTextController.text = RouteInputDialog.savedStartText!;
//       startLocation = RouteInputDialog.savedStartLatLng;
//     } else {
//       // Otherwise, use the current GPS location
//       _startTextController.text = widget.currentAddress;
//       startLocation = widget.currentLatLng;
//     }

//     // 2. Initialize END location
//     if (RouteInputDialog.savedEndText != null && RouteInputDialog.savedEndText!.isNotEmpty) {
//       _endTextController.text = RouteInputDialog.savedEndText!;
//       endLocation = RouteInputDialog.savedEndLatLng;
//     } else {
//       _endTextController.text = widget.currentAddress;
//       endLocation = widget.currentLatLng;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double dialogWidth = MediaQuery.of(context).size.width * 0.9;

//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: Colors.white,
//       child: Container(
//         width: dialogWidth,
//         constraints: const BoxConstraints(minHeight: 350),
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.close, size: 28),
//                   onPressed: () => Navigator.pop(context),
//                 )
//               ],
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Set your trip’s start location",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             _buildLocationField(
//               hint: "Start Location",
//               icon: Icons.my_location,
//               iconColor: Colors.blue,
//               controller: _startTextController,
//               onLocationSelected: (latLng, address) => startLocation = latLng,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Set your trip’s end location",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             _buildLocationField(
//               hint: "Destination Location",
//               icon: Icons.location_on,
//               iconColor: Colors.red,
//               controller: _endTextController,
//               onLocationSelected: (latLng, address) => endLocation = latLng,
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 2,
//                 ),
//                 onPressed: isLoading
//                     ? null
//                     : () async {
//                         // 1. Validation
//                         if (startLocation == null || endLocation == null) return;

//                         setState(() => isLoading = true);

//                         // 2. CHECK IF LOCATION CHANGED OR IS NEW
//                         // We check if the current start/end matches the LAST SAVED start/end.
//                         // If they match, it means the user hasn't edited the fields (or changed them back),
//                         // so we SKIP the limit check.
//                         // If 'RouteInputDialog.savedStartLatLng' is null, it means it's the very first time, so we must count it.
                        
//                         bool isStartChanged = startLocation != RouteInputDialog.savedStartLatLng;
//                         bool isEndChanged = endLocation != RouteInputDialog.savedEndLatLng;
                        
//                         // If either changed (or it's the first run where saved is null), we check the limit.
//                         if (isStartChanged || isEndChanged) {
                            
//                             var limitResult = await widget.controller.checkAndIncrementDailyLimit();

//                             if (limitResult == -1 || limitResult == false) {
//                                 // Limit Reached
//                                 setState(() => isLoading = false);
//                                 showCustomToastDisplay(
//                                     context, 
//                                     "Daily limit reached. You cannot search new custom routes today.", 
//                                     Colors.red, 
//                                     Icons.block
//                                 );
//                                 return; // STOP HERE
//                             } else {
//                                 // Limit Success
//                                 if (limitResult is int && limitResult > 0) {
//                                     showCustomToastDisplay(context, "Daily Limit Updated: $limitResult / 3", Colors.green, Icons.check_circle);
//                                 }
//                             }
//                         } 
//                         // ELSE: If (isStartChanged == false && isEndChanged == false), 
//                         // we skip the limit logic entirely and proceed to API/Map.

//                         try {
//                           // 3. Save the new locations as the "Default" for next time
//                           // We only update these on a successful attempt (implied by reaching here)
//                           RouteInputDialog.savedStartText = _startTextController.text;
//                           RouteInputDialog.savedEndText = _endTextController.text;
//                           RouteInputDialog.savedStartLatLng = startLocation;
//                           RouteInputDialog.savedEndLatLng = endLocation;

//                           widget.controller.currentLatLng.value = startLocation;
//                           widget.controller.searchedLatLng.value = endLocation;

//                           // 4. Prepare Data for API
//                           final selectedIds = widget
//                               .controller.selectedCustomers
//                               .map((c) => c.customerId)
//                               .toSet();

//                           List<String> addresses = widget
//                               .controller.selectedCustomers
//                               .map((customer) => customer.address.toString())
//                               .toList();

//                           var creditResponse =
//                               await ApiWorker().debitRouteCredits(
//                             amount: addresses.length * 3,
//                             details: 'TESTING',
//                             addresses: addresses,
//                           );

//                           await widget.controller.updateCredit(
//                             creditResponse.credit.toString(),
//                           );

//                           {
//                             final selectedCustomerIds = widget
//                                 .controller.selectedCustomers
//                                 .map((c) => c.customerId)
//                                 .toSet();

//                             final selectedEventIds = widget.eventData
//                                 .where((event) =>
//                                     event.event != null &&
//                                     selectedCustomerIds.contains(
//                                         event.event!.customerId.toString()))
//                                 .map((event) => event.event!.eventId)
//                                 .whereType<String>()
//                                 .toList();

//                             if (mounted) Navigator.pop(context);

//                             widget.controller.showSelectedCustomerRoute(
//                               context,
//                               widget.customerIds,
//                               selectedEventIds,
//                               startAddress: _startTextController.text,
//                               endAddress: _endTextController.text,
//                             );
//                           }
//                         } catch (e) {
//                           print("Error in RouteInputDialog: $e");
//                           setState(() => isLoading = false);
//                         }
//                       },
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Show Route",
//                         style: TextStyle(
//                             color: Color.fromRGBO(255, 255, 255, 1),
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationField({
//     required String hint,
//     required IconData icon,
//     required Color iconColor,
//     required TextEditingController controller,
//     required Function(LatLng, String) onLocationSelected,
//   }) {
//     // ... (Your existing _buildLocationField code stays exactly the same) ...
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!, width: 1.5),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           Expanded(
//             child: Autocomplete<Map<String, dynamic>>(
//               initialValue: TextEditingValue(text: controller.text),
//               optionsBuilder: (TextEditingValue textEditingValue) async {
//                 if (textEditingValue.text == '') {
//                   return const Iterable<Map<String, dynamic>>.empty();
//                 }
//                 return await widget.controller
//                     .fetchAutoCompletePlaces(textEditingValue.text);
//               },
//               displayStringForOption: (Map<String, dynamic> option) {
//                 return option['description'] ?? '';
//               },
//               onSelected: (Map<String, dynamic> selection) async {
//                 controller.text = selection['description'];
//                 final placeId = selection['place_id'];
//                 if (placeId != null) {
//                   LatLng? coords =
//                       await widget.controller.getLatLngFromPlaceId(placeId);
//                   if (coords != null) {
//                     onLocationSelected(coords, selection['description']);
//                   }
//                 }
//               },
//               fieldViewBuilder:
//                   (context, textController, focusNode, onFieldSubmitted) {
//                 if (textController.text != controller.text) {
//                   textController.text = controller.text;
//                 }
//                 return TextField(
//                   controller: textController,
//                   focusNode: focusNode,
//                   style: const TextStyle(fontSize: 16),
//                   onSubmitted: (val) {
//                     controller.text = val;
//                   },
//                   onChanged: (val) {
//                     controller.text = val;
//                   },
//                   decoration: InputDecoration(
//                       hintText: hint,
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                       isDense: true,
//                       suffixIcon: textController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear,
//                                   size: 20, color: Colors.grey),
//                               onPressed: () {
//                                 textController.clear();
//                                 controller.clear();
//                               },
//                             )
//                           : null),
//                 );
//               },
//               optionsViewBuilder: (context, onSelected, options) {
//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     elevation: 8.0,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.75,
//                       constraints: const BoxConstraints(maxHeight: 250),
//                       color: Colors.white,
//                       child: ListView.separated(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         shrinkWrap: true,
//                         itemCount: options.length,
//                         separatorBuilder: (ctx, i) => const Divider(height: 1),
//                         itemBuilder: (BuildContext context, int index) {
//                           final option = options.elementAt(index);
//                           return ListTile(
//                             leading: const Icon(Icons.location_on_outlined,
//                                 size: 22, color: Colors.grey),
//                             title: Text(option['description'],
//                                 style: const TextStyle(
//                                     fontSize: 14, fontWeight: FontWeight.w500)),
//                             onTap: () => onSelected(option),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






// // Inside route_input_dialog.dart (or wherever you placed this class)


// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// // route_input_dialog.dart

// import 'package:calendar_view/calendar_view.dart';



// class RouteInputDialog extends StatefulWidget {
//   final CalenderMapController controller;
//   final String currentAddress;
//   final LatLng currentLatLng;

//   // New required fields to perform the logic
//   final List<String> customerIds;
//   final List<CalendarEventData<EventData>> eventData;

//   const RouteInputDialog({
//     super.key,
//     required this.controller,
//     required this.currentAddress,
//     required this.currentLatLng,
//     required this.customerIds,
//     required this.eventData,
//   });

//   @override
//   State<RouteInputDialog> createState() => _RouteInputDialogState();
// }

// class _RouteInputDialogState extends State<RouteInputDialog> {
//   final TextEditingController _startTextController = TextEditingController();
//   final TextEditingController _endTextController = TextEditingController();
//   LatLng? startLocation;
//   LatLng? endLocation;
//   bool isLoading = false; 
  
//   late String initialStartText;
//   late String initialEndText;

//   @override
//   void initState() {
//     super.initState();
//     _startTextController.text = widget.currentAddress;
//     _endTextController.text = widget.currentAddress;
//     startLocation = widget.currentLatLng;
//     endLocation = widget.currentLatLng;
//     initialStartText = widget.currentAddress; 
//     initialEndText = widget.currentAddress;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double dialogWidth = MediaQuery.of(context).size.width * 0.9;

//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: Colors.white,
//       child: Container(
//         width: dialogWidth,
//         constraints: const BoxConstraints(minHeight: 350),
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment:
//                   MainAxisAlignment.end, // Aligns button to the right
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.close, size: 28),
//                   onPressed: () => Navigator.pop(context),
//                 )
//               ],
//             ),
         
//             const SizedBox(height: 10),


//             const Text(
//               "Set your trip’s start location",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             _buildLocationField(
//               hint: "Start Location",
//               icon: Icons.my_location,
//               iconColor: Colors.blue,
//               controller: _startTextController,
//               onLocationSelected: (latLng, address) => startLocation = latLng,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Set your trip’s end location",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             _buildLocationField(
//               hint: "Destination Location",
//               icon: Icons.location_on,
//               iconColor: Colors.red,
//               controller: _endTextController,
//               onLocationSelected: (latLng, address) => endLocation = latLng,
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 2,
//                 ),
//                 onPressed: isLoading
//                     ? null
//                     : () async {
//                         // 1. Validation
//                         if (startLocation == null || endLocation == null)
//                           return;

//                         setState(() => isLoading = true);
//                         bool isStartEdited = _startTextController.text != initialStartText;
//                         bool isEndEdited = _endTextController.text != initialEndText;
//                         if (isStartEdited || isEndEdited) {
//                           int usageCount = await widget.controller.checkAndIncrementDailyLimit();
//                           // bool canProceed = await widget.controller.checkAndIncrementDailyLimit();
//                           if (usageCount == -1) {
//              setState(() => isLoading = false);
//              showCustomToastDisplay(
//                 context, 
//                 "Daily limit reached (3/3). You cannot search new custom routes today.", 
//                 Colors.red, 
//                 Icons.block
//              );
//              return; // STOP HERE
//           } else {
//              // SUCCESS: Show the usage count popup (1/3, 2/3, etc.)
//              showCustomToastDisplay(
//                 context, 
//                 "Daily Limit Updated: $usageCount / 3", 
//                 Colors.green, 
//                 Icons.check_circle
//              );
//           }
//         }
//                         //   if (!canProceed) {
//                         //      setState(() => isLoading = false);
//                         //      // Show Toast/Snackbar
//                         //      showCustomToastDisplay(
//                         //         context, 
//                         //         "Daily limit reached (3/3). You cannot search new custom routes today.", 
//                         //         Colors.red, 
//                         //         Icons.block
//                         //      );
//                         //      return; // STOP HERE
//                         //   }
//                         // }

//                         try {
//                           widget.controller.currentLatLng.value = startLocation;
//                           widget.controller.searchedLatLng.value = endLocation;

//                           // 3. Prepare Data for API
//                           final selectedIds = widget
//                               .controller.selectedCustomers
//                               .map((c) => c.customerId)
//                               .toSet();

//                           List<String> addresses = widget
//                               .controller.selectedCustomers
//                               .map((customer) => customer.address.toString())
//                               .toList();

//                           var creditResponse =
//                               await ApiWorker().debitRouteCredits(
//                             amount: addresses.length * 3,
//                             details: 'TESTING',
//                             addresses: addresses,
//                           );

//                           await widget.controller.updateCredit(
//                             creditResponse.credit.toString(),
//                           );

//                           {
//                             final selectedCustomerIds = widget
//                                 .controller.selectedCustomers
//                                 .map((c) => c.customerId)
//                                 .toSet();

//                             final selectedEventIds = widget.eventData
//                                 .where((event) =>
//                                     event.event != null &&
//                                     selectedCustomerIds.contains(
//                                         event.event!.customerId.toString()))
//                                 .map((event) => event.event!.eventId)
//                                 .whereType<String>()
//                                 .toList();

//                             if (mounted) Navigator.pop(context);

//                             widget.controller.showSelectedCustomerRoute(
//                               context,
//                               widget.customerIds,
//                               selectedEventIds,
//                               // Pass the text from your text fields here
//                               startAddress: _startTextController.text,
//                               endAddress: _endTextController.text,
//                             );
//                           }

//                           // widget.controller.fetchDistanceAndTime();
//                         } catch (e) {
//                           print("Error in RouteInputDialog: $e");
//                           setState(() => isLoading = false);
//                           // Optionally show toast error here
//                         }
//                       },
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Show Route",
//                         style: TextStyle(
//                             color: Color.fromRGBO(255, 255, 255, 1),
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationField({
//     required String hint,
//     required IconData icon,
//     required Color iconColor,
//     required TextEditingController controller,
//     required Function(LatLng, String) onLocationSelected,
//   }) {
    
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!, width: 1.5),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           Expanded(
//             child: Autocomplete<Map<String, dynamic>>(
//               initialValue: TextEditingValue(text: controller.text),
//               optionsBuilder: (TextEditingValue textEditingValue) async {
//                 if (textEditingValue.text == '') {
//                   return const Iterable<Map<String, dynamic>>.empty();
//                 }
//                 return await widget.controller
//                     .fetchAutoCompletePlaces(textEditingValue.text);
//               },
//               displayStringForOption: (Map<String, dynamic> option) {
//                 return option['description'] ?? '';
//               },
//               onSelected: (Map<String, dynamic> selection) async {
//                 controller.text = selection['description'];
//                 final placeId = selection['place_id'];
//                 if (placeId != null) {
//                   LatLng? coords =
//                       await widget.controller.getLatLngFromPlaceId(placeId);
//                   if (coords != null) {
//                     onLocationSelected(coords, selection['description']);
//                   }
//                 }
//               },
//               fieldViewBuilder:
//                   (context, textController, focusNode, onFieldSubmitted) {
//                 if (textController.text != controller.text) {
//                   textController.text = controller.text;
//                 }
//                 return TextField(
//                   controller: textController,
//                   focusNode: focusNode,
//                   style: const TextStyle(fontSize: 16),
//                   onSubmitted: (val) {
//                     controller.text = val;
//                   },
//                   onChanged: (val) {
//                     controller.text = val;
//                   },
//                   decoration: InputDecoration(
//                       hintText: hint,
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                       isDense: true,
//                       suffixIcon: textController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear,
//                                   size: 20, color: Colors.grey),
//                               onPressed: () {
//                                 textController.clear();
//                                 controller.clear();
//                               },
//                             )
//                           : null),
//                 );
//               },
//               optionsViewBuilder: (context, onSelected, options) {
//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     elevation: 8.0,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.75,
//                       constraints: const BoxConstraints(maxHeight: 250),
//                       color: Colors.white,
//                       child: ListView.separated(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         shrinkWrap: true,
//                         itemCount: options.length,
//                         separatorBuilder: (ctx, i) => const Divider(height: 1),
//                         itemBuilder: (BuildContext context, int index) {
//                           final option = options.elementAt(index);
//                           return ListTile(
//                             leading: const Icon(Icons.location_on_outlined,
//                                 size: 22, color: Colors.grey),
//                             title: Text(option['description'],
//                                 style: const TextStyle(
//                                     fontSize: 14, fontWeight: FontWeight.w500)),
//                             onTap: () => onSelected(option),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
