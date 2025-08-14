// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RangePickerWidget extends StatefulWidget {
  final bool isSmallScreen;

  const RangePickerWidget({super.key, this.isSmallScreen = false});

  @override
  State<RangePickerWidget> createState() => _RangePickerWidgetState();
}

class _RangePickerWidgetState extends State<RangePickerWidget> {
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    checkOnline();
  }

  Future<void> checkOnline() async {
    isOnline = await ConnectivityService().isOnline();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _datePickerButton(context, provider, widget.isSmallScreen, true),
            const SizedBox(width: 6),
            _datePickerButton(context, provider, widget.isSmallScreen, false),
            const SizedBox(width: 6),
            _goButton(context, provider, widget.isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _datePickerButton(BuildContext context, DashboardProvider provider,
      bool isSmallScreen, bool isStartDate) {
    return GestureDetector(
      onTap: () async {
        await checkOnline();
        if (!isOnline) {
          showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
          return;
        }

        provider.selectDate(context, isStartDate);
      },
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
            const Icon(
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
        await checkOnline();
        if (!isOnline) {
          showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
          return;
        }

        if (provider.selectedStartDate.isEmpty) {
          showCustomToastDisplay(
              context, "Select start date", Colors.orange, Icons.warning);
        }
        if (provider.selectedEndDate.isEmpty) {
          showCustomToastDisplay(
              context, "Select end date", Colors.orange, Icons.warning);
        }
        if (provider.selectedStartDate.isNotEmpty &&
            provider.selectedEndDate.isNotEmpty) {
          final dashboardProvider =
              Provider.of<DashboardProvider>(context, listen: false);

          await dashboardProvider.setTempToFilter();

          // DASHBOARD TOP WIDGET ONTAP DIALOG DATA
          await dashboardProvider.fetchAllOrdersAtOnce();

          dashboardProvider.fetchData();
        }
      },
      color: primaryColor,
    );
  }
}
