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
            // const SizedBox(width: 6),
            // _goButton(context, provider, widget.isSmallScreen),
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
        height: 42,
        width: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
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

  // Widget _goButton(
  //     BuildContext context, DashboardProvider provider, bool isSmallScreen) {
  //   return Container(
  //     height: 50,
  //     child: ElevatedButton(
  //       onPressed: () async {
  //         await checkOnline();
  //         if (!isOnline) {
  //           showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
  //           return;
  //         }

  //         if (provider.selectedStartDate.isEmpty) {
  //           showCustomToastDisplay(
  //               context, "Select start date", Colors.orange, Icons.warning);
  //         }
  //         if (provider.selectedEndDate.isEmpty) {
  //           showCustomToastDisplay(
  //               context, "Select end date", Colors.orange, Icons.warning);
  //         }
  //         if (provider.selectedStartDate.isNotEmpty &&
  //             provider.selectedEndDate.isNotEmpty) {
  //           final dashboardProvider =
  //               Provider.of<DashboardProvider>(context, listen: false);

  //           await dashboardProvider.setTempToFilter();

  //           await dashboardProvider.fetchAllOrdersAtOnce();

  //           dashboardProvider.fetchData();
  //         }
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: primaryColor,
  //         foregroundColor: Colors.white,
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         elevation: 4,
  //         shadowColor: primaryColor.withOpacity(0.4),
  //         textStyle: const TextStyle(
  //           fontSize: 13,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //       child: const Text('Go'),
  //     ),
  //   );
  // }
}
