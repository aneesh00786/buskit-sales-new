// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';



class DatePickerWidget extends StatefulWidget {
  // 1. Add the optional callback parameter
  final VoidCallback? onApplyTap;

  const DatePickerWidget({super.key, this.onApplyTap});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    checkOnline();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      
      // format: yyyy-MM-dd (matches your _selectDate logic)
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      provider.updateSelectedDate(today);
    });
  }

  Future<void> checkOnline() async {
    isOnline = await ConnectivityService().isOnline();
    if (mounted) setState(() {}); 
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      // Updates the selectedDate in DashboardProvider
      Provider.of<DashboardProvider>(context, listen: false)
          .updateSelectedDate(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              width: 125,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 0,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    await checkOnline();
                    if (!isOnline) {
                      showCustomToastDisplay(
                          context, "You are Offline!", red, Icons.close);
                      return;
                    }
                    _selectDate(context);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            provider.selectedDate.isNotEmpty
                                ? DateFormat('dd-MM-yyyy').format(
                                    DateTime.parse(provider.selectedDate))
                                : "DD-MM-YYYY",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            
            // 2. Updated Go Button Logic
            Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await checkOnline();
                  if (!isOnline) {
                    showCustomToastDisplay(
                        context, "You are Offline!", red, Icons.close);
                    return;
                  }

                  // Check if Custom Action is provided
                  if (widget.onApplyTap != null) {
                    widget.onApplyTap!();
                  } else {
                    // Default Dashboard Logic
                    final dashboardProvider =
                        Provider.of<DashboardProvider>(context, listen: false);
                    await dashboardProvider.setTempToFilter();

                    await dashboardProvider.fetchAllOrdersAtOnce();

                    dashboardProvider.fetchData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ],
        );
      },
    );
  }
}


// class DatePickerWidget extends StatefulWidget {
//   const DatePickerWidget({super.key});

//   @override
//   _DatePickerWidgetState createState() => _DatePickerWidgetState();
// }

// class _DatePickerWidgetState extends State<DatePickerWidget> {
//   bool isOnline = false;

//   @override
//   void initState() {
//     super.initState();
//     checkOnline();
//   }

//   Future<void> checkOnline() async {
//     isOnline = await ConnectivityService().isOnline();
//     setState(() {}); // Refresh UI when online status changes
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime now = DateTime.now();
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//       Provider.of<DashboardProvider>(context, listen: false)
//           .updateSelectedDate(formattedDate);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DashboardProvider>(
//       builder: (context, provider, child) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 45,
//               width: 160,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade300, width: 1),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.shade50,
//                       blurRadius: 8,
//                       offset: const Offset(2, 4),
//                     ),
//                   ],
//                 ),
//                 child: InkWell(
//                   onTap: () async {
//                     await checkOnline();
//                     if (!isOnline) {
//                       showCustomToastDisplay(
//                           context, "You are Offline!", red, Icons.close);
//                       return;
//                     }
//                     _selectDate(context);
//                   },
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             provider.selectedDate.isNotEmpty
//                                 ? DateFormat('dd-MM-yyyy').format(
//                                     DateTime.parse(provider.selectedDate))
//                                 : "DD-MM-YYYY",
//                             style: const TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.w500),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const Icon(Icons.calendar_today,
//                             size: 18, color: Colors.blue),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 5),
//             CustomButton(
//               text: 'Go',
//               onPressed: () async {
//                 await checkOnline();
//                 if (!isOnline) {
//                   showCustomToastDisplay(
//                       context, "You are Offline!", red, Icons.close);
//                   return;
//                 }

//                 final dashboardProvider =
//                     Provider.of<DashboardProvider>(context, listen: false);
//                 await dashboardProvider.setTempToFilter();

//                 // DASHBOARD TOP WIDGET ONTAP DIALOG DATA
//                 await dashboardProvider.fetchAllOrdersAtOnce();

//                 dashboardProvider.fetchData();
//               },
//               color: primaryColor,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
