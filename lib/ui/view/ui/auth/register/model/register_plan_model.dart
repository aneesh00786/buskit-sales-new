import 'dart:convert';

class Plan {
  int? id;
  String? planName;
  String? price;
  String? billingCycle;
  int? planIdentifier;
  String? productAvailabilityStatus;
  PlanFeatures? planFeatures;

  Plan({
    this.id,
    this.planName,
    this.price,
    this.billingCycle,
    this.planIdentifier,
    this.productAvailabilityStatus,
    this.planFeatures,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? planFeaturesMap = json['plan_features'] != null
        ? jsonDecode(json['plan_features'])
        : null;

    return Plan(
      id: json['id'],
      planName: json['plan_name'],
      price: json['price'],
      billingCycle: json['billing_cycle'],
      planIdentifier: json['plan_identifier'],
      productAvailabilityStatus:
          planFeaturesMap?['product_availability_status'],
      planFeatures: planFeaturesMap != null
          ? PlanFeatures.fromJson(planFeaturesMap)
          : null,
    );
  }
}

class PlanFeatures {
  String? id;
  String? name;
  Map<String, Feature>? features;

  PlanFeatures({this.id, this.name, this.features});

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    Map<String, Feature>? featuresMap =
        (json['features'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, Feature.fromJson(value)),
    );

    return PlanFeatures(
      id: json['id'],
      name: json['name'],
      features: featuresMap,
    );
  }
}

class Feature {
  String? tagId;
  String? status;
  String? name;

  Feature({this.tagId, this.status, this.name});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      tagId: json['tag_id'],
      status: json['status'],
      name: json['name'],
    );
  }
}
