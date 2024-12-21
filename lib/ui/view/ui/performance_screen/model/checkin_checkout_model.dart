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
        statusCode: json["status_code"] ?? 0, // Provide a default value
        status: json["status"] ?? false, // Default to `false`
        message: json["message"] ?? '', // Default to an empty string
        data: json["data"] != null
            ? List<CheckInCheckoutData>.from(
                json["data"].map((x) => CheckInCheckoutData.fromJson(x)),
              )
            : [], // Ensure `data` is never null
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
        customerId: json["customer_id"] ?? '', // Default to an empty string
        id: json["id"] ?? 0, // Default to 0
        fullname: json["fullname"] ?? '', // Default to an empty string
        email: json["email"] ?? '', // Default to an empty string
        mobileno: json["mobileno"] ?? '', // Default to an empty string
        imageUrl: json["image_url"] ?? '', // Default to an empty string
        salesmanId: json["salesman_id"] ?? '', // Default to an empty string
        eventId: json["event_id"] ?? '', // Default to an empty string
        individualVisit: json["individual_visit"] ?? 0, // Default to 0
        totalVisits: json["total_visits"] ?? '0', // Default to '0'
        checkIn: json["check_in"] != null
            ? DateTime.tryParse(json["check_in"]) // Safely parse DateTime
            : null,
        checkOut: json["check_out"] != null
            ? DateTime.tryParse(json["check_out"]) // Safely parse DateTime
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
