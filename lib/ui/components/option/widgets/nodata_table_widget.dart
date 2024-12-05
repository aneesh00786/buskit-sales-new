  import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Container nodataDialogueTable({
    required String head_1,
    required String head_2,
    required String head_3,
    required String head_4,
    required String head_5,
    required String head_6,
  }) {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Column(
            children: [
              // Header Section
              Container(
                color: primaryColor,
                padding: EdgeInsets.all(8.0),
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildTableHeader1(head_1),
                        _buildTableHeader1(head_2),
                        _buildTableHeader1(head_3),
                        _buildTableHeader1(head_4),
                        _buildTableHeader1(head_5),
                        _buildTableHeader1(head_5),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: NodataWidget(),
                ),
              ),
            ],
          ),
          // Close Button
          Positioned(
            top: 1,
            right: 1,
            child: IconButton(
              icon: Icon(
                EneftyIcons.close_circle_outline,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
  Container nodataOrderTableDialogue() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: primaryColor,
                padding: EdgeInsets.all(8.0),
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                    6: FlexColumnWidth(2),
                    7: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildTableHeader1('Customer List'),
                        _buildTableHeader1('Order Number'),
                        _buildTableHeader1('Order Created'),
                        _buildTableHeader1('Created By'),
                        _buildTableHeader1('Order Price'),
                        _buildTableHeader1('Invoice'),
                        _buildTableHeader1('Payment Status'),
                        _buildTableHeader1('Status'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: NodataWidget(),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                EneftyIcons.close_circle_outline,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildTableHeader1(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }