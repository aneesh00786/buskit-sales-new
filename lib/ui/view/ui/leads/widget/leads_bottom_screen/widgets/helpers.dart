  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

Widget buildTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }

  Widget buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: buildHeaderText('Address', 12)),
          Expanded(child: buildHeaderText('Town', 12)),
          Expanded(child: buildHeaderText('State', 12)),
          Expanded(child: buildHeaderText('Zip Code', 12)),
          Expanded(child: buildHeaderText('Mobile', 12)),
          Expanded(child: buildHeaderText('Email', 12)),
          Expanded(child: buildHeaderText('Contact Person', 12)),
          Expanded(child: buildHeaderText('Contact Number', 12)),
          Expanded(child: buildHeaderText('Status', 12)),
          const Expanded(child: Text('')),
        ],
      ),
    );
  }

  Widget buildHeaderText(String text, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }