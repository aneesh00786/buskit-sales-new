import 'dart:convert';

/// status_code : 200
/// status : true
/// message : "Data Fetch successfully"
/// data : [{"id":1,"salesman_id":"SALES1","fullname":"raj patel","mobileno":"9327622916","email":"rttt@gmail.com","password":"1234","town":"wankaner","state":"Gujarat","zipcode":123,"address":"123","idimage_path":"http://139.59.3.15:1000/uploads/salesman/1687352671056.png","image_path":"http://139.59.3.15:1000/uploads/salesman/1687352670695.jpg","create_at":"2023-06-21T13:04:31.000Z","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJhaiBwYXRlbCIsImlhdCI6MTY4NzM1MjY3MX0.e9-qOKpCRl7xS8VjTsdsB2MYidEM4RrSqj-1_sav8fA"},{"id":2,"salesman_id":"SALES2","fullname":"raj","mobileno":"9327622917","email":"rajranipa47@gmail.com","password":"321","town":"2332","state":"12321","zipcode":982481,"address":"123212","idimage_path":"http://139.59.3.15:1000/uploads/salesman/1687353825860.svg","image_path":"http://139.59.3.15:1000/uploads/salesman/1687353825821.svg","create_at":"2023-06-21T13:23:45.000Z","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJhaiIsImlhdCI6MTY4NzM1MzgyNX0.C8DCOo7hiik5iStZyRoYXcyDUHEmbrrdXlVB4n2ziDk"},{"id":3,"salesman_id":"SALES3","fullname":"BuskitSelesTest","mobileno":"0000000000","email":"Buskit@google.com","password":"buskit123","town":"Ahd","state":"Guj","zipcode":362222,"address":"TestAAAA","idimage_path":"http://139.59.3.15:1000/uploads/salesman/1688388364357.gif","image_path":"http://139.59.3.15:1000/uploads/salesman/1688388364058.gif","create_at":"2023-07-03T12:46:04.000Z","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IkJ1c2tpdFNlbGVzVGVzdCIsImlhdCI6MTY4ODM4ODM2NH0.7JPSMPXqYtgVuSBGLJ9j7hwP64P2PzkTSHf1ULQ8C-E"}]

StaffResponce staffResponceFromJson(String str) =>
    StaffResponce.fromJson(json.decode(str));
String staffResponceToJson(StaffResponce data) => json.encode(data.toJson());

class StaffResponce {
  StaffResponce({
    this.statusCode,
    this.status,
    this.message,
    this.staffData,
  });

  StaffResponce.fromJson(dynamic json) {
    statusCode = json['status_code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      staffData = [];
      json['data'].forEach((v) {
        staffData?.add(StaffData.fromJson(v));
      });
    }
  }
  int? statusCode;
  bool? status;
  String? message;
  List<StaffData>? staffData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status_code'] = statusCode;
    map['status'] = status;
    map['message'] = message;
    if (staffData != null) {
      map['data'] = staffData?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// salesman_id : "SALES1"
/// fullname : "raj patel"
/// mobileno : "9327622916"
/// email : "rttt@gmail.com"
/// password : "1234"
/// town : "wankaner"
/// state : "Gujarat"
/// zipcode : 123
/// address : "123"
/// idimage_path : "http://139.59.3.15:1000/uploads/salesman/1687352671056.png"
/// image_path : "http://139.59.3.15:1000/uploads/salesman/1687352670695.jpg"
/// create_at : "2023-06-21T13:04:31.000Z"
/// token : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJhaiBwYXRlbCIsImlhdCI6MTY4NzM1MjY3MX0.e9-qOKpCRl7xS8VjTsdsB2MYidEM4RrSqj-1_sav8fA"

StaffData dataFromJson(String str) => StaffData.fromJson(json.decode(str));
String dataToJson(StaffData data) => json.encode(data.toJson());

class StaffData {
  StaffData({
    this.id,
    this.salesmanId,
    this.fullname,
    this.mobileno,
    this.email,
    this.password,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.idimagePath,
    this.imagePath,
    this.createAt,
    this.token,
    this.customer,
    this.orders,
    this.bookings,
    this.timesheet,
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
    this.routes,
    this.totalTarget,
    this.projection,
    this.orderTotal,
  });

  StaffData.fromJson(dynamic json) {
    id = json['id'];
    salesmanId = json['salesman_id'];
    fullname = json['fullname'];
    mobileno = json['mobileno'];
    email = json['email'];
    password = json['password'];
    town = json['town'];
    state = json['state'];
    zipcode = json['zipcode'];
    address = json['address'];
    events = (json['events'] as List?)
        ?.map((dynamic e) => Events.fromJson(e as Map<String, dynamic>))
        .toList();
    idimagePath = json['idimage_path'];
    imagePath = json['image_path'];
    createAt = json['create_at'];
    token = json['token'];
    customer = json['customer'];
    orders = json['orders'];
    bookings = json['bookings'];
    timesheet = json['timesheet'];
    schedule = json['schedule'].toString();
    creditPoint = json['credit_point'].toString();
    cancelEventReason = json['cancel_event_reason'].toString();
    routes = json['routes'];
    totalTarget = json['total_target'];
    projection = json['projection'];
    orderTotal = json['order_total'].toString();
  }
  int? id;
  String? salesmanId;
  String? fullname;
  String? mobileno;
  String? email;
  String? password;
  String? town;
  String? state;
  int? zipcode;
  List<Events>? events;
  String? address;
  String? idimagePath;
  String? imagePath;
  String? createAt;
  String? token;
  int? customer;
  int? orders;
  int? bookings;
  int? timesheet;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;
  int? routes;
  int? totalTarget;
  int? projection;
  String? orderTotal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['salesman_id'] = salesmanId;
    map['fullname'] = fullname;
    map['mobileno'] = mobileno;
    map['email'] = email;
    map['password'] = password;
    map['town'] = town;
    map['state'] = state;
    map['zipcode'] = zipcode;
    map['address'] = address;
    map['idimage_path'] = idimagePath;
    map['image_path'] = imagePath;
    map['create_at'] = createAt;
    map['token'] = token;
    map['customer'] = customer;
    map['orders'] = orders;
    map['events'] = events?.map((e) => e.toJson()).toList();
    map['bookings'] = bookings;
    map['timesheet'] = timesheet;
    map['schedule'] = schedule;
    map['credit_point'] = creditPoint;
    map['cancel_event_reason'] = cancelEventReason;
    map['routes'] = routes;
    map['total_target'] = totalTarget;
    map['projection'] = projection;
    map['order_total'] = orderTotal;
    return map;
  }
}

class Events {
  int? totalEvent;
  String? start;
  String? salesmanId;
  String? customerId;
  String? end;
  List<Salesman>? salesman;

  Events({
    this.totalEvent,
    this.start,
    this.salesmanId,
    this.customerId,
    this.end,
    this.salesman,
  });

  Events.fromJson(Map<String, dynamic> json) {
    totalEvent = json['total_event'] as int?;
    start = json['start'] as String?;
    salesmanId = json['salesman_id'] as String?;
    customerId = json['customer_id'] as String?;
    end = json['end'] as String?;
    salesman = (json['salesman'] as List?)
        ?.map((dynamic e) => Salesman.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['total_event'] = totalEvent;
    json['start'] = start;
    json['salesman_id'] = salesmanId;
    json['customer_id'] = customerId;
    json['end'] = end;
    json['salesman'] = salesman?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Salesman {
  int? id;
  String? customerId;
  dynamic cartId;
  String? fullname;
  String? mobileno;
  String? email;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? businessName;
  String? businessNo;
  String? remark;
  String? imageUrl;
  String? salesmanId;
  int? status;
  String? createAt;
  String? salesmanName;
  String? discount;
  int? eventType;
  dynamic eventDays;

  Salesman({
    this.id,
    this.customerId,
    this.cartId,
    this.fullname,
    this.mobileno,
    this.email,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.businessName,
    this.businessNo,
    this.remark,
    this.imageUrl,
    this.salesmanId,
    this.status,
    this.createAt,
    this.salesmanName,
    this.discount,
    this.eventType,
    this.eventDays,
  });

  Salesman.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    customerId = json['customer_id'] as String?;
    cartId = json['cart_id'];
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    town = json['town'] as String?;
    state = json['state'] as String?;
    zipcode = json['zipcode'] as int?;
    address = json['address'] as String?;
    businessName = json['business_name'] as String?;
    businessNo = json['business_no'] as String?;
    remark = json['remark'] as String?;
    imageUrl = json['image_url'] as String?;
    salesmanId = json['salesman_id'] as String?;
    status = json['status'] as int?;
    createAt = json['create_at'] as String?;
    salesmanName = json['salesman_name'] as String?;
    discount = json['discount'] as String?;
    eventType = json['event_type'] as int?;
    eventDays = json['event_days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['customer_id'] = customerId;
    json['cart_id'] = cartId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['address'] = address;
    json['business_name'] = businessName;
    json['business_no'] = businessNo;
    json['remark'] = remark;
    json['image_url'] = imageUrl;
    json['salesman_id'] = salesmanId;
    json['status'] = status;
    json['create_at'] = createAt;
    json['salesman_name'] = salesmanName;
    json['discount'] = discount;
    json['event_type'] = eventType;
    json['event_days'] = eventDays;
    return json;
  }
}
