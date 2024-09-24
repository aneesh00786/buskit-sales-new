import 'package:hive/hive.dart';

part 'category_model.g.dart'; 

@HiveType(typeId: 3) 
class CategoryModel extends HiveObject {
  @HiveField(0)
  int? statusCode;

  @HiveField(1)
  bool? status;

  @HiveField(2)
  String? message;

  @HiveField(3)
  List<CategoryData>? data = [];

  CategoryModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  CategoryModel.fromJson(dynamic json) {
    statusCode = json['status_code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(CategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status_code'] = statusCode;
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

@HiveType(typeId: 4)
class CategoryData extends HiveObject {
  @HiveField(0)
  String? categoryName;

  @HiveField(1)
  String? id;

  @HiveField(2)
  List<SubCategoryItem>? subCategoryItem;

  @HiveField(3)
  bool isExpand = false;

  CategoryData({
    this.categoryName,
    this.id,
    this.subCategoryItem,
  });

  CategoryData.fromJson(dynamic json) {
    categoryName = json['categoryName'];
    id = json['id'];
    if (json['categoryItem'] != null) {
      subCategoryItem = [];
      json['categoryItem'].forEach((v) {
        subCategoryItem?.add(SubCategoryItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryName'] = categoryName;
    map['id'] = id;
    if (subCategoryItem != null) {
      map['categoryItem'] = subCategoryItem?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

@HiveType(typeId: 5)  
class SubCategoryItem extends HiveObject {
  @HiveField(0)
  String? subCategory;

  @HiveField(1)
  String? id;

  @HiveField(2)
  bool isEdit = false;

  SubCategoryItem({
    this.subCategory,
    this.id,
  });

  SubCategoryItem.fromJson(dynamic json) {
    subCategory = json['sub_category'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sub_category'] = subCategory;
    map['id'] = id;
    return map;
  }
}


class ProductList {
  int? id;
  String? productId;
  String? brandName;
  String? productname;
  String? description;
  String? reasonBySalesman;
  String? imagePath;
  String? imagePathTemp;
  int? status;
  String? scid;
  List<Variant>? variant;

  ProductList({
    this.id,
    this.productId,
    this.brandName,
    this.productname,
    this.description,
    this.reasonBySalesman,
    this.imagePath,
    this.status,
    this.scid,
    this.variant,
  });

  ProductList.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as String?;
    brandName = json['brandname'] as String?;
    productname = json['product_name'] as String?;
    description = json['description'] as String?;
    reasonBySalesman = json['reason_by_salesman'];
    imagePath = json['image_url'].toString();
    imagePathTemp = json['image_url'].toString();
    status = json['status'] as int?;
    scid = json['scid'] as String?;
    variant = (json['detail'] as List?)
        ?.map((dynamic e) => Variant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['product_id'] = productId;
    json['brandname'] = brandName;
    json['product_name'] = productname;
    json['description'] = description;
    json['reason_by_salesman'] = reasonBySalesman;
    json['image_url'] = imagePath;
    json['status'] = status;
    json['scid'] = scid;
    json['detail'] = variant?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Variant {
  int? id;
  String? productId;
  String? variationId;
  String? variants;
  String? variantType;
  num? price;
  num? tax;
  String? packtype;
  num? pieces;
  num? stock;
  num? lowstock;
  num? fullstock;
  num? quntity = 0;
  String? imageUrl;
  int? status;
  String? createdAt;
  String? updatedAt;
  bool isEdit = false;

  Variant(
      {this.id,
      this.productId,
      this.variationId,
      this.variants,
      this.variantType,
      this.price,
      this.tax,
      this.packtype,
      this.isEdit = false,
      this.pieces,
      this.stock,
      this.lowstock,
      this.fullstock,
      this.imageUrl,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.quntity});

  bool get checkDataIsNotEmpty =>
      variants != null &&
      price != null &&
      tax != null &&
      packtype != null &&
      pieces != null &&
      stock != null &&
      lowstock != null &&
      fullstock != null;

  Variant.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as String?;
    variationId = json['variation_id'] as String?;
    variants = json['variation_name'] as String?;
    variantType = json['unitType'] as String?;
    price = num.parse(json['price']?.toString() ?? '0');
    tax = num.parse(json['tax']?.toString() ?? '0');
    packtype = json['packtype'] as String?;
    pieces = json['pieces'] as int?;
    stock = json['stock'] as int?;
    lowstock = json['lowstock'] as int?;
    fullstock = json['fullstock'] as int?;
    imageUrl = json['image_url'] as String?;
    status = json['status'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
  }

/*  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['product_id'] = productId;
    json['variation_id'] = variationId;
    json['variation_name'] = variationName;
    json['unitType'] = unitType;
    json['price'] = price;
    json['tax'] = tax;
    json['packtype'] = packtype;
    json['pieces'] = pieces;
    json['stock'] = stock;
    json['lowstock'] = lowstock;
    json['fullstock'] = fullstock;
    json['image_url'] = imageUrl;
    json['status'] = status;
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    return json;
  }*/

  Map<String, dynamic> toJsonTemp() {
    final map = <String, dynamic>{};
    map['id'] = productId;
    //map['product_id'] = productId;
    map['variant'] = variants;
    map['unitPrice'] = price;
    map['unitType'] = variantType;
    map['tax'] = tax;
    map['packType'] = packtype;
    map['pieces'] = pieces;
    map['stock'] = stock;
    map['lowStock'] = lowstock;
    map['fullStock'] = fullstock;
    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': productId,
        //'product_id': productId,
        'variants': variants,
        'unitType': variantType,
        'price': price,
        'tax': tax,
        'packtype': packtype,
        'pieces': pieces,
        "quantity": quntity,
        'stock': stock,
        'lowstock': lowstock,
        'fullstock': fullstock,
      };
}

/* {
  "status_code": 200,
  "status": true,
  "message": "Data Fetch Successfully",
  "data": [
    {
      "categoryName": "Drinks",
      "id": "C17",
      "categoryItem": [
        {
          "sub_category": "pepsi",
          "id": "C17SC45",
          "productList": [
            {
              "Productname": "pepsi ",
              "description": "pepsi is very testy",
              "image_path": "http://139.59.3.15:1000/uploads/product/1686914853650.jpg",
              "variant": [
                {
                  "id": 24,
                  "pid": "C17SC45PD24",
                  "variants": "200ml",
                  "price": 20,
                  "tax": 3,
                  "packtype": "Carton",
                  "pieces": 12,
                  "stock": 100,
                  "lowstock": 5,
                  "fullstock": 1000
                },
                {
                  "id": 24,
                  "pid": "C17SC45PD24",
                  "variants": "200ml",
                  "price": 20,
                  "tax": 3,
                  "packtype": "Carton",
                  "pieces": 12,
                  "stock": 100,
                  "lowstock": 5,
                  "fullstock": 1000
                },
                {
                  "id": 24,
                  "pid": "C17SC45PD24",
                  "variants": "200ml",
                  "price": 20,
                  "tax": 3,
                  "packtype": "Carton",
                  "pieces": 12,
                  "stock": 100,
                  "lowstock": 5,
                  "fullstock": 1000
                }
              ]
            }
          ]
        },
        {
          "sub_category": "Cola",
          "id": "C17SC46",
          "productList": [
            {
              "Productname": "pepsi ",
              "description": "pepsi is very testy",
              "image_path": "http://139.59.3.15:1000/uploads/product/1686914853650.jpg",
              "variant": [
                {
                  "id": 24,
                  "pid": "C17SC45PD24",
                  "variants": "200ml",
                  "price": 20,
                  "tax": 3,
                  "packtype": "Carton",
                  "pieces": 12,
                  "stock": 100,
                  "lowstock": 5,
                  "fullstock": 1000
                }
              ]
            }
          ]
        }
      ]
    }
  ]
} */
