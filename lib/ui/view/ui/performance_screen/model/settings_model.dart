import 'dart:convert';

AllCompanySettings allCompanySettingsFromJson(String str) =>
    AllCompanySettings.fromJson(json.decode(str));

String allCompanySettingsToJson(AllCompanySettings data) =>
    json.encode(data.toJson());

class AllCompanySettings {
  int statusCode;
  bool status;
  List<AllCompanySettingsData> data;
  String message;

  AllCompanySettings({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.message,
  });

  factory AllCompanySettings.fromJson(Map<String, dynamic> json) =>
      AllCompanySettings(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<AllCompanySettingsData>.from(
            json["data"].map((x) => AllCompanySettingsData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class AllCompanySettingsData {
  int? id;
  String? key;
  String? value;
  int? companyId;
  DateTime? createdAt;
  DateTime? editAt;

  AllCompanySettingsData({
     this.id,
     this.key,
     this.value,
     this.companyId,
     this.createdAt,
     this.editAt,
  });
  factory AllCompanySettingsData.fromJson(Map<String, dynamic> json) {
    return AllCompanySettingsData(
      id: json["id"] ?? 0,
      key: json["key"] ?? "default_key",
      value: json["value"] ?? "default_value",
      companyId: json["company_id"] ?? 0,
      createdAt: json["created_at"] == null
          ? DateTime.now()
          : DateTime.tryParse(json["created_at"]) ?? DateTime.now(),
      editAt: json["edit_at"] == null
          ? DateTime.now()
          : DateTime.tryParse(json["edit_at"]) ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
        "company_id": companyId,
        "created_at": createdAt?.toIso8601String(),
        "edit_at": editAt?.toIso8601String(),
      };
}




class Currency {
  String? country;
  String? currencyCode;
  String? currencySymbol;
  int? decimals;
  double? cashRounding;

  Currency({
    this.country,
    this.currencyCode,
    this.currencySymbol,
    this.decimals,
    this.cashRounding,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        country: json["country"] as String?,
        currencyCode: json["currency_code"] as String?,
        currencySymbol: json["currency_symbol"] as String?,
        decimals: json["decimals"] != null
            ? int.tryParse(json["decimals"].toString())
            : null,
        cashRounding: json["cashRounding"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "currency_code": currencyCode,
        "currency_symbol": currencySymbol,
        "decimals": decimals,
        "cashRounding": cashRounding,
      };
}
