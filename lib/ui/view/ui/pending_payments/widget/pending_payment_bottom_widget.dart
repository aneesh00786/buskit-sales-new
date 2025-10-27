import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:intl/intl.dart';

class PendingPaymentBottomWidget extends StatefulWidget {
  final PendingPaymentController orderController;
  final int selectedTabIndex;

  const PendingPaymentBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
  });

  @override
  State<PendingPaymentBottomWidget> createState() =>
      _PendingPaymentBottomWidgetState();
}

class _PendingPaymentBottomWidgetState
    extends State<PendingPaymentBottomWidget> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _orderScrollController = ScrollController();
  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();

    _headerScrollController.addListener(() {
      if (_orderScrollController.hasClients &&
          _headerScrollController.offset != _orderScrollController.offset) {
        _orderScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    _orderScrollController.addListener(() {
      if (_headerScrollController.hasClients &&
          _orderScrollController.offset != _headerScrollController.offset) {
        _headerScrollController.jumpTo(_orderScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _orderScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (subscriptionController.appPendingPaymentList.value != "true") {
        return Center(
          child: UpgradePlanButton(),
        );
      }

      if (widget.orderController.isLoadingPayment.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (widget.orderController.orderDataList.isEmpty) {
        return const Center(child: NodataWidget());
      }

      return NkWidgetExceptionHandel(
        onRetryPressed: () => {},
        data: widget.orderController.orderDataList,
        child: Stack(
          children: [
            buildHeader(context, _headerScrollController),
            buildOrderList(context, widget.orderController,_orderScrollController),
          ],
        ),
      );
    });
  }
  String getFormattedOrderCreatAt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '';
    }

    try {
      if (value is DateTime) {
        return DateFormat('dd-MM-yyyy').format(value);
      }
      DateTime parsedDate = DateTime.parse(value.toString());
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
  }
}
