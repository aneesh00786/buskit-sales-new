class EventData {
  int? id;
  String? eventId;
  String? customerId;
  String? salesmanId;
  String? title;
  String? start;
  String? end;
  int? type;
  dynamic checkIn;
  String? checkInLongitude;
  String? checkInLatitude;
  dynamic checkOut;
  String? checkOutLatitude;
  int? checkOutLongitude;
  dynamic eventCancel;
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
  String? salesmanFirstname;
  String? salesmanLastname;
  String? salesmanMobileno;
  String? salesmanEmail;

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
      this.longitude,
      this.salesmanFirstname,
      this.salesmanLastname,
      this.salesmanMobileno,
      this.salesmanEmail,
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
    status = json['status'] is bool
        ? (json['status'] == true ? 1 : 0)
        : json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    businessName = json['business_name'];
    imageUrl = json['image_url'];
    email = json["email"];
    mobileNo = json["mobileno"];
    address = json["address"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    salesmanFirstname = json["salesman_firstname"];
    salesmanLastname = json["salesman_lastname"];
    salesmanMobileno = json["salesman_mobileno"];
    salesmanEmail = json["salesman_email"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['event_id'] = eventId;
    data['customer_id'] = customerId;
    data['salesman_id'] = salesmanId;
    data['title'] = title;
    data['start'] = start;
    data['end'] = end;
    data['type'] = type;
    data['check_in'] = checkIn;
    data['check_in_longitude'] = checkInLongitude;
    data['check_in_latitude'] = checkInLatitude;
    data['check_out'] = checkOut;
    data['check_out_latitude'] = checkOutLatitude;
    data['check_out_longitude'] = checkOutLongitude;
    data['event_cancel'] = eventCancel;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['business_name'] = businessName;
    data['image_url'] = imageUrl;
    data['email'] = email;
    data['mobileno'] = mobileNo;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['salesman_firstname'] = salesmanFirstname;
    data['salesman_lastname'] = salesmanLastname;
    data['salesman_mobileno'] = salesmanMobileno;
    data['salesman_email'] = salesmanEmail;
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
