class GetRecentOrderReturn {
    int? statusCode;
    bool? status;
    List<GetRecentOrderReturnData>? data;
    String? message;
    Pagination? pagination;

    GetRecentOrderReturn({
        this.statusCode,
        this.status,
        this.data,
        this.message,
        this.pagination,
    });

    factory GetRecentOrderReturn.fromJson(Map<String, dynamic> json) => GetRecentOrderReturn(
        statusCode: json["status_code"],
        status: json["status"],
        data: json["data"] == null ? [] : List<GetRecentOrderReturnData>.from(json["data"]!.map((x) => GetRecentOrderReturnData.fromJson(x))),
        message: json["message"],
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "pagination": pagination?.toJson(),
    };
}

class GetRecentOrderReturnData {
    int? id;
    String? orderId;
    String? customerId;
    String? salesmanId;
    int? paymentStatus;
    int? paymentType;
    String? paymentDetail;
    int? orderStatus;
    String? cartId;
    DateTime? generatedDate;
    DateTime? orderCreatAt;
    String? statusChanged;
    double? orderTotal;
    String? receivedAmount;
    DateTime? receivedAmountDate;
    DateTime? checkDueDate;
    int? checkNumber;
    DateTime? transactionDate;
    String? transactionDetails;
    String? rejectionReason;
    dynamic rejectedDate;
    int? receivableAmount;
    DateTime? deliveryDatetime;
    int? notificationStatus;
    dynamic orderCreatedStored;
    int? companyId;
    String? fullname;
    String? lastname;
    String? editedFullname;
    String? editedLastname;
    int? totalCount;
    List<Cart>? cart;
    List<Customer>? customer;
    Invoice? invoice;

    GetRecentOrderReturnData({
        this.id,
        this.orderId,
        this.customerId,
        this.salesmanId,
        this.paymentStatus,
        this.paymentType,
        this.paymentDetail,
        this.orderStatus,
        this.cartId,
        this.generatedDate,
        this.orderCreatAt,
        this.statusChanged,
        this.orderTotal,
        this.receivedAmount,
        this.receivedAmountDate,
        this.checkDueDate,
        this.checkNumber,
        this.transactionDate,
        this.transactionDetails,
        this.rejectionReason,
        this.rejectedDate,
        this.receivableAmount,
        this.deliveryDatetime,
        this.notificationStatus,
        this.orderCreatedStored,
        this.companyId,
        this.fullname,
        this.lastname,
        this.editedFullname,
        this.editedLastname,
        this.totalCount,
        this.cart,
        this.customer,
        this.invoice,
    });

    factory GetRecentOrderReturnData.fromJson(Map<String, dynamic> json) => GetRecentOrderReturnData(
        id: json["id"],
        orderId: json["order_id"],
        customerId: json["customer_id"],
        salesmanId: json["salesman_id"],
        paymentStatus: json["payment_status"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
        orderStatus: json["order_status"],
        cartId: json["cart_id"],
        generatedDate: json["generated_date"] == null ? null : DateTime.parse(json["generated_date"]),
        orderCreatAt: json["order_creat_at"] == null ? null : DateTime.parse(json["order_creat_at"]),
        statusChanged: json["status_changed"],
        orderTotal: json["order_total"]?.toDouble(),
        receivedAmount: json["received_amount"],
        receivedAmountDate: json["received_amount_date"] == null ? null : DateTime.parse(json["received_amount_date"]),
        checkDueDate: json["check_due_date"] == null ? null : DateTime.parse(json["check_due_date"]),
        checkNumber: json["check_number"],
        transactionDate: json["transaction_date"] == null ? null : DateTime.parse(json["transaction_date"]),
        transactionDetails: json["transaction_details"],
        rejectionReason: json["rejection_reason"],
        rejectedDate: json["rejected_date"],
        receivableAmount: json["receivable_amount"],
        deliveryDatetime: json["delivery_datetime"] == null ? null : DateTime.parse(json["delivery_datetime"]),
        notificationStatus: json["notification_status"],
        orderCreatedStored: json["order_created_stored"],
        companyId: json["company_id"],
        fullname: json["fullname"],
        lastname: json["lastname"],
        editedFullname: json["edited_fullname"],
        editedLastname: json["edited_lastname"],
        totalCount: json["total_count"],
        cart: json["cart"] == null ? [] : List<Cart>.from(json["cart"]!.map((x) => Cart.fromJson(x))),
        customer: json["customer"] == null ? [] : List<Customer>.from(json["customer"]!.map((x) => Customer.fromJson(x))),
        invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "salesman_id": salesmanId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "cart_id": cartId,
        "generated_date": generatedDate?.toIso8601String(),
        "order_creat_at": orderCreatAt?.toIso8601String(),
        "status_changed": statusChanged,
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate?.toIso8601String(),
        "check_due_date": checkDueDate?.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate?.toIso8601String(),
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate,
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime?.toIso8601String(),
        "notification_status": notificationStatus,
        "order_created_stored": orderCreatedStored,
        "company_id": companyId,
        "fullname": fullname,
        "lastname": lastname,
        "edited_fullname": editedFullname,
        "edited_lastname": editedLastname,
        "total_count": totalCount,
        "cart": cart == null ? [] : List<dynamic>.from(cart!.map((x) => x.toJson())),
        "customer": customer == null ? [] : List<dynamic>.from(customer!.map((x) => x.toJson())),
        "invoice": invoice?.toJson(),
    };
}

class Cart {
    int? id;
    String? cartId;
    String? productId;
    String? variationId;
    String? price;
    dynamic reason;
    int? quantity;
    int? pieces;
    String? packType;
    String? discount;
    String? discountAmount;
    int? totalPrice;
    String? tax;
    String? inclTax;
    int? isPromo;
    int? isBundle;
    String? promoCode;
    int? status;
    int? orderPlaceStatus;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? companyId;

    Cart({
        this.id,
        this.cartId,
        this.productId,
        this.variationId,
        this.price,
        this.reason,
        this.quantity,
        this.pieces,
        this.packType,
        this.discount,
        this.discountAmount,
        this.totalPrice,
        this.tax,
        this.inclTax,
        this.isPromo,
        this.isBundle,
        this.promoCode,
        this.status,
        this.orderPlaceStatus,
        this.createdAt,
        this.updatedAt,
        this.companyId,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        cartId: json["cart_id"],
        productId: json["product_id"],
        variationId: json["variation_id"],
        price: json["price"],
        reason: json["reason"],
        quantity: json["quantity"],
        pieces: json["pieces"],
        packType: json["packType"],
        discount: json["discount"],
        discountAmount: json["discount_amount"],
        totalPrice: json["total_price"],
        tax: json["tax"],
        inclTax: json["incl_tax"],
        isPromo: json["is_promo"],
        isBundle: json["is_bundle"],
        promoCode: json["promo_code"],
        status: json["status"],
        orderPlaceStatus: json["order_place_status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        companyId: json["company_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "price": price,
        "reason": reason,
        "quantity": quantity,
        "pieces": pieces,
        "packType": packType,
        "discount": discount,
        "discount_amount": discountAmount,
        "total_price": totalPrice,
        "tax": tax,
        "incl_tax": inclTax,
        "is_promo": isPromo,
        "is_bundle": isBundle,
        "promo_code": promoCode,
        "status": status,
        "order_place_status": orderPlaceStatus,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "company_id": companyId,
    };
}

class Customer {
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
    String? salesmanId;
    int? status;
    DateTime? createAt;
    DateTime? updatedAt;
    String? createdBy;
    String? salesmanName;
    String? discount;
    int? eventType;
    String? eventDays;
    int? eventPeriod;
    int? creditPeriod;
    int? companyId;
    int? qbId;
    String? xeroId;

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
        this.updatedAt,
        this.createdBy,
        this.salesmanName,
        this.discount,
        this.eventType,
        this.eventDays,
        this.eventPeriod,
        this.creditPeriod,
        this.companyId,
        this.qbId,
        this.xeroId,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
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
        salesmanId: json["salesman_id"],
        status: json["status"],
        createAt: json["create_at"] == null ? null : DateTime.parse(json["create_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdBy: json["created_by"],
        salesmanName: json["salesman_name"],
        discount: json["discount"],
        eventType: json["event_type"],
        eventDays: json["event_days"],
        eventPeriod: json["event_period"],
        creditPeriod: json["credit_period"],
        companyId: json["company_id"],
        qbId: json["qb_id"],
        xeroId: json["xero_id"],
    );

    Map<String, dynamic> toJson() => {
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
        "salesman_id": salesmanId,
        "status": status,
        "create_at": createAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "created_by": createdBy,
        "salesman_name": salesmanName,
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDays,
        "event_period": eventPeriod,
        "credit_period": creditPeriod,
        "company_id": companyId,
        "qb_id": qbId,
        "xero_id": xeroId,
    };
}

class Invoice {
    String? invoiceId;
    DateTime? createdAt;

    Invoice({
        this.invoiceId,
        this.createdAt,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: json["invoice_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "created_at": createdAt?.toIso8601String(),
    };
}

class Pagination {
    int? totalRecord;
    int? totalPages;
    int? currentPage;
    int? perPage;

    Pagination({
        this.totalRecord,
        this.totalPages,
        this.currentPage,
        this.perPage,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalRecord: json["total_record"],
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        perPage: json["per_page"],
    );

    Map<String, dynamic> toJson() => {
        "total_record": totalRecord,
        "total_pages": totalPages,
        "current_page": currentPage,
        "per_page": perPage,
    };
}
