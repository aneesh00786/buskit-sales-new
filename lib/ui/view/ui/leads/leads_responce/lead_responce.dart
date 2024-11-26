
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/database/session/null_check_oprations.dart';

class LeadResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<LeadCustomerData>? leadCustomerData;

  LeadResponce({
    this.statusCode,
    this.status,
    this.message,
    this.leadCustomerData,
  });

  LeadResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    leadCustomerData = (json['data'] as List?)
        ?.map(
            (dynamic e) => LeadCustomerData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = leadCustomerData?.map((e) => e.toJson()).toList();
    return json;
  }
}

class LeadCustomerData {
  int? id;
  String? customerId;
  String? fullname;
  String? mobileno;
  String? email;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? businessName;
  String? businessNo;
  String? remark;
  String? imageUrl;
  String? oldImageUrl;

  /// for Update
  String? salesmanId;
  int? status;
  String? createAt;
  String? salesmanName;

  LeadCustomerData({
    this.id,
    this.customerId,
    this.fullname,
    this.mobileno,
    this.email,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.businessName,
    this.businessNo,
    this.remark,
    this.imageUrl,
    this.salesmanId,
    this.oldImageUrl,
    this.status,
    this.createAt,
    this.salesmanName,
  });

  LeadCustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    customerId = json['customer_id'] as String?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    town = json['town'] as String?;
    state = json['state'] as String?;
    zipcode = json['zipcode'] as int?;
    address = json['address'] as String?;
    businessName = json['business_name'] as String?;
    businessNo = json['business_no'] as String?;
    remark = json['remark'] as String?;
    imageUrl = json['image_url'] as String?;
    oldImageUrl = json['image_url'] as String?;
    salesmanId = json['salesman_id'] as String?;
    status = json['status'] as int?;
    createAt = json['create_at'] as String?;
    salesmanName = json['salesman_name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['customer_id'] = customerId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['address'] = address;
    json['business_name'] = businessName;
    json['business_no'] = businessNo;
    json['remark'] = remark;
    json['image_url'] = imageUrl;
    json['salesman_id'] = salesmanId;
    json['status'] = status;
    json['create_at'] = createAt;
    json['salesman_name'] = salesmanName;
    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['address'] = address;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['businessname'] = businessName;
    json['businesscontact'] = businessNo;
    json['remark'] = remark;
    json['oldimage_url'] = oldImageUrl;
    json['cutomerpicture'] =
        !CheckNullData.checkLocalOrServerImage(imageUrl ?? '')
            ? NkCommonFunction.getFormData(imageUrl ?? '', mapKeyName: "")
            : null;
    json['customer_id'] = customerId;
    return json;
  }
}
