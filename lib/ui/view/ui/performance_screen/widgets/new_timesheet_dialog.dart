// import 'dart:math';

// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
// import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';

// class StaffTimeSheetDialog extends StatefulWidget {
//   final StaffController staffController;
//   // final StaffData staffData;

//   const StaffTimeSheetDialog({
//     super.key,
//     required this.staffController,
//     // required this.staffData
//   });

//   @override
//   _StaffTimeSheetDialogState createState() => _StaffTimeSheetDialogState();
// }

// class _StaffTimeSheetDialogState extends State<StaffTimeSheetDialog> {
//   late List<TextEditingController> _checkInControllers;
//   late List<TextEditingController> _checkOutControllers;
//   late List<String> _calculatedHours;

//   RxBool isLoading = true.obs;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _loadTimesheetData();
//   }

//   void _initializeControllers() async {
//     isLoading.value = true;

//     final String startDate = DateFormat('yyyy-MM-dd').format(
//       DateTime(DateTime.now().year,
//           widget.staffController.tabController.index + 1, 1),
//     );
//     final int year = DateTime.now().year;
//     final int month = widget.staffController.tabController.index + 1;
//     final int lastDay = DateTime(year, month + 1, 0).day;
//     final String endDate = DateFormat('yyyy-MM-dd').format(
//       DateTime(year, month, lastDay),
//     );

//     await widget.staffController.loadTimesheetData(
//       startDate,
//       endDate,
//     );

//     setState(() {
//       var data = widget.staffController.staffTimesheetData;
//       if (data.isNotEmpty) {
//         _checkInControllers = List.generate(
//           data.length,
//           (index) => TextEditingController(
//               text: _formatTo12HourFormat(
//                   data.values.elementAt(index).checkIn ?? '')),
//         );
//         _checkOutControllers = List.generate(
//           data.length,
//           (index) => TextEditingController(
//               text: _formatTo12HourFormat(
//                   data.values.elementAt(index).checkOut ?? '')),
//         );
//         _calculatedHours = List.generate(
//           data.length,
//           (index) => _calculateTimeDifference(_checkInControllers[index].text,
//               _checkOutControllers[index].text),
//         );
//       } else {
//         // If no data, initialize empty lists
//         _checkInControllers = [];
//         _checkOutControllers = [];
//         _calculatedHours = [];
//       }
//     });

//     isLoading.value = false;
//   }

//   void _loadTimesheetData() async {
//     final String startDate = DateFormat('yyyy-MM-dd').format(
//       DateTime(DateTime.now().year,
//           widget.staffController.tabController.index + 1, 1),
//     );
//     final int year = DateTime.now().year;
//     final int month = widget.staffController.tabController.index + 1;
//     final int lastDay = DateTime(year, month + 1, 0).day;
//     final String endDate = DateFormat('yyyy-MM-dd').format(
//       DateTime(year, month, lastDay),
//     );
//     await widget.staffController.loadTimesheetData(
//       startDate,
//       endDate,
//     );
//     setState(() {
//       var data = widget.staffController.staffTimesheetData;
//       _checkInControllers = List.generate(
//         data.length,
//         (index) => TextEditingController(
//             text: _formatTo12HourFormat(
//                 data.values.elementAt(index).checkIn ?? '')),
//       );
//       _checkOutControllers = List.generate(
//         data.length,
//         (index) => TextEditingController(
//             text: _formatTo12HourFormat(
//                 data.values.elementAt(index).checkOut ?? '')),
//       );
//       _calculatedHours = List.generate(
//         data.length,
//         (index) => _calculateTimeDifference(
//             _checkInControllers[index].text, _checkOutControllers[index].text),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     for (var controller in _checkInControllers) {
//       controller.dispose();
//     }
//     for (var controller in _checkOutControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: white,
//       surfaceTintColor: white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Obx(() {
//         if (isLoading.value) {
//           return Container(
//             width: MediaQuery.of(context).size.width * 0.7,
//             height: 200,
//             padding: const EdgeInsets.all(20.0),
//             child: const Center(child: Text('LOADING')),
//           );
//         }

//         if (widget.staffController.staffTimesheetData.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.all(20.0),
//             child: Text('No data available'),
//           );
//         }

//         return IntrinsicWidth(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(context),
//               _buildTable(context),
//               // _buildSaveButton(),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   String _formatTo12HourFormat(String timeString) {
//     try {
//       final time = DateFormat("HH:mm:ss").parse(timeString);
//       final formatter = DateFormat("hh:mm a");
//       return formatter.format(time);
//     } catch (e) {
//       return timeString;
//     }
//   }

//   String _calculateTimeDifference(String checkIn, String checkOut) {
//     try {
//       final timeFormat = DateFormat("hh:mm a");
//       DateTime checkInTime = timeFormat.parse(checkIn);
//       DateTime checkOutTime = timeFormat.parse(checkOut);

//       final duration = checkOutTime.difference(checkInTime);
//       int hours = duration.inHours;
//       int minutes = duration.inMinutes % 60;

//       return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hrs";
//     } catch (e) {
//       return '00:00 hrs';
//     }
//   }

//   String _formatDate(String dateString) {
//     try {
//       final datePart =
//           '${dateString.split(' ')[1]} ${dateString.split(' ')[2]} ${dateString.split(' ')[3]}';

//       DateTime dateTime = DateFormat('MMM dd yyyy').parse(datePart);
//       final DateFormat outputFormatter = DateFormat('dd-MM-yyyy');
//       return outputFormatter.format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       height: 50,
//       padding: const EdgeInsets.all(12.0),
//       decoration: const BoxDecoration(
//         color: primaryColor,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Time Sheet',
//             style: TextStyle(
//               color: white,
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Poppins_Regular',
//             ),
//           ),
//           dialogCloseButton1(context, red)
//         ],
//       ),
//     );
//   }

//   Widget _buildTable(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.7,
//       padding: const EdgeInsets.all(8.0),
//       child: Table(
//         border: TableBorder.all(color: Colors.grey),
//         columnWidths: const {
//           0: FlexColumnWidth(2),
//           1: FlexColumnWidth(3),
//           2: FlexColumnWidth(3),
//           3: FlexColumnWidth(2),
//         },
//         children: [
//           TableRow(
//             decoration: BoxDecoration(color: Colors.grey[300]),
//             children: [
//               _buildTableHeader('Date'),
//               _buildTableHeader('Check-In'),
//               _buildTableHeader('Check-Out'),
//               _buildTableHeader('Hrs'),
//             ],
//           ),
//           ..._buildDataRows(),
//         ],
//       ),
//     );
//   }

//   List<TableRow> _buildDataRows() {
//     final keys = widget.staffController.staffTimesheetData.keys.toList();
//     return List.generate(widget.staffController.staffTimesheetData.length,
//         (index) {
//       String checkIn = _checkInControllers[index].text;
//       String checkOut = _checkOutControllers[index].text;

//       _calculatedHours[index] = _calculateTimeDifference(checkIn, checkOut);

//       return TableRow(
//         children: [
//           _buildTableCell(_formatDate(keys[index])),
//           _buildTableTime(index, 'checkIn'),
//           _buildTableTime(index, 'checkOut'),
//           _buildTableCell(_calculatedHours[index]),
//         ],
//       );
//     });
//   }

//   Widget _buildTableHeader(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(text,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _buildTableCell(String text) {
//     return SizedBox(
//       height: 50,
//       child: Center(
//         child: Text(text, textAlign: TextAlign.center),
//       ),
//     );
//   }

//   Widget _buildTableTime(int index, String type) {
//     return Container(
//       height: 50,
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: Text(
//           (type == 'checkIn'
//               ? _checkInControllers[index].text
//               : _checkOutControllers[index].text),
//           style: const TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }
// }

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
  _StaffTimeSheetDialogState createState() => _StaffTimeSheetDialogState();
}

class _StaffTimeSheetDialogState extends State<StaffTimeSheetDialog> {
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
    final int month = widget.staffController.tabController.index + 1;
    final int lastDay = DateTime(year, month + 1, 0).day;
    final String endDate = DateFormat('yyyy-MM-dd').format(
      DateTime(year, month, lastDay),
    );
    await widget.staffController.loadTimesheetData(startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: white,
      surfaceTintColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() {
        // if (widget.staffController.isTimesheetLoading.value) {
        //   return Container(
        //     width: MediaQuery.of(context).size.width * 0.7,
        //     height: 200,
        //     padding: const EdgeInsets.all(20.0),
        //     child: const Center(child: Text('LOADING')),
        //   );
        // }

        if (widget.staffController.staffTimesheetData.isEmpty) {
          return Container(
            // padding: EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.7,
            height: 200,
            child: Stack(
              children: [
                Center(
                    child: Text('NO TIMESHEET DATA',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                Positioned(
                    top: 10, right: 10, child: dialogCloseButton1(context, red))
              ],
            ),
          );
        }

        return IntrinsicWidth(
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
      width: MediaQuery.of(context).size.width * 0.7,
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
