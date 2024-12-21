// To parse this JSON data, do
//
//     final visitData = visitDataFromJson(jsonString);

import 'dart:convert';

VisitData visitDataFromJson(String str) => VisitData.fromJson(json.decode(str));

String visitDataToJson(VisitData data) => json.encode(data.toJson());

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
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<VisitDataItem>.from(json["data"].map((x) => VisitDataItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
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
        id: json["id"],
        companyId: json["company_id"],
        eventId: json["event_id"],
        customerId: json["customer_id"],
        salesmanId: salesmanIdValues.map[json["salesman_id"]],
        title: json["title"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        type: json["type"],
        checkIn: DateTime.parse(json["check_in"]),
        checkInLongitude: json["check_in_longitude"],
        checkInLatitude: json["check_in_latitude"],
        checkOut: json["check_out"],
        checkOutLatitude: json["check_out_latitude"],
        checkOutLongitude: json["check_out_longitude"],
        eventCancel: json["event_cancel"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "event_id": eventId,
        "customer_id": customerId,
        "salesman_id": salesmanIdValues.reverse[salesmanId],
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

enum SalesmanId {
    SALES1
}

final salesmanIdValues = EnumValues({
    "SALES1": SalesmanId.SALES1
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
