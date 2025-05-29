import 'dart:convert';

CheckInOut checkInOutFromJson(String str) => CheckInOut.fromJson(json.decode(str));

String checkInOutToJson(CheckInOut data) => json.encode(data.toJson());

class CheckInOut {
  int? statusCode;
  bool? status;
  String? message;
  List<CheckInCheckoutData>? data;

  CheckInOut({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory CheckInOut.fromJson(Map<String, dynamic> json) => CheckInOut(
        statusCode: json["status_code"] ?? 0,
        status: json["status"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? List<CheckInCheckoutData>.from(
                json["data"].map((x) => CheckInCheckoutData.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode ?? 0,
        "status": status ?? false,
        "message": message ?? '',
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };
}

class CheckInCheckoutData {
  String? customerId;
  int? id;
  String? fullname;
  String? email;
  String? mobileno;
  String? imageUrl;
  String? salesmanId;
  String? eventId;
  int? individualVisit;
  String? totalVisits;
  DateTime? checkIn;
  DateTime? checkOut;

  CheckInCheckoutData({
    this.customerId,
    this.id,
    this.fullname,
    this.email,
    this.mobileno,
    this.imageUrl,
    this.salesmanId,
    this.eventId,
    this.individualVisit,
    this.totalVisits,
    this.checkIn,
    this.checkOut,
  });

  factory CheckInCheckoutData.fromJson(Map<String, dynamic> json) => CheckInCheckoutData(
        customerId: json["customer_id"] ?? '',
        id: json["id"] ?? 0,
        fullname: json["fullname"] ?? '', 
        email: json["email"] ?? '', 
        mobileno: json["mobileno"] ?? '', 
        imageUrl: json["image_url"] ?? '', 
        salesmanId: json["salesman_id"] ?? '', 
        eventId: json["event_id"] ?? '', 
        individualVisit: json["individual_visit"] ?? 0, 
        totalVisits: json["total_visits"] ?? '0', 
        checkIn: json["check_in"] != null
            ? DateTime.tryParse(json["check_in"])
            : null,
        checkOut: json["check_out"] != null
            ? DateTime.tryParse(json["check_out"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId ?? '',
        "id": id ?? 0,
        "fullname": fullname ?? '',
        "email": email ?? '',
        "mobileno": mobileno ?? '',
        "image_url": imageUrl ?? '',
        "salesman_id": salesmanId ?? '',
        "event_id": eventId ?? '',
        "individual_visit": individualVisit ?? 0,
        "total_visits": totalVisits ?? '0',
        "check_in": checkIn?.toIso8601String(),
        "check_out": checkOut?.toIso8601String(),
      };
}
