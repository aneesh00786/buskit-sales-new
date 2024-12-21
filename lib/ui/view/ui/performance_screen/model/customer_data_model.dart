// To parse this JSON data, do
//
//     final customerData = customerDataFromJson(jsonString?);

import 'dart:convert';

CustomerData customerDataFromJson(String? str) => CustomerData.fromJson(json.decode(str??''));

String? customerDataToJson(CustomerData data) => json.encode(data.toJson());

class CustomerData {
    int? statusCode;
    bool? status;
    String? message;
    List<CustomerItem>? data;

    CustomerData({
        this.statusCode,
        this.status,
        this.message,
        this.data,
    });

    factory CustomerData.fromJson(Map<String?, dynamic> json) => CustomerData(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<CustomerItem>.from(json["data"].map((x) => CustomerItem.fromJson(x))),
    );

    Map<String?, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class CustomerItem {
    int? id;
    String? customerId;
    dynamic cartId;
    String? fullname;
    String? mobileno;
    String? email;
    String? town;
    String? state;
    int? zipcode;
    String? address;
    String? latitude;
    String? longitude;
    String? businessName;
    String? businessNo;
    String? tfn;
    String? addressCheckbox;
    String? deliveryAddress;
    String? deliveryTown;
    String? deliveryState;
    int? deliveryZipcode;
    String? remark;
    String? imageUrl;
    CreatedBy? salesmanId;
    int? status;
    DateTime? createAt;
    CreatedBy? createdBy;
    SalesmanName? salesmanName;
    String? discount;
    int? eventType;
    String? eventDays;
    int? creditPeriod;
    int? companyId;

    CustomerItem({
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
        this.latitude,
        this.longitude,
        this.businessName,
        this.businessNo,
        this.tfn,
        this.addressCheckbox,
        this.deliveryAddress,
        this.deliveryTown,
        this.deliveryState,
        this.deliveryZipcode,
        this.remark,
        this.imageUrl,
        this.salesmanId,
        this.status,
        this.createAt,
        this.createdBy,
        this.salesmanName,
        this.discount,
        this.eventType,
        this.eventDays,
        this.creditPeriod,
        this.companyId,
    });

    factory CustomerItem.fromJson(Map<String?, dynamic> json) => CustomerItem(
        id: json["id"],
        customerId: json["customer_id"],
        cartId: json["cart_id"],
        fullname: json["fullname"],
        mobileno: json["mobileno"],
        email: json["email"],
        town: json["town"],
        state: json["state"],
        zipcode: json["zipcode"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        businessName: json["business_name"],
        businessNo: json["business_no"],
        tfn: json["tfn"],
        addressCheckbox: json["addressCheckbox"],
        deliveryAddress: json["delivery_address"],
        deliveryTown: json["delivery_town"],
        deliveryState: json["delivery_state"],
        deliveryZipcode: json["delivery_zipcode"],
        remark: json["remark"],
        imageUrl: json["image_url"],
        salesmanId: createdByValues.map[json["salesman_id"]],
        status: json["status"],
        createAt: DateTime.parse(json["create_at"]),
        createdBy: createdByValues.map[json["created_by"]],
        salesmanName: salesmanNameValues.map[json["salesman_name"]],
        discount: json["discount"],
        eventType: json["event_type"],
        eventDays: json["event_days"],
        creditPeriod: json["credit_period"],
        companyId: json["company_id"],
    );

    Map<String?, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "cart_id": cartId,
        "fullname": fullname,
        "mobileno": mobileno,
        "email": email,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "business_name": businessName,
        "business_no": businessNo,
        "tfn": tfn,
        "addressCheckbox": addressCheckbox,
        "delivery_address": deliveryAddress,
        "delivery_town": deliveryTown,
        "delivery_state": deliveryState,
        "delivery_zipcode": deliveryZipcode,
        "remark": remark,
        "image_url": imageUrl,
        "salesman_id": createdByValues.reverse[salesmanId],
        "status": status,
        "create_at": createAt?.toIso8601String != null?():'',
        "created_by": createdByValues.reverse[createdBy],
        "salesman_name": salesmanNameValues.reverse[salesmanName],
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDays,
        "credit_period": creditPeriod,
        "company_id": companyId,
    };
}

enum CreatedBy {
    SALES1
}

final createdByValues = EnumValues({
    "SALES1": CreatedBy.SALES1
});

enum SalesmanName {
    RP
}

final salesmanNameValues = EnumValues({
    "RP": SalesmanName.RP
});

class EnumValues<T> {
    Map<String?, T> map;
    late Map<T, String?> reverseMap;

    EnumValues(this.map);

    Map<T, String?> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
