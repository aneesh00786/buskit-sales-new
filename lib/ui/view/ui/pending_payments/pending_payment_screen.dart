
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_tabbar.dart';
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

  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    orderController.loadOrderData(chartIndex: selectedTabIndex,isLogin: false);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 6.0),
          child: Column(
            children: [
              PendingPaymentTopWidget(
                pendingPaymentController: orderController,
              ),
              nkMediumSizeBox(),
              Flexible(
                flex: 3,
                child: PendingTabBar(orderController: orderController,)),
            ],
          ),
        ),
      );
    });
  }
}
