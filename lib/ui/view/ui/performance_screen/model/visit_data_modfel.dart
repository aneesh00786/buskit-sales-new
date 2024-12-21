class VisitData {
  int? statusCode;
  bool? status;
  String? message;
  List<VisitDataItem>? data;

  VisitData({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory VisitData.fromJson(Map<String, dynamic> json) => VisitData(
        statusCode: json["status_code"] ?? 0,
        status: json["status"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? List<VisitDataItem>.from(
                json["data"].map((x) => VisitDataItem.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };
}

class VisitDataItem {
  int? id;
  int? companyId;
  String? eventId;
  String? customerId;
  SalesmanId? salesmanId;
  String? title;
  DateTime? start;
  DateTime? end;
  int? type;
  DateTime? checkIn;
  String? checkInLongitude;
  String? checkInLatitude;
  dynamic checkOut;
  String? checkOutLatitude;
  int? checkOutLongitude;
  dynamic eventCancel;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  VisitDataItem({
    this.id,
    this.companyId,
    this.eventId,
    this.customerId,
    this.salesmanId,
    this.title,
    this.start,
    this.end,
    this.type,
    this.checkIn,
    this.checkInLongitude,
    this.checkInLatitude,
    this.checkOut,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.eventCancel,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory VisitDataItem.fromJson(Map<String, dynamic> json) => VisitDataItem(
        id: json["id"] ?? 0,
        companyId: json["company_id"] ?? 0,
        eventId: json["event_id"] ?? '',
        customerId: json["customer_id"] ?? '',
        salesmanId: json["salesman_id"] != null
            ? salesmanIdValues.map[json["salesman_id"]]
            : null,
        title: json["title"] ?? '',
        start: json["start"] != null ? DateTime.tryParse(json["start"]) : null,
        end: json["end"] != null ? DateTime.tryParse(json["end"]) : null,
        type: json["type"] ?? 0,
        checkIn: json["check_in"] != null
            ? DateTime.tryParse(json["check_in"])
            : null,
        checkInLongitude: json["check_in_longitude"] ?? '',
        checkInLatitude: json["check_in_latitude"] ?? '',
        checkOut: json["check_out"],
        checkOutLatitude: json["check_out_latitude"] ?? '',
        checkOutLongitude: json["check_out_longitude"] ?? 0,
        eventCancel: json["event_cancel"],
        status: json["status"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "event_id": eventId,
        "customer_id": customerId,
        "salesman_id": salesmanId != null
            ? salesmanIdValues.reverse[salesmanId]
            : null,
        "title": title,
        "start": start?.toIso8601String(),
        "end": end?.toIso8601String(),
        "type": type,
        "check_in": checkIn?.toIso8601String(),
        "check_in_longitude": checkInLongitude,
        "check_in_latitude": checkInLatitude,
        "check_out": checkOut,
        "check_out_latitude": checkOutLatitude,
        "check_out_longitude": checkOutLongitude,
        "event_cancel": eventCancel,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

enum SalesmanId { SALES1 }

final salesmanIdValues = EnumValues({
  "SALES1": SalesmanId.SALES1,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
