import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RangePickerWidget extends StatelessWidget {
  final bool isSmallScreen;

  const RangePickerWidget({super.key, this.isSmallScreen = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _datePickerButton(context, provider, isSmallScreen, true),
            const SizedBox(width: 6),
            _datePickerButton(context, provider, isSmallScreen, false),
            const SizedBox(width: 6),
            _goButton(context, provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _datePickerButton(BuildContext context, DashboardProvider provider,
      bool isSmallScreen, bool isStartDate) {
    return GestureDetector(
      onTap: () => provider.selectDate(context, isStartDate),
      child: Container(
        height: isSmallScreen ? 34 : 42,
        width: isSmallScreen ? 80 : 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isStartDate
                    ? (provider.selectedStartDate.isEmpty
                        ? 'DD-MM-YYYY'
                        : DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(provider.selectedStartDate)))
                    : (provider.selectedEndDate.isEmpty
                        ? 'DD-MM-YYYY'
                        : DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(provider.selectedEndDate))),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _goButton(
      BuildContext context, DashboardProvider provider, bool isSmallScreen) {
    return CustomButton(
      text: 'Go',
      onPressed: () async {
        await provider.setTempToFilter();
        provider.fetchData();
      },
      color: primaryColor,
    );
  }
}
