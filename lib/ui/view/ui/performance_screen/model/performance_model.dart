import 'dart:developer';

// class PerformanceResponse {
//   int? statusCode;
//   bool? status;
//   String? message;
//   PerformanceData? data;

//   PerformanceResponse({this.statusCode, this.status, this.message, this.data});

//   PerformanceResponse.fromJson(Map<String, dynamic> json) {
//     statusCode = json['status_code'];
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? PerformanceData.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['status_code'] = statusCode;
//     data['status'] = status;
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class PerformanceData {
//   NavbarAndTargetContent? navbarAndTargetContent;
//   List<CategoryPerformance>? categoryPerformance;
//   List<String>? months;

//   PerformanceData({this.navbarAndTargetContent, this.categoryPerformance, this.months});

// PerformanceData.fromJson(Map<String, dynamic> json) {
//   navbarAndTargetContent = json['navbar_and_target_content'] != null
//       ? NavbarAndTargetContent.fromJson(json['navbar_and_target_content'])
//       : null;

//   if (json['category_performance'] != null) {
//     categoryPerformance = <CategoryPerformance>[];
//     json['category_performance'].forEach((v) {
//       categoryPerformance!.add(CategoryPerformance.fromJson(v));
//     });
//     log('Parsed category_performance: ${categoryPerformance!.length}');
//   } else {
//     log('No category_performance in response');
//   }

//   months = json['months'] != null ? List<String>.from(json['months']) : null;
// }


//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     if (navbarAndTargetContent != null) {
//       data['navbar_and_target_content'] = navbarAndTargetContent!.toJson();
//     }
//     if (categoryPerformance != null) {
//       data['category_performance'] =
//           categoryPerformance!.map((v) => v.toJson()).toList();
//     }
//     data['months'] = months;
//     return data;
//   }
// }

// class NavbarAndTargetContent {
//   int? id;
//   int? companyId;
//   String? salesmanId;
//   String? fullname;
//   String? lastname;
//   String? department;
//   String? portfolio;
//   String? mobileno;
//   String? email;
//   String? password;
//   String? town;
//   String? state;
//   int? zipcode;
//   String? address;
//   String? idimagePath;
//   String? imagePath;
//   String? createAt;
//   String? token;
//   dynamic events;
//   dynamic schedule;
//   dynamic creditPoint;
//   dynamic cancelEventReason;
//   int? projectionPrice;
//   int? projectionTarget;
//   String? lastOnline;
//   int? status;
//   int? customer;
//   int? totalTarget;
//   double? actual;
//   int? timesheet;
//   List<SalesmanINOUT>? salesmanINOUT;
//   int? visit;

//   NavbarAndTargetContent({
//     this.id,
//     this.companyId,
//     this.salesmanId,
//     this.fullname,
//     this.lastname,
//     this.department,
//     this.portfolio,
//     this.mobileno,
//     this.email,
//     this.password,
//     this.town,
//     this.state,
//     this.zipcode,
//     this.address,
//     this.idimagePath,
//     this.imagePath,
//     this.createAt,
//     this.token,
//     this.events,
//     this.schedule,
//     this.creditPoint,
//     this.cancelEventReason,
//     this.projectionPrice,
//     this.projectionTarget,
//     this.lastOnline,
//     this.status,
//     this.customer,
//     this.totalTarget,
//     this.actual,
//     this.timesheet,
//     this.salesmanINOUT,
//     this.visit,
//   });

//   NavbarAndTargetContent.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     companyId = json['company_id'];
//     salesmanId = json['salesman_id'];
//     fullname = json['fullname'];
//     lastname = json['lastname'];
//     department = json['department'];
//     portfolio = json['portfolio'];
//     mobileno = json['mobileno'];
//     email = json['email'];
//     password = json['password'];
//     town = json['town'];
//     state = json['state'];
//     zipcode = json['zipcode'];
//     address = json['address'];
//     idimagePath = json['idimage_path'];
//     imagePath = json['image_path'];
//     createAt = json['create_at'];
//     token = json['token'];
//     events = json['events'];
//     schedule = json['schedule'];
//     creditPoint? = json['credit_point'];
//     cancelEventReason = json['cancel_event_reason'];
//     projectionPrice = json['projection_price'];
//     projectionTarget = json['projection_target'];
//     lastOnline = json['last_online'];
//     status = json['status'];
//     customer = json['customer'];
//     totalTarget = json['total_target'];
//     actual = json['actual'];
//     timesheet = json['timesheet'];
//     if (json['salesman_IN_OUT'] != null) {
//       salesmanINOUT = <SalesmanINOUT>[];
//       json['salesman_IN_OUT'].forEach((v) {
//         salesmanINOUT!.add(SalesmanINOUT.fromJson(v));
//       });
//     }
//     visit = json['visit'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['id'] = id;
//     data['company_id'] = companyId;
//     data['salesman_id'] = salesmanId;
//     data['fullname'] = fullname;
//     data['lastname'] = lastname;
//     data['department'] = department;
//     data['portfolio'] = portfolio;
//     data['mobileno'] = mobileno;
//     data['email'] = email;
//     data['password'] = password;
//     data['town'] = town;
//     data['state'] = state;
//     data['zipcode'] = zipcode;
//     data['address'] = address;
//     data['idimage_path'] = idimagePath;
//     data['image_path'] = imagePath;
//     data['create_at'] = createAt;
//     data['token'] = token;
//     data['events'] = events;
//     data['schedule'] = schedule;
//     data['credit_point'] = creditPoint;
//     data['cancel_event_reason'] = cancelEventReason;
//     data['projection_price'] = projectionPrice;
//     data['projection_target'] = projectionTarget;
//     data['last_online'] = lastOnline;
//     data['status'] = status;
//     data['customer'] = customer;
//     data['total_target'] = totalTarget;
//     data['actual'] = actual;
//     data['timesheet'] = timesheet;
//     if (salesmanINOUT != null) {
//       data['salesman_IN_OUT'] = salesmanINOUT!.map((v) => v.toJson()).toList();
//     }
//     data['visit'] = visit;
//     return data;
//   }
// }

// class SalesmanINOUT {
//   String? customerId;
//   int? id;
//   String? fullname;
//   String? email;
//   String? mobileno;
//   String? imageUrl;
//   String? salesmanId;
//   int? individualVisit;
//   String? totalVisits;
//   String? checkIn;
//   dynamic checkOut;

//   SalesmanINOUT({
//     this.customerId,
//     this.id,
//     this.fullname,
//     this.email,
//     this.mobileno,
//     this.imageUrl,
//     this.salesmanId,
//     this.individualVisit,
//     this.totalVisits,
//     this.checkIn,
//     this.checkOut,
//   });

//   SalesmanINOUT.fromJson(Map<String, dynamic> json) {
//     customerId = json['customer_id'];
//     id = json['id'];
//     fullname = json['fullname'];
//     email = json['email'];
//     mobileno = json['mobileno'];
//     imageUrl = json['image_url'];
//     salesmanId = json['salesman_id'];
//     individualVisit = json['individual_visit'];
//     totalVisits = json['total_visits'];
//     checkIn = json['check_in'];
//     checkOut = json['check_out'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['customer_id'] = customerId;
//     data['id'] = id;
//     data['fullname'] = fullname;
//     data['email'] = email;
//     data['mobileno'] = mobileno;
//     data['image_url'] = imageUrl;
//     data['salesman_id'] = salesmanId;
//     data['individual_visit'] = individualVisit;
//     data['total_visits'] = totalVisits;
//     data['check_in'] = checkIn;
//     data['check_out'] = checkOut;
//     return data;
//   }
// }

// class CategoryPerformance {
//   int? cid;
//   String? category;
//   double? actualProjection;
//   double? actualTarget;
//   String? actualSales;
//   List<dynamic>? salesman; 

//   CategoryPerformance({
//     this.cid,
//     this.category,
//     this.actualProjection,
//     this.actualTarget,
//     this.actualSales,
//     this.salesman,
//   });

//   CategoryPerformance.fromJson(Map<String, dynamic> json) {
//     cid = json['cid'];
//     category = json['category'];
//     actualProjection = json['actual_projection'] != null
//         ? double.tryParse(json['actual_projection'].toString())
//         : 0.0;
//     actualTarget = json['actual_target'] != null
//         ? double.tryParse(json['actual_target'].toString())
//         : 0.0;
//     actualSales = json['actual_sales'] != null
//         ? json['actual_sales'].toString()
//         : '0.0';
//     salesman = json['salesman'] != null ? List.from(json['salesman']) : [];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['cid'] = cid;
//     data['category'] = category;
//     data['actual_projection'] = actualProjection;
//     data['actual_target'] = actualTarget;
//     data['actual_sales'] = actualSales;
//     data['salesman'] = salesman;
//     return data;
//   }
// }

class PerformanceResponse {
  int? statusCode;
  bool? status;
  String? message;
  PerformanceData? data;

  PerformanceResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory PerformanceResponse.fromJson(Map<String, dynamic> json) => PerformanceResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: json["data"] != null ? PerformanceData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class PerformanceData {
  NavbarAndTargetContent? navbarAndTargetContent;
  List<CategoryPerformance>? categoryPerformance;
  List<String>? months;

  PerformanceData({
    this.navbarAndTargetContent,
    this.categoryPerformance,
    this.months,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) => PerformanceData(
        navbarAndTargetContent: json["navbar_and_target_content"] != null
            ? NavbarAndTargetContent.fromJson(json["navbar_and_target_content"])
            : null,
        categoryPerformance: json["category_performance"] != null
            ? List<CategoryPerformance>.from(
                json["category_performance"].map((x) => CategoryPerformance.fromJson(x)),
              )
            : [],
        months: json["months"] != null
            ? List<String>.from(json["months"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "navbar_and_target_content": navbarAndTargetContent?.toJson(),
        "category_performance": categoryPerformance != null
            ? List<dynamic>.from(categoryPerformance!.map((x) => x.toJson()))
            : [],
        "months": months != null ? List<dynamic>.from(months!.map((x) => x)) : [],
      };
}

class CategoryPerformance {
  int? cid;
  String? category;
  int? actualProjection;
  int? actualTarget;
  String? actualSales;
  List<dynamic>? salesman;

  CategoryPerformance({
    this.cid,
    this.category,
    this.actualProjection,
    this.actualTarget,
    this.actualSales,
    this.salesman,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) => CategoryPerformance(
        cid: json["cid"],
        category: json["category"],
        actualProjection: json["actual_projection"] ?? 0,
        actualTarget: json["actual_target"] ?? 0,
        actualSales: json["actual_sales"] ?? "0.0",
        salesman: json["salesman"] != null
            ? List<dynamic>.from(json["salesman"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "cid": cid,
        "category": category,
        "actual_projection": actualProjection,
        "actual_target": actualTarget,
        "actual_sales": actualSales,
        "salesman": salesman != null ? List<dynamic>.from(salesman!.map((x) => x)) : [],
      };
}

class NavbarAndTargetContent {
  int? id;
  int? companyId;
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
  DateTime? createAt;
  String? token;
  dynamic events;
  dynamic schedule;
  dynamic creditPoint;
  dynamic cancelEventReason;
  int? projectionPrice;
  int? projectionTarget;
  DateTime? lastOnline;
  int? status;
  int? customer;
  int? totalTarget;
  double? actual;
  int? timesheet;
  List<SalesmanInOut>? salesmanInOut;
  int? visit;

  NavbarAndTargetContent({
    this.id,
    this.companyId,
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
    this.status,
    this.customer,
    this.totalTarget,
    this.actual,
    this.timesheet,
    this.salesmanInOut,
    this.visit,
  });

  factory NavbarAndTargetContent.fromJson(Map<String, dynamic> json) => NavbarAndTargetContent(
        id: json["id"],
        companyId: json["company_id"],
        salesmanId: json["salesman_id"],
        fullname: json["fullname"],
        lastname: json["lastname"],
        department: json["department"],
        portfolio: json["portfolio"],
        mobileno: json["mobileno"],
        email: json["email"],
        password: json["password"],
        town: json["town"],
        state: json["state"],
        zipcode: json["zipcode"] ?? 0,
        address: json["address"],
        idimagePath: json["idimage_path"],
        imagePath: json["image_path"],
        createAt: json["create_at"] != null ? DateTime.tryParse(json["create_at"]) : null,
        token: json["token"],
        events: json["events"],
        schedule: json["schedule"],
        creditPoint: json["credit_point"],
        cancelEventReason: json["cancel_event_reason"],
        projectionPrice: json["projection_price"] ?? 0,
        projectionTarget: json["projection_target"] ?? 0,
        lastOnline: json["last_online"] != null ? DateTime.tryParse(json["last_online"]) : null,
        status: json["status"],
        customer: json["customer"] ?? 0,
        totalTarget: json["total_target"] ?? 0,
        actual: json["actual"] != null ? json["actual"].toDouble() : 0.0,
        timesheet: json["timesheet"] ?? 0,
        salesmanInOut: json["salesman_IN_OUT"] != null
            ? List<SalesmanInOut>.from(json["salesman_IN_OUT"].map((x) => SalesmanInOut.fromJson(x)))
            : [],
        visit: json["visit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "salesman_id": salesmanId,
        "fullname": fullname,
        "lastname": lastname,
        "department": department,
        "portfolio": portfolio,
        "mobileno": mobileno,
        "email": email,
        "password": password,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "address": address,
        "idimage_path": idimagePath,
        "image_path": imagePath,
        "create_at": createAt?.toIso8601String(),
        "token": token,
        "events": events,
        "schedule": schedule,
        "credit_point": creditPoint,
        "cancel_event_reason": cancelEventReason,
        "projection_price": projectionPrice,
        "projection_target": projectionTarget,
        "last_online": lastOnline?.toIso8601String(),
        "status": status,
        "customer": customer,
        "total_target": totalTarget,
        "actual": actual,
        "timesheet": timesheet,
        "salesman_IN_OUT": salesmanInOut != null
            ? List<dynamic>.from(salesmanInOut!.map((x) => x.toJson()))
            : [],
        "visit": visit,
      };
}

class SalesmanInOut {
  String? customerId;
  int? id;
  String? fullname;
  String? email;
  String? mobileno;
  String? imageUrl;
  String? salesmanId;
  int? individualVisit;
  String? totalVisits;
  DateTime? checkIn;
  dynamic checkOut;

  SalesmanInOut({
    this.customerId,
    this.id,
    this.fullname,
    this.email,
    this.mobileno,
    this.imageUrl,
    this.salesmanId,
    this.individualVisit,
    this.totalVisits,
    this.checkIn,
    this.checkOut,
  });

  factory SalesmanInOut.fromJson(Map<String, dynamic> json) => SalesmanInOut(
        customerId: json["customer_id"],
        id: json["id"],
        fullname: json["fullname"],
        email: json["email"],
        mobileno: json["mobileno"],
        imageUrl: json["image_url"],
        salesmanId: json["salesman_id"],
        individualVisit: json["individual_visit"] ?? 0,
        totalVisits: json["total_visits"] ?? "0",
        checkIn: json["check_in"] != null ? DateTime.tryParse(json["check_in"]) : null,
        checkOut: json["check_out"],
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "id": id,
        "fullname": fullname,
        "email": email,
        "mobileno": mobileno,
        "image_url": imageUrl,
        "salesman_id": salesmanId,
        "individual_visit": individualVisit,
        "total_visits": totalVisits,
        "check_in": checkIn?.toIso8601String(),
        "check_out": checkOut,
      };
}

