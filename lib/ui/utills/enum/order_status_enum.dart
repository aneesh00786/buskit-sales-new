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
  newOrder,
  waitApproval,
  quickSale,
  rejected,
}

enum UserType { salesman, customer }

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.preOrder:
        return "Pre-Order";
      case OrderStatus.outOfDelivery:
        return "Out for Delivery";
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
      case OrderStatus.newOrder:
        return "New";
      case OrderStatus.waitApproval:
        return "Waiting for Approval";
      case OrderStatus.quickSale:
        return "Processing";
        // return "Quick Sale";
      case OrderStatus.rejected:
        return "Rejected";
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
      case OrderStatus.newOrder:
        return 11;
      case OrderStatus.waitApproval:
        return 12;
      case OrderStatus.rejected:
        return 13;
      case OrderStatus.quickSale:
        return 14;
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
      case OrderStatus.newOrder:
        return primaryColor;
      case OrderStatus.waitApproval:
        return primaryColor;
      case OrderStatus.rejected:
        return primaryColor;
      case OrderStatus.quickSale:
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
      case 6:
        return OrderStatus.pending;
      case 7:
        return OrderStatus.estimates;
      case 11:
        return OrderStatus.newOrder;
      case 12:
        return OrderStatus.waitApproval;
      case 13:
        return OrderStatus.rejected;
      case 14:
        return OrderStatus.quickSale;
      default:
        return OrderStatus.preOrder;
    }
  }
}

