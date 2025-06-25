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
    selectedMinute = widget.initialMinute;
    selectedPeriod = widget.initialPeriod;
    log('TIMEE : $selectedHour : $selectedMinute   $selectedPeriod');
  }

  void showTimePickerPopup() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(widget.initialHour) ?? 1,
        minute: int.tryParse(widget.initialMinute) ?? 0,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: primaryColor, // color of the moving clock hand
              dialBackgroundColor: Colors.blue.shade50,
              hourMinuteColor: WidgetStateColor.resolveWith(
                  (states) => Colors.blue), // background of hour/min container
              hourMinuteTextColor: WidgetStateColor.resolveWith(
                  (states) => Colors.white), // text color inside hour/min
              entryModeIconColor: primaryColor, // icon color
            ),
            colorScheme: ColorScheme.light(
              primary: primaryColor, // selected hour/minute color
              onPrimary: Colors.white, // text color on selected
              onSurface: Colors.black, // other text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor, // OK / CANCEL button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      int hour = picked.hour;
      int minute = picked.minute;

      // Determine AM/PM
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12 == 0 ? 12 : hour % 12;

      setState(() {
        selectedHour = displayHour.toString().padLeft(2, '0');
        selectedMinute = minute.toString().padLeft(2, '0');
        selectedPeriod = period;
      });

      final formattedTime =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      widget.onTimeSelected(widget.eventId, formattedTime);
    }
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
