import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDialogHeading extends StatelessWidget {
  const CustomDialogHeading({
    super.key,
    required this.headerHeight,
  });

  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 248, 248, 249),
      height: headerHeight,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Date".tr,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Invoice".tr,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Status".tr,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DialogTableHeaderText(
                text: "Amount".tr,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Due By".tr,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Select".tr,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
