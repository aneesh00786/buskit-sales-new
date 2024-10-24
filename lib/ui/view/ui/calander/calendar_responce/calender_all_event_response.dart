class CalenderDatas {
  int? statusCode;
  bool? status;
  String? message;
  List<EventData>? data;

  CalenderDatas({this.statusCode, this.status, this.message, this.data});

  CalenderDatas.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <EventData>[];
      json['data'].forEach((v) {
        data!.add(new EventData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status_code'] = this.statusCode;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventData {
  int? id;
  String? eventId;
  String? customerId;
  String? salesmanId;
  String? title;
  String? start;
  String? end;
  int? type;
  Null? checkIn;
  String? checkInLongitude;
  String? checkInLatitude;
  Null? checkOut;
  String? checkOutLatitude;
  int? checkOutLongitude;
  Null? eventCancel;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? businessName;
  String? imageUrl;
  String? email;
  String? mobileNo;
  String? address;
  String? latitude;
  String? longitude;


  EventData(
      {this.id,
      this.eventId,
      this.customerId,
      this.salesmanId,
      this.title,
      this.start,
      this.end,
      this.type,
      this.checkIn,
      this.checkInLongitude,
      this.checkInLatitude,
      this.checkOut,
      this.checkOutLatitude,
      this.checkOutLongitude,
      this.eventCancel,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.businessName,
      this.imageUrl,
      this.email,
      this.mobileNo,
      this.address,
      this.latitude,
      this.longitude
      
      });
EventData.fromJson(Map<String, dynamic> json) {
    

  id = json['id'];
  eventId = json['event_id'];
  customerId = json['customer_id'];
  salesmanId = json['salesman_id'];
  title = json['title'];
  start = json['start'];
  end = json['end'];
  type = json['type'] is bool ? (json['type'] == true ? 1 : 0) : json['type'];
  checkIn = json['check_in'];
  checkInLongitude = json['check_in_longitude'];
  checkInLatitude = json['check_in_latitude'];
  checkOut = json['check_out'];
  checkOutLatitude = json['check_out_latitude'];
  checkOutLongitude = json['check_out_longitude'] is bool 
      ? (json['check_out_longitude'] == true ? 1 : 0) 
      : json['check_out_longitude'];

  eventCancel = json['event_cancel'];
  status = json['status'] is bool ? (json['status'] == true ? 1 : 0) : json['status'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  businessName = json['business_name'];
  imageUrl = json['image_url'];
  email = json["email"];
  mobileNo = json["mobileno"];
  address = json["address"];
  latitude = json["latitude"];
  longitude =json["longitude"];
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['event_id'] = this.eventId;
    data['customer_id'] = this.customerId;
    data['salesman_id'] = this.salesmanId;
    data['title'] = this.title;
    data['start'] = this.start;
    data['end'] = this.end;
    data['type'] = this.type;
    data['check_in'] = this.checkIn;
    data['check_in_longitude'] = this.checkInLongitude;
    data['check_in_latitude'] = this.checkInLatitude;
    data['check_out'] = this.checkOut;
    data['check_out_latitude'] = this.checkOutLatitude;
    data['check_out_longitude'] = this.checkOutLongitude;
    data['event_cancel'] = this.eventCancel;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['business_name'] = this.businessName;
    data['image_url'] = this.imageUrl;
    data['email'] = this.email;
    data['mobileno'] = this.mobileNo;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
class Customer {
  String? customerId;
  final String? mobileno;
  final String? email;
  final String? address;
  final String? businessName;
  final String? imageUrl;
  String? latitude;
  String? longitude;
  String? distance;
  String? duration;

  Customer({
    this.customerId,
    this.mobileno,
    this.email,
    this.address,
    this.businessName,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.distance,
    this.duration,
  });

  Customer.fromJson(Map<String, dynamic> json)
      : customerId = json['customer_id'] as String?,
        mobileno = json['mobileno'] as String?,
        email = json['email'] as String?,
        address = json['address'] as String?,
        businessName = json['business_name'] as String?,
        imageUrl = json['image_url'] as String?,
        latitude = json['latitude'] as String?,
        longitude = json['longitude'] as String?,
        distance = json['distance'] as String?, 
        duration = json['duration'] as String?;

  Map<String, dynamic> toJson() => {
        'customer_id':customerId,
        'mobileno': mobileno,
        'email': email,
        'address': address,
        'business_name': businessName,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
        'duration': duration,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.mobileno == mobileno &&
        other.email == email &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode =>
      mobileno.hashCode ^ email.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

