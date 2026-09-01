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
        return "Booking";
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

  // Canonical status-pill palette used everywhere a status badge is shown
  // (dashboard dialogs, orders list, customer & orders, pending payments...).
  // Keep every screen pointed at these three getters instead of hardcoding
  // its own colors, so a status always reads the same color app-wide.
  Color get statusBgColor {
    switch (this) {
      case OrderStatus.delivered:
        return const Color(0xFFDCFCE7);
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return const Color(0xFFFEE2E2);
      case OrderStatus.estimates:
      case OrderStatus.pending:
        return const Color(0xFFFEF3C7);
      case OrderStatus.preOrder:
      case OrderStatus.processing:
      case OrderStatus.quickSale:
        return const Color(0xFFDBEAFE);
      case OrderStatus.draft:
        return const Color(0xFFF1F5F9);
      case OrderStatus.outOfDelivery:
        return const Color(0xFFEDE9FE);
      case OrderStatus.newOrder:
        return const Color(0xFFCCFBF1);
      case OrderStatus.waitApproval:
        return const Color(0xFFFFEDD5);
    }
  }

  Color get statusTextColor {
    switch (this) {
      case OrderStatus.delivered:
        return const Color(0xFF064E3B);
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return const Color(0xFF7F1D1D);
      case OrderStatus.estimates:
      case OrderStatus.pending:
        return const Color(0xFF78350F);
      case OrderStatus.preOrder:
      case OrderStatus.processing:
      case OrderStatus.quickSale:
        return const Color(0xFF1E3A8A);
      case OrderStatus.draft:
        return const Color(0xFF0F172A);
      case OrderStatus.outOfDelivery:
        return const Color(0xFF4C1D95);
      case OrderStatus.newOrder:
        return const Color(0xFF134E4A);
      case OrderStatus.waitApproval:
        return const Color(0xFF7C2D12);
    }
  }

  Color get statusDotColor {
    switch (this) {
      case OrderStatus.delivered:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return const Color(0xFFDC2626);
      case OrderStatus.estimates:
      case OrderStatus.pending:
        return const Color(0xFFD97706);
      case OrderStatus.preOrder:
      case OrderStatus.processing:
      case OrderStatus.quickSale:
        return const Color(0xFF2563EB);
      case OrderStatus.draft:
        return const Color(0xFF475569);
      case OrderStatus.outOfDelivery:
        return const Color(0xFF7C3AED);
      case OrderStatus.newOrder:
        return const Color(0xFF0D9488);
      case OrderStatus.waitApproval:
        return const Color(0xFFEA580C);
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
