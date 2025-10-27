// ignore_for_file: unnecessary_null_comparison

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_list.dart';
import 'package:flutter/material.dart';

class OrdersBottomTitleRow extends StatelessWidget {
  final OrderBottomWidget widget;
  final ScrollController _scrollController2;
  final int tabIndex;
  const OrdersBottomTitleRow({
    super.key,
    required this.widget,
    required ScrollController scrollController2,
    required this.tabIndex,
  }) : _scrollController2 = scrollController2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Order NO',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Created',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Created By',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: CustomText(
                          content: 'Order Amount',
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins_Regular',
                          fontSize: 12,
                          textAlign: TextAlign.center,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Payment Status',
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Status',
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        ' ',
                        style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                if (tabIndex != 0) ...[
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Order Details',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Process Date',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Order Amount',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Payment Status',
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: CustomText(
                          content: 'Status',
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        ' ',
                        style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ],
            ),
          ),
        ),

        if (widget.orderController.orderDataList == null) ...[
          const Text("Record not found"),
        ],

        if (widget.orderController.orderDataList != null) ...[
          OrdersBottomList(
            scrollController2: _scrollController2,
            widget: widget,
            tabIndex: tabIndex,
          ),
          Container(
            padding: const EdgeInsets.all(3),
            height: 50,
            color: Colors.grey[200],
          ),
        ],
      ],
    );
  }
}
