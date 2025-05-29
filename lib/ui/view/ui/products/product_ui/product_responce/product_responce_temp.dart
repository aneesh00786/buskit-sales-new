import 'dart:convert';

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';

ProductResponceTemp productResponceTempFromJson(String str) =>
    ProductResponceTemp.fromJson(json.decode(str));
String productResponceTempToJson(ProductResponceTemp data) =>
    json.encode(data.toJson());

class ProductResponceTemp {
  ProductResponceTemp({
    this.statusCode,
    this.status,
    this.message,
    this.newarray,
  });

  ProductResponceTemp.fromJson(dynamic json) {
    statusCode = json['status_code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      newarray = [];
      json['data'].forEach((v) {
        newarray?.add(Newarray.fromJson(v));
      });
    }
  }
  int? statusCode;
  bool? status;
  String? message;
  List<Newarray>? newarray;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status_code'] = statusCode;
    map['status'] = status;
    map['message'] = message;
    if (newarray != null) {
      map['data'] = newarray?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
Newarray dataFromJson(String str) => Newarray.fromJson(json.decode(str));
String dataToJson(Newarray data) => json.encode(data.toJson());

class Newarray {
  Newarray({
    this.scid,
    this.productList,
  });

  Newarray.fromJson(dynamic json) {
    scid = json['scid'];
    if (json['product'] != null) {
      productList = [];
      json['product'].forEach((v) {
        productList?.add(ProductList.fromJson(v));
      });
    }
  }
  String? scid;
  List<ProductList>? productList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['scid'] = scid;
    if (productList != null) {
      map['product'] = productList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
