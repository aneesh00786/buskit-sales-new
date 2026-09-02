// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';



class WeekDropdown extends StatefulWidget {
  // 1. Add the callback parameter
  final VoidCallback? onApplyTap;

  const WeekDropdown({super.key, this.onApplyTap});

  @override
  _WeekDropdownState createState() => _WeekDropdownState();
}

class _WeekDropdownState extends State<WeekDropdown> {
  bool isOnline = false;

  final GlobalKey _dropdownKey = GlobalKey();

  late final List<String> weeks;
  final Map<String, StateSetter> _weekStateSetters = {};
  StateSetter? _selectAllStateSetter;

  @override
  void initState() {
    super.initState();

    checkOnline();

    int totalWeeks = DateTimeRange(
          start: DateTime(DateTime.now().year, 1, 1),
          end: DateTime(DateTime.now().year, 12, 31),
        ).duration.inDays ~/ 7;

    weeks = List.generate(totalWeeks, (index) => "week${index + 1}");

    final firstDayOfYear = DateTime(DateTime.now().year, 1, 1);
  final daysSinceStart = DateTime.now().difference(firstDayOfYear).inDays;
  final currentWeekNumber = (daysSinceStart ~/ 7) + 1;
  final currentWeek = "week$currentWeekNumber";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      if (provider.selectedFilterWeeks.isEmpty) {
        provider.updateSelectedWeeks([currentWeek]);
      }
      // provider.updateSelectedWeeks([]);
    });
  }

  Future<void> checkOnline() async {
    isOnline = await ConnectivityService().isOnline();
    if (mounted) setState(() {});
  }

  void _toggleWeekSelection(BuildContext context, String week) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final selectedWeeks = provider.selectedFilterWeeks;

    final formattedWeek = week.toLowerCase().replaceAll(' ', '');

    if (selectedWeeks.contains(formattedWeek)) {
      selectedWeeks.remove(formattedWeek);
    } else {
      selectedWeeks.add(formattedWeek);
    }

    provider.updateSelectedWeeks(List.from(selectedWeeks));
    _weekStateSetters[week]?.call(() {});
    _selectAllStateSetter?.call(() {});
    setState(() {});
  }

  void _toggleSelectAll(BuildContext context, bool? value) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    if (value == true) {
      provider.updateSelectedWeeks(
          List.from(weeks.map((w) => w.toLowerCase().replaceAll(' ', ''))));
    } else {
      provider.updateSelectedWeeks([]);
    }

    _selectAllStateSetter?.call(() {});
    for (var week in weeks) {
      _weekStateSetters[week]?.call(() {});
    }

    setState(() {});
  }

  void _clearSelection(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.updateSelectedWeeks([]);

    _selectAllStateSetter?.call(() {});
    for (var setter in _weekStateSetters.values) {
      setter.call(() {});
    }
    setState(() {});
  }

  String _getSelectedText(BuildContext context) {
    final selectedWeeks =
        Provider.of<DashboardProvider>(context).selectedFilterWeeks;

    if (selectedWeeks.length == weeks.length) {
      return "All weeks";
    } else if (selectedWeeks.length == 1) {
      return selectedWeeks.first.replaceAll("week", "Week ");
    } else if (selectedWeeks.isNotEmpty) {
      return "${selectedWeeks.length} weeks selected";
    } else {
      return "Select Weeks";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      bool hasSelection = provider.selectedFilterWeeks.isNotEmpty;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 42,
            width: 125,
            child: Container(
              key: _dropdownKey,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                              value: provider.selectedFilterWeeks.length ==
                                  weeks.length,
                              onChanged: (value) {
                                _toggleSelectAll(context, value);
                              },
                              title: const Text("Select All",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                      const PopupMenuDivider(),
                      ...weeks.map((week) {
                        return PopupMenuItem<void>(
                          child: StatefulBuilder(
                            builder: (context, setStatePopup) {
                              _weekStateSetters[week] = setStatePopup;
                              return CheckboxListTile(
                                value: provider.selectedFilterWeeks.contains(
                                    week.toLowerCase().replaceAll(' ', '')),
                                onChanged: (value) {
                                  _toggleWeekSelection(context, week);
                                },
                                title: Text(week.replaceAll("week", "Week ")),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getSelectedText(context),
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSelection)
                        GestureDetector(
                          onTap: () => _clearSelection(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child:
                                Icon(Icons.close, size: 16, color: Colors.grey),
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
          // Container(
          //   height: 50,
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       if (!isOnline) {
          //         showCustomToastDisplay(
          //             context, "You are Offline!".tr, red, Icons.close);
          //         return;
          //       }

          //       // CHECK: If custom action exists, run it. Else, run Dashboard logic.
          //       if (widget.onApplyTap != null) {
          //         widget.onApplyTap!();
          //       } else {
          //         final dashboardProvider =
          //             Provider.of<DashboardProvider>(context, listen: false);

          //         await dashboardProvider.setTempToFilter();
          //         await dashboardProvider.fetchAllOrdersAtOnce();
          //         dashboardProvider.fetchData();
          //       }
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: primaryColor,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       elevation: 4,
          //       shadowColor: primaryColor.withOpacity(0.4),
          //       textStyle: const TextStyle(
          //         fontSize: 13,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //     child: const Text('Go'),
          //   ),
          // ),
        ],
      );
    });
  }
}


// class WeekDropdown extends StatefulWidget {
//   const WeekDropdown({super.key});

//   @override
//   _WeekDropdownState createState() => _WeekDropdownState();
// }

// class _WeekDropdownState extends State<WeekDropdown> {
//   bool isOnline = false;

//   final GlobalKey _dropdownKey = GlobalKey();

//   late final List<String> weeks;
//   final Map<String, StateSetter> _weekStateSetters = {};
//   StateSetter? _selectAllStateSetter;

//   @override
//   void initState() {
//     super.initState();

//     checkOnline();

//     int totalWeeks = DateTimeRange(
//           start: DateTime(DateTime.now().year, 1, 1),
//           end: DateTime(DateTime.now().year, 12, 31),
//         ).duration.inDays ~/
//         7;

//     weeks = List.generate(totalWeeks, (index) => "week${index + 1}");

//     final currentWeek =
//         "week${((DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays) ~/ 7) + 1}";

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<DashboardProvider>(context, listen: false);
//       if (provider.selectedFilterWeeks.isEmpty) {
//         provider.updateSelectedWeeks([currentWeek]);
//       }
//     });
//   }

//   Future<void> checkOnline() async {
//     isOnline = await ConnectivityService().isOnline();
//     setState(() {}); 
//   }

//   void _toggleWeekSelection(BuildContext context, String week) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);
//     final selectedWeeks = provider.selectedFilterWeeks;

//     final formattedWeek = week.toLowerCase().replaceAll(' ', '');

//     if (selectedWeeks.contains(formattedWeek)) {
//       selectedWeeks.remove(formattedWeek);
//     } else {
//       selectedWeeks.add(formattedWeek);
//     }

//     provider.updateSelectedWeeks(List.from(selectedWeeks));
//     _weekStateSetters[week]?.call(() {});
//     _selectAllStateSetter?.call(() {});
//     setState(() {});
//   }

//   void _toggleSelectAll(BuildContext context, bool? value) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);

//     if (value == true) {
//       provider.updateSelectedWeeks(
//           List.from(weeks.map((w) => w.toLowerCase().replaceAll(' ', ''))));
//     } else {
//       provider.updateSelectedWeeks([]);
//     }

//     _selectAllStateSetter?.call(() {});
//     for (var week in weeks) {
//       _weekStateSetters[week]?.call(() {});
//     }

//     setState(() {});
//   }

//   void _clearSelection(BuildContext context) {
//     final provider = Provider.of<DashboardProvider>(context, listen: false);
//     provider.updateSelectedWeeks([]);

//     _selectAllStateSetter?.call(() {});
//     for (var setter in _weekStateSetters.values) {
//       setter.call(() {});
//     }
//     setState(() {});
//   }

//   String _getSelectedText(BuildContext context) {
//     final selectedWeeks =
//         Provider.of<DashboardProvider>(context).selectedFilterWeeks;

//     if (selectedWeeks.length == weeks.length) {
//       return "All weeks";
//     } else if (selectedWeeks.length == 1) {
//       return selectedWeeks.first.replaceAll("week", "Week ");
//     } else if (selectedWeeks.isNotEmpty) {
//       return "${selectedWeeks.length} weeks selected";
//     } else {
//       return "Select Weeks";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DashboardProvider>(builder: (context, provider, child) {
//       bool hasSelection = provider.selectedFilterWeeks.isNotEmpty;

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
//                   await checkOnline();
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
//                               value: provider.selectedFilterWeeks.length ==
//                                   weeks.length,
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
//                       ...weeks.map((week) {
//                         return PopupMenuItem<void>(
//                           child: StatefulBuilder(
//                             builder: (context, setStatePopup) {
//                               _weekStateSetters[week] = setStatePopup;
//                               return CheckboxListTile(
//                                 value: provider.selectedFilterWeeks.contains(
//                                     week.toLowerCase().replaceAll(' ', '')),
//                                 onChanged: (value) {
//                                   _toggleWeekSelection(context, week);
//                                 },
//                                 title: Text(week.replaceAll("week", "Week ")),
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
