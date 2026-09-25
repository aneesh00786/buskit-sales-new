// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

<<<<<<< HEAD
import 'dart:async';

=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarx.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/services/checkin_service.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class CustomSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final bool active;
  final String selectedName;
  final String customerId;

  const CustomSwitch({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.active,
    required this.selectedName,
    required this.customerId,
  });

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}


class _CustomSwitchState extends State<CustomSwitch> {
  final subscriptionController = Get.find<SubscriptionController>();

  late bool isOn;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  void _toggleSwitch() {
    setState(() {
      isOn = !isOn;
    });
    widget.onChanged(isOn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isOn ? Colors.green : Colors.red,
        content: Text(isOn
            ? 'You are successfully checked-in'.tr
            : 'You are successfully checked-out'.tr),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveCheckInOutRequestOffline({
    required String date,
    required String time,
    required String direction,
    required String lat,
    required String long,
    required String customerId,
  }) async {
    final box = await Hive.openBox('offlineRequests');
    final payload = {
      "custid": customerId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "direction": direction,
      "time": time,
      "longitude": double.tryParse(long) ?? 0.0,
      "latitude": double.tryParse(lat) ?? 0.0,
    };
    await box.add({
      'url': ApiConstants.baseUrl + ApiConstants.updateCheckinCustomer,
      'payload': payload,
<<<<<<< HEAD
      // The live customer check-in/out call sends a JSON body (see
      // ApiWorker.updateCustomerCheckInOut), not multipart form-data.
      'isJson': true,
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
    });
  }

  // Helper method to show standard confirmation dialogs
  Future<bool> _showConfirmDialog(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          title: Row(
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 25.0,
                color: primaryColor,
              ),
              const SizedBox(width: 8.0),
              Text(
                title.tr,
                style: const TextStyle(
                  fontFamily: myFont,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            content.tr,
            style: const TextStyle(
              fontFamily: myFont,
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: primaryColor, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: myFont,
                        fontSize: 14.0,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: Colors.green, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Confirm'.tr,
                      style: const TextStyle(
                        fontFamily: myFont,
                        fontSize: 14.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _handleSwitchToggle(BuildContext context) async {
    bool newState = !isOn;
    bool proceedWithCustomerCheckIn = false;

    // --- NEW LOGIC: Check Attendance Status First ---
    if (newState == true) { // If user is trying to check IN
      bool isAttendanceCheckedIn = await ApiWorker().loadSwitchState();

      if (!isAttendanceCheckedIn) {
        // Show dual check-in dialog
        bool? confirmBoth = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
              actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 25.0,
                    color: primaryColor,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Required',
                    style: TextStyle(
                      fontFamily: myFont,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Text(
                'You are required to sign in, to proceed with customer location check-in and order taking'.tr,
                style: const TextStyle(
                  fontFamily: myFont,
                  fontSize: 14.0,
                  color: Colors.black87,
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          side: const BorderSide(color: primaryColor, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel'.tr,
                          style: const TextStyle(
                            fontFamily: myFont,
                            fontSize: 14.0,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          side: const BorderSide(color: Colors.green, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Check-In'.tr,
                          style: const TextStyle(
                            fontFamily: myFont,
                            fontSize: 14.0,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );

        if (confirmBoth == true) {
          setState(() {
            _isLoading = true;
          });

          // 1. Perform daily attendance check-in
          await CheckInService().performCheckIn(context);

          // Verify if daily attendance check-in actually succeeded
          // (User might have cancelled location permissions during the process)
          bool verifyAttendance = await ApiWorker().loadSwitchState();
          if (verifyAttendance) {
            proceedWithCustomerCheckIn = true; // Safe to proceed to customer check-in
          } else {
            setState(() {
              _isLoading = false;
            });
            return; // Abort if attendance failed
          }
        } else {
          return; // User cancelled the popup
        }
      } else {
        // Already checked in for attendance, standard confirmation
        proceedWithCustomerCheckIn = await _showConfirmDialog(
          context, 
          'Confirm Check-In'.tr, 
          'Are you sure you want to check in to this customer?'.tr
        );
      }
    } else {
      // Checking OUT of customer, standard confirmation
      proceedWithCustomerCheckIn = await _showConfirmDialog(
        context, 
        'Confirm Check-Out'.tr, 
        'Are you sure you want to check out?'.tr
      );
    }

    // --- EXISTING CUSTOMER CHECK-IN LOGIC ---
    if (proceedWithCustomerCheckIn) {
      if (!await handleLocationPermission(context)) {
        setState(() { _isLoading = false; });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
<<<<<<< HEAD
        Position position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );
        } on TimeoutException {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            position = lastKnown;
          } else {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 10),
            );
          }
        }
=======
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a

        final connectivityService = ConnectivityService();
        final isOnline = await connectivityService.isOnline();
        final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
        final time =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()).toString();
        final direction = newState ? "IN" : "OUT";
        final lat = position.latitude.toString();
        final long = position.longitude.toString();
        final customerId = widget.customerId;

        if (!isOnline) {
          await _saveCheckInOutRequestOffline(
            date: date,
            time: time,
            direction: direction,
            lat: lat,
            long: long,
            customerId: customerId,
          );
          if (mounted) {
            _toggleSwitch();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text(
                    'You are offline. Your check-in/out will sync when online.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          final response = await ApiWorker().updateCustomerCheckInOut(
              date: date,
              time: time,
              direction: direction,
              lat: lat,
              long: long,
              customerId: customerId);

          if (response.statusCode != 200) {
            showCustomToastDisplay(
                context, response.statusMessage.toString(), Colors.red, Icons.close);
          }

          if (response.statusCode == 200) {
            // await ApiWorker().saveSwitchState(newState);

            if (mounted) {
              _toggleSwitch();
            }
          }
        }
      } catch (e) {
<<<<<<< HEAD
        if (mounted) {
          final message = e is TimeoutException
              ? 'Unable to get your current location. Please make sure GPS is turned on and try again.'
              : 'Something went wrong. Please try again.';
          showCustomToastDisplay(context, message, Colors.red, Icons.close);
        }
=======
        // Handle error
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: subscriptionController.customerCheckInOut.value == "true"
          ? widget.selectedName.isNotEmpty
              ? () => _handleSwitchToggle(context)
              : () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                        actionsAlignment: MainAxisAlignment.center,
                        title: const Center(
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 50,
                          ),
                        ),
                        content: CustomText(
                          content: 'Please select a customer to check-in'.tr,
                          fontSize: 14,
                        ),
                        actions: [
                          SizedBox(
                            width: 150,
                            height: 45,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'OK'.tr,
                                style: const TextStyle(
                                  fontFamily: myFont,
                                  color: Color(0xFF727CF5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
          : () {
              showUpgradePlanDialog(context);
            },
      child: _isLoading
          ? const SizedBox(
              width: 140.0,
              height: 50.0,
              child: Center(child: CircularProgressIndicator()))
          : Container(
              width: 140.0,
              height: 50.0,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: isOn ? Colors.green : Colors.red,
              ),
              child: Stack(
                alignment: isOn ? Alignment.centerLeft : Alignment.centerRight,
                children: [
                  Padding(
                    padding: isOn
                        ? const EdgeInsets.only(left: 8)
                        : const EdgeInsets.only(right: 8),
                    child: MyRegularText(
                      label: isOn ? "Checked-in".tr : "Check-out".tr,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
<<<<<<< HEAD
                      fontSize: 12,
=======
                      fontSize: 15,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment:
                        isOn ? Alignment.centerRight : Alignment.centerLeft,
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isOn
                              ? EneftyIcons.tick_circle_outline
                              : EneftyIcons.close_circle_outline,
                          color: isOn ? Colors.green : Colors.red,
                          size: 25,
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
// class _CustomSwitchState extends State<CustomSwitch> {
//   final subscriptionController = Get.find<SubscriptionController>();

//   late bool isOn;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     isOn = widget.initialValue;
//   }

//   void _toggleSwitch() {
//     setState(() {
//       isOn = !isOn;
//     });
//     widget.onChanged(isOn);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: isOn ? Colors.green : Colors.red,
//         content: Text(isOn
//             ? 'You are successfully checked-in'
//             : 'You are successfully checked-out'),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> _saveCheckInOutRequestOffline({
//     required String date,
//     required String time,
//     required String direction,
//     required String lat,
//     required String long,
//     required String customerId,
//   }) async {
//     final box = await Hive.openBox('offlineRequests');
//     final payload = {
//       "custid": customerId,
//       "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
//       "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
//       "direction": direction,
//       "time": time,
//       "longitude": double.tryParse(long) ?? 0.0,
//       "latitude": double.tryParse(lat) ?? 0.0,
//     };
//     await box.add({
//       'url': ApiConstants.baseUrl + ApiConstants.updateCheckinCustomer,
//       'payload': payload,
//     });
//   }

//   void _handleSwitchToggle(BuildContext context) async {
//     bool newState = !isOn;

//     // Show confirmation dialog
//     bool? confirmAction = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(!isOn ? 'Confirm Check-In' : 'Confirm Check-Out'),
//           content: Text(
//               'Are you sure you want to ${!isOn ? 'check in' : 'check out'}?'),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             ElevatedButton(
//               child: const Text('Confirm'),
//               onPressed: () => Navigator.of(context).pop(true),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmAction == true) {
//       if (!await handleLocationPermission(context)) {
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           // ignore: deprecated_member_use
//           desiredAccuracy: LocationAccuracy.high,
//         );

//         final connectivityService = ConnectivityService();
//         final isOnline = await connectivityService.isOnline();
//         final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//         final time =
//             DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()).toString();
//         final direction = newState ? "IN" : "OUT";
//         final lat = position.latitude.toString();
//         final long = position.longitude.toString();
//         final customerId = widget.customerId;
//   print('customer id :$customerId');
//         if (!isOnline) {
//           // Save request offline and change switch state immediately
//           await _saveCheckInOutRequestOffline(
//             date: date,
//             time: time,
//             direction: direction,
//             lat: lat,
//             long: long,
//             customerId: customerId,
//           );
//           if (mounted) {
//             _toggleSwitch();
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 backgroundColor: Colors.orange,
//                 content: Text(
//                     'You are offline. Your check-in/out will sync when online.'),
//                 duration: Duration(seconds: 3),
//               ),
//             );
//           }
//         } else {
//           final response = await ApiWorker().updateCustomerCheckInOut(
//               date: date,
//               time: time,
//               direction: direction,
//               lat: lat,
//               long: long,
//               customerId: customerId);

//           if (response.statusCode != 200) {
//             showCustomToastDisplay(
//                 context, response.statusMessage.toString(), red, Icons.close);
//           }

//           if (response.statusCode == 200) {
//             await ApiWorker().saveSwitchState(newState);

//             if (mounted) {
//               _toggleSwitch();
//             }
//           }
//         }
//       } catch (e) {
//       //
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     return GestureDetector(
//       onTap: subscriptionController.customerCheckInOut.value == "true"
//           ? widget.selectedName.isNotEmpty
//               ? () => _handleSwitchToggle(context)
//               : () {
//                   showDialog(
//                     barrierDismissible: false,
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         actions: [
//                           const SizedBox(height: 20),
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Icon(
//                                 Icons.warning_amber_rounded,
//                                 color: Colors.orange,
//                                 size: 50,
//                               ),
//                             ),
//                           ),
//                           Center(
//                             child: CustomText(
//                               content: 'Please select a customer to check-in',
//                               fontSize: 17,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Ok'),
//                           )
//                         ],
//                       );
//                     },
//                   );
//                 }
//           : () {
//               showUpgradePlanDialog(context);
//             },
//       child: _isLoading
//           ? SizedBox(
//               width: 140.0,
//               height: 50.0,
//               child: Center(child: CircularProgressIndicator()))
//           : Container(
//               width: 140.0,
//               height: 50.0,
//               padding: const EdgeInsets.all(4.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25.0),
//                 color: isOn ? Colors.green : Colors.red,
//               ),
//               child: Stack(
//                 alignment: isOn ? Alignment.centerLeft : Alignment.centerRight,
//                 children: [
//                   Padding(
//                     padding: isOn
//                         ? const EdgeInsets.only(left: 8)
//                         : const EdgeInsets.only(right: 8),
//                     child: MyRegularText(
//                       label: isOn ? "Checked-in" : "Check-out",
//                       color: white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                   AnimatedAlign(
//                     duration: const Duration(milliseconds: 300),
//                     alignment:
//                         isOn ? Alignment.centerRight : Alignment.centerLeft,
//                     curve: Curves.easeInOut,
//                     child: Container(
//                       width: 40.0,
//                       height: 40.0,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 4.0,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Icon(
//                           isOn
//                               ? EneftyIcons.tick_circle_outline
//                               : EneftyIcons.close_circle_outline,
//                           color: isOn ? Colors.green : Colors.red,
//                           size: 25,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
