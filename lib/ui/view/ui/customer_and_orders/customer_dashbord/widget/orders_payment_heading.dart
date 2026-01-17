import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payments.dart';
import 'package:flutter/material.dart';

class OrdersPaymentHeading extends StatelessWidget {
  const OrdersPaymentHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
        width: colDateWidth,
          child: Center(
            child: Text(
              "Date",
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
              "Invoice",
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
              "Status",
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
              "Amount",
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
              "Due By",
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
              "Select",
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