import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/database/session/null_check_oprations.dart';

class LeadResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<LeadCustomerData>? leadCustomerData;
  LeadsPagination? pagination;

  LeadResponce({
    this.statusCode,
    this.status,
    this.message,
    this.leadCustomerData,
    this.pagination,
  });

  LeadResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    leadCustomerData = (json['data'] as List?)
        ?.map(
            (dynamic e) => LeadCustomerData.fromJson(e as Map<String, dynamic>))
        .toList();
    pagination = LeadsPagination.fromJson(json["pagination"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = leadCustomerData?.map((e) => e.toJson()).toList();
    return json;
  }
}

class LeadCustomerData {
  int? id;
  String? customerId;
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
  String? oldImageUrl;

  String? salesmanId;
  int? status;
  String? createAt;
  String? salesmanName;

  LeadCustomerData({
    this.id,
    this.customerId,
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
    this.oldImageUrl,
    this.status,
    this.createAt,
    this.salesmanName,
  });

  LeadCustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    customerId = json['customer_id'] as String?;
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
    oldImageUrl = json['image_url'] as String?;
    salesmanId = json['salesman_id'] as String?;
    status = json['status'] as int?;
    createAt = json['create_at'] as String?;
    salesmanName = json['salesman_name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['customer_id'] = customerId;
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
    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['address'] = address;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['businessname'] = businessName;
    json['businesscontact'] = businessNo;
    json['remark'] = remark;
    json['oldimage_url'] = oldImageUrl;
    json['cutomerpicture'] =
        !CheckNullData.checkLocalOrServerImage(imageUrl ?? '')
            ? NkCommonFunction.getFormData(imageUrl ?? '', mapKeyName: "")
            : null;
    json['customer_id'] = customerId;
    return json;
  }
}

class LeadsPagination {
  int totalRecord;
  int totalPages;
  int perPage;

  LeadsPagination({
    required this.totalRecord,
    required this.totalPages,
    required this.perPage,
  });

  factory LeadsPagination.fromJson(Map<String, dynamic> json) =>
      LeadsPagination(
        totalRecord: int.tryParse(json["total_record"].toString()) ?? 0,
        totalPages: int.tryParse(json["total_pages"].toString()) ?? 0,
        perPage: int.tryParse(json["per_page"].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "total_record": totalRecord,
        "total_pages": totalPages,
        "per_page": perPage,
      };
}

class LeadsForUpdating {
  int statusCode;
  bool status;
  List<LeadsForUpdatingData> data;
  String message;

  LeadsForUpdating({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.message,
  });

  factory LeadsForUpdating.fromJson(Map<String, dynamic> json) =>
      LeadsForUpdating(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<LeadsForUpdatingData>.from(
            json["data"].map((x) => LeadsForUpdatingData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class LeadsForUpdatingData {
  int? id;
  String? customerId;
  String? cartId;
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
  dynamic eventDays;
  int? creditPeriod;
  int? companyId;
  dynamic deliveryContact;

  LeadsForUpdatingData({
    required this.id,
    required this.customerId,
    required this.cartId,
    required this.fullname,
    required this.mobileno,
    required this.email,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.businessName,
    required this.businessNo,
    required this.tfn,
    required this.addressCheckbox,
    required this.deliveryAddress,
    required this.deliveryTown,
    required this.deliveryState,
    required this.deliveryZipcode,
    required this.remark,
    required this.imageUrl,
    required this.salesmanId,
    required this.status,
    required this.createAt,
    required this.createdBy,
    required this.salesmanName,
    required this.discount,
    required this.eventType,
    required this.eventDays,
    required this.creditPeriod,
    required this.companyId,
    this.deliveryContact,
  });

  factory LeadsForUpdatingData.fromJson(Map<String, dynamic> json) =>
      LeadsForUpdatingData(
        id: json["id"] ?? 0,
        customerId: json["customer_id"] ?? '',
        cartId: json["cart_id"] ?? '',
        fullname: json["fullname"] ?? '',
        mobileno: json["mobileno"] ?? '',
        email: json["email"] ?? '',
        town: json["town"] ?? '',
        state: json["state"] ?? '',
        zipcode: json["zipcode"] ?? 0,
        address: json["address"] ?? '',
        latitude: json["latitude"] ?? '',
        longitude: json["longitude"] ?? '',
        businessName: json["business_name"] ?? '',
        businessNo: json["business_no"] ?? '',
        tfn: json["tfn"] ?? '',
        addressCheckbox: json["addressCheckbox"] ?? '',
        deliveryAddress: json["delivery_address"] ?? '',
        deliveryTown: json["delivery_town"] ?? '',
        deliveryState: json["delivery_state"] ?? '',
        deliveryZipcode: json["delivery_zipcode"] ?? 0,
        remark: json["remark"] ?? '',
        imageUrl: json["image_url"] ?? '',
        salesmanId: json["salesman_id"] ?? '',
        status: json["status"] ?? 0,
        createAt: json["create_at"] != null
            ? DateTime.parse(json["create_at"])
            : DateTime.now(),
        createdBy: json["created_by"] ?? '',
        salesmanName: json["salesman_name"] ?? '',
        discount: json["discount"] ?? '',
        eventType: json["event_type"] ?? 0,
        eventDays: json["event_days"],
        creditPeriod: json["credit_period"] ?? 0,
        companyId: json["company_id"] ?? 0,
        deliveryContact: json["delivery_contact"],
      );

  Map<String, dynamic> toJson() => {
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
        "create_at": createAt!.toIso8601String(),
        "created_by": createdBy,
        "salesman_name": salesmanName,
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDays,
        "credit_period": creditPeriod,
        "company_id": companyId,
        "delivery_contact": deliveryContact,
      };
}
