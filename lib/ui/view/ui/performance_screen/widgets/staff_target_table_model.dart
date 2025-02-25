class SalesmanTargetTableResponse {
  int? statusCode;
  bool? status;
  String? message;
  List<SalesmanTargetTableData>? data;

  SalesmanTargetTableResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory SalesmanTargetTableResponse.fromJson(Map<String, dynamic> json) =>
      SalesmanTargetTableResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<SalesmanTargetTableData>.from(
            json["data"].map((x) => SalesmanTargetTableData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SalesmanTargetTableData {
  String? categoryName;
  int? id;
  int? target;
  int? projection;
  WeeklyTargetTableClass? weeklyTarget;
  WeeklyProjectionTableClass? weeklyProjection;

  SalesmanTargetTableData({
    this.categoryName,
    this.id,
    this.target,
    this.projection,
    this.weeklyTarget,
    this.weeklyProjection,
  });

  factory SalesmanTargetTableData.fromJson(Map<String, dynamic> json) =>
      SalesmanTargetTableData(
        categoryName: json["categoryName"],
        id: json["id"],
        target: json["target"],
        projection: json["projection"],
        weeklyTarget: json["weekly_target"] is Map
            ? WeeklyTargetTableClass.fromJson(json["weekly_target"])
            : WeeklyTargetTableClass(),
        weeklyProjection: json["weekly_projection"] is Map
            ? WeeklyProjectionTableClass.fromJson(json["weekly_projection"])
            : WeeklyProjectionTableClass(),
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "id": id,
        "target": target,
        "projection": projection,
        "weekly_target": weeklyTarget?.toJson(),
        "weekly_projection": weeklyProjection?.toJson(),
      };
}

class WeeklyTargetTableClass {
  Map<String, int?>? targets;

  WeeklyTargetTableClass({this.targets});

  factory WeeklyTargetTableClass.fromJson(Map<String, dynamic> json) {
    return WeeklyTargetTableClass(
      targets: json.map((key, value) {
        if (key.startsWith('week')) {
          return MapEntry(key, value as int?);
        }
        return MapEntry(key, null); // Ignore keys that don't match "weekX"
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return Map.fromEntries(
      (targets ?? {}).entries.where((entry) => entry.key.startsWith('week')),
    );
  }

  WeeklyTargetTableClass copyWith({Map<String, int?>? targets}) {
    return WeeklyTargetTableClass(
      targets: targets ?? this.targets,
    );
  }
}

class WeeklyProjectionTableClass {
  Map<String, int?>? targets;

  WeeklyProjectionTableClass({this.targets});

  factory WeeklyProjectionTableClass.fromJson(Map<String, dynamic> json) {
    return WeeklyProjectionTableClass(
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

  WeeklyProjectionTableClass copyWith({Map<String, int?>? targets}) {
    return WeeklyProjectionTableClass(
      targets: targets ?? this.targets,
    );
  }
}