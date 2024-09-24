import 'dart:convert';

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';

/// status_code : 200
/// status : true
/// message : "Data Fetch successfully"
/// data : [{"scid":"C17SC45","productList":[{"Productname":"pepsi ","description":"pepsi is very testy","image_path":"http://139.59.3.15:1000/uploads/product/1686914853650.jpg","variant":[{"id":24,"pid":"C17SC45PD24","variants":"200ml","price":20,"tax":3,"packtype":"Carton","pieces":12,"stock":100,"lowstock":5,"fullstock":1000}]}]},{"scid":"C17SC46","productList":[{"Productname":"Coke","description":"Cockeee","image_path":"http://139.59.3.15:1000/uploads/product/1686920135469.jpeg","variant":[{"id":25,"pid":"C17SC46PD25","variants":"120","price":60,"tax":5,"packtype":"Loose","pieces":55,"stock":44,"lowstock":60,"fullstock":55}]}]}]

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

/// scid : "C17SC45"
/// productList : [{"Productname":"pepsi ","description":"pepsi is very testy","image_path":"http://139.59.3.15:1000/uploads/product/1686914853650.jpg","variant":[{"id":24,"pid":"C17SC45PD24","variants":"200ml","price":20,"tax":3,"packtype":"Carton","pieces":12,"stock":100,"lowstock":5,"fullstock":1000}]}]

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
