class AllCalenderEvent {
  final int? statusCode;
  final bool? status;
  final String? message;
  final List<CalenderData>? data;

  AllCalenderEvent({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  AllCalenderEvent.fromJson(Map<String, dynamic> json)
      : statusCode = json['status_code'] as int?,
        status = json['status'] as bool?,
        message = json['message'] as String?,
        data = (json['data'] as List?)
            ?.map(
                (dynamic e) => CalenderData.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status': status,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList()
      };
}

class CalenderData {
  final int? id;
  final String? salesmanId;
  final String? fullname;
  final String? mobileno;
  final String? email;
  final String? password;
  final String? town;
  final String? state;
  final int? zipcode;
  final String? address;
  final String? idimagePath;
  final String? imagePath;
  final String? createAt;
  final String? token;
  final List<SalesmanEvents>? events;
  final dynamic schedule;
  final dynamic creditPoint;
  final dynamic cancelEventReason;

  CalenderData({
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

  CalenderData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        salesmanId = json['salesman_id'] as String?,
        fullname = json['fullname'] as String?,
        mobileno = json['mobileno'] as String?,
        email = json['email'] as String?,
        password = json['password'] as String?,
        town = json['town'] as String?,
        state = json['state'] as String?,
        zipcode = json['zipcode'] as int?,
        address = json['address'] as String?,
        idimagePath = json['idimage_path'] as String?,
        imagePath = json['image_path'] as String?,
        createAt = json['create_at'] as String?,
        token = json['token'] as String?,
        events = (json['events'] as List?)
            ?.map((dynamic e) =>
                SalesmanEvents.fromJson(e as Map<String, dynamic>))
            .toList(),
        schedule = json['schedule'],
        creditPoint = json['credit_point'],
        cancelEventReason = json['cancel_event_reason'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'salesman_id': salesmanId,
        'fullname': fullname,
        'mobileno': mobileno,
        'email': email,
        'password': password,
        'town': town,
        'state': state,
        'zipcode': zipcode,
        'address': address,
        'idimage_path': idimagePath,
        'image_path': imagePath,
        'create_at': createAt,
        'token': token,
        'events': events?.map((e) => e.toJson()).toList(),
        'schedule': schedule,
        'credit_point': creditPoint,
        'cancel_event_reason': cancelEventReason
      };
}

class SalesmanEvents {
  final int? totalEvent;
  final String? start;
  final String? salesmanId;
  final String? customerId;
  final String? end;
  final List<Salesman>? salesman;

  SalesmanEvents({
    this.totalEvent,
    this.start,
    this.salesmanId,
    this.customerId,
    this.end,
    this.salesman,
  });

  SalesmanEvents.fromJson(Map<String, dynamic> json)
      : totalEvent = json['total_event'] as int?,
        start = json['start'] as String?,
        salesmanId = json['salesman_id'] as String?,
        customerId = json['customer_id'] as String?,
        end = json['end'] as String?,
        salesman = (json['salesman'] as List?)
            ?.map((dynamic e) => Salesman.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'total_event': totalEvent,
        'start': start,
        'salesman_id': salesmanId,
        'customer_id': customerId,
        'end': end,
        'salesman': salesman?.map((e) => e.toJson()).toList()
      };
}

class Salesman {
  final int? id;
  final String? salesmanId;
  final String? fullname;
  final String? mobileno;
  final String? email;
  final String? password;
  final String? town;
  final String? state;
  final int? zipcode;
  final String? address;
  final String? idimagePath;
  final String? imagePath;
  final String? createAt;
  final String? token;
  final dynamic events;
  final dynamic schedule;
  final dynamic creditPoint;
  final dynamic cancelEventReason;
  final List<Customer>? customer;

  Salesman({
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
    this.customer,
  });

  Salesman.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        salesmanId = json['salesman_id'] as String?,
        fullname = json['fullname'] as String?,
        mobileno = json['mobileno'] as String?,
        email = json['email'] as String?,
        password = json['password'] as String?,
        town = json['town'] as String?,
        state = json['state'] as String?,
        zipcode = json['zipcode'] as int?,
        address = json['address'] as String?,
        idimagePath = json['idimage_path'] as String?,
        imagePath = json['image_path'] as String?,
        createAt = json['create_at'] as String?,
        token = json['token'] as String?,
        events = json['events'],
        schedule = json['schedule'],
        creditPoint = json['credit_point'],
        cancelEventReason = json['cancel_event_reason'],
        customer = (json['customer'] as List?)
            ?.map((dynamic e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'salesman_id': salesmanId,
        'fullname': fullname,
        'mobileno': mobileno,
        'email': email,
        'password': password,
        'town': town,
        'state': state,
        'zipcode': zipcode,
        'address': address,
        'idimage_path': idimagePath,
        'image_path': imagePath,
        'create_at': createAt,
        'token': token,
        'events': events,
        'schedule': schedule,
        'credit_point': creditPoint,
        'cancel_event_reason': cancelEventReason,
        'customer': customer?.map((e) => e.toJson()).toList()
      };
}

class Customer {
  final int? id;
  final String? customerId;
  final dynamic cartId;
  final String? fullname;
  final String? mobileno;
  final String? email;
  final String? town;
  final String? state;
  final int? zipcode;
  final String? address;
  final String? businessName;
  final String? businessNo;
  final String? remark;
  final String? imageUrl;
  final String? salesmanId;
  final int? status;
  final String? createAt;
  final String? salesmanName;
  final String? discount;
  final int? eventType;
  final String? eventDays;

  Customer({
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
    this.eventType,
    this.eventDays,
  });

  Customer.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        customerId = json['customer_id'] as String?,
        cartId = json['cart_id'],
        fullname = json['fullname'] as String?,
        mobileno = json['mobileno'] as String?,
        email = json['email'] as String?,
        town = json['town'] as String?,
        state = json['state'] as String?,
        zipcode = json['zipcode'] as int?,
        address = json['address'] as String?,
        businessName = json['business_name'] as String?,
        businessNo = json['business_no'] as String?,
        remark = json['remark'] as String?,
        imageUrl = json['image_url'] as String?,
        salesmanId = json['salesman_id'] as String?,
        status = json['status'] as int?,
        createAt = json['create_at'] as String?,
        salesmanName = json['salesman_name'] as String?,
        discount = json['discount'] as String?,
        eventType = json['event_type'] as int?,
        eventDays = json['event_days'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'cart_id': cartId,
        'fullname': fullname,
        'mobileno': mobileno,
        'email': email,
        'town': town,
        'state': state,
        'zipcode': zipcode,
        'address': address,
        'business_name': businessName,
        'business_no': businessNo,
        'remark': remark,
        'image_url': imageUrl,
        'salesman_id': salesmanId,
        'status': status,
        'create_at': createAt,
        'salesman_name': salesmanName,
        'discount': discount,
        'event_type': eventType,
        'event_days': eventDays
      };
}
