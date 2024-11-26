// import 'package:busskit_admin/ui/view/ui/pending_payments/pending_payment_controller.dart';
// import 'package:busskit_admin/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PendingPaymentCollectionDialog extends StatelessWidget {
//   final IndividualPendingData customerData;

//   const PendingPaymentCollectionDialog({Key? key, required this.customerData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final PendingPaymentController controller = Get.find(); // Access the controller
//     String selectedPaymentMethod = 'Cash';

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: FutureBuilder<IndividualPendingPaymentResponse>(
//         future: controller.loadIndividualPendingPayments(customerData.id), // Call the loading function
//         builder: (BuildContext context, AsyncSnapshot<IndividualPendingPaymentResponse> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Center(child: CircularProgressIndicator()),
//             );
//           } else if (snapshot.hasError) {
//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text('Error: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.pendingPayments.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Text('No data available'),
//             );
//           } else {
//             final pendingPayments = snapshot.data!.pendingPayments;

//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Header of the dialog
//                   Container(
//                     height: 45,
//                     padding: const EdgeInsets.all(10),
//                     decoration: const BoxDecoration(
//                       color: Color(0xff008000),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Payment',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontFamily: 'Poppins_Regular',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.red),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: DataTable(
//                             dataRowHeight: 30,
//                             headingRowHeight: 40,
//                             columnSpacing: 30,
//                             border: TableBorder.all(color: Colors.grey.shade300),
//                             columns: const [
//                               DataColumn(label: Text('Date', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Invoice', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Amount', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Status', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Payment', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Receivable', style: TextStyle(fontSize: 13))),
//                               DataColumn(label: Text('Select', style: TextStyle(fontSize: 13))),
//                             ],
//                             rows: pendingPayments.map((payment) {
//                               return DataRow(cells: [
//                                 DataCell(Center(child: Text(payment.date))),
//                                 DataCell(Center(child: Text(payment.invoice))),
//                                 DataCell(Center(child: Text(payment.amount.toString()))),
//                                 DataCell(Center(child: Text(payment.status))),
//                                 DataCell(Center(
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xff008000),
//                                       borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                                     ),
//                                     child: const Padding(
//                                       padding: EdgeInsets.symmetric(horizontal: 5),
//                                       child: Text(
//                                         'Delivered',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                                 DataCell(Center(child: Text(payment.receivable.toString()))),
//                                 DataCell(
//                                   Center(
//                                     child: Checkbox(
//                                       value: payment.isSelected,
//                                       onChanged: (bool? value) {
//                                         payment.isSelected = value ?? false; // Update selection
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ]);
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: DataTable(
//                             dataRowHeight: 35,
//                             headingRowHeight: 30,
//                             columns: const [
//                               DataColumn(label: Text('Payment Method', style: TextStyle(fontSize: 11))),
//                               DataColumn(label: Text('Balance Amount', style: TextStyle(fontSize: 11))),
//                               DataColumn(label: Text('Received Amount', style: TextStyle(fontSize: 11))),
//                               DataColumn(label: Text('Remarks', style: TextStyle(fontSize: 11))),
//                               DataColumn(label: Text('')),
//                             ],
//                             rows: [
//                               DataRow(cells: [
//                                 DataCell(
//                                   Container(
//                                     height: 35,
//                                     child: DropdownButtonFormField<String>(
//                                       value: selectedPaymentMethod,
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(10.0),
//                                         ),
//                                         contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       ),
//                                       dropdownColor: Colors.white,
//                                       items: const [
//                                         DropdownMenuItem(child: Text('Cash'), value: 'Cash'),
//                                         DropdownMenuItem(child: Text('Cheque'), value: 'Cheque'),
//                                         DropdownMenuItem(child: Text('Bank Transfer'), value: 'Bank Transfer'),
//                                       ],
//                                       onChanged: (value) {
//                                         if (value != null) {
//                                           selectedPaymentMethod = value;
//                                         }
//                                       },
//                                       hint: const Text('Select'),
//                                       style: const TextStyle(fontSize: 12, color: Colors.black),
//                                       icon: const Icon(Icons.arrow_drop_down, size: 24.0, color: Colors.black),
//                                       iconSize: 24.0,
//                                     ),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: MediaQuery.of(context).size.width * 0.15,
//                                     child: TextField(
//                                       readOnly: true,
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(10.0),
//                                         ),
//                                         hintText: '150.00',
//                                         hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
//                                         contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//                                       ),
//                                       style: TextStyle(fontSize: 12, color: Colors.black),
//                                     ),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: MediaQuery.of(context).size.width * 0.15,
//                                     child: TextField(
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(10.0),
//                                         ),
//                                         hintText: '150.00',
//                                         hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
//                                         contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//                                       ),
//                                       style: TextStyle(fontSize: 12, color: Colors.black),
//                                     ),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: MediaQuery.of(context).size.width * 0.15,
//                                     child: TextField(
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(10.0),
//                                         ),
//                                         hintText: 'Received in full',
//                                         hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
//                                         contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//                                       ),
//                                       style: TextStyle(fontSize: 12, color: Colors.black),
//                                     ),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   Center(
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         // Save or submit action
//                                       },
//                                       child: Text('Submit', style: TextStyle(fontSize: 14)),
//                                       style: ElevatedButton.styleFrom(
//                                         shadowColor: Colors.transparent,
//                                         backgroundColor: Colors.green.withOpacity(0.1),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10.0),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ]),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
