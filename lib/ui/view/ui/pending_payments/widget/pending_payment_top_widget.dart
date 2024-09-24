import 'package:busskit_salesexecutive/ui/components/widgets/range_selector.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:flutter/material.dart';

class PendingPaymentTopWidget extends StatelessWidget {
  final PendingPaymentController pendingPaymentController;
  const PendingPaymentTopWidget(
      {super.key, required this.pendingPaymentController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // calender(today),
        RangeSelector(
          onChanged:
              (selectedIndex, (DateTime? startDate, DateTime? endDate) label) {
            pendingPaymentController.updateCustomerVisitScheduleSet(
                label.$1, label.$2);
            /*customerAndOrderController.updateCustomerVisitScheduleSet(
                label.$1, label.$2);*/
            //customerAndOrderController.updateCustomerVisitScheduleSet(label);
          },
        ),
      ],
    );
  }

  /*Widget calender(String calender) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RangeSelector(
          onChanged: (selectedIndex, label) {},
        ),
        Flexible(
          child: MyThemeButton(
              buttonText: go, width: AppDimensions.instance!.width * 0.12),
        )
      ],
    );
  }*/
}
