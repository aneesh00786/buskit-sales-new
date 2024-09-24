import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pending_payment_controller.dart';

class PendingPaymentScreen extends StatefulWidget {
  const PendingPaymentScreen({super.key});

  @override
  State<PendingPaymentScreen> createState() => _PendingPaymentScreenState();
}

class _PendingPaymentScreenState extends State<PendingPaymentScreen> {
  PendingPaymentController orderController =
      Get.put(PendingPaymentController());

  @override
  void initState() {
    orderController.loadOrderData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return Scaffold(
        body: SafeArea(
          minimum: nkRegularPadding(),
          child: Column(
            children: [
              PendingPaymentTopWidget(
                pendingPaymentController: orderController,
              ),
              nkMediumSizeBox(),
              Flexible(
                  child: PendingPaymentBottomWidget(
                      orderController: orderController))
            ],
          ),
        ),
      );
    });
  }
}
