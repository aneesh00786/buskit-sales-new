import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:flutter/material.dart';

class TimePickerField extends StatefulWidget {
  final String eventId;
  final Function(String eventId, String time24Format) onTimeSelected;
  final String initialHour;
  final String initialMinute;
  final String initialPeriod;

  const TimePickerField({
    super.key,
    required this.eventId,
    required this.onTimeSelected,
    required this.initialMinute,
    required this.initialHour,
    required this.initialPeriod,
  });

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  String selectedHour = '__';
  String selectedMinute = '__';
  String selectedPeriod = '_';

  @override
  void initState() {
    super.initState();
    log('TIMEE widget : ${widget.initialHour} : ${widget.initialMinute}   ${widget.initialPeriod}');
    selectedHour = widget.initialHour;
    //  == '' ? widget.initialHour : '__';
    selectedMinute = widget.initialMinute;
    //  == '' ? widget.initialMinute : '__';
    selectedPeriod = widget.initialPeriod;
    //  == '' ? widget.initialPeriod : '_';
    log('TIMEE : $selectedHour : $selectedMinute   $selectedPeriod');
  }

  void showTimePickerPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 400,
            width: 300,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            "Hr",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Min",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "AM/PM",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 1,
                  child: Divider(
                    color: black,
                    thickness: 1,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Scroll lists
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hour
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedHour = hourList[index];
                                });
                              },
                              perspective: 0.002,
                              physics: const FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: hourList.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      hourList[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Minute
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedMinute = minuteList[index];
                                });
                              },
                              perspective: 0.002,
                              physics: const FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: minuteList.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      minuteList[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // AM/PM
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedPeriod = periodList[index];
                                });
                              },
                              perspective: 0.002,
                              physics: const FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: periodList.length,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      periodList[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Highlight overlay (center selection lines)
                      Align(
                        alignment: Alignment.center,
                        child: IgnorePointer(
                          child: Container(
                            height: 40, // Same as itemExtent
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              border: Border(
                                top: BorderSide(color: Colors.blue, width: 2),
                                bottom:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 1,
                  child: Divider(
                    color: black,
                    thickness: 1,
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Center(
                    child: CustomButton(
                      text: "OK",
                      color: primaryColor,
                      onPressed: () {
                        if (selectedHour == "__") {
                          setState(() {
                            selectedHour = "01";
                          });
                        }
                        if (selectedMinute == "__") {
                          setState(() {
                            selectedMinute = "00";
                          });
                        }
                        if (selectedPeriod == "_") {
                          setState(() {
                            selectedPeriod = "AM";
                          });
                        }

                        // Convert to 24-hour format
                        int hour = int.parse(
                            selectedHour == '__' ? '01' : selectedHour);
                        String minute =
                            selectedMinute == '__' ? '00' : selectedMinute;

                        if (selectedPeriod == 'PM' && hour != 12) {
                          hour += 12;
                        } else if (selectedPeriod == 'AM' && hour == 12) {
                          hour = 0;
                        }

                        final formattedTime =
                            '${hour.toString().padLeft(2, '0')}:$minute';

                        // Send back to parent
                        widget.onTimeSelected(widget.eventId, formattedTime);

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> hourList =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> minuteList =
      List.generate(60, (index) => index.toString().padLeft(2, '0'));
  List<String> periodList = ['AM', 'PM'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showTimePickerPopup,
      child: Container(
        height: 50,
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  content: '$selectedHour : $selectedMinute   $selectedPeriod',
                  fontSize: 12,
                ),
              ),
              const Icon(Icons.access_time, size: 18)
            ],
          ),
        ),
      ),
    );
  }
}
