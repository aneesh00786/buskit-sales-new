class CustomerDashboardTotalSaleResponse {
  int? statusCode;
  bool? status;
  String? message;
  CustomerDashboardTotalSaleData? data;

  CustomerDashboardTotalSaleResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  CustomerDashboardTotalSaleResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as Map<String, dynamic>?) != null
        ? CustomerDashboardTotalSaleData.fromJson(
            json['data'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.toJson();
    return json;
  }
}

class CustomerDashboardTotalSaleData {
  TotalSale? totalSale;
  List<dynamic>? discountData;

  CustomerDashboardTotalSaleData({
    this.totalSale,
    this.discountData,
  });

  CustomerDashboardTotalSaleData.fromJson(Map<String, dynamic> json) {
    totalSale = (json['total_sale'] as Map<String, dynamic>?) != null
        ? TotalSale.fromJson(json['total_sale'] as Map<String, dynamic>)
        : null;
    discountData = json['discount_data'] as List?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['total_sale'] = totalSale?.toJson();
    json['discount_data'] = discountData;
    return json;
  }
}

class TotalSale {
  PaymentCompleted? paymentCompleted;
  PaymentRemaning? paymentRemaning;

  TotalSale({
    this.paymentCompleted,
    this.paymentRemaning,
  });

  TotalSale.fromJson(Map<String, dynamic> json) {
    paymentCompleted =
        (json['payment_completed'] as Map<String, dynamic>?) != null
            ? PaymentCompleted.fromJson(
                json['payment_completed'] as Map<String, dynamic>)
            : null;
    paymentRemaning =
        (json['payment_remaning'] as Map<String, dynamic>?) != null
            ? PaymentRemaning.fromJson(
                json['payment_remaning'] as Map<String, dynamic>)
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['payment_completed'] = paymentCompleted?.toJson();
    json['payment_remaning'] = paymentRemaning?.toJson();
    return json;
  }
}

class PaymentCompleted {
  int? count;
  int? percentage;

  PaymentCompleted({
    this.count,
    this.percentage,
  });

  PaymentCompleted.fromJson(Map<String, dynamic> json) {
    count = json['count'] as int?;
    percentage = json['percentage'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['count'] = count;
    json['percentage'] = percentage;
    return json;
  }
}

class PaymentRemaning {
  int? count;
  int? percentage;

  PaymentRemaning({
    this.count,
    this.percentage,
  });

  PaymentRemaning.fromJson(Map<String, dynamic> json) {
    count = json['count'] as int?;
    percentage = json['percentage'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['count'] = count;
    json['percentage'] = percentage;
    return json;
  }
}
