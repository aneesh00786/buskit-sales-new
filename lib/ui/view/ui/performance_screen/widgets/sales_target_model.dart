class SalesmanTargetResponse {
  int? statusCode;
  bool? status;
  String? message;
  List<SalesmanTargetData>? data;

  SalesmanTargetResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory SalesmanTargetResponse.fromJson(Map<String, dynamic> json) =>
      SalesmanTargetResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<SalesmanTargetData>.from(
            json["data"].map((x) => SalesmanTargetData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SalesmanTargetData {
  String? categoryName;
  int? id;
  int? target;
  WeeklyTargetClass? weeklyTarget;

  SalesmanTargetData({
    this.categoryName,
    this.id,
    this.target,
    this.weeklyTarget,
  });

  factory SalesmanTargetData.fromJson(Map<String, dynamic> json) =>
      SalesmanTargetData(
        categoryName: json["categoryName"],
        id: json["id"],
        target: json["target"],
        weeklyTarget: json["weekly_target"] is Map
            ? WeeklyTargetClass.fromJson(json["weekly_target"])
            : WeeklyTargetClass(),
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "id": id,
        "target": target,
        "weekly_target": weeklyTarget?.toJson(),
      };
}
class WeeklyTargetClass {
  Map<String, int?>? targets;

  WeeklyTargetClass({this.targets});

  factory WeeklyTargetClass.fromJson(Map<String, dynamic> json) {
    return WeeklyTargetClass(
      targets: json.map((key, value) {
        if (key.startsWith('week')) {
          return MapEntry(key, value as int?);
        }
        return MapEntry(key, null);
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return Map.fromEntries(
      (targets ?? {}).entries.where((entry) => entry.key.startsWith('week')),
    );
  }

  WeeklyTargetClass copyWith({Map<String, int?>? targets}) {
    return WeeklyTargetClass(
      targets: targets ?? this.targets,
    );
  }
}