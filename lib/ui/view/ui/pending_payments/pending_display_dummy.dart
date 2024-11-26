// import 'package:busskit_admin/api_handler/api_constants.dart';
// import 'package:busskit_admin/ui/view/ui/pending_payments/pending_payment_collect_model.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart'; // Assuming you're using Dio for HTTP requests

// class CustomerOrdersPage extends StatefulWidget {
//   final String customerId;

//   CustomerOrdersPage({required this.customerId});

//   @override
//   _CustomerOrdersPageState createState() => _CustomerOrdersPageState();
// }

// class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
//   Future<List<PendingIndividualData>>? pendingOrders;

//   @override
//   void initState() {
//     super.initState();
//     pendingOrders = getAllPendingPaymentsForCustomer(
//         widget.customerId);
//   }

//   // Define the function here or import it from another file

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Customer Orders')),
//       body: FutureBuilder<List<PendingIndividualData>>(
//         future: pendingOrders,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No orders found for this customer.'));
//           }

//           // If data is available, display it in a DataTable
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columns: [
//                 DataColumn(label: Text('Order ID')),
//                 DataColumn(label: Text('Payment Type')),
//                 DataColumn(label: Text('Credit Period')),
//                 DataColumn(label: Text('Received Amount')),
//                 DataColumn(label: Text('Order Total')),
//                 DataColumn(label: Text('Order Status')),
//               ],
//               rows: snapshot.data!.map((order) {
//                 return DataRow(cells: [
//                   DataCell(Text(order.orderId)),
//                   DataCell(Text(order.paymentType.toString())),
//                   DataCell(Text(order.creditPeriod.toString())),
//                   DataCell(Text(order.receivedAmount.toString())),
//                   DataCell(Text(order.orderTotal.toString())),
//                   DataCell(Text(order.orderStatus.toString())),
//                 ]);
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
