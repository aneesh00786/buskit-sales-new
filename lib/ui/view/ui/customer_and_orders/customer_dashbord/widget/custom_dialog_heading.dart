import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';

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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Date",
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Invoice",
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Status",
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DialogTableHeaderText(
                text: "Amount",
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Due By",
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DialogTableHeaderText(
                text: "Select",
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
