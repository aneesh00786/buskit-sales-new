import 'package:busskit_salesexecutive/ui/components/widgets/range_selector.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:flutter/material.dart';

class OrderTopWidget extends StatelessWidget {
  final OrderController orderController;
  const OrderTopWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        calender(today),
      ],
    );
  }

  Widget calender(String calender) {
    return RangeSelector(
      onChanged:
          (selectedIndex, (DateTime? startDate, DateTime? endDate) label) {
        orderController.updateCustomerVisitScheduleSet(label.$1, label.$2);
        //customerAndOrderController.updateCustomerVisitScheduleSet(label);
      },
    );
  }
}
