class ProductFrequencyResponse {
    int? statusCode;
    bool? status;
    List<ProductFrequencyData>? data;
    Summary? summary;

    ProductFrequencyResponse({
        this.statusCode,
        this.status,
        this.data,
        this.summary,
    });

    factory ProductFrequencyResponse.fromJson(Map<String, dynamic> json) => ProductFrequencyResponse(
        statusCode: json["status_code"],
        status: json["status"],
        data: json["data"] == null ? [] : List<ProductFrequencyData>.from(json["data"]!.map((x) => ProductFrequencyData.fromJson(x))),
        summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "summary": summary?.toJson(),
    };
}

class ProductFrequencyData {
    String? productId;
    String? productName;
    String? brandname;
    String? productCode;
    String? customerId;
    String? frequencyLevel;
    String? frequencyScore;
    int? totalOrders;
    int? totalQuantity;
    DateTime? lastOrderDate;
    int? analysisPeriodMonths;
    DateTime? updatedAt;
    String? colorCode;

    ProductFrequencyData({
        this.productId,
        this.productName,
        this.brandname,
        this.productCode,
        this.customerId,
        this.frequencyLevel,
        this.frequencyScore,
        this.totalOrders,
        this.totalQuantity,
        this.lastOrderDate,
        this.analysisPeriodMonths,
        this.updatedAt,
        this.colorCode,
    });

    factory ProductFrequencyData.fromJson(Map<String, dynamic> json) => ProductFrequencyData(
        productId: json["product_id"],
        productName: json["product_name"],
        brandname: json["brandname"],
        productCode: json["product_code"],
        customerId: json["customer_id"],
        frequencyLevel: json["frequency_level"],
        frequencyScore: json["frequency_score"],
        totalOrders: json["total_orders"],
        totalQuantity: json["total_quantity"],
        lastOrderDate: json["last_order_date"] == null ? null : DateTime.parse(json["last_order_date"]),
        analysisPeriodMonths: json["analysis_period_months"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        colorCode: json["color_code"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "product_name": productName,
        "brandname": brandname,
        "product_code": productCode,
        "customer_id": customerId,
        "frequency_level": frequencyLevel,
        "frequency_score": frequencyScore,
        "total_orders": totalOrders,
        "total_quantity": totalQuantity,
        "last_order_date": lastOrderDate?.toIso8601String(),
        "analysis_period_months": analysisPeriodMonths,
        "updated_at": updatedAt?.toIso8601String(),
        "color_code": colorCode,
    };
}

class Summary {
    int? total;
    int? high;
    int? medium;
    int? low;
    int? none;

    Summary({
        this.total,
        this.high,
        this.medium,
        this.low,
        this.none,
    });

    factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        total: json["total"],
        high: json["high"],
        medium: json["medium"],
        low: json["low"],
        none: json["none"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "high": high,
        "medium": medium,
        "low": low,
        "none": none,
    };
}