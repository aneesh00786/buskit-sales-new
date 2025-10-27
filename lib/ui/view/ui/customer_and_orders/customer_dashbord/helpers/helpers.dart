import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';

String getCountForTitle(String title, OrderDataas orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList.totalOrder.toString();
      case 'estimates':
        return orderCountList.estimateOrder.toString();
      case 'bookings':
        return orderCountList.preorderOrder.toString();
      case 'drafts':
        return orderCountList.draftOrder.toString();
      case 'cancelled':
        return orderCountList.cancelOrder.toString();
      default:
        return "0";
    }
  }
