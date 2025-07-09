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

  @HiveField(4)
  List<CategoryTax>? categoryTax;

  CategoryData({
    this.categoryName,
    this.id,
    this.subCategoryItem,
    this.categoryTax,
  });

  CategoryData.fromJson(dynamic json) {
    categoryName = json['categoryName'] ?? '';
    id = json['id'] ?? '';
    if (json['categoryItem'] != null) {
      subCategoryItem = [];
      json['categoryItem'].forEach((v) {
        subCategoryItem?.add(SubCategoryItem.fromJson(v ?? {}));
      });
    } else {
      subCategoryItem = [];
    }
    if (json['categoryTax'] != null) {
      categoryTax = [];
      json['categoryTax'].forEach((v) {
        categoryTax?.add(CategoryTax.fromJson(v ?? {}));
      });
    } else {
      categoryTax = [];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryName'] = categoryName ?? '';
    map['id'] = id ?? '';
    map['categoryItem'] = subCategoryItem?.map((v) => v.toJson()).toList() ?? [];
    map['categoryTax'] = categoryTax?.map((v) => v.toJson()).toList() ?? [];
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
    subCategory = json['sub_category'] ?? '';
    id = json['id'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sub_category'] = subCategory ?? '';
    map['id'] = id ?? '';
    return map;
  }
}

@HiveType(typeId: 6)
class CategoryTax extends HiveObject {
  @HiveField(0)
  int? taxId;

  @HiveField(1)
  String? taxName;

  @HiveField(2)
  num? tax;

  CategoryTax({
    this.taxId,
    this.taxName,
    this.tax,
  });

  factory CategoryTax.fromJson(Map<String, dynamic> json) => CategoryTax(
        taxId: json["tax_id"] ?? 0,
        taxName: json["tax_name"] ?? '',
        tax: json["tax"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "tax_id": taxId ?? 0,
        "tax_name": taxName ?? '',
        "tax": tax ?? 0,
      };
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

  Map<String, dynamic> toJsonTemp() {
    final map = <String, dynamic>{};
    map['id'] = productId;
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

class AddProductRequestModel {
  int? companyId;
  String? brandName;
  String? productName;
  String? productDescription;
  String? inclTax;
  String? description;
  String? imageUrl;
  String? scId;
  String? cId;

  AddProductRequestModel(
      {this.companyId,
      this.brandName,
      this.productName,
      this.productDescription,
      this.inclTax,
      this.description,
      this.imageUrl,
      this.scId,
      this.cId});

  AddProductRequestModel.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'] as int?;
    brandName = json['brandName'] as String?;
    productName = json['product_name'] as String?;
    productDescription = json['productDiscription'] as String?;
    inclTax = json['incl_tax'] as String?;
    description = json['description'] as String?;
    imageUrl = json['image_url'] as String?;
    scId = json['sub_category_id'] as String?;
    cId = json['category_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['companyId'] = companyId;
    json['brandName'] = brandName;
    json['product_name'] = productName;
    json['productDiscription'] = productDescription;
    json['incl_tax'] = inclTax;
    json['description'] = description;
    json['image_url'] = imageUrl;
    json['sub_category_id'] = scId;
    json['category_id'] = cId;
    return json;
  }
}

class AddProductResponse {
  int statusCode;
  bool status;
  String message;
  List<AddProductResponseData> data;

  AddProductResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddProductResponse.fromJson(Map<String, dynamic> json) =>
      AddProductResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<AddProductResponseData>.from(
            json["data"].map((x) => AddProductResponseData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AddProductResponseData {
  int id;
  String productId;
  String brandname;
  String productName;
  String description;
  dynamic reasonBySalesman;
  String imageUrl;
  String inclTax;
  int status;
  String scid;
  int catId;
  int companyId;

  AddProductResponseData({
    required this.id,
    required this.productId,
    required this.brandname,
    required this.productName,
    required this.description,
    required this.reasonBySalesman,
    required this.imageUrl,
    required this.inclTax,
    required this.status,
    required this.scid,
    required this.catId,
    required this.companyId,
  });

  factory AddProductResponseData.fromJson(Map<String, dynamic> json) =>
      AddProductResponseData(
        id: json["id"],
        productId: json["product_id"],
        brandname: json["brandname"],
        productName: json["product_name"],
        description: json["description"],
        reasonBySalesman: json["reason_by_salesman"],
        imageUrl: json["image_url"],
        inclTax: json["incl_tax"],
        status: json["status"],
        scid: json["scid"],
        catId: json["catId"],
        companyId: json["company_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "brandname": brandname,
        "product_name": productName,
        "description": description,
        "reason_by_salesman": reasonBySalesman,
        "image_url": imageUrl,
        "incl_tax": inclTax,
        "status": status,
        "scid": scid,
        "catId": catId,
        "company_id": companyId,
      };
}
