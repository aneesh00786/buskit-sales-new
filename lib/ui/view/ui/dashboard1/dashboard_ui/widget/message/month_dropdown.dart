// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MonthDropdown extends StatefulWidget {
  // NEW: Add this optional callback parameter
  final VoidCallback? onApplyTap;

  const MonthDropdown({super.key, this.onApplyTap});

  @override
  _MonthDropdownState createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<MonthDropdown> {
  bool isInitOnline = false;

  final GlobalKey _dropdownKey = GlobalKey(); 

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final Map<String, StateSetter> _monthStateSetters = {};
  StateSetter? _selectAllStateSetter;

  @override
  void initState() {
    super.initState();
    checkOnline();

    final currentMonthIndex = DateTime.now().month;
    final currentMonth = months[currentMonthIndex - 1];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      if (provider.selectedFilterMonths.isEmpty) {
        provider.updateSelectedMonths([currentMonth]);
      }
    });
  }

  Future<void> checkOnline() async {
    isInitOnline = await ConnectivityService().isOnline();
    setState(() {});
  }

  // ... (Your existing toggle logic remains exactly the same) ...
  void _toggleMonthSelection(BuildContext context, String month) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final selectedMonths = provider.selectedFilterMonths;

    if (selectedMonths.contains(month)) {
      selectedMonths.remove(month);
    } else {
      selectedMonths.add(month);
    }
    provider.updateSelectedMonths(List.from(selectedMonths));
    _monthStateSetters[month]?.call(() {});
    _selectAllStateSetter?.call(() {});
    setState(() {});
  }

  void _toggleSelectAll(BuildContext context, bool? value) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    if (value == true) {
      provider.updateSelectedMonths(List.from(months));
    } else {
      provider.updateSelectedMonths([]);
    }
    _selectAllStateSetter?.call(() {});
    for (var setter in _monthStateSetters.values) {
      setter.call(() {});
    }
    setState(() {});
  }

  void _clearSelection(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.updateSelectedMonths([]);
    _selectAllStateSetter?.call(() {});
    for (var setter in _monthStateSetters.values) {
      setter.call(() {});
    }
    setState(() {});
  }

  String _getSelectedText(BuildContext context) {
    final selectedMonths = Provider.of<DashboardProvider>(context).selectedFilterMonths;
    if (selectedMonths.length == months.length) {
      return "All months";
    } else if (selectedMonths.length == 1) {
      return selectedMonths.first;
    } else if (selectedMonths.isNotEmpty) {
      return "${selectedMonths.length} months selected";
    } else {
      return "Select Months";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      bool hasSelection = provider.selectedFilterMonths.isNotEmpty;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            width: 125,
            child: Container(
              key: _dropdownKey,
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
              child: GestureDetector(
                onTap: () async {
                  bool isOnline = await ConnectivityService().isOnline();
                  if (!isOnline) {
                    showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
                    return;
                  }

                  final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
                  final Offset position = renderBox.localToGlobal(Offset.zero);
                  final Size size = renderBox.size;

                  await showMenu<void>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx - 50,
                      53,
                      position.dx + size.width,
                      position.dy,
                    ),
                    items: <PopupMenuEntry<void>>[
                      PopupMenuItem<void>(
                        child: StatefulBuilder(
                          builder: (context, setStatePopup) {
                            _selectAllStateSetter = setStatePopup;
                            return CheckboxListTile(
                              value: provider.selectedFilterMonths.length == months.length,
                              onChanged: (value) {
                                _toggleSelectAll(context, value);
                              },
                              title: const Text("Select All", style: TextStyle(fontWeight: FontWeight.bold)),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                      const PopupMenuDivider(),
                      ...months.map((month) {
                        return PopupMenuItem<void>(
                          child: StatefulBuilder(
                            builder: (context, setStatePopup) {
                              _monthStateSetters[month] = setStatePopup;
                              return CheckboxListTile(
                                value: provider.selectedFilterMonths.contains(month),
                                onChanged: (value) {
                                  _toggleMonthSelection(context, month);
                                },
                                title: Text(month),
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getSelectedText(context),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSelection)
                        GestureDetector(
                          onTap: () => _clearSelection(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.close, size: 16, color: Colors.grey),
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
          
          // --- UPDATED BUTTON LOGIC STARTS HERE ---
          Container(
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
                  return;
                }

                // CHECK: Is a custom action (like Customer Fetch) provided?
                if (widget.onApplyTap != null) {
                  // If yes, execute that action!
                  widget.onApplyTap!();
                } else {
                  // If no, fallback to original Dashboard behavior
                  final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
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
          // --- UPDATED BUTTON LOGIC ENDS HERE ---
        ],
      );
    });
  }
}

// class MonthDropdown extends StatefulWidget {
//   const MonthDropdown({super.key});

//   @override

//   _MonthDropdownState createState() => _MonthDropdownState();
// }

// class _MonthDropdownState extends State<MonthDropdown> {
//   bool isInitOnline = false;

//   final GlobalKey _dropdownKey = GlobalKey(); 

//   final List<String> months = [
//     "January",
//     "February",
//     "March",
//     "April",
//     "May",
//     "June",
//     "July",
//     "August",
//     "September",
//     "October",
//     "November",
//     "December"
//   ];

//   final Map<String, StateSetter> _monthStateSetters = {};
//   StateSetter? _selectAllStateSetter;

//   @override
//   void initState() {
//     super.initState();
//     checkOnline();

//     final currentMonthIndex = DateTime.now().month;
//     final currentMonth = months[currentMonthIndex - 1];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<DashboardProvider>(context, listen: false);
//       if (provider.selectedFilterMonths.isEmpty) {
//         provider.updateSelectedMonths([currentMonth]);
//       }
//     });
//   }

//   Future<void> checkOnline() async {
//     isInitOnline = await ConnectivityService().isOnline();
//     setState(() {});
//   }

//   void _toggleMonthSelection(BuildContext context, String month) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);
//     final selectedMonths = provider.selectedFilterMonths;

//     if (selectedMonths.contains(month)) {
//       selectedMonths.remove(month);
//     } else {
//       selectedMonths.add(month);
//     }

//     provider.updateSelectedMonths(List.from(selectedMonths));

//     _monthStateSetters[month]?.call(() {});
//     _selectAllStateSetter?.call(() {});
//     setState(() {});
//   }

//   void _toggleSelectAll(BuildContext context, bool? value) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);

//     if (value == true) {
//       provider.updateSelectedMonths(List.from(months));
//     } else {
//       provider.updateSelectedMonths([]);
//     }

//     _selectAllStateSetter?.call(() {});
//     for (var setter in _monthStateSetters.values) {
//       setter.call(() {});
//     }
//     setState(() {});
//   }

//   void _clearSelection(BuildContext context) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);
//     provider.updateSelectedMonths([]);

//     _selectAllStateSetter?.call(() {});
//     for (var setter in _monthStateSetters.values) {
//       setter.call(() {});
//     }
//     setState(() {});
//   }

//   String _getSelectedText(BuildContext context) {
//     final selectedMonths =
//         Provider.of<DashboardProvider>(context).selectedFilterMonths;

//     if (selectedMonths.length == months.length) {
//       return "All months";
//     } else if (selectedMonths.length == 1) {
//       return selectedMonths.first;
//     } else if (selectedMonths.isNotEmpty) {
//       return "${selectedMonths.length} months selected";
//     } else {
//       return "Select Months";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DashboardProvider>(builder: (context, provider, child) {
//       bool hasSelection = provider.selectedFilterMonths.isNotEmpty;

//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             height: 45,
//             width: 180,
//             child: Container(
//               key: _dropdownKey,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300, width: 1),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade50,
//                     blurRadius: 8,
//                     offset: const Offset(2, 4),
//                   ),
//                 ],
//               ),
//               child: GestureDetector(
//                 onTap: () async {
//                   bool isOnline = await ConnectivityService().isOnline();
//                   if (!isOnline) {
//                     showCustomToastDisplay(
//                         context, "You are Offline!", red, Icons.close);
//                     return;
//                   }

//                   final RenderBox renderBox = _dropdownKey.currentContext!
//                       .findRenderObject() as RenderBox;
//                   final Offset position = renderBox.localToGlobal(Offset.zero);
//                   final Size size = renderBox.size;

//                   await showMenu<void>(
//                     context: context,
//                     position: RelativeRect.fromLTRB(
//                       position.dx - 50,
//                       53,
//                       position.dx + size.width,
//                       position.dy,
//                     ),
//                     items: <PopupMenuEntry<void>>[
//                       PopupMenuItem<void>(
//                         child: StatefulBuilder(
//                           builder: (context, setStatePopup) {
//                             _selectAllStateSetter = setStatePopup;
//                             return CheckboxListTile(
//                               value: provider.selectedFilterMonths.length ==
//                                   months.length,
//                               onChanged: (value) {
//                                 _toggleSelectAll(context, value);
//                               },
//                               title: const Text("Select All",
//                                   style:
//                                       TextStyle(fontWeight: FontWeight.bold)),
//                               controlAffinity: ListTileControlAffinity.leading,
//                             );
//                           },
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       ...months.map((month) {
//                         return PopupMenuItem<void>(
//                           child: StatefulBuilder(
//                             builder: (context, setStatePopup) {
//                               _monthStateSetters[month] = setStatePopup;
//                               return CheckboxListTile(
//                                 value: provider.selectedFilterMonths
//                                     .contains(month),
//                                 onChanged: (value) {
//                                   _toggleMonthSelection(context, month);
//                                 },
//                                 title: Text(month),
//                                 controlAffinity:
//                                     ListTileControlAffinity.leading,
//                               );
//                             },
//                           ),
//                         );
//                       }),
//                     ],
//                   );
//                 },
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           _getSelectedText(context),
//                           style: const TextStyle(
//                               fontSize: 12, fontWeight: FontWeight.w500),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       if (hasSelection)
//                         GestureDetector(
//                           onTap: () => _clearSelection(context),
//                           child: const Padding(
//                             padding: EdgeInsets.only(right: 8),
//                             child:
//                                 Icon(Icons.close, size: 16, color: Colors.grey),
//                           ),
//                         ),
//                       const Icon(Icons.arrow_drop_down, size: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 5),
//           CustomButton(
//             text: 'Go',
//             onPressed: () async {
//               bool isOnline = await ConnectivityService().isOnline();
//               if (!isOnline) {
//                 showCustomToastDisplay(
//                     context, "You are Offline!", red, Icons.close);
//                 return;
//               }

//               final dashboardProvider =
//                   Provider.of<DashboardProvider>(context, listen: false);

//               await dashboardProvider.setTempToFilter();
//               await dashboardProvider.fetchAllOrdersAtOnce();
//               dashboardProvider.fetchData();
//             },
//             color: primaryColor,
//           ),
//         ],
//       );
//     });
//   }
// }
