class Bulk {
  int? statusCode;
  bool? status;
  List<BulkData>? data;

  Bulk({
    this.statusCode,
    this.status,
    this.data,
  });

  factory Bulk.fromJson(Map<String, dynamic> json) => Bulk(
        statusCode: _parseInt(json["status_code"]),
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<BulkData>.from(
                json["data"]!.map((x) => BulkData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null; // or throw if you prefer
}

class BulkData {
  int? id;
  String? volumeName;
  int? itemNumbers;
  String? unitPrice;
  String? volumePrice;
  String? categoryId;
  String? subcategoryId;
  String? productId;
  String? productVariantId;
  String? categoryName;
  String? subcategoryName;
  String? productName;
  DateTime? createdAt;
  String? calculatedTotal;
  double? discountPercentage;
  String? discountAmount;
  String? bulkId;
  String? variationName;
  String? inclTax;
  double? bulkTax;
  int? stock;
  String? vName;
  String? unitType;

  BulkData({
    this.id,
    this.volumeName,
    this.itemNumbers,
    this.unitPrice,
    this.volumePrice,
    this.categoryId,
    this.subcategoryId,
    this.productId,
    this.productVariantId,
    this.categoryName,
    this.subcategoryName,
    this.productName,
    this.createdAt,
    this.calculatedTotal,
    this.discountPercentage,
    this.discountAmount,
    this.bulkId,
    this.variationName,
    this.inclTax,
    this.bulkTax,
    this.stock,
    this.vName,
    this.unitType,
  });

  factory BulkData.fromJson(Map<String, dynamic> json) => BulkData(
        id: _parseInt(json["id"]),
        volumeName: json["volume_name"] as String?,
        itemNumbers: _parseInt(json["item_numbers"]),
        unitPrice: json["unit_price"]?.toString(),
        volumePrice: json["volume_price"]?.toString(),
        categoryId: json["category_id"]?.toString(),
        subcategoryId: json["subcategory_id"]?.toString(),
        productId: json["product_id"]?.toString(),
        productVariantId: json["product_variant_id"]?.toString(),
        categoryName: json["category_name"] as String?,
        subcategoryName: json["subcategory_name"] as String?,
        productName: json["product_name"] as String?,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        calculatedTotal: json["calculated_total"]?.toString(),
        discountPercentage: _parseDouble(json["discount_percentage"]),
        discountAmount: json["discount_amount"]?.toString(),
        bulkId: json["bulk_id"]?.toString(),
        variationName: json["variation_name"] as String?,
        inclTax: json["incl_tax"],
        bulkTax: _parseDouble(json["cat_tax"]),
        stock: _parseInt(json["stock"]),
        vName: json["v_name"] as String?,
        unitType: json["unitType"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "volume_name": volumeName,
        "item_numbers": itemNumbers,
        "unit_price": unitPrice,
        "volume_price": volumePrice,
        "category_id": categoryId,
        "subcategory_id": subcategoryId,
        "product_id": productId,
        "product_variant_id": productVariantId,
        "category_name": categoryName,
        "subcategory_name": subcategoryName,
        "product_name": productName,
        "created_at": createdAt?.toIso8601String(),
        "calculated_total": calculatedTotal,
        "discount_percentage": discountPercentage,
        "discount_amount": discountAmount,
        "bulk_id": bulkId,
        "variation_name": variationName,
        "incl_tax": inclTax,
        "cat_tax": bulkTax,
        "stock": stock,
        "v_name": vName,
        "unitType": unitType,
      };
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
