
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:flutter/material.dart';

class PendingPaymentTopWidget extends StatelessWidget {
  final PendingPaymentController pendingPaymentController;
  const PendingPaymentTopWidget(
      {super.key, required this.pendingPaymentController});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Spacer(),
        const NotificationWidget(
          startDate: '',
          endDate: '',
        ),
        profiloe(),
      ],
    );
  }
}
