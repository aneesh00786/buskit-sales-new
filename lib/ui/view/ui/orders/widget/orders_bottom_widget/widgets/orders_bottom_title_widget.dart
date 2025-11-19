// ignore_for_file: unnecessary_null_comparison



// orders_bottom_title_row.dart
// ignore_for_file: unnecessary_null_comparison

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_list.dart';
import 'package:flutter/material.dart';

class OrdersBottomTitleRow extends StatelessWidget {
  final OrderBottomWidget widget;
  final ScrollController scrollController2;
  final int tabIndex;
  final List<OrderData> orderList;

  const OrdersBottomTitleRow({
    super.key,
    required this.widget,
    required this.scrollController2,
    required this.tabIndex,
    required this.orderList,
  });

  // THIS IS THE KEY: Correctly returns List<OrderData>
  List<OrderData> get _displayList {
    if (widget.isSearchMode && widget.overrideOrders != null) {
      return widget.overrideOrders!;
    }
    return widget.orderController.orderDataList;
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderData> orders = _displayList;
    final bool isEmpty = orders.isEmpty;

    return Column(
      children: [
        // HEADER ROW
        Container(
          width: double.infinity,
          height: 50,
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tabIndex == 0) ...[
                  const SizedBox(width: 5),
                  _headerCell('Order NO', 4),
                  const SizedBox(width: 5),
                  _headerCell('Created', 4),
                  const SizedBox(width: 5),
                  _headerCell('Created By', 4),
                  const SizedBox(width: 5),
                  _headerCell('Order Amount', 5),
                  const SizedBox(width: 5),
                  _headerCell('Payment Status', 4),
                  const SizedBox(width: 5),
                  _headerCell('Status', 4),
                  const Expanded(flex: 2, child: SizedBox()),
                  const SizedBox(width: 5),
                ] else ...[
                  const SizedBox(width: 5),
                  _headerCell('Order Details', 4),
                  const SizedBox(width: 5),
                  _headerCell('Process Date', 4),
                  const SizedBox(width: 5),
                  _headerCell('Order Amount', 4),
                  const SizedBox(width: 5),
                  _headerCell('Payment Status', 4),
                  const SizedBox(width: 5),
                  _headerCell('Status', 4),
                  const Expanded(flex: 2, child: SizedBox()),
                  const SizedBox(width: 5),
                ],
              ],
            ),
          ),
        ),

        // EMPTY STATE (when search returns nothing)
        if (isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No orders found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

        // MAIN LIST (normal or search results)
        if (!isEmpty)
          Expanded(
            child: OrdersBottomList(
              scrollController2: scrollController2,
              widget: widget,
              tabIndex: tabIndex,
              orderList: orders, // This is now 100% safe List<OrderData>
            ),
          ),

        // FOOTER
        Container(
          padding: const EdgeInsets.all(3),
          height: 50,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  // Helper for clean header cells
  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Center(
        child: CustomText(
          content: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }
}


// import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_list.dart';
// import 'package:flutter/material.dart';

// class OrdersBottomTitleRow extends StatelessWidget {
//   final OrderBottomWidget widget;
//   final ScrollController _scrollController2;
//   final int tabIndex;
//   const OrdersBottomTitleRow({
//     super.key,
//     required this.widget,
//     required ScrollController scrollController2,
//     required this.tabIndex,
//   }) : _scrollController2 = scrollController2;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           height: 50,
//           color: primaryColor,
//           child: Padding(
//             padding: const EdgeInsets.all(0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (tabIndex == 0) ...[
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Order NO',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Created',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Created By',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 5,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Order Amount',
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins_Regular',
//                           fontSize: 12,
//                           textAlign: TextAlign.center,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Payment Status',
//                           fontFamily: 'Poppins_Regular',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Status',
//                           fontFamily: 'Poppins_Regular',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const Expanded(
//                     flex: 2,
//                     child: Center(
//                       child: Text(
//                         ' ',
//                         style: TextStyle(
//                             fontFamily: 'Poppins_Regular',
//                             fontStyle: FontStyle.normal,
//                             fontSize: 12,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                 ],
//                 if (tabIndex != 0) ...[
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Order Details',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Process Date',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Order Amount',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Payment Status',
//                           fontFamily: 'Poppins_Regular',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     flex: 4,
//                     child: Center(
//                       child: CustomText(
//                           content: 'Status',
//                           fontFamily: 'Poppins_Regular',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const Expanded(
//                     flex: 2,
//                     child: Center(
//                       child: Text(
//                         ' ',
//                         style: TextStyle(
//                             fontFamily: 'Poppins_Regular',
//                             fontStyle: FontStyle.normal,
//                             fontSize: 12,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                 ],
//               ],
//             ),
//           ),
//         ),

//         if (widget.orderController.orderDataList == null) ...[
//           const Text("Record not found"),
//         ],

//         if (widget.orderController.orderDataList != null) ...[
//           OrdersBottomList(
//             scrollController2: _scrollController2,
//             widget: widget,
//             tabIndex: tabIndex,
//           ),
//           Container(
//             padding: const EdgeInsets.all(3),
//             height: 50,
//             color: Colors.grey[200],
//           ),
//         ],
//       ],
//     );
//   }
// }
