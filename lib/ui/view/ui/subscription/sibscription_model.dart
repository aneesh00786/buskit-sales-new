import 'dart:convert';

class SubscribedPlan {
  int statusCode;
  bool status;
  String message;
  List<SubscribedPlanData> data;

  SubscribedPlan({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubscribedPlan.fromJson(Map<String, dynamic> json) => SubscribedPlan(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<SubscribedPlanData>.from(
            json["data"].map((x) => SubscribedPlanData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SubscribedPlanData {
  int id;
  int userId;
  String status;
  DateTime startDate;
  DateTime endDate;
  String planName;
  String price;
  String billingCycle;
  int planIdentifier;
  PlanFeatures planFeatures;

  SubscribedPlanData({
    required this.id,
    required this.userId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.planName,
    required this.price,
    required this.billingCycle,
    required this.planIdentifier,
    required this.planFeatures,
  });

  factory SubscribedPlanData.fromJson(Map<String, dynamic> json) =>
      SubscribedPlanData(
        id: json["id"],
        userId: json["user_id"],
        status: json["status"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        planName: json["plan_name"],
        price: json["price"],
        billingCycle: json["billing_cycle"],
        planIdentifier: json["plan_identifier"],
        planFeatures:
            PlanFeatures.fromJson(jsonDecode(json["plan_features"].toString())),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "status": status,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "plan_name": planName,
        "price": price,
        "billing_cycle": billingCycle,
        "plan_identifier": planIdentifier,
        "plan_features": planFeatures.toJson(),
      };
}

class PlanFeatures {
  String id;
  String name;
  Map<String, Feature> features;

  PlanFeatures({
    required this.id,
    required this.name,
    required this.features,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) => PlanFeatures(
        id: json["id"],
        name: json["name"],
        features: Map.from(json["features"])
            .map((k, v) => MapEntry<String, Feature>(k, Feature.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "features": Map.from(features)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Feature {
  String tagId;
  String status;
  String name;

  Feature({
    required this.tagId,
    required this.status,
    required this.name,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        tagId: json["tag_id"],
        status: json["status"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "tag_id": tagId,
        "status": status,
        "name": name,
      };
}

class SubscribtionPlanDetails {
  int statusCode;
  bool status;
  String message;
  List<SubscribtionPlanDetailsData> data;

  SubscribtionPlanDetails({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubscribtionPlanDetails.fromJson(Map<String, dynamic> json) =>
      SubscribtionPlanDetails(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<SubscribtionPlanDetailsData>.from(
            json["data"].map((x) => SubscribtionPlanDetailsData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SubscribtionPlanDetailsData {
  int id;
  String planName;
  String price;
  String billingCycle;
  int planIdentifier;
  PlanFeatures planFeatures;

  SubscribtionPlanDetailsData({
    required this.id,
    required this.planName,
    required this.price,
    required this.billingCycle,
    required this.planIdentifier,
    required this.planFeatures,
  });

  factory SubscribtionPlanDetailsData.fromJson(Map<String, dynamic> json) =>
      SubscribtionPlanDetailsData(
        id: json["id"],
        planName: json["plan_name"],
        price: json["price"],
        billingCycle: json["billing_cycle"],
        planIdentifier: json["plan_identifier"],
        planFeatures: PlanFeatures.fromJson(jsonDecode(json["plan_features"])),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "plan_name": planName,
        "price": price,
        "billing_cycle": billingCycle,
        "plan_identifier": planIdentifier,
        "plan_features": jsonEncode(planFeatures.toJson()),
      };
}

class PlanDetailsPlanFeatures {
  String id;
  String name;
  Map<String, FeatureItem> features;

  PlanDetailsPlanFeatures({
    required this.id,
    required this.name,
    required this.features,
  });

  factory PlanDetailsPlanFeatures.fromJson(Map<String, dynamic> json) =>
      PlanDetailsPlanFeatures(
        id: json["id"],
        name: json["name"],
        features: Map.from(json["features"])
            .map((k, v) => MapEntry(k, FeatureItem.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "features": Map.from(features).map((k, v) => MapEntry(k, v.toJson())),
      };
}

class FeatureItem {
  String tagId;
  String status;
  String name;

  FeatureItem({
    required this.tagId,
    required this.status,
    required this.name,
  });

  factory FeatureItem.fromJson(Map<String, dynamic> json) => FeatureItem(
        tagId: json["tag_id"],
        status: json["status"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "tag_id": tagId,
        "status": status,
        "name": name,
      };
}
