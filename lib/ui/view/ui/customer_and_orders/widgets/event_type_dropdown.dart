// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, library_private_types_in_public_api, deprecated_member_use

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart'; // Assuming GetX is used based on your code

// Enum and Extension
enum EventType {
  select,
  weekly,
  fortnightly,
  monthly,
  daily,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.select:
        return "-Select-";
      case EventType.weekly:
        return "Weekly";
      case EventType.fortnightly:
        return "Fortnightly";
      case EventType.monthly:
        return "Monthly";
      case EventType.daily:
        return "Daily";
    }
  }

  int get value {
    switch (this) {
      case EventType.select:
        return 0;
      case EventType.weekly:
        return 2;
      case EventType.fortnightly:
        return 3;
      case EventType.monthly:
        return 4;
      case EventType.daily:
        return 5;
    }
  }

  static EventType fromValue(int value) {
    switch (value) {
      case 0:
        return EventType.select;
      case 2:
        return EventType.weekly;
      case 3:
        return EventType.fortnightly;
      case 4:
        return EventType.monthly;
      case 5:
        return EventType.daily;
      default:
        return EventType.weekly;
    }
  }
}

// Widget Class
class EventTypeDropdown extends StatefulWidget {
  final EventType initialValue;
  final Function(EventType) onChanged;
  final List<String> defaultEventDays;
  final String customerId;
  final int eventPeriod;
  final int eventStatus;
  final dynamic provider; // using dynamic or CustomersProvider type

  const EventTypeDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.defaultEventDays,
    required this.customerId,
    required this.eventPeriod,
    required this.eventStatus,
    required this.provider,
  });

  @override
  _EventTypeDropdownState createState() => _EventTypeDropdownState();
}

class _EventTypeDropdownState extends State<EventTypeDropdown> {
  late EventType selectedValue;
  bool isLoading = false;

  // Assuming SubscriptionController is available via GetX
  var subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xffdddefc),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            height: 38,
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 2),
              child: GestureDetector(
                onTap: () {
                  if (subscriptionController.visitSetting.value != 'true') {
                    // showUpgradePlanDialog(context); // Make sure this function exists
                  }
                },
                child: AbsorbPointer(
                  absorbing: subscriptionController.visitSetting.value != 'true',
                  child: DropdownButton<EventType>(
                    iconSize: 17.5,
                    value: selectedValue,
                    onChanged: (EventType? newValue) async {
                      if (newValue != null) {
                        // 1. Guard: Prevent action if selecting the same value
                        if (newValue == selectedValue) {
                          return;
                        }

                        // Capture previous value
                        final previousValue = selectedValue;

                        // ==========================================================
                        // CASE A: User selected "-Select-" (DELETE EVENT)
                        // ==========================================================
                        if (newValue == EventType.select) {
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              bool isDialogLoading = false;

                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.all(20),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded,
                                                color: Colors.redAccent),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Cancel Visit",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Are you sure you want to cancel the existing ${selectedValue.displayName} visit?",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (isDialogLoading)
                                              const CircularProgressIndicator()
                                            else ...[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text("No, Keep it",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  setStateDialog(() {
                                                    isDialogLoading = true;
                                                  });

                                                  try {
                                                    Dio dio = Dio();
                                                    final response = await dio.post(
                                                      'https://test.thrivewoo.com/delete_future_events',
                                                      data: {
                                                        "customer_id":
                                                            widget.customerId
                                                      },
                                                    );

                                                    if (response.statusCode ==
                                                        200) {
                                                      await widget.provider
                                                          .fetchCustomerData(
                                                        page: widget.provider
                                                            .currentPage,
                                                      );

                                                      setState(() {
                                                        selectedValue = newValue;
                                                      });
                                                      widget
                                                          .onChanged(newValue);

                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  } catch (e) {
                                                    Navigator.of(context).pop();
                                                  } finally {
                                                    if (mounted) {
                                                      setStateDialog(() {
                                                        isDialogLoading = false;
                                                      });
                                                    }
                                                  }
                                                },
                                                child: const Text("Yes, Cancel",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          return;
                        }

                        // ==========================================================
                        // CASE B: User selected a new Event Type (CHANGE EVENT)
                        // ==========================================================

                        // 1. Show Change Confirmation (Only if NOT coming from Select)
                        if (selectedValue != EventType.select) {
                          bool? confirmChange = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.all(20),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Change Visit Type",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Are you sure you want to change the visit from ${selectedValue.displayName} to ${newValue.displayName}?",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(false),
                                          child: const Text("Cancel",
                                              style: TextStyle(
                                                  color: Colors.orange)),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(true),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          // If user cancels the "Change Visit" dialog, stop everything
                          if (confirmChange != true) {
                            return;
                          }
                        }

                        // 2. Proceed with Logic
                        if (newValue == EventType.daily) {
                          setState(() {
                            selectedValue = newValue;
                          });

                          // Only show "Are you sure you want to add" if coming from Select
                          if (previousValue == EventType.select) {
                            bool? confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                bool isDialogLoading = false;
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.all(20),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  color: Colors.orange),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Are you sure you want to add this visit to the calendar?.",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (isDialogLoading)
                                                const CircularProgressIndicator()
                                              else ...[
                                                ElevatedButton(
                                                  onPressed: (){
                                                      Navigator.of(context)
                                                          .pop(false);
                                                  }, 
                                                     style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.grey),
                                                  child: Text('Cancel',style: TextStyle(color: Colors.white),)
                                                  ),

                                                // TextButton(
                                                //   onPressed: () =>
                                                //       Navigator.of(context)
                                                //           .pop(false),
                                                //   child: const Text("Cancel",
                                                //       style: TextStyle(
                                                //           color:
                                                //               Colors.orange)),
                                                // ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    setStateDialog(() {
                                                      isDialogLoading = true;
                                                    });
                                                    try {
                                                      final response =
                                                          await widget.provider
                                                              .addEvent(
                                                        widget.customerId,
                                                        5,
                                                        [],
                                                        "",
                                                        context,
                                                      );
                                                      if (response.statusCode !=
                                                          200) {
                                                        // showCustomToastDisplay(context, response.message, red, Icons.close);
                                                        await Future.delayed(
                                                            const Duration(
                                                                seconds: 2));
                                                        Navigator.of(context)
                                                            .pop(false);
                                                        return;
                                                      }
                                                      await widget.provider
                                                          .fetchCustomerData(
                                                              page: widget
                                                                  .provider
                                                                  .currentPage);
                                                      widget
                                                          .onChanged(newValue);
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    } catch (e) {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    } finally {
                                                      setStateDialog(() {
                                                        isDialogLoading = false;
                                                      });
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  child: const Text("Continue"),
                                                ),
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );

                            if (confirmed != true) {
                              setState(() {
                                selectedValue = previousValue;
                              });
                            }
                          } else {
                            // User came from Weekly/Monthly (already confirmed "Change Visit").
                            // Skip the "Add Event" popup, call API directly with a loader.
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                  child: CircularProgressIndicator()),
                            );

                            try {
                              final response = await widget.provider.addEvent(
                                widget.customerId,
                                5,
                                [],
                                "",
                                context,
                              );

                              Navigator.of(context).pop(); // Close loader

                              if (response.statusCode == 200) {
                                await widget.provider.fetchCustomerData(
                                    page: widget.provider.currentPage);
                                widget.onChanged(newValue);
                              } else {
                                // Revert on API error
                                setState(() {
                                  selectedValue = previousValue;
                                });
                                // showCustomToastDisplay(context, response.message, red, Icons.close);
                              }
                            } catch (e) {
                              Navigator.of(context)
                                  .pop(); // Close loader on error
                              setState(() {
                                selectedValue = previousValue;
                              });
                            }
                          }
                        } else {
                          // WEEKLY / MONTHLY / ETC
                          setState(() {
                            selectedValue = newValue;
                          });

                          widget.onChanged(newValue);

                          // ✅ UPDATE 1: Pass bool based on previousValue
                          bool confirmed = await showDaysOfWeekPopup(
                            context,
                            widget.defaultEventDays,
                            widget.eventPeriod,
                            widget.customerId,
                            newValue.value,
                            widget.provider,
                            mode: newValue,
                            showConfirmation:
                                previousValue == EventType.select,
                          );

                          if (!confirmed) {
                            setState(() {
                              selectedValue = previousValue;
                            });
                            widget.onChanged(previousValue);
                          }
                        }
                      }
                    },
                    items: EventType.values
                        .map<DropdownMenuItem<EventType>>((value) {
                      return DropdownMenuItem<EventType>(
                        value: value,
                        child: Text(
                          value.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    underline: Container(),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          if (widget.defaultEventDays.isNotEmpty &&
              selectedValue != EventType.select &&
              selectedValue != EventType.daily)
            SizedBox(
              width: 24,
              height: 24,
              child: GestureDetector(
                  onTap: () {
                    // ✅ UPDATE 2: Pass showConfirmation: false here
                    showDaysOfWeekPopup(
                        context,
                        widget.defaultEventDays,
                        widget.eventPeriod,
                        widget.customerId,
                        widget.eventStatus,
                        widget.provider,
                        mode: selectedValue,
                        showConfirmation: false);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.indigo, // using primaryColor placeholder
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
            ),
        ],
      ),
    );
  }

  // ✅ UPDATE 3: Modified function with showConfirmation parameter
  Future<bool> showDaysOfWeekPopup(
    BuildContext context,
    List<String> selectedDays,
    int period,
    String cusID,
    int eventSt,
    dynamic provider, {
    required EventType mode,
    bool showConfirmation = true, // Added default parameter
  }) {
    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    final List<String> weekOptions = mode == EventType.monthly
        ? ['Week 1', 'Week 2', 'Week 3', 'Week 4']
        : ['Week 1', 'Week 2'];

    int correctedPeriod =
        (eventSt == 3 && (period == 3 || period == 4)) ? 1 : period;
    String? selectedWeek =
        correctedPeriod != 0 ? "Week $correctedPeriod" : "Week 1";

    bool isLoading = false;

    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
           width: fullScreenWidth(context) * 0.5,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Select Event Days",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo, // primaryColor
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (mode == EventType.monthly ||
                          mode == EventType.fortnightly)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select Week",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedWeek,
                              isExpanded: true,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade50,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              items: weekOptions
                                  .map((week) => DropdownMenuItem(
                                        value: week,
                                        child: Text(week),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWeek = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Days",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView(
                            shrinkWrap: true,
                            children: daysOfWeek.map((day) {
                              return CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(day),
                                value: selectedDays.contains(day.toLowerCase()),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedDays.add(day.toLowerCase());
                                    } else {
                                      selectedDays.remove(day.toLowerCase());
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isLoading) ...[
                            const CircularProgressIndicator()
                          ] else ...[
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.indigo,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                bool confirmed = true;

                                // ✅ UPDATE 4: Conditional Popup
                                if (showConfirmation) {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.all(20),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  color: Colors.orange),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Are you sure you want to add this visit to the calendar?.",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                               ElevatedButton(
                                                  onPressed: (){
                                                      Navigator.of(context)
                                                          .pop(false);
                                                  }, 
                                                     style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.grey),
                                                  child: Text('Cancel',style: TextStyle(color: Colors.white),)
                                                  ),
                                              // TextButton(
                                              //   onPressed: () =>
                                              //       Navigator.of(context)
                                              //           .pop(false),
                                              //   child: const Text("Cancel",
                                              //       style: TextStyle(
                                              //           color: Colors.orange)),
                                              // ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                                child: const Text("Continue",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                  confirmed = result ?? false;
                                }

                                if (confirmed == true) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  List<String> validDaysOrder = [
                                    'monday',
                                    'tuesday',
                                    'wednesday',
                                    'thursday',
                                    'friday',
                                    'saturday',
                                  ];

                                  List<String> eventDays = selectedDays
                                      .where((day) => validDaysOrder
                                          .contains(day.toLowerCase()))
                                      .map((e) => e.toLowerCase())
                                      .toList()
                                    ..sort((a, b) => validDaysOrder
                                        .indexOf(a)
                                        .compareTo(validDaysOrder.indexOf(b)));

                                  String period = mode == EventType.monthly ||
                                          mode == EventType.fortnightly
                                      ? selectedWeek?.split(' ').last ?? ''
                                      : "";

                                  try {
                                    final response = await provider.addEvent(
                                      cusID,
                                      eventSt,
                                      eventDays,
                                      period,
                                      context,
                                    );

                                    if (response.statusCode != 200) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Navigator.of(context).pop(false);
                                      return;
                                    }

                                    await provider.fetchCustomerData(
                                        page: provider.currentPage);

                                    setState(() {
                                      isLoading = false;
                                    });

                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });

                                    Navigator.of(context).pop(false);
                                  }
                                }
                              },
                              child: const Text(
                                "Add to Calendar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((value) => value ?? false);
  }
}

// enum EventType {
//   select,
//   weekly,
//   fortnightly,
//   monthly,
//   daily,
// }

// extension EventTypeExtension on EventType {
//   String get displayName {
//     switch (this) {
//       case EventType.select:
//         return "-Select-";
//       case EventType.weekly:
//         return "Weekly";
//       case EventType.fortnightly:
//         return "Fortnightly";
//       case EventType.monthly:
//         return "Monthly";
//       case EventType.daily:
//         return "Daily";
//     }
//   }

//   int get value {
//     switch (this) {
//       case EventType.select:
//         return 0;
//       case EventType.weekly:
//         return 2;
//       case EventType.fortnightly:
//         return 3;
//       case EventType.monthly:
//         return 4;
//       case EventType.daily:
//         return 5;
//     }
//   }

//   static EventType fromValue(int value) {
//     switch (value) {
//       case 0:
//         return EventType.select;
//       case 2:
//         return EventType.weekly;
//       case 3:
//         return EventType.fortnightly;
//       case 4:
//         return EventType.monthly;
//       case 5:
//         return EventType.daily;
//       default:
//         return EventType.weekly;
//     }
//   }
// }

// class EventTypeDropdown extends StatefulWidget {
//   final EventType initialValue;
//   final Function(EventType) onChanged;
//   final List<String> defaultEventDays;
//   final String customerId;
//   final int eventPeriod;
//   final int eventStatus;
//   final CustomersProvider provider;

//   const EventTypeDropdown({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     required this.defaultEventDays,
//     required this.customerId,
//     required this.eventPeriod,
//     required this.eventStatus,
//     required this.provider,
//   });

//   @override
//   _EventTypeDropdownState createState() => _EventTypeDropdownState();
// }

// class _EventTypeDropdownState extends State<EventTypeDropdown> {
//   late EventType selectedValue;
//   bool isLoading = false;

//   SubscriptionController subscriptionController =
//       Get.find<SubscriptionController>();

//   @override
//   void initState() {
//     super.initState();
//     selectedValue = widget.initialValue;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//                 color: Color(0xffdddefc),
//                 borderRadius: BorderRadius.all(Radius.circular(5))),
//             height: 38,
//             width: 80,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8, right: 2),
//               child: GestureDetector(
//                 onTap: () {
//                   if (subscriptionController.visitSetting.value != 'true') {
//                     showUpgradePlanDialog(context);
//                   }
//                 },
//                 child: AbsorbPointer(
//                   absorbing:
//                       subscriptionController.visitSetting.value != 'true',
//                   child: DropdownButton<EventType>(
//                     iconSize: 17.5,
//                     value: selectedValue,


// onChanged: (EventType? newValue) async {
//   if (newValue != null) {
   
//     if (newValue == selectedValue) {
//       return;
//     }

   
//     final previousValue = selectedValue;

//     if (newValue == EventType.select) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) {
//           bool isDialogLoading = false;

//           return StatefulBuilder(
//             builder: (context, setStateDialog) {
//               return AlertDialog(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 contentPadding: const EdgeInsets.all(20),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(Icons.warning_amber_rounded,
//                             color: Colors.redAccent),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Cancel Visit",
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Are you sure you want to cancel the existing ${selectedValue.displayName} visit?",
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         if (isDialogLoading)
//                           const CircularProgressIndicator()
//                         else ...[
//                           TextButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             child: const Text("No, Keep it",
//                                 style: TextStyle(color: Colors.grey)),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.redAccent,
//                             ),
//                             onPressed: () async {
//                               setStateDialog(() {
//                                 isDialogLoading = true;
//                               });

//                               try {
//                                 Dio dio = Dio();
//                                 final response = await dio.post(
//                                   'https://test.thrivewoo.com/delete_future_events',
//                                   data: {"customer_id": widget.customerId},
//                                 );

//                                 if (response.statusCode == 200) {
//                                   await widget.provider.fetchCustomerData(
//                                     page: widget.provider.currentPage,
//                                   );
                                  
//                                   setState(() {
//                                     selectedValue = newValue;
//                                   });
//                                   widget.onChanged(newValue);
                                  
//                                   Navigator.of(context).pop();
//                                 } else {
//                                   Navigator.of(context).pop();
//                                 }
//                               } catch (e) {
//                                 Navigator.of(context).pop();
//                               } finally {
//                                 if (mounted) {
//                                   setStateDialog(() {
//                                     isDialogLoading = false;
//                                   });
//                                 }
//                               }
//                             },
//                             child: const Text("Yes, Cancel",
//                                 style: TextStyle(color: Colors.white)),
//                           ),
//                         ]
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       );
//       return; 
//     }

//     if (selectedValue != EventType.select) {
//       bool? confirmChange = await showDialog<bool>(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),
//             contentPadding: const EdgeInsets.all(20),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Change Visit Type",
//                   style: TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Are you sure you want to change the visit from ${selectedValue.displayName} to ${newValue.displayName}?",
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(false),
//                       child: const Text("Cancel",
//                           style: TextStyle(color: Colors.orange)),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(true),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange),
//                       child: const Text("Confirm"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );

//       // If user cancels the "Change Visit" dialog, stop everything
//       if (confirmChange != true) {
//         return;
//       }
//     }

//     // 2. Proceed with Logic
//     if (newValue == EventType.daily) {
//       setState(() {
//         selectedValue = newValue;
//       });

//       // ✅ LOGIC UPDATE: 
//       // Only show "Are you sure you want to add this event" if coming from Select.
//       if (previousValue == EventType.select) {
//         bool? confirmed = await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) {
//             bool isDialogLoading = false;
//             return StatefulBuilder(
//               builder: (context, setStateDialog) {
//                 return AlertDialog(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   contentPadding: const EdgeInsets.all(20),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.warning_amber_rounded,
//                               color: Colors.orange),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               "Are you sure you want to add this event!",
//                               style: TextStyle(
//                                   fontSize: 15, fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           if (isDialogLoading)
//                             const CircularProgressIndicator()
//                           else ...[
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: const Text("Cancel",
//                                   style: TextStyle(color: Colors.orange)),
//                             ),
//                             const SizedBox(width: 10),
//                             ElevatedButton(
//                               onPressed: () async {
//                                 setStateDialog(() {
//                                   isDialogLoading = true;
//                                 });
//                                 try {
//                                   final response = await widget.provider.addEvent(
//                                     widget.customerId,
//                                     5,
//                                     [],
//                                     "",
//                                     context,
//                                   );
//                                   if (response.statusCode != 200) {
//                                     showCustomToastDisplay(context,
//                                         response.message, red, Icons.close);
//                                     await Future.delayed(
//                                         const Duration(seconds: 2));
//                                     Navigator.of(context).pop(false);
//                                     return;
//                                   }
//                                   await widget.provider.fetchCustomerData(
//                                       page: widget.provider.currentPage);
//                                   widget.onChanged(newValue);
//                                   Navigator.of(context).pop(true);
//                                 } catch (e) {
//                                   Navigator.of(context).pop(false);
//                                 } finally {
//                                   setStateDialog(() {
//                                     isDialogLoading = false;
//                                   });
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.orange),
//                               child: const Text("Continue"),
//                             ),
//                           ]
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         );

//         if (confirmed != true) {
//           setState(() {
//             selectedValue = previousValue;
//           });
//         }
//       } else {
//         // ✅ User came from Weekly/Monthly (already confirmed "Change Visit").
//         // Skip the "Add Event" popup, call API directly with a loader.
        
//         // Show simple loader
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const Center(child: CircularProgressIndicator()),
//         );

//         try {
//           final response = await widget.provider.addEvent(
//             widget.customerId,
//             5,
//             [],
//             "",
//             context,
//           );

//           Navigator.of(context).pop(); // Close loader

//           if (response.statusCode == 200) {
//              await widget.provider.fetchCustomerData(
//                 page: widget.provider.currentPage);
//              widget.onChanged(newValue);
//           } else {
//              // Revert on API error
//              setState(() {
//                 selectedValue = previousValue;
//              });
//              showCustomToastDisplay(context, response.message, red, Icons.close);
//           }
//         } catch (e) {
//           Navigator.of(context).pop(); // Close loader on error
//           setState(() {
//             selectedValue = previousValue;
//           });
//         }
//       }
//     } else {
//       // Existing "Other days" logic (Weekly, Fortnightly, etc.)
//       setState(() {
//         selectedValue = newValue;
//       });

//       widget.onChanged(newValue);

//       bool confirmed = await showDaysOfWeekPopup(
//         context,
//         widget.defaultEventDays,
//         widget.eventPeriod,
//         widget.customerId,
//         newValue.value,
//         widget.provider,
//         mode: newValue,
//       );

//       if (!confirmed) {
//         setState(() {
//           selectedValue = previousValue;
//         });
//         widget.onChanged(previousValue);
//       }
//     }
//   }
// },
// //      
//                     items: EventType.values
//                         .map<DropdownMenuItem<EventType>>((value) {
//                       return DropdownMenuItem<EventType>(
//                         value: value,
//                         child: Text(
//                           value.displayName,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                     underline: Container(),
//                     isExpanded: true,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 5.0,
//           ),
//           if (widget.defaultEventDays.isNotEmpty &&
//               selectedValue != EventType.select &&
//               selectedValue != EventType.daily)
//             SizedBox(
//               width: 24,
//               height: 24,
//               child: GestureDetector(
//                   onTap: () {
//                     showDaysOfWeekPopup(
//                         context,
//                         widget.defaultEventDays,
//                         widget.eventPeriod,
//                         widget.customerId,
//                         widget.eventStatus,
//                         widget.provider,
//                         mode: selectedValue);
//                   },
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'i',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   )),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<bool> showDaysOfWeekPopup(
//     BuildContext context,
//     List<String> selectedDays,
//     int period,
//     String cusID,
//     int eventSt,
//     CustomersProvider provider, {
//     required EventType mode,
//   }) {
//     final List<String> daysOfWeek = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//     ];

//     final List<String> weekOptions = mode == EventType.monthly
//         ? ['Week 1', 'Week 2', 'Week 3', 'Week 4']
//         : ['Week 1', 'Week 2'];

//     // Override period if eventSt is 3 and period is 3 or 4
//     int correctedPeriod =
//         (eventSt == 3 && (period == 3 || period == 4)) ? 1 : period;
//     String? selectedWeek =
//         correctedPeriod != 0 ? "Week $correctedPeriod" : "Week 1";

//     bool isLoading = false;

//     return showDialog<bool>(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           insetPadding: const EdgeInsets.all(20),
//           child: SizedBox(
//             width: fullScreenWidth(context) * 0.5,
//             child: StatefulBuilder(
//               builder: (context, setState) {
//                 return Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         "Select Event Days",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: primaryColor,
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Week selector (optional)
//                       if (mode == EventType.monthly ||
//                           mode == EventType.fortnightly)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "Select Week",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             DropdownButtonFormField<String>(
//                               value: selectedWeek,
//                               isExpanded: true,
//                               decoration: InputDecoration(
//                                 fillColor: Colors.grey.shade50,
//                                 filled: true,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 10),
//                               ),
//                               items: weekOptions
//                                   .map((week) => DropdownMenuItem(
//                                         value: week,
//                                         child: Text(week),
//                                       ))
//                                   .toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedWeek = value;
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//                         ),

//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Select Days",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 6),

//                       // ✅ Scrollable checkboxes
//                       Flexible(
//                         child: Scrollbar(
//                           thumbVisibility: true,
//                           child: ListView(
//                             shrinkWrap: true,
//                             children: daysOfWeek.map((day) {
//                               return CheckboxListTile(
//                                 dense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 controlAffinity:
//                                     ListTileControlAffinity.leading,
//                                 title: Text(day),
//                                 value: selectedDays.contains(day.toLowerCase()),
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     if (value == true) {
//                                       selectedDays.add(day.toLowerCase());
//                                     } else {
//                                       selectedDays.remove(day.toLowerCase());
//                                     }
//                                   });
//                                 },
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Action buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           if (isLoading) ...[
//                             const CircularProgressIndicator()
//                           ] else ...[
//                             TextButton(
//                               style: TextButton.styleFrom(
//                                 foregroundColor: primaryColor,
//                               ),
//                               onPressed: () {
//                                 Navigator.of(context).pop(false);
//                               },
//                               child: const Text(
//                                 "Cancel",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryColor,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 18, vertical: 10),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               onPressed: () async {
//                                 bool confirmed = await showDialog(
//                                   context: context,
//                                   barrierDismissible: false,
//                                   builder: (context) => AlertDialog(
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     contentPadding: const EdgeInsets.all(20),
//                                     content: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Row(
//                                           children: [
//                                             Icon(Icons.warning_amber_rounded,
//                                                 color: Colors.orange),
//                                             SizedBox(width: 8),
//                                             Expanded(
//                                               child: Text(
//                                                 "Are you sure you want to add this event!",
//                                                 style: TextStyle(
//                                                     fontSize: 15,
//                                                     fontWeight:
//                                                         FontWeight.w500),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 20),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.of(context)
//                                                       .pop(false),
//                                               child: const Text("Cancel",
//                                                   style: TextStyle(
//                                                       color: Colors.orange)),
//                                             ),
//                                             const SizedBox(width: 10),
//                                             ElevatedButton(
//                                               onPressed: () =>
//                                                   Navigator.of(context)
//                                                       .pop(true),
//                                               style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       Colors.orange),
//                                               child: const Text("Continue",
//                                                   style:
//                                                       TextStyle(color: white)),
//                                             ),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 );

//                                 if (confirmed == true) {
//                                   setState(() {
//                                     isLoading = true;
//                                   });

//                                   List<String> validDaysOrder = [
//                                     'monday',
//                                     'tuesday',
//                                     'wednesday',
//                                     'thursday',
//                                     'friday',
//                                     'saturday',
//                                   ];

//                                   List<String> eventDays = selectedDays
//                                       .where((day) => validDaysOrder
//                                           .contains(day.toLowerCase()))
//                                       .map((e) => e.toLowerCase())
//                                       .toList()
//                                     ..sort((a, b) => validDaysOrder
//                                         .indexOf(a)
//                                         .compareTo(validDaysOrder.indexOf(b)));

//                                   String period = mode == EventType.monthly ||
//                                           mode == EventType.fortnightly
//                                       ? selectedWeek?.split(' ').last ?? ''
//                                       : "";

//                                   try {
//                                     final response = await provider.addEvent(
//                                       cusID,
//                                       eventSt,
//                                       eventDays,
//                                       period,
//                                       context,
//                                     );

//                                     if (response.statusCode != 200) {
//                                       setState(() {
//                                         isLoading = false;
//                                       });
//                                       Navigator.of(context).pop(false);
//                                       return;
//                                     }

//                                     await provider.fetchCustomerData(
//                                         page: provider.currentPage);

//                                     setState(() {
//                                       isLoading = false;
//                                     });

//                                     Navigator.of(context).pop(true);
//                                   } catch (e) {
//                                     setState(() {
//                                       isLoading = false;
//                                     });

//                                     Navigator.of(context).pop(false);
//                                   }
//                                 }
//                               },
//                               child: const Text(
//                                 "Add to Calendar",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ]
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     ).then((value) => value ?? false);
//   }
// }
