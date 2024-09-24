class LoginResponce {
  int? statusCode;
  bool? status;
  String? message;
  LoginData? data;
  LoginResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });
  LoginResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as Map<String, dynamic>?) != null ? LoginData.fromJson(json['data'] as Map<String, dynamic>) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.toJson();
    return json;
  }
}
class LoginData {
  int? id;
  String? salesmanId;
  String? fullname;
  String? mobileno;
  String? email;
  String? password;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? idimagePath;
  String? imagePath;
  String? createAt;
  String? token;
  int? company_id;
  LoginData({
    this.id,
    this.salesmanId,
    this.fullname,
    this.mobileno,
    this.email,
    this.password,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.idimagePath,
    this.imagePath,
    this.createAt,
    this.token,
    this.company_id,
  });
  LoginData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    salesmanId = json['salesman_id'] as String?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    password = json['password'] as String?;
    town = json['town'] as String?;
    state = json['state'] as String?;
    zipcode = json['zipcode'] as int?;
    address = json['address'] as String?;
    idimagePath = json['idimage_path'] as String?;
    imagePath = json['image_path'] as String?;
    createAt = json['create_at'] as String?;
    token = json['token'] as String?;
    company_id = json['company_id'] as int?;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['salesman_id'] = salesmanId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['password'] = password;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['address'] = address;
    json['idimage_path'] = idimagePath;
    json['image_path'] = imagePath;
    json['create_at'] = createAt;
    json['token'] = token;
    json['company_id'] = company_id;
    return json;
  }
}
