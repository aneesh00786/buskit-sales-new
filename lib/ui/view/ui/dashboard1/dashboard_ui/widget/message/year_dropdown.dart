// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class YearDropdown extends StatefulWidget {
  // 1. Add the optional callback parameter
  final VoidCallback? onApplyTap;

  const YearDropdown({super.key, this.onApplyTap});

  @override
  _YearDropdownState createState() => _YearDropdownState();
}

class _YearDropdownState extends State<YearDropdown> {
  bool isOnline = false;

  final int startYear = 2024;
  final int endYear = DateTime.now().year;
  late List<int> years;

  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    checkOnline();
    years = startYear <= endYear
        ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
        : [];

    final currentYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      // if (provider.selectedYear == 0) {
        provider.updateSelectedYear(currentYear);
      // }
      // provider.updateSelectedYear(0);
    });
  }

  Future<void> checkOnline() async {
    isOnline = await ConnectivityService().isOnline();
    if (mounted) setState(() {});
  }

  void _selectYear(BuildContext context, int year) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.updateSelectedYear(year);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 45,
              width: 160,
              child: Container(
                key: _dropdownKey,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () async {
                    await checkOnline();
                    if (!isOnline) {
                      showCustomToastDisplay(
                          context, "You are Offline!", red, Icons.close);
                      return;
                    }

                    final RenderBox renderBox = _dropdownKey.currentContext!
                        .findRenderObject() as RenderBox;
                    final Offset position =
                        renderBox.localToGlobal(Offset.zero);
                    final Size size = renderBox.size;

                    await showMenu<int>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        position.dx - 30,
                        position.dy + size.height,
                        position.dx + size.width,
                        position.dy,
                      ),
                      items: years.map((year) {
                        return PopupMenuItem<int>(
                          value: year,
                          child: ListTile(
                            title: Text(year.toString()),
                            trailing: provider.selectedYear == year
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                            onTap: () {
                              Navigator.pop(context); // Close menu
                              _selectYear(context, year);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            provider.selectedYear != 0
                                ? provider.selectedYear.toString()
                                : 'Select Year',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            
            // 2. Updated Go Button Logic
            CustomButton(
              text: 'Go',
              onPressed: () async {
                await checkOnline();
                if (!isOnline) {
                  showCustomToastDisplay(
                      context, "You are Offline!", red, Icons.close);
                  return;
                }

                // Check for custom callback
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
              color: primaryColor,
            ),
          ],
        );
      },
    );
  }
}



// class YearDropdown extends StatefulWidget {
//   const YearDropdown({super.key});

//   @override
//   _YearDropdownState createState() => _YearDropdownState();
// }

// class _YearDropdownState extends State<YearDropdown> {
//   bool isOnline = false;

//   final int startYear = 2024;
//   final int endYear = DateTime.now().year;
//   late List<int> years;

//   final GlobalKey _dropdownKey = GlobalKey(); 

//   @override
//   void initState() {
//     super.initState();
//     checkOnline();
//     years = startYear <= endYear
//         ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
//         : [];

//     final currentYear = DateTime.now().year;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<DashboardProvider>(context, listen: false);
//       if (provider.selectedYear == 0) {
//         provider.updateSelectedYear(currentYear);
//       }
//     });
//   }

//   Future<void> checkOnline() async {
//     isOnline = await ConnectivityService().isOnline();
//     setState(() {}); 
//   }

//   void _selectYear(BuildContext context, int year) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);
//     provider.updateSelectedYear(year);
//     setState(() {}); 
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
//                 key: _dropdownKey,
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
//                 child: GestureDetector(
//                   onTap: () async {
//                     await checkOnline();
//                     if (!isOnline) {
//                       showCustomToastDisplay(
//                           context, "You are Offline!", red, Icons.close);
//                       return;
//                     }

//                     final RenderBox renderBox = _dropdownKey.currentContext!
//                         .findRenderObject() as RenderBox;
//                     final Offset position =
//                         renderBox.localToGlobal(Offset.zero);
//                     final Size size = renderBox.size;

//                     await showMenu<int>(
//                       context: context,
//                       position: RelativeRect.fromLTRB(
//                         position.dx - 30,
//                         position.dy + size.height,
//                         position.dx + size.width,
//                         position.dy,
//                       ),
//                       items: years.map((year) {
//                         return PopupMenuItem<int>(
//                           value: year,
//                           child: ListTile(
//                             title: Text(year.toString()),
//                             trailing: provider.selectedYear == year
//                                 ? const Icon(Icons.check, color: Colors.blue,size: 24,)
//                                 : null,
//                             onTap: () {
//                               Navigator.pop(context); 
//                               _selectYear(context, year);
//                             },
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             provider.selectedYear != 0
//                                 ? provider.selectedYear.toString()
//                                 : 'Select Year',
//                             style: const TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.w500),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const Icon(Icons.arrow_drop_down, size: 20),
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
