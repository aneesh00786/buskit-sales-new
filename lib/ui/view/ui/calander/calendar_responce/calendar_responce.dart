import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';

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

class FetchOnlyCustomer {
  int statusCode;
  bool status;
  String message;
  List<FetchOnlyCustomerData> data;

  FetchOnlyCustomer({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchOnlyCustomer.fromJson(Map<String, dynamic> json) =>
      FetchOnlyCustomer(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<FetchOnlyCustomerData>.from(
            json["data"].map((x) => FetchOnlyCustomerData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class FetchOnlyCustomerData {
  String eventId;
  String? scheduleTime;
  DateTime? checkIn;
  DateTime start;
  String customerId;
  String fullname;
  String mobileno;
  String email;
  String businessName;
  String imageUrl;

  FetchOnlyCustomerData({
    required this.eventId,
    required this.scheduleTime,
    required this.checkIn,
    required this.start,
    required this.customerId,
    required this.fullname,
    required this.mobileno,
    required this.email,
    required this.businessName,
    required this.imageUrl,
  });

  factory FetchOnlyCustomerData.fromJson(Map<String, dynamic> json) =>
      FetchOnlyCustomerData(
        eventId: json["event_id"],
        scheduleTime: json["schedule_time"],
        checkIn:
            json["check_in"] == null ? null : DateTime.parse(json["check_in"]),
        start: DateTime.parse(json["start"]),
        customerId: json["customer_id"],
        fullname: json["fullname"],
        mobileno: json["mobileno"],
        email: json["email"],
        businessName: json["business_name"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "schedule_time": scheduleTime,
        "check_in": checkIn?.toIso8601String(),
        "start": start.toIso8601String(),
        "customer_id": customerId,
        "fullname": fullname,
        "mobileno": mobileno,
        "email": email,
        "business_name": businessName,
        "image_url": imageUrl,
      };
}

class DebitCreditResponse {
    int statusCode;
    bool status;
    int credit;
    String message;

    DebitCreditResponse({
        required this.statusCode,
        required this.status,
        required this.credit,
        required this.message,
    });

    factory DebitCreditResponse.fromJson(Map<String, dynamic> json) => DebitCreditResponse(
        statusCode: json["status_code"],
        status: json["status"],
        credit: json["credit"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "credit": credit,
        "message": message,
    };
}

class ShowRouteResponse {
  List<Result> results;

  ShowRouteResponse({
    required this.results,
  });

  factory ShowRouteResponse.fromJson(Map<String, dynamic> json) =>
      ShowRouteResponse(
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  String businessName;
  String email;
  String mobileno;
  String customerId;
  String address;
  String town;
  String state;
  int zipcode;
  String imageUrl;
  String scheduleTime;
  double latitude;
  double longitude;
  String formattedAddress;

  Result({
    required this.businessName,
    required this.email,
    required this.mobileno,
    required this.customerId,
    required this.address,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.imageUrl,
    required this.scheduleTime,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        businessName: json["business_name"],
        email: json["email"],
        mobileno: json["mobileno"],
        customerId: json["customer_id"],
        address: json["address"],
        town: json["town"],
        state: json["state"],
        zipcode: json["zipcode"],
        imageUrl: json["image_url"],
        scheduleTime: json["schedule_time"],
        latitude: json["latitude"] != "error"
            ? json["latitude"]?.toDouble()
            : "error",
        longitude: json["longitude"] != "error"
            ? json["longitude"]?.toDouble()
            : "error",
        formattedAddress: json["formatted_address"],
      );

  Map<String, dynamic> toJson() => {
        "business_name": businessName,
        "email": email,
        "mobileno": mobileno,
        "customer_id": customerId,
        "address": address,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "image_url": imageUrl,
        "schedule_time": scheduleTime,
        "latitude": latitude,
        "longitude": longitude,
        "formatted_address": formattedAddress,
      };
}
