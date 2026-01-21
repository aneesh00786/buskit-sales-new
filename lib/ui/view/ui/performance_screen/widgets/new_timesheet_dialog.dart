import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
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
    final String startDate = DateFormat('yyyy-MM-dd').format(
      DateTime(DateTime.now().year,
          widget.staffController.tabController.index + 1, 1),
    );
    final int year = DateTime.now().year;
    
    
    await widget.staffController.loadTimesheetData(year.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      backgroundColor: white,
      surfaceTintColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() {
        return widget.staffController.isTimesheetLoading.value
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 200,
                child: const Center(child: Text('LOADING')),
              )
            : widget.staffController.staffTimesheetData.isEmpty
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 200,
                    child: Stack(
                      children: [
                        const Center(
                            child: Text('NO TIMESHEET DATA',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                        Positioned(
                            top: 10,
                            right: 10,
                            child: dialogCloseButton1(context, red))
                      ],
                    ),
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
          const Text(
            'Time Sheet',
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
      width: isPhonePortrait(context)
          ? fullScreenWidth(context)
          : fullScreenWidth(context) * 0.7,
      padding: const EdgeInsets.all(8.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: [
              _buildTableHeader('Date'),
              _buildTableHeader('Check-In'),
              _buildTableHeader('Check-Out'),
              _buildTableHeader('Hrs'),
            ],
          ),
          ..._buildDataRows(),
        ],
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    final keys = widget.staffController.staffTimesheetData.keys.toList();
    return keys.map((date) {
      final entry = widget.staffController.staffTimesheetData[date]!;
      final checkIn = _formatTo12HourFormat(entry.checkIn ?? '');
      final checkOut = _formatTo12HourFormat(entry.checkOut ?? '');
      final hoursWorked =
          _calculateTimeDifference(entry.checkIn ?? '', entry.checkOut ?? '');

      return TableRow(
        children: [
          _buildTableCell(_formatDate(date)),
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
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
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
