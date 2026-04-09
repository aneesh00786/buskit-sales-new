import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payments.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersPaymentHeading extends StatelessWidget {
  const OrdersPaymentHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        SizedBox(
        width: colDateWidth,
          child: Center(
            child: Text(
              "Date".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
        SizedBox(
       width: colInvoiceWidth,
          child: Center(
            child: Text(
              "Invoice".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
        SizedBox(
         width: colStatusWidth,
          child: Center(
            child: Text(
              "Status".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
        SizedBox(
         width: colAmountWidth,
          child: Center(
            child: Text(
              "Amount".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
        SizedBox(
        width: colDueWidth,
          child: Center(
            child: Text(
              "Due By".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
            ),
          ),
        ),
        SizedBox(
        width: colSelectWidth,
          child: Center(
            child: Text(
              "Select".tr,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}