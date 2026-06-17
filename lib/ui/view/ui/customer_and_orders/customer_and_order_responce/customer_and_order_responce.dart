
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';

class CustomerAndOrderResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<CustomerAndOrderData>? custAndOrderdata;

  CustomerAndOrderResponce({
    this.statusCode,
    this.status,
    this.message,
    this.custAndOrderdata,
  });

  CustomerAndOrderResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    custAndOrderdata = (json['data'] as List?)
        ?.map((dynamic e) =>
            CustomerAndOrderData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = custAndOrderdata?.map((e) => e.toJson()).toList();
    return json;
  }
}

class CustomerAndOrderData {
  int? id;
  String? customerId;
  String? cartId;
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
  String? salesmanId;
  int? status;
  String? createAt;
  String? salesmanName;
  List<String> selectedWeekDay = [];
  List<CustomerCart>? cart;
  String? discount;
  int? visitType;
  int? totalSales;
  int? sales;
  int? delivery;
  int? payment;
  int? estimates;
  int? preOrder;
  int? drafts;
  int? cancelled;
  List<CustomerAssignedSalesman>? salesman;
  bool isSelected = false;

  CustomerAndOrderData({
    this.id,
    this.customerId,
    this.cartId,
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
    this.status,
    this.createAt,
    this.salesmanName,
    this.discount,
    this.visitType,
    this.totalSales,
    this.sales,
    this.delivery,
    this.payment,
    this.estimates,
    this.preOrder,
    this.drafts,
    this.cancelled,
    this.salesman,
    this.cart,
  });

  CustomerAndOrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    customerId = json['customer_id'] as String?;
    cartId = json['cart_id'] as String?;
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
    salesmanId = json['salesman_id'] as String?;
    status = json['status'] as int?;
    createAt = json['create_at'] as String?;
    salesmanName = json['salesman_name'] as String?;
    discount = json['discount'] as String?;
    visitType = json['event_type'] as int?;
    totalSales = json['total_sales'] != null
        ? int.parse(json['total_sales'].toString())
        : 0;
    sales = json['sales'] as int?;
    delivery = json['delivery'] as int?;
    payment = json['payment'] as int?;
    estimates = json['Estimates'] as int?;
    preOrder = json['pre_order'] as int?;
    drafts = json['Drafts'] as int?;
    cancelled = json['Cancelled'] as int?;
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>))
        .toList();
    salesman = (json['salesman'] as List?)
        ?.map((dynamic e) =>
            CustomerAssignedSalesman.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['customer_id'] = customerId;
    json['cart_id'] = cartId;
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
    json['discount'] = discount;
    json['event_type'] = visitType;
    json['total_sales'] = totalSales;
    json['sales'] = sales;
    json['delivery'] = delivery;
    json['payment'] = payment;
    json['Estimates'] = estimates;
    json['pre_order'] = preOrder;
    json['Drafts'] = drafts;
    json['Cancelled'] = cancelled;
    json['salesman'] = salesman?.map((e) => e.toJson()).toList();
    return json;
  }
}

class CustomerAssignedSalesman {
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
  dynamic events;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;

  CustomerAssignedSalesman({
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
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
  });

  CustomerAssignedSalesman.fromJson(Map<String, dynamic> json) {
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
    events = json['events'];
    schedule = json['schedule'];
    creditPoint = json['credit_point'];
    cancelEventReason = json['cancel_event_reason'];
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
    json['events'] = events;
    json['schedule'] = schedule;
    json['credit_point'] = creditPoint;
    json['cancel_event_reason'] = cancelEventReason;
    return json;
  }
}

class AddEvent {
    int statusCode;
    bool status;
    String message;

    AddEvent({
        required this.statusCode,
        required this.status,
        required this.message,
    });

    factory AddEvent.fromJson(Map<String, dynamic> json) => AddEvent(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
    };
}

class CustomerCategoryDiscountData {
  int? cid;
  String? category;
  int? id;
  int? companyId;
  String? customerId;
  String? categoriesId;
  String? value;
  String? discount;

  CustomerCategoryDiscountData({
    this.cid,
    this.category,
    this.id,
    this.companyId,
    this.customerId,
    this.categoriesId,
    this.value,
    this.discount,
  });

  factory CustomerCategoryDiscountData.fromJson(Map<String, dynamic> json) {
    return CustomerCategoryDiscountData(
      cid: json['cid'],
      category: json['category'],
      id: json['id'],
      companyId: json['company_id'],
      customerId: json['customer_id'],
      categoriesId: json['categories_id'],
      value: json['value']?.toString() ?? '', 
      discount: json['discount']?.toString() ?? '',
    );
  }
}
