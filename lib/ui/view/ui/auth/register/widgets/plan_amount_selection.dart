import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class PlanCheckboxRow extends StatelessWidget {
  final String planName;
  final double fontSize;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const PlanCheckboxRow({
    Key? key,
    required this.planName,
    this.fontSize = 16,
    required this.isSelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          content: planName,
          color: white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
        Checkbox(
          value: isSelected,
          onChanged: onChanged,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.green;
            }
            return Colors.white;
          }),
          checkColor: Colors.white,
        ),
      ],
    );
  }
}
