// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesmanTargetByCategoryDialog extends StatefulWidget {
  String title;
  DashboardProvider provider;

  SalesmanTargetByCategoryDialog(
      {super.key, required this.title, required this.provider});

  @override
  _SalesmanTargetByCategoryDialogState createState() =>
      _SalesmanTargetByCategoryDialogState();
}

class _SalesmanTargetByCategoryDialogState
    extends State<SalesmanTargetByCategoryDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: white,
      surfaceTintColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title.tr,
            style: TextStyle(
              color: white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins_Regular',
            ),
          ),
          dialogCloseButton1(context, red)
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.all(8.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: [
              _buildTableHeader('Month'),
              if (widget.title == 'Target') _buildTableHeader('Target'),
              if (widget.title == 'Projection') _buildTableHeader('Projection'),
            ],
          ),
          ..._buildDataRows(),
        ],
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    final keys = widget.provider.salesmanTargetByCategory;
    return List.generate(keys.length, (index) {
      return TableRow(
        children: [
          _buildTableCell(keys[index].month.toString()),
          if (widget.title == 'Target')
            _buildTableCell(formatAmount(keys[index].target)),
          if (widget.title == 'Projection')
            _buildTableCell(formatAmount(keys[index].projection)),
        ],
      );
    });
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTableCell(String text) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
