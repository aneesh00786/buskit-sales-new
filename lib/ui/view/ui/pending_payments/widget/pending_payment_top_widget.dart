
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingPaymentTopWidget extends StatelessWidget {
  final PendingPaymentController pendingPaymentController;
  const PendingPaymentTopWidget(
      {super.key, required this.pendingPaymentController});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10,),
       Padding(
         padding: const EdgeInsets.only(top: 20),
         child: Text('Pending Payments'.tr, style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              )),
       ),
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
