import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class StaffTimeSheetDialog extends StatefulWidget {
  final StaffController staffController;

  const StaffTimeSheetDialog({
    super.key,
    required this.staffController,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StaffTimeSheetDialogState createState() => _StaffTimeSheetDialogState();
}

class _StaffTimeSheetDialogState extends State<StaffTimeSheetDialog> {
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadTimesheetData();
  }

  void _loadTimesheetData() async {
    // 1. Get the current tab index (0 = Jan, 1 = Feb, etc.)
    int monthIndex = widget.staffController.tabController.index + 1;

    // 2. Generate the full Month Name (e.g., "March")
    // using any year (e.g., 2026) is fine to just get the month string
    String monthName = DateFormat('MMMM').format(DateTime(2026, monthIndex));

    // 3. Pass "March" to the controller
    await widget.staffController.loadTimesheetData(monthName);
  }
  // void _loadTimesheetData() async {
  //   final String startDate = DateFormat('yyyy-MM-dd').format(
  //     DateTime(DateTime.now().year,
  //         widget.staffController.tabController.index + 1, 1),
  //   );
  //   final int year = DateTime.now().year;

  //   await widget.staffController.loadTimesheetData(year.toString());
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      backgroundColor: white,
      surfaceTintColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Obx(() {
          return widget.staffController.isTimesheetLoading.value
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                  ],
                )
              : widget.staffController.staffTimesheetData.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 200,
                          child: Center(
                            child: Text(
                              'NO TIMESHEET DATA'.tr,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(context),
                          _buildTable(context),
                        ],
                      ),
                    );
        }),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final datePart =
          '${dateString.split(' ')[1]} ${dateString.split(' ')[2]} ${dateString.split(' ')[3]}';

      DateTime dateTime = DateFormat('MMM dd yyyy').parse(datePart);
      final DateFormat outputFormatter = DateFormat('dd-MM-yyyy');
      return outputFormatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Time Sheet'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins_Regular',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkResponse(
            onTap: () => Navigator.of(context).pop(),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      width: isPhonePortrait(context)
          ? fullScreenWidth(context)
          : fullScreenWidth(context) * 0.7,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              children: [
                _buildTableHeader('Date'.tr),
                _buildTableHeader('Check-In'.tr),
                _buildTableHeader('Check-Out'.tr),
                _buildTableHeader('Hrs'.tr),
              ],
            ),
            ..._buildDataRows(),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    final keys = widget.staffController.staffTimesheetData.keys.toList();
    return keys.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final date = mapEntry.value;
      final entry = widget.staffController.staffTimesheetData[date]!;
      final checkIn = _formatTo12HourFormat(entry.checkIn ?? '');
      final checkOut = _formatTo12HourFormat(entry.checkOut ?? '');
      final hoursWorked =
          _calculateTimeDifference(entry.checkIn ?? '', entry.checkOut ?? '');
      final rowColor = index.isEven ? Colors.white : const Color(0xFFF8FAFC);

      return TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: [
          _buildTableCell(NKDateUtils.commonDayFormat(DateTime.parse(date))),
          _buildTableCell(checkIn),
          _buildTableCell(checkOut),
          _buildTableCell(checkIn != '' && checkOut != '' ? hoursWorked : ''),
        ],
      );
    }).toList();
  }

  String _formatTo12HourFormat(String timeString) {
    try {
      if (timeString.isEmpty) return '';
      final time = DateFormat("HH:mm:ss").parse(timeString);
      return DateFormat("hh:mm a").format(time);
    } catch (e) {
      return timeString;
    }
  }

  String _calculateTimeDifference(String checkIn, String checkOut) {
    try {
      if (checkIn.isEmpty || checkOut.isEmpty) return '00:00 hrs';
      final timeFormat = DateFormat("HH:mm:ss");
      DateTime checkInTime = timeFormat.parse(checkIn);
      DateTime checkOutTime = timeFormat.parse(checkOut);
      final duration = checkOutTime.difference(checkInTime);
      return "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')} hrs";
    } catch (e) {
      return '00:00 hrs';
    }
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: Color(0xFF0F172A),
          )),
    );
  }

  Widget _buildTableCell(String text) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12.5,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
