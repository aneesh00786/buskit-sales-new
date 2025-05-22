// ignore_for_file: non_constant_identifier_names

class LoginResponse {
  int? statusCode;
  bool? status;
  String? message;
  LoginData? data;

  LoginResponse({this.statusCode, this.status, this.message, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.toJson();
    return json;
  }
}

class LoginData {
  int? id;
  int? company_id;
  String? salesmanId;
  String? fullname;
  String? lastname;
  String? department;
  String? portfolio;
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
  dynamic events;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;
  int? projectionPrice;
  int? projectionTarget;
  String? lastOnline;
  int? appStatus;
  String? usertype;
  int? status;
  String? createdToken;

  LoginData({
    this.id,
    this.company_id,
    this.salesmanId,
    this.fullname,
    this.lastname,
    this.department,
    this.portfolio,
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
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
    this.projectionPrice,
    this.projectionTarget,
    this.lastOnline,
    this.appStatus,
    this.usertype,
    this.status,
    this.createdToken,
  });

  LoginData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    company_id = json['company_id'];
    salesmanId = json['salesman_id'];
    fullname = json['fullname'];
    lastname = json['lastname'];
    department = json['department'];
    portfolio = json['portfolio'];
    mobileno = json['mobileno'];
    email = json['email'];
    password = json['password'];
    town = json['town'];
    state = json['state'];
    zipcode = json['zipcode'];
    address = json['address'];
    idimagePath = json['idimage_path'];
    imagePath = json['image_path'];
    createAt = json['create_at'];
    token = json['token'];
    events = json['events'];
    schedule = json['schedule'];
    creditPoint = json['credit_point'];
    cancelEventReason = json['cancel_event_reason'];
    projectionPrice = json['projection_price'];
    projectionTarget = json['projection_target'];
    lastOnline = json['last_online'];
    appStatus = json['app_status'];
    usertype = json['usertype'];
    status = json['status'];
    createdToken = json['createdToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['id'] = id;
    json['company_id'] = company_id;
    json['salesman_id'] = salesmanId;
    json['fullname'] = fullname;
    json['lastname'] = lastname;
    json['department'] = department;
    json['portfolio'] = portfolio;
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
    json['events'] = events;
    json['schedule'] = schedule;
    json['credit_point'] = creditPoint;
    json['cancel_event_reason'] = cancelEventReason;
    json['projection_price'] = projectionPrice;
    json['projection_target'] = projectionTarget;
    json['last_online'] = lastOnline;
    json['app_status'] = appStatus;
    json['usertype'] = usertype;
    json['status'] = status;
    json['createdToken'] = createdToken;
    return json;
  }
}

