import 'dart:convert';

/// status_code : 200
/// status : true
/// message : "Data Fetch successfully"
/// data : [{"id":1,"pid":"C33SC65PD1","Productname":"nike air jorden","description":"it's user comfort tech Developed by nike and give best comfortness to you. ","variants":"7size","price":100,"tax":18,"packtype":"Box","pieces":1,"stock":100,"lowstock":20,"fullstock":1000,"image_path":"http:/192.168.1.51:1000/uploads/product/1686296131751.jpg","image_name":"1686296131751.jpg","scid":"C33SC65"},{"id":5,"pid":"C33SC65PD5","Productname":"nike high top","description":"it's styles with hot red color","variants":"8size","price":60,"tax":18,"packtype":"Box","pieces":1,"stock":50,"lowstock":5,"fullstock":200,"image_path":"http:/192.168.1.51:1000/uploads/product/1686297092420.jpg","image_name":"1686297092420.jpg","scid":"C33SC65"},{"id":8,"pid":"C33SC65PD8","Productname":"nike running","description":"it's very light and Durable ","variants":"8size","price":60,"tax":18,"packtype":"Box","pieces":1,"stock":200,"lowstock":20,"fullstock":1000,"image_path":"http:/192.168.1.51:1000/uploads/product/1686297317968.jpg","image_name":"1686297317968.jpg","scid":"C33SC65"},{"id":11,"pid":"C33SC65PD11","Productname":"nike casual","description":"it's in light color and pop up style ","variants":"8size","price":60,"tax":18,"packtype":"Box","pieces":1,"stock":200,"lowstock":20,"fullstock":1000,"image_path":"http:/192.168.1.51:1000/uploads/product/1686297492417.jpg","image_name":"1686297492417.jpg","scid":"C33SC65"},{"id":14,"pid":"C33SC65PD14","Productname":"nike jorden","description":"it's mid-top black and red color combination with sof-tech by nike ","variants":"9size","price":300,"tax":18,"packtype":"Box","pieces":1,"stock":500,"lowstock":55,"fullstock":2000,"image_path":"http:/192.168.1.51:1000/uploads/product/1686297708255.jpg","image_name":"1686297708255.jpg","scid":"C33SC65"},{"id":16,"pid":"C33SC66PD16","Productname":"green flip-flop","description":"it's branded ny nike ","variants":"8size","price":50,"tax":18,"packtype":"Box","pieces":1,"stock":500,"lowstock":55,"fullstock":2000,"image_path":"http:/192.168.1.51:1000/uploads/product/1686297872526.jpg","image_name":"1686297872526.jpg","scid":"C33SC66"},{"id":19,"pid":"C33SC66PD19","Productname":"lather flip-flop","description":"it's made of orignal lather ","variants":"9size","price":20,"tax":18,"packtype":"Box","pieces":1,"stock":35,"lowstock":2,"fullstock":80,"image_path":"http:/192.168.1.51:1000/uploads/product/1686299045753.jpg","image_name":"1686299045753.jpg","scid":"C33SC66"},{"id":22,"pid":"C31SC61PD22","Productname":"test","description":"no","variants":"0kg","price":0,"tax":0,"packtype":"Carton","pieces":0,"stock":0,"lowstock":0,"fullstock":0,"image_path":"http:/192.168.1.51:1000/uploads/product/1686303435715.JPG","image_name":"1686303435715.JPG","scid":"C31SC61"},{"id":23,"pid":"C31SC62PD23","Productname":"test 2","description":"no","variants":"0kg","price":0,"tax":0,"packtype":"Carton","pieces":0,"stock":0,"lowstock":0,"fullstock":0,"image_path":"http:/192.168.1.51:1000/uploads/product/1686303510624.jpg","image_name":"1686303510624.jpg","scid":"C31SC62"},{"id":24,"pid":"C31SC61PD24","Productname":"test3","description":"no","variants":"0kg","price":0,"tax":0,"packtype":"Carton","pieces":0,"stock":0,"lowstock":0,"fullstock":0,"image_path":"http:/192.168.1.51:1000/uploads/product/1686303560911.jpg","image_name":"1686303560911.jpg","scid":"C31SC61"}]

ProductResponce productResponceFromJson(String str) =>
    ProductResponce.fromJson(json.decode(str));
String productResponceToJson(ProductResponce data) =>
    json.encode(data.toJson());

class ProductResponce {
  ProductResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  ProductResponce.fromJson(dynamic json) {
    statusCode = json['status_code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ProductResponceData.fromJson(v));
      });
    }
  }
  int? statusCode;
  bool? status;
  String? message;
  List<ProductResponceData>? data;

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

/// id : 1
/// pid : "C33SC65PD1"
/// Productname : "nike air jorden"
/// description : "it's user comfort tech Developed by nike and give best comfortness to you. "
/// variants : "7size"
/// price : 100
/// tax : 18
/// packtype : "Box"
/// pieces : 1
/// stock : 100
/// lowstock : 20
/// fullstock : 1000
/// image_path : "http:/192.168.1.51:1000/uploads/product/1686296131751.jpg"
/// image_name : "1686296131751.jpg"
/// scid : "C33SC65"

ProductResponceData dataFromJson(String str) =>
    ProductResponceData.fromJson(json.decode(str));
String dataToJson(ProductResponceData data) => json.encode(data.toJson());

class ProductResponceData {
  ProductResponceData({
    this.id,
    this.pid,
    this.productname,
    this.description,
    this.variants,
    this.price,
    this.tax,
    this.packtype,
    this.pieces,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.imagePath,
    this.imageName,
    this.scid,
  });

  ProductResponceData.fromJson(dynamic json) {
    id = json['id'].toString();
    pid = json['pid'];
    productname = json['Productname'];
    description = json['description'];
    variants = json['variants'];
    price = json['price'];
    tax = json['tax'];
    packtype = json['packtype'];
    pieces = json['pieces'];
    stock = json['stock'];
    lowstock = json['lowstock'];
    fullstock = json['fullstock'];
    imagePath = json['image_path'];
    imageName = json['image_name'];
    scid = json['scid'];
  }
  String? id;
  String? pid;
  String? productname;
  String? description;
  String? variants;
  int? price;
  int? tax;
  String? packtype;
  int? pieces;
  int? stock;
  int? lowstock;
  int? fullstock;
  String? imagePath;
  String? imageName;
  String? scid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['pid'] = pid;
    map['Productname'] = productname;
    map['description'] = description;
    map['variants'] = variants;
    map['price'] = price;
    map['tax'] = tax;
    map['packtype'] = packtype;
    map['pieces'] = pieces;
    map['stock'] = stock;
    map['lowstock'] = lowstock;
    map['fullstock'] = fullstock;
    map['image_path'] = imagePath;
    map['image_name'] = imageName;
    map['scid'] = scid;
    return map;
  }
}
