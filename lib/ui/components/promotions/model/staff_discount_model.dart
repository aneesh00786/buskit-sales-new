
class StaffDiscount {
    int? statusCode;
    bool? status;
    String? message;
    DiscountData? data;

    StaffDiscount({
        this.statusCode,
        this.status,
        this.message,
        this.data,
    });

    factory StaffDiscount.fromJson(Map<String, dynamic> json) => StaffDiscount(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : DiscountData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class DiscountData {
    List<Category>? categories;

    DiscountData({
        this.categories,
    });

    factory DiscountData.fromJson(Map<String, dynamic> json) => DiscountData(
        categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    };
}

class Category {
    String? categoryId;
    String? categoryName;
    int? categoryDiscount;
    List<DiscountProduct>? products;

    Category({
        this.categoryId,
        this.categoryName,
        this.categoryDiscount,
        this.products,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        categoryDiscount: json["category_discount"],
        products: json["products"] == null ? [] : List<DiscountProduct>.from(json["products"]!.map((x) => DiscountProduct.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_name": categoryName,
        "category_discount": categoryDiscount,
        "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    };
}

class DiscountProduct {
    String? id;
    String? name;
    int? discount;

    DiscountProduct({
        this.id,
        this.name,
        this.discount,
    });

    factory DiscountProduct.fromJson(Map<String, dynamic> json) => DiscountProduct(
        id: json["id"],
        name: json["name"],
        discount: json["discount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "discount": discount,
    };
}
