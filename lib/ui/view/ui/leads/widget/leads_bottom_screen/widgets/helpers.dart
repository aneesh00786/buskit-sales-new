  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          Expanded(child: buildHeaderText('Address'.tr, 12)),
          Expanded(child: buildHeaderText('Town'.tr, 12)),
          Expanded(child: buildHeaderText('State'.tr, 12)),
          Expanded(child: buildHeaderText('Zip Code'.tr, 12)),
          Expanded(child: buildHeaderText('Mobile'.tr, 12)),
          Expanded(child: buildHeaderText('Email'.tr.tr, 12)),
          Expanded(child: buildHeaderText('Contact Person'.tr, 12)),
          Expanded(child: buildHeaderText('Contact Number'.tr, 12)),
          Expanded(child: buildHeaderText('Status'.tr, 12)),
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