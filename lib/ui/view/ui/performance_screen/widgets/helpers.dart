
  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget getBottomTitles(double value, TitleMeta meta,String targetType,List<ValueTargetDatum> valuePerformance,List<CategoryPerformance>categoryPerformance) {
    if (targetType == '0') {
      if (value.toInt() >= 0 &&
          value.toInt() < valuePerformance.length) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          child: Transform.rotate(
            angle: -1.34 / 4,
            child: MyRegularText(
              label: valuePerformance[value.toInt()].cid ?? '',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      if (value.toInt() >= 0 &&
          value.toInt() < categoryPerformance.length) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          child: Transform.rotate(
            angle: -1.34 / 4,
            child: MyRegularText(
              label: categoryPerformance[value.toInt()].category ?? '',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    }
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return MyRegularText(
      label: value.toInt().toString(),
      fontSize: 8.6,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }
    Widget buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 2),
        MyRegularText(
          label: label,
          color: const Color(0xFF0F172A),
          fontSize: 11.6,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 10),
      ],
    );
  }
    Widget buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  String getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
    Widget buildTableTextField(int index, TextEditingController textController) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          fillColor: Colors.blueGrey.shade50,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }
    Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }