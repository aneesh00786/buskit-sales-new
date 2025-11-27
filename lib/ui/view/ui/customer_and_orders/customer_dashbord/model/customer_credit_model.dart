
class CustomerCredit {
    int? statusCode;
    bool? status;
    List<Customer>? customers;

    CustomerCredit({
        this.statusCode,
        this.status,
        this.customers,
    });

    factory CustomerCredit.fromJson(Map<String, dynamic> json) => CustomerCredit(
        statusCode: json["status_code"],
        status: json["status"],
        customers: json["customers"] == null ? [] : List<Customer>.from(json["customers"]!.map((x) => Customer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "customers": customers == null ? [] : List<dynamic>.from(customers!.map((x) => x.toJson())),
    };
}

class Customer {
    String? customerId;
    int? creditAmt;

    Customer({
        this.customerId,
        this.creditAmt,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        customerId: json["customer_id"],
        creditAmt: json["credit_amt"],
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "credit_amt": creditAmt,
    };
}
