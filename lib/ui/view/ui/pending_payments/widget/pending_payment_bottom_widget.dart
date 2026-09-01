import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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
  // LinkedScrollControllerGroup forwards the user's drag delta to every
  // linked controller directly, instead of reacting to a finished position
  // change with jumpTo() — the jumpTo-based approach could fight an in
  // -progress drag/fling on the other controller and made the table feel
  // like it randomly stopped responding to horizontal/vertical drags.
  late final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _headerScrollController =
      _horizontalGroup.addAndGet();
  late final ScrollController _orderScrollController =
      _horizontalGroup.addAndGet();

  late final LinkedScrollControllerGroup _verticalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _customerListScrollController =
      _verticalGroup.addAndGet();
  late final ScrollController _orderRowsScrollController =
      _verticalGroup.addAndGet();

  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void dispose() {
    _headerScrollController.dispose();
    _orderScrollController.dispose();
    _customerListScrollController.dispose();
    _orderRowsScrollController.dispose();
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
          child: CircularProgressIndicator(color: primaryColor),
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
            buildOrderList(
              context,
              widget.orderController,
              _orderScrollController,
              _customerListScrollController,
              _orderRowsScrollController,
            ),
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
