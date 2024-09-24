import 'dart:ui';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';

enum OrderStatus {
  preOrder,
  outOfDelivery,
  delivered,
  draft,
  cancelled,
  processing,
  estimates,
  pending,
}

enum UserType { salesman, customer }

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.preOrder:
        return "Pre-Order";
      case OrderStatus.outOfDelivery:
        return "Out of Delivery";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.draft:
        return "Draft";
      case OrderStatus.cancelled:
        return "Cancelled";
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.estimates:
        return "Estimates";
      case OrderStatus.pending:
        return "Pending";
    }
  }

  int get type {
    switch (this) {
      case OrderStatus.preOrder:
        return 0;
      case OrderStatus.outOfDelivery:
        return 1;
      case OrderStatus.delivered:
        return 2;
      case OrderStatus.draft:
        return 4;
      case OrderStatus.cancelled:
        return 3;
      case OrderStatus.processing:
        return 5;
      case OrderStatus.pending:
        return 6;
      case OrderStatus.estimates:
        return 7;
    }
  }

  Color get orderColor {
    switch (this) {
      case OrderStatus.preOrder:
        return secondaryColor;
      case OrderStatus.outOfDelivery:
        return secondaryColor;
      case OrderStatus.delivered:
        return secondaryColor;
      case OrderStatus.draft:
        return secondaryColor;
      case OrderStatus.cancelled:
        return primaryColor;
      case OrderStatus.processing:
        return primaryColor;
      case OrderStatus.pending:
        return primaryColor;
      case OrderStatus.estimates:
        return primaryColor;
    }
  }
}

class OrderHandlingClass {
  static OrderStatus fromType(int type) {
    switch (type) {
      case 0:
        return OrderStatus.preOrder;
      case 1:
        return OrderStatus.outOfDelivery;
      case 2:
        return OrderStatus.delivered;
      case 3:
        return OrderStatus.cancelled;
      case 4:
        return OrderStatus.draft;
      case 5:
        return OrderStatus.processing;
      default:
        return OrderStatus.preOrder;
    }
  }
}
