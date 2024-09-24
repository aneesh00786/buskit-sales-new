import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';

class WeekPicker extends StatefulWidget {
  final void Function(int index, List<String> selectedWeek)? onChanged;
  const WeekPicker({
    super.key,
    this.onChanged,
  });

  @override
  State<WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<WeekPicker> {
  List<bool> selectedWeek = [];
  List<String> selectedWeekName = [];

  @override
  void initState() {
    for (var i = 0; i < NKDateUtils.weekdays.length; i++) {
      selectedWeek.add(false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 400,
      child: _weekDayWidget(),
    );
  }

  Widget _weekDayWidget() {
    return Wrap(
      children: List.generate(NKDateUtils.weekdays.length,
          (index) => _weekDayComponent(NKDateUtils.weekdays[index], index)),
    );
  }

  Widget _weekDayComponent(String weekDay, int index) {
    return ListTile(
      leading: MyRegularText(
        label: weekDay,
        fontSize: NkFontSize.largeFont(),
        fontWeight: FontWeight.bold,
      ),
      trailing: Checkbox.adaptive(
        value: selectedWeek[index],
        onChanged: (bool? value) {
          setState(() {
            selectedWeek[index] = value ?? false;
            if (value == true && selectedWeekName.contains(weekDay) == false) {
              selectedWeekName.add(weekDay);
            }
            widget.onChanged?.call(index, selectedWeekName);
          });
        },
      ),
    );
  }
}
