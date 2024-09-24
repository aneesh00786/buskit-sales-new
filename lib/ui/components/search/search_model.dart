class SearchResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<SearchData>? data;

  SearchResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  SearchResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => SearchData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.map((e) => e.toJson()).toList();
    return json;
  }
}

class SearchData {
  String? customerId;
  String? fullname;
  String? mobileno;
  String? email;
  String? imageUrl;

  SearchData({
    this.customerId,
    this.fullname,
    this.mobileno,
    this.email,
    this.imageUrl,
  });

  SearchData.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'] as String?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    imageUrl = json['image_url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['customer_id'] = customerId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['image_url'] = imageUrl;
    return json;
  }
}
