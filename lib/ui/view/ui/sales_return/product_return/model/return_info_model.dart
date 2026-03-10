class ReturnInfo {
  final bool status;
  final List<ReturnInfoData> data;
  final List<Aggregated> aggregated;

  ReturnInfo({
    required this.status,
    required this.data,
    required this.aggregated,
  });

  factory ReturnInfo.fromJson(Map<String, dynamic> json) => ReturnInfo(
        status: json["status"] ?? false,
        data: (json["data"] as List<dynamic>?)
                ?.map((x) => ReturnInfoData.fromJson(x as Map<String, dynamic>))
                .toList() ??
            [],
        aggregated: (json["aggregated"] as List<dynamic>?)
                ?.map((x) => Aggregated.fromJson(x as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.map((x) => x.toJson()).toList(),
        "aggregated": aggregated.map((x) => x.toJson()).toList(),
      };
}

class Aggregated {
  final String variationId;
  final int pendingQty; // Changed from String to int

  Aggregated({
    required this.variationId,
    required this.pendingQty,
  });

  factory Aggregated.fromJson(Map<String, dynamic> json) => Aggregated(
        variationId: json["variation_id"] as String,
        pendingQty: int.tryParse(json["pending_qty"]?.toString() ?? '0') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "variation_id": variationId,
        "pending_qty": pendingQty.toString(), // Keep as string in JSON
      };
}

class ReturnInfoData {
  final int id;
  final String returnId;
  final String cartId;
  final String productId;
  final String variationId;
  final String productName;
  final String variationName;
  final int returnQuantity;
  final String returnStatus;
  final String returnType;
  final DateTime? createdAt;
  final String? imageUrl;
  final String itemReturnReason;
  final String parentCompanyId;
  final DateTime? parentReturnDate;

  ReturnInfoData({
    required this.id,
    required this.returnId,
    required this.cartId,
    required this.productId,
    required this.variationId,
    required this.productName,
    required this.variationName,
    required this.returnQuantity,
    required this.returnStatus,
    required this.returnType,
    this.createdAt,
    this.imageUrl,
    required this.itemReturnReason,
    required this.parentCompanyId,
    this.parentReturnDate,
  });

  factory ReturnInfoData.fromJson(Map<String, dynamic> json) => ReturnInfoData(
        id: json["id"] as int,
        returnId: json["return_id"] as String,
        cartId: json["cart_id"] as String,
        productId: json["product_id"] as String,
        variationId: json["variation_id"] as String,
        productName: json["product_name"] as String,
        variationName: json["variation_name"] as String,
        returnQuantity: json["return_quantity"] as int,
        returnStatus: json["return_status"] as String,
        returnType: json["return_type"] as String,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"] as String),
        imageUrl: json["image_url"] as String?,
        itemReturnReason: json["item_return_reason"] as String? ?? '',
        parentCompanyId: json["parent_company_id"] as String,
        parentReturnDate: json["parent_return_date"] == null
            ? null
            : DateTime.parse(json["parent_return_date"] as String),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "return_id": returnId,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "product_name": productName,
        "variation_name": variationName,
        "return_quantity": returnQuantity,
        "return_status": returnStatus,
        "return_type": returnType,
        "created_at": createdAt?.toIso8601String(),
        "image_url": imageUrl,
        "item_return_reason": itemReturnReason,
        "parent_company_id": parentCompanyId,
        "parent_return_date": parentReturnDate?.toIso8601String(),
      };
}