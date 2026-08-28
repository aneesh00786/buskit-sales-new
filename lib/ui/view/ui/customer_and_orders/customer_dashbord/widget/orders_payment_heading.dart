import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payments.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersPaymentHeading extends StatelessWidget {
  const OrdersPaymentHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          SizedBox(
            width: colDateWidth,
            child: Center(
              child: Text(
                "Date".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(
            width: colInvoiceWidth,
            child: Center(
              child: Text(
                "Invoice".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(
            width: colStatusWidth,
            child: Center(
              child: Text(
                "Status".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(
            width: colAmountWidth,
            child: Center(
              child: Text(
                "Amount".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(
            width: colDueWidth,
            child: Center(
              child: Text(
                "Due By".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(
            width: colSelectWidth,
            child: Center(
              child: Text(
                "Select".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
