import 'package:hive_flutter/hive_flutter.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? productId;

  @HiveField(2)
  String? brandname;

  @HiveField(3)
  String? productName;

  @HiveField(4)
  String? description;

  @HiveField(5)
  String? reasonBySalesman;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  String? inclTax;

  @HiveField(8)
  int? status;

  @HiveField(9)
  String? scid;

  @HiveField(10)
  int? catId;

  @HiveField(11)
  int? companyId;

  @HiveField(12)
  String? stock;

  @HiveField(13)
  List<Detail>? detail;

  ProductModel({
    this.id,
    this.productId,
    this.brandname,
    this.productName,
    this.description,
    this.reasonBySalesman,
    this.imageUrl,
    this.inclTax,
    this.status,
    this.scid,
    this.catId,
    this.companyId,
    this.stock,
    this.detail,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    brandname = json['brandname'];
    productName = json['product_name'];
    description = json['description'];
    reasonBySalesman = json['reason_by_salesman'];
    imageUrl = json['image_url'];
    inclTax = json['incl_tax'];
    status = json['status'];
    scid = json['scid'];
    catId = json['catId'];
    companyId = json['company_id'];
    stock = json['stock'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['brandname'] = this.brandname;
    data['product_name'] = this.productName;
    data['description'] = this.description;
    data['reason_by_salesman'] = this.reasonBySalesman;
    data['image_url'] = this.imageUrl;
    data['incl_tax'] = this.inclTax;
    data['status'] = this.status;
    data['scid'] = this.scid;
    data['catId'] = this.catId;
    data['company_id'] = this.companyId;
    data['stock'] = this.stock;
    if (this.detail != null) {
      data['detail'] = this.detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 0)
class Detail {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? companyId;

  @HiveField(2)
  String? productId;

  @HiveField(3)
  String? variationId;

  @HiveField(4)
  String? inNo;

  @HiveField(5)
  String? barcode;

  @HiveField(6)
  String? variationName;

  @HiveField(7)
  String? unitType;

  @HiveField(8)
  String? price;

  @HiveField(9)
  String? sellPrice;

  @HiveField(10)
  num? tax;

  @HiveField(11)
  String? packtype;

  @HiveField(12)
  num? pieces;

  @HiveField(13)
  num? stock;

  @HiveField(14)
  num? lowstock;

  @HiveField(15)
  num? fullstock;

  @HiveField(16)
  String? imageUrl;

  @HiveField(17)
  int? status;

  @HiveField(18)
  int? vStatus;

  @HiveField(19)
  String? createdAt;

  @HiveField(20)
  String? updatedAt;

  @HiveField(21)
  num count;

  @HiveField(22)
  String? saleBy = 'Pack';

  @HiveField(23)
  num? totalPrice = 0.0;

  @HiveField(24)
  num? sellingPrice;

  @HiveField(25)
  num? packPrice;

  @HiveField(26)
  num? sellingPackPrice;

  Detail({
    this.id,
    this.companyId,
    this.productId,
    this.variationId,
    this.inNo,
    this.barcode,
    this.variationName,
    this.unitType,
    this.price,
    this.sellPrice,
    this.tax,
    this.packtype,
    this.pieces,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.imageUrl,
    this.status,
    this.vStatus,
    this.createdAt,
    this.updatedAt,
    this.count = 0,
    this.saleBy,
    this.totalPrice,
    this.sellingPrice,
    this.packPrice,
    this.sellingPackPrice,
  });

  Detail.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        companyId = json['company_id'],
        productId = json['product_id'],
        variationId = json['variation_id'],
        inNo = json['in_no'],
        barcode = json['barcode'],
        variationName = json['variation_name'],
        unitType = json['unitType'],
        price = json['price'],
        sellPrice = json['sell_price'],
        tax = json['tax'],
        packtype = json['packtype'],
        pieces = json['pieces'],
        stock = json['stock'],
        lowstock = json['lowstock'],
        fullstock = json['fullstock'],
        imageUrl = json['image_url'],
        status = json['status'],
        vStatus = json['v_status'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        count = json['count']??0.0,
        saleBy = json['saleBy'],
        totalPrice = json['totalPrice'],
        sellingPrice = json['selling_price'],
        packPrice = json['pack_price'],
        sellingPackPrice = json['selling_pack_price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['product_id'] = this.productId;
    data['variation_id'] = this.variationId;
    data['in_no'] = this.inNo;
    data['barcode'] = this.barcode;
    data['variation_name'] = this.variationName;
    data['unitType'] = this.unitType;
    data['price'] = this.price;
    data['sell_price'] = this.sellPrice;
    data['tax'] = this.tax;
    data['packtype'] = this.packtype;
    data['pieces'] = this.pieces;
    data['stock'] = this.stock;
    data['lowstock'] = this.lowstock;
    data['fullstock'] = this.fullstock;
    data['image_url'] = this.imageUrl;
    data['status'] = this.status;
    data['v_status'] = this.vStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['count'] = this.count;
    data['saleBy'] = this.saleBy;
    data['totalPrice'] = this.totalPrice;
    data['selling_price'] = this.sellingPrice;
    data['pack_price'] = this.packPrice;
    data['selling_pack_price'] = this.sellingPackPrice;
    return data;
  }
}
