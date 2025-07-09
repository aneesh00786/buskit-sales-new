class CategoryItem {
  final String subCategory;
  final String id;

  CategoryItem({
    required this.subCategory,
    required this.id,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      subCategory: json['sub_category'] ?? '',
      id: json['id'] ?? '',
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
      categoryName: json['categoryName'] ?? '',
      id: json['id'] ?? '',
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
      statusCode: json['status_code'] is int ? json['status_code'] : 0,
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] ?? '',
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
