import 'package:flutter/material.dart';

class OrdersPaymentHeading extends StatelessWidget {
  const OrdersPaymentHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 2,
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
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 1,
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