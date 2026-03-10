

class CalendarSalesmanResponse {
  int? statusCode;
  bool? status;
  String? message;
  List<CalendarSalesmanData>? data;

  CalendarSalesmanResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory CalendarSalesmanResponse.fromJson(Map<String, dynamic> json) =>
      CalendarSalesmanResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<CalendarSalesmanData>.from(
            json["data"].map((x) => CalendarSalesmanData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CalendarSalesmanData {
  int? id;
  int? companyId;
  String? salesmanId;
  String? fullname;
  String? lastname;
  String? department;
  String? portfolio;
  String? mobileno;
  String? email;
  String? password;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? idimagePath;
  String? imagePath;
  DateTime? createAt;
  String? token;
  dynamic events;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;
  int? projectionPrice;
  int? projectionTarget;
  DateTime? lastOnline;
  int? status;
  List<SalesmanCustomer>? customer;

  CalendarSalesmanData({
    this.id,
    this.companyId,
    this.salesmanId,
    this.fullname,
    this.lastname,
    this.department,
    this.portfolio,
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
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
    this.projectionPrice,
    this.projectionTarget,
    this.lastOnline,
    this.status,
    this.customer,
  });

  factory CalendarSalesmanData.fromJson(Map<String, dynamic> json) {
    return CalendarSalesmanData(
      id: json["id"] as int?,
      companyId: json["company_id"] as int?,
      salesmanId: json["salesman_id"] as String?,
      fullname: json["fullname"] as String?,
      lastname: json["lastname"] as String?,
      department: json["department"] as String?,
      portfolio: json["portfolio"] as String?,
      mobileno: json["mobileno"] as String?,
      email: json["email"] as String?,
      password: json["password"] as String?,
      town: json["town"] as String?,
      state: json["state"] as String?,
      zipcode: json["zipcode"] as int?,
      address: json["address"] as String?,
      idimagePath: json["idimage_path"] as String?,
      imagePath: json["image_path"] as String?,
      createAt: json["create_at"] != null
          ? DateTime.parse(json["create_at"] as String)
          : null,
      token: json["token"] as String?,
      events: json["events"],
      schedule: json["schedule"],
      creditPoint: json["credit_point"],
      cancelEventReason: json["cancel_event_reason"],
      projectionPrice: json["projection_price"] as int?,
      projectionTarget: json["projection_target"] as int?,
      lastOnline: json["last_online"] != null
          ? DateTime.parse(json["last_online"] as String)
          : null,
      status: json["status"] as int?,
      customer: json["customer"] != null
          ? List<SalesmanCustomer>.from(
              json["customer"].map((x) => SalesmanCustomer.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "company_id": companyId,
      "salesman_id": salesmanId,
      "fullname": fullname,
      "lastname": lastname,
      "department": department,
      "portfolio": portfolio,
      "mobileno": mobileno,
      "email": email,
      "password": password,
      "town": town,
      "state": state,
      "zipcode": zipcode,
      "address": address,
      "idimage_path": idimagePath,
      "image_path": imagePath,
      "create_at": createAt?.toIso8601String(),
      "token": token,
      "events": events,
      "schedule": schedule,
      "credit_point": creditPoint,
      "cancel_event_reason": cancelEventReason,
      "projection_price": projectionPrice,
      "projection_target": projectionTarget,
      "last_online": lastOnline?.toIso8601String(),
      "status": status,
      "customer": customer != null
          ? List<dynamic>.from(customer!.map((x) => x.toJson()))
          : null,
    };
  }
}

class SalesmanCustomer {
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
  String? latitude;
  String? longitude;
  String? businessName;
  String? businessNo;
  String? tfn;
  String? addressCheckbox;
  String? deliveryAddress;
  String? deliveryTown;
  String? deliveryState;
  int? deliveryZipcode;
  String? remark;
  String? imageUrl;
  String? salesmanId;
  int? status;
  DateTime? createAt;
  String? createdBy;
  String? salesmanName;
  String? discount;
  int? eventType;
  String? eventDays;
  int? creditPeriod;
  int? companyId;

  SalesmanCustomer({
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
    this.latitude,
    this.longitude,
    this.businessName,
    this.businessNo,
    this.tfn,
    this.addressCheckbox,
    this.deliveryAddress,
    this.deliveryTown,
    this.deliveryState,
    this.deliveryZipcode,
    this.remark,
    this.imageUrl,
    this.salesmanId,
    this.status,
    this.createAt,
    this.createdBy,
    this.salesmanName,
    this.discount,
    this.eventType,
    this.eventDays,
    this.creditPeriod,
    this.companyId,
  });

  factory SalesmanCustomer.fromJson(Map<String, dynamic> json) {
    return SalesmanCustomer(
      id: json["id"] as int?,
      customerId: json["customer_id"] as String?,
      cartId: json["cart_id"],
      fullname: json["fullname"] as String?,
      mobileno: json["mobileno"] as String?,
      email: json["email"] as String?,
      town: json["town"] as String?,
      state: json["state"] as String?,
      zipcode: json["zipcode"] as int?,
      address: json["address"] as String?,
      latitude: json["latitude"] as String?,
      longitude: json["longitude"] as String?,
      businessName: json["business_name"] as String?,
      businessNo: json["business_no"] as String?,
      tfn: json["tfn"] as String?,
      addressCheckbox: json["addressCheckbox"] as String?,
      deliveryAddress: json["delivery_address"] as String?,
      deliveryTown: json["delivery_town"] as String?,
      deliveryState: json["delivery_state"] as String?,
      deliveryZipcode: json["delivery_zipcode"] as int?,
      remark: json["remark"] as String?,
      imageUrl: json["image_url"] as String?,
      salesmanId: json["salesman_id"] as String?,
      status: json["status"] as int?,
      createAt: json["create_at"] != null
          ? DateTime.parse(json["create_at"] as String)
          : null,
      createdBy: json["created_by"] as String?,
      salesmanName: json["salesman_name"] as String?,
      discount: json["discount"] as String?,
      eventType: json["event_type"] as int?,
      eventDays: json["event_days"] as String?,
      creditPeriod: json["credit_period"] as int?,
      companyId: json["company_id"] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "customer_id": customerId,
      "cart_id": cartId,
      "fullname": fullname,
      "mobileno": mobileno,
      "email": email,
      "town": town,
      "state": state,
      "zipcode": zipcode,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "business_name": businessName,
      "business_no": businessNo,
      "tfn": tfn,
      "addressCheckbox": addressCheckbox,
      "delivery_address": deliveryAddress,
      "delivery_town": deliveryTown,
      "delivery_state": deliveryState,
      "delivery_zipcode": deliveryZipcode,
      "remark": remark,
      "image_url": imageUrl,
      "salesman_id": salesmanId,
      "status": status,
      "create_at": createAt?.toIso8601String(),
      "created_by": createdBy,
      "salesman_name": salesmanName,
      "discount": discount,
      "event_type": eventType,
      "event_days": eventDays,
      "credit_period": creditPeriod,
      "company_id": companyId,
    };
  }
}
