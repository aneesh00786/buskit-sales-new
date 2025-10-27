class RecentOrderCountResponse {
  int? statusCode;
  bool? status;
  RecentOrderCountData? data;
  String? message;

  RecentOrderCountResponse({
    this.statusCode,
    this.status,
    this.data,
    this.message,
  });

  factory RecentOrderCountResponse.fromJson(Map<String, dynamic> json) =>
      RecentOrderCountResponse(
        statusCode: json["status_code"],
        status: json["status"],
        data: RecentOrderCountData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": data!.toJson(),
        "message": message,
      };
}

class RecentOrderCountData {
  int? notificationCreated;
  dynamic notificationDraft;
  dynamic notificationPreorder;
  dynamic notificationEstimate;
  dynamic notificationCancelled;
  MainNotification? mainNotification;

  RecentOrderCountData({
    this.notificationCreated,
    this.notificationDraft,
    this.notificationPreorder,
    this.notificationEstimate,
    this.notificationCancelled,
    this.mainNotification,
  });

  factory RecentOrderCountData.fromJson(Map<String, dynamic> json) => RecentOrderCountData(
        notificationCreated: json["notification_created"],
        notificationDraft: json["notification_draft"],
        notificationPreorder: json["notification_preorder"],
        notificationEstimate: json["notification_estimate"],
        notificationCancelled: json["notification_cancelled"],
        mainNotification: MainNotification.fromJson(json["mainNotification"]),
      );

  Map<String, dynamic> toJson() => {
        "notification_created": notificationCreated,
        "notification_draft": notificationDraft,
        "notification_preorder": notificationPreorder,
        "notification_estimate": notificationEstimate,
        "notification_cancelled": notificationCancelled,
        "mainNotification": mainNotification!.toJson(),
      };
}

class MainNotification {
  int? recentOrders;
  int? waitingForApproval;
  int? quickSale;
  int? processingOrders;
  int? packedAndReadyForDelivery;
  int? delivered;
  int? rejected;

  MainNotification({
    this.recentOrders,
    this.waitingForApproval,
    this.quickSale,
    this.processingOrders,
    this.packedAndReadyForDelivery,
    this.delivered,
    this.rejected,
  });

  factory MainNotification.fromJson(Map<String, dynamic> json) =>
      MainNotification(
        recentOrders: json["recent_orders"] ?? 0,
        waitingForApproval: json["waiting_for_approval"]  ?? 0,
        quickSale: json["quick_sale"]  ?? 0,
        processingOrders: json["processing_orders"]   ?? 0,
        packedAndReadyForDelivery: json["packed_and_ready_for_delivery"]  ?? 0,
        delivered: json["delivered"]  ?? 0,
        rejected: json["rejected"]  ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "recent_orders": recentOrders,
        "waiting_for_approval": waitingForApproval,
        "quick_sale": quickSale,
        "processing_orders": processingOrders,
        "packed_and_ready_for_delivery": packedAndReadyForDelivery,
        "delivered": delivered,
        "rejected": rejected,
      };
}

class LeadsCountData {
    int? statusCode;
    bool? status;
    String? message;
    int? data;

    LeadsCountData({
        this.statusCode,
        this.status,
        this.message,
        this.data,
    });

    factory LeadsCountData.fromJson(Map<String, dynamic> json) => LeadsCountData(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data,
    };
}
