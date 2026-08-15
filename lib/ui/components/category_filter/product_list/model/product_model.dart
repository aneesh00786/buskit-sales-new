import 'package:hive_flutter/hive_flutter.dart';

part 'product_model.g.dart';

// New response model for the updated API structure
@HiveType(typeId: 12)
class ProductApiResponse {
  @HiveField(0)
  final int statusCode;
  @HiveField(1)
  final bool status;
  @HiveField(2)
  final String message;
  @HiveField(3)
  final List<ScidProductGroup> data;

  ProductApiResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
    return ProductApiResponse(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => ScidProductGroup.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

// Model for scid-based product grouping
@HiveType(typeId: 13)
class ScidProductGroup {
  @HiveField(0)
  final String scid;
  @HiveField(1)
  final List<ProductModel> products;

  ScidProductGroup({
    required this.scid,
    required this.products,
  });

  factory ScidProductGroup.fromJson(Map<String, dynamic> json) {
    return ScidProductGroup(
      scid: json['scid'] ?? '',
      products: (json['product'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scid': scid,
      'product': products.map((product) => product.toJson()).toList(),
    };
  }
}

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

  @HiveField(14)
  String? productCode;

  @HiveField(15)
  num? catTax;

  @HiveField(16)
  String? pName;

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
    this.productCode,
    this.catTax,
    this.pName,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    // id = json['id'];
    if (json['id'] != null) {
      if (json['id'] is int) {
        id = json['id'];
      } else {
       
        id = int.tryParse(json['id'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
      }
    } else {
      id = null;
    }
    productId = json['product_id'];
    brandname = json['brandname'];
    productName = json['product_name'];
    pName = json['p_name'];
    description = json['description'];
    reasonBySalesman = json['reason_by_salesman'];
    imageUrl = json['image_url'];
    inclTax = json['incl_tax'];
    status = json['status'];
    scid = json['scid'];
    catId = json['catId'];
    companyId = json['company_id'];
  stock = json['stock']?.toString();
    productCode = json['product_code'];

    var rawTax = json['cat_tax'];

    
    if (rawTax == null &&
        json['detail'] != null &&
        (json['detail'] as List).isNotEmpty) {
      rawTax = json['detail'][0]['cat_tax'];
    }

    
    catTax = rawTax != null ? num.tryParse(rawTax.toString()) : 0;
   

    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
  }

  // ProductModel.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   productId = json['product_id'];
  //   brandname = json['brandname'];
  //   productName = json['product_name'];
  //   description = json['description'];
  //   reasonBySalesman = json['reason_by_salesman'];
  //   imageUrl = json['image_url'];
  //   inclTax = json['incl_tax'];
  //   status = json['status'];
  //   scid = json['scid'];
  //   catId = json['catId'];
  //   companyId = json['company_id'];
  //   stock = json['stock'];
  //   productCode = json['product_code'];
  //  if (json['cat_tax'] != null) {
  //     catTax = num.tryParse(json['cat_tax'].toString());
  //   } else {
  //     catTax = 0; // Or null, depending on your preference
  //   }
  //   if (json['detail'] != null) {
  //     detail = <Detail>[];
  //     json['detail'].forEach((v) {
  //       detail!.add(Detail.fromJson(v));
  //     });
  //   }
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['product_id'] = productId;
    data['brandname'] = brandname;
    data['product_name'] = productName;
    data['p_name'] = pName;
    data['description'] = description;
    data['reason_by_salesman'] = reasonBySalesman;
    data['image_url'] = imageUrl;
    data['incl_tax'] = inclTax;
    data['status'] = status;
    data['scid'] = scid;
    data['catId'] = catId;
    data['company_id'] = companyId;
    data['stock'] = stock;
    data['product_code'] = productCode;
    data['cat_tax'] = catTax;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
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

  @HiveField(27)
  String? inclTax;

  @HiveField(28)
  num? initialQuantity;

  @HiveField(29)
  num? unitTax;

  @HiveField(30)
  String? pack;

  @HiveField(31)
  num? discount;

  @HiveField(32)
  num? totaltax;

  @HiveField(33)
  String? productName;

  @HiveField(34)
  num? maxDiscount;

   @HiveField(35)
  num? promoDiscount;

  @HiveField(36)
  num? customerDiscount;

  @HiveField(37) 
  num? initialCount;


  @HiveField(38)
  String? bulkId;

  @HiveField(39)
  num? bulkDiscount; 

  @HiveField(40)
  num? bulkTax;

  @HiveField(41)
  num? bulkDiscountAmount;



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
    this.count = 0,
    this.saleBy,
    this.totalPrice,
    this.sellingPrice,
    this.packPrice,
    this.sellingPackPrice,
    this.inclTax,
    this.initialQuantity,
    this.unitTax,
    this.pack,
    this.discount,
    this.totaltax,
    this.productName,
    this.maxDiscount,
    this.promoDiscount,
    this.customerDiscount,
    this.initialCount,
    this.bulkId,
    this.bulkDiscount,
    this.bulkTax,
    this.bulkDiscountAmount,
  });
  Detail copyWith({
    int? id,
    int? companyId,
    String? productId,
    String? variationId,
    String? inNo,
    String? barcode,
    String? variationName,
    String? unitType,
    String? price,
    String? sellPrice,
    num? tax,
    String? packtype,
    num? pieces,
    num? stock,
    num? lowstock,
    num? fullstock,
    String? imageUrl,
    int? status,
    int? vStatus,
    num? count,
    String? saleBy,
    num? totalPrice,
    num? sellingPrice,
    num? packPrice,
    num? sellingPackPrice,
    String? inclTax,
    num? initialQuantity,
    num? unitTax,
    String? pack,
    num? discount,
    num? totaltax,
    num? maxDiscount,
    String? productName,
    String? bulkId,
    num? bulkDiscount,
    num? bulkTax,
    num? bulkDiscountAmount,
  }) {
    return Detail(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      productId: productId ?? this.productId,
      variationId: variationId ?? this.variationId,
      inNo: inNo ?? this.inNo,
      barcode: barcode ?? this.barcode,
      variationName: variationName ?? this.variationName,
      unitType: unitType ?? this.unitType,
      price: price ?? this.price,
      sellPrice: sellPrice ?? this.sellPrice,
      tax: tax ?? this.tax,
      packtype: packtype ?? this.packtype,
      pieces: pieces ?? this.pieces,
      stock: stock ?? this.stock,
      lowstock: lowstock ?? this.lowstock,
      fullstock: fullstock ?? this.fullstock,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      vStatus: vStatus ?? this.vStatus,
      count: count ?? this.count,
      saleBy: saleBy ?? this.saleBy,
      totalPrice: totalPrice ?? this.totalPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      packPrice: packPrice ?? this.packPrice,
      sellingPackPrice: sellingPackPrice ?? this.sellingPackPrice,
      inclTax: inclTax ?? this.inclTax,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      unitTax: unitTax ?? this.unitTax,
      pack: pack ?? this.pack,
      discount: discount ?? this.discount,
      totaltax: totaltax ?? totaltax,
      productName: productName ?? this.productName,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      bulkId: bulkId ?? this.bulkId,
      bulkDiscount: bulkDiscount ?? this.bulkDiscount,
      bulkTax: bulkTax ?? this.bulkTax,
      bulkDiscountAmount: bulkDiscountAmount ?? this.bulkDiscountAmount,
    );
  }

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
        count = json['count'] ?? 0.0,
        saleBy = json['saleBy'],
        totalPrice = json['totalPrice'],
        sellingPrice = json['selling_price'],
        packPrice = json['pack_price'],
        sellingPackPrice = json['selling_pack_price'],
        inclTax = json['incl_tax'],
        initialQuantity = json['quantity'],
        unitTax = json['unit_tax'],
        pack = json['packtype'],
        discount = json['discount'],
        totaltax = json['total_tax'],
        productName = json['product_name'],
        maxDiscount = json['max_discount'],
        promoDiscount = json['promo_discount'],
        initialCount = json['initialCount'] ?? json['count'] ?? 0.0,
        bulkId = json['bulk_id'],
        bulkDiscount = json['bulk_discount'],
        bulkTax = json['bulk_tax'],
        bulkDiscountAmount = json['bulk_discount_amount'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['company_id'] = companyId;
    data['product_id'] = productId;
    data['variation_id'] = variationId;
    data['in_no'] = inNo;
    data['barcode'] = barcode;
    data['variation_name'] = variationName;
    data['unitType'] = unitType;
    data['price'] = price;
    data['sell_price'] = sellPrice;
    data['tax'] = tax;
    data['packtype'] = packtype;
    data['pieces'] = pieces;
    data['stock'] = stock;
    data['lowstock'] = lowstock;
    data['fullstock'] = fullstock;
    data['image_url'] = imageUrl;
    data['status'] = status;
    data['v_status'] = vStatus;
    data['count'] = count;
    data['saleBy'] = saleBy;
    data['totalPrice'] = totalPrice;
    data['selling_price'] = sellingPrice;
    data['pack_price'] = packPrice;
    data['selling_pack_price'] = sellingPackPrice;
    data['incl_tax'] = inclTax;
    data['quantity'] = initialQuantity;
    data['unit_tax'] = unitTax;
    data['packType'] = pack;
    data['discount'] = discount;
    data['total_tax'] = totaltax;
    data['product_name'] = productName;
    data['max_discount'] = maxDiscount;
    data['promo_discount'] = promoDiscount;
    data['initialCount'] = initialCount;
    data['bulk_id'] = bulkId;
    data['bulk_discount'] = bulkDiscount;
    data['bulk_tax'] = bulkTax;
    data['bulk_discount_amount'] = bulkDiscountAmount;
    return data;
  }
}
