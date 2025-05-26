import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:flutter/material.dart';

Widget noDataTable(String staffProjection, {bool isDayOrRange = false}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double dialogWidth = MediaQuery.of(context).size.width * 0.7;
      double headerHeight = 40.0;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 250,
        ),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                    Expanded(
                      child: Text(
                        '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    dialogCloseButton1(context, red),
                  ],
                ),
              ),
              // Table Header
              Container(
                color: const Color.fromARGB(255, 247, 247, 247),
                height: headerHeight,
                child: Row(
                  children: [
                    const Expanded(
                      child: DialogTableHeaderText(
                        text: 'Name',
                        fontSize: 13,
                      ),
                    ),
                    if (!isDayOrRange) ...[
                      // if (targertType == '1') ...[
                      const DialogTableHeaderText(
                        text: 'Target',
                        fontSize: 13,
                      ),
                      // ],
                      if (staffProjection == '1') ...[
                        const DialogTableHeaderText(
                          text: 'Projection',
                          fontSize: 13,
                        ),
                      ]
                    ],
                    const Expanded(
                      child: DialogTableHeaderText(
                        text: 'Actual',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: NodataWidget(),
              ),
            ],
          ),
        ),
      );
    },
  );
}