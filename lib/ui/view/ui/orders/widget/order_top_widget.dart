
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text('Recent Orders'.tr, style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              )),
        ),
        const Spacer(),
        profiloe(),
      ],
    );
  }
}
