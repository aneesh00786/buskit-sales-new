class CategoryItem {
  final String subCategory;
  final String id;

  CategoryItem({
    required this.subCategory,
    required this.id,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      subCategory:
          json['sub_category'] ?? '', // Provide a default value if null
      id: json['id'] ?? '', // Provide a default value if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_category': subCategory,
      'id': id,
    };
  }
}

class CategoryP {
  final String categoryName;
  final String id;
  final List<CategoryItem> categoryItem;

  CategoryP({
    required this.categoryName,
    required this.id,
    required this.categoryItem,
  });

  factory CategoryP.fromJson(Map<String, dynamic> json) {
    return CategoryP(
      categoryName:
          json['categoryName'] ?? '', // Provide a default value if null
      id: json['id'] ?? '', // Provide a default value if null
      categoryItem: (json['categoryItem'] as List<dynamic>? ?? [])
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'id': id,
      'categoryItem': categoryItem.map((item) => item.toJson()).toList(),
    };
  }
}

class CategoryResponse {
  final int statusCode;
  final bool status;
  final String message;
  final List<CategoryP> data;

  CategoryResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      statusCode: json['status_code'] is int
          ? json['status_code']
          : 0, // Ensure type safety
      status:
          json['status'] is bool ? json['status'] : false, // Ensure type safety
      message: json['message'] ?? '', // Provide a default value if null
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => CategoryP.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}

class ApiResponsePo {
  final int statusCode;
  final bool status;
  final String message;
  final List<StoreDataPo> data;

  ApiResponsePo({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponsePo.fromJson(Map<String, dynamic> json) {
    return ApiResponsePo(
      statusCode: json['status_code'] is int ? json['status_code'] : 0,
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map(
                  (item) => StoreDataPo.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StoreDataPo {
  final String scid;
  final List<ProductPo> product;

  StoreDataPo({
    required this.scid,
    required this.product,
  });

  factory StoreDataPo.fromJson(Map<String, dynamic> json) {
    return StoreDataPo(
      scid: json['scid'] ?? '',
      product: (json['product'] as List<dynamic>?)
              ?.map((item) => ProductPo.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ProductPo {
  final int id;
  final String productId;
  final String brandName;
  final String productName;
  final String description;
  final String? reasonBySalesman;
  final String imageUrl;
  final int status;
  final String scid;
  final int catId;
  final List<DetailPo> detail;

  ProductPo({
    required this.id,
    required this.productId,
    required this.brandName,
    required this.productName,
    required this.description,
    this.reasonBySalesman,
    required this.imageUrl,
    required this.status,
    required this.scid,
    required this.catId,
    required this.detail,
  });

  factory ProductPo.fromJson(Map<String, dynamic> json) {
    return ProductPo(
      id: json['id'] is int ? json['id'] : 0,
      productId: json['product_id'] ?? '',
      brandName: json['brandname'] ?? '',
      productName: json['product_name'] ?? '',
      description: json['description'] ?? '',
      reasonBySalesman: json['reason_by_salesman'],
      imageUrl: json['image_url'] ?? '',
      status: json['status'] is int ? json['status'] : 0,
      scid: json['scid'] ?? '',
      catId: json['catId'] is int ? json['catId'] : 0,
      detail: (json['detail'] as List<dynamic>?)
              ?.map((item) => DetailPo.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DetailPo {
  final int id;
  final String productId;
  final String variationId;
  final String variationName;
  final String unitType;
  final String price;
  final String tax;
  final String packType;
  final int pieces;
  final int stock;
  final int lowStock;
  final int fullStock;
  final String imageUrl;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DetailPo({
    required this.id,
    required this.productId,
    required this.variationId,
    required this.variationName,
    required this.unitType,
    required this.price,
    required this.tax,
    required this.packType,
    required this.pieces,
    required this.stock,
    required this.lowStock,
    required this.fullStock,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailPo.fromJson(Map<String, dynamic> json) {
    return DetailPo(
      id: json['id'] is int ? json['id'] : 0,
      productId: json['product_id'] ?? '',
      variationId: json['variation_id'] ?? '',
      variationName: json['variation_name'] ?? '',
      unitType: json['unitType'] ?? '',
      price: json['price'] ?? '',
      tax: json['tax'] ?? '',
      packType: json['packtype'] ?? '',
      pieces: json['pieces'] is int ? json['pieces'] : 0,
      stock: json['stock'] is int ? json['stock'] : 0,
      lowStock: json['lowstock'] is int ? json['lowstock'] : 0,
      fullStock: json['fullstock'] is int ? json['fullstock'] : 0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] is int ? json['status'] : 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
