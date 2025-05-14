
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
class CalendarEventResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<CalendarResEventData>? data;

  CalendarEventResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  CalendarEventResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) =>
            CalendarResEventData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.map((e) => e.toJson()).toList();
    return json;
  }
}

class CalendarResEventData {
  String? fullname;
  String? mobileno;
  String? email;
  String? imagePath;
  String? salesmanId;
  List<CalEvents>? events;

  CalendarResEventData({
    this.fullname,
    this.mobileno,
    this.email,
    this.imagePath,
    this.salesmanId,
    this.events,
  });

  CalendarResEventData.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    imagePath = json['image_path'] as String?;
    salesmanId = json['salesman_id'] as String?;
    events = json['events'] != 0
        ? (json['events'] as List?)
            ?.map((dynamic e) => CalEvents.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['image_path'] = imagePath;
    json['salesman_id'] = salesmanId;
    json['events'] = events?.map((e) => e.toJson()).toList();
    return json;
  }
}

class CalEvents {
  String? end;
  String? start;
  String? title;
  List<CustomerAndOrderData>? customer;
  String? eventType;

  CalEvents({
    this.end,
    this.start,
    this.title,
    this.customer,
    this.eventType,
  });

  CalEvents.fromJson(Map<String, dynamic> json) {
    end = json['end'] as String?;
    start = json['start'] as String?;
    title = json['title'] as String?;
    customer = json['customer'] != 0
        ? (json['customer'] as List?)
            ?.map((dynamic e) =>
                CustomerAndOrderData.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
    eventType = json['eventType'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['end'] = end;
    json['start'] = start;
    json['title'] = title;
    json['customer'] = customer?.map((e) => e.toJson()).toList();
    json['eventType'] = eventType;
    return json;
  }
}




class SalesmanResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<SalesmanData>? data;

  SalesmanResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  SalesmanResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => SalesmanData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.map((e) => e.toJson()).toList();
    return json;
  }
}

class SalesmanData {
  int? id;
  String? salesmanId;
  String? fullname;
  String? mobileno;
  String? email;
  String? password;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? idimagePath;
  String? imagePath;
  String? createAt;
  String? token;
  List<SalesManVisitEvents>? events;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;

  SalesmanData({
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
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
  });

  SalesmanData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    salesmanId = json['salesman_id'] as String?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    password = json['password'] as String?;
    town = json['town'] as String?;
    state = json['state'] as String?;
    zipcode = json['zipcode'] as int?;
    address = json['address'] as String?;
    idimagePath = json['idimage_path'] as String?;
    imagePath = json['image_path'] as String?;
    createAt = json['create_at'] as String?;
    token = json['token'] as String?;
    events = (json['events'] as List?)
        ?.map((dynamic e) =>
            SalesManVisitEvents.fromJson(e as Map<String, dynamic>))
        .toList();
    schedule = json['schedule'];
    creditPoint = json['credit_point'];
    cancelEventReason = json['cancel_event_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['salesman_id'] = salesmanId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['password'] = password;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['address'] = address;
    json['idimage_path'] = idimagePath;
    json['image_path'] = imagePath;
    json['create_at'] = createAt;
    json['token'] = token;
    json['events'] = events?.map((e) => e.toJson()).toList();
    json['schedule'] = schedule;
    json['credit_point'] = creditPoint;
    json['cancel_event_reason'] = cancelEventReason;
    return json;
  }
}

class SalesManVisitEvents {
  int? id;
  String? eventId;
  String? customerId;
  String? salesmanId;
  String? title;
  String? start;
  String? end;
  int? type;
  dynamic eventCancel;
  int? status;
  String? createdAt;
  String? updatedAt;
  CustomerDetails? customer;

  SalesManVisitEvents({
    this.id,
    this.eventId,
    this.customerId,
    this.salesmanId,
    this.title,
    this.start,
    this.end,
    this.type,
    this.eventCancel,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.customer,
  });

  SalesManVisitEvents.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    eventId = json['event_id'] as String?;
    customerId = json['customer_id'] as String?;
    salesmanId = json['salesman_id'] as String?;
    title = json['title'] as String?;
    start = json['start'] as String?;
    end = json['end'] as String?;
    type = json['type'] as int?;
    eventCancel = json['event_cancel'];
    status = json['status'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    customer = (json['customer'] is List)
        ? CustomerDetails.fromJson(
            (json['customer'] as List).first as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['event_id'] = eventId;
    json['customer_id'] = customerId;
    json['salesman_id'] = salesmanId;
    json['title'] = title;
    json['start'] = start;
    json['end'] = end;
    json['type'] = type;
    json['event_cancel'] = eventCancel;
    json['status'] = status;
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    return json;
  }
}


class RouteCreditResponse {
    int statusCode;
    bool status;
    int companyId;
    String credit;

    RouteCreditResponse({
        required this.statusCode,
        required this.status,
        required this.companyId,
        required this.credit,
    });

    factory RouteCreditResponse.fromJson(Map<String, dynamic> json) => RouteCreditResponse(
        statusCode: json["status_code"],
        status: json["status"],
        companyId: json["companyId"],
        credit: json["credit"],
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "companyId": companyId,
        "credit": credit,
    };
}

