import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:flutter/material.dart';

class BarchartDialogBottomRow extends StatelessWidget {
  const BarchartDialogBottomRow({
    super.key,
    required this.totalTarget,
    required this.totalProjection,
    required this.totalActual,
    required this.isDayOrRange,
    required this.staffProjection,
  });

  final num totalTarget;
  final num totalProjection;
  final num totalActual;
  final bool isDayOrRange;
  final String staffProjection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomText(
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                content: 'Total',
                fontSize: 11,
                maxLine: 1)),
        if (!isDayOrRange)
          Expanded(
              child: CustomText(
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  content: formatAmount(totalTarget),
                  fontSize: 11,
                  maxLine: 1)),
        if (!isDayOrRange && staffProjection == '1')
          Expanded(
              child: CustomText(
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  content: formatAmount(totalProjection),
                  fontSize: 11,
                  maxLine: 1)),
        Expanded(
            child: CustomText(
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                content: formatAmount(totalActual),
                fontSize: 11,
                maxLine: 1)),
      ],
    );
  }
}