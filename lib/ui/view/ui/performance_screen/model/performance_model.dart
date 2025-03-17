
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
  List<ValueTargetDatum>? valueTarget;
  List<String>? months;

  PerformanceData({
    this.navbarAndTargetContent,
    this.categoryPerformance,
    this.valueTarget,
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
        valueTarget: json["value_targetData"] != null
            ? List<ValueTargetDatum>.from(
                json["value_targetData"].map((x) => ValueTargetDatum.fromJson(x)),
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
        "value_targetData": valueTarget != null
            ? List<dynamic>.from(valueTarget!.map((x) => x.toJson()))
            : [],
        "months": months != null ? List<dynamic>.from(months!.map((x) => x)) : [],
      };
}
class ValueTargetDatum {
    ValueTargetDatum({
         this.id,
         this.target,
         this.projection,
         this.salesId,
         this.month,
         this.year,
         this.companyId,
    });
    final int? id;
    final int? target;
    final int? projection;
    final String? salesId;
    final String? month;
    final String? year;
    final int? companyId;

    factory ValueTargetDatum.fromJson(Map<String, dynamic> json){ 
        return ValueTargetDatum(
            id: json["id"],
            target: json["target"],
            projection: json["projection"],
            salesId: json["sales_id"],
            month: json["month"],
            year: json["year"],
            companyId: json["company_id"],
        );
    }
      Map<String, dynamic> toJson() => {
        "cid": id,
        "target": target,
        "projection": projection,
        "sales_id": salesId,
        "month": month,
        "year": year,
        "company_id":companyId,
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

class ScheduleListResponse {
  int? statusCode;
  bool? status;
  String? message;
  List<ScheduleListData>? data;

  ScheduleListResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory ScheduleListResponse.fromJson(Map<String, dynamic> json) =>
      ScheduleListResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<ScheduleListData>.from(
            json["data"].map((x) => ScheduleListData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ScheduleListData {
  String? customerId;
  String? salesmanId;
  DateTime? start;
  DateTime? end;
  dynamic checkIn;
  dynamic checkOut;
  int? count;
  List<ScheduleListCustomer>? customer;

  ScheduleListData({
    this.customerId,
    this.salesmanId,
    this.start,
    this.end,
    this.checkIn,
    this.checkOut,
    this.count,
    this.customer,
  });

  factory ScheduleListData.fromJson(Map<String, dynamic> json) =>
      ScheduleListData(
        customerId: json["customer_id"],
        salesmanId: json["salesman_id"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        checkIn: json["check_in"],
        checkOut: json["check_out"],
        count: json["count"],
        customer: List<ScheduleListCustomer>.from(
            json["customer"].map((x) => ScheduleListCustomer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "salesman_id": salesmanId,
        "start": start!.toIso8601String(),
        "end": end!.toIso8601String(),
        "check_in": checkIn,
        "check_out": checkOut,
        "count": count,
        "customer": List<dynamic>.from(customer!.map((x) => x.toJson())),
      };
}

class ScheduleListCustomer {
  String? businessName;

  ScheduleListCustomer({
    this.businessName,
  });

  factory ScheduleListCustomer.fromJson(Map<String, dynamic> json) =>
      ScheduleListCustomer(
        businessName: json["business_name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "business_name": businessName,
      };
}

//####################################### VALUE TARGET ###########################################
class SalesmanValueTargetResponse {
  bool success;
  List<SalesmanValueTargetData> data;

  SalesmanValueTargetResponse({
    required this.success,
    required this.data,
  });

  factory SalesmanValueTargetResponse.fromJson(Map<String, dynamic> json) =>
      SalesmanValueTargetResponse(
        success: json["success"],
        data: List<SalesmanValueTargetData>.from(
            json["data"].map((x) => SalesmanValueTargetData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SalesmanValueTargetData {
  int? id;
  int? target;
  int? projection;
  String? salesId;
  String? month;
  String? year;
  int? companyId;
  WeeklyTargetProjection? weeklyTargetProjection;
  String? actualTotal;
  String? orderTotal;

  SalesmanValueTargetData({
    required this.id,
    required this.target,
    required this.projection,
    required this.salesId,
    required this.month,
    required this.year,
    required this.companyId,
    required this.weeklyTargetProjection,
    required this.actualTotal,
    required this.orderTotal,
  });

  factory SalesmanValueTargetData.fromJson(Map<String, dynamic> json) =>
      SalesmanValueTargetData(
        id: json["id"],
        target: json["target"],
        projection: json["projection"],
        salesId: json["sales_id"],
        month: json["month"],
        year: json["year"],
        companyId: json["company_id"],
        weeklyTargetProjection: json["weekly_target_projection"] != null
            ? WeeklyTargetProjection.fromJson(json["weekly_target_projection"])
            : null,
        actualTotal: json["actual_total"].toString(),
        orderTotal: json["order_total"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "target": target,
        "projection": projection,
        "sales_id": salesId,
        "month": month,
        "year": year,
        "company_id": companyId,
        "weekly_target_projection": weeklyTargetProjection?.toJson(),
        "actual_total": actualTotal,
        "order_total": orderTotal,
      };
}

class WeeklyTargetProjection {
  Map<String, WeekData>? weeks;

  WeeklyTargetProjection({required this.weeks});

  factory WeeklyTargetProjection.fromJson(Map<String, dynamic> json) {
    Map<String, WeekData> parsedWeeks = {};

    json.forEach((key, value) {
      parsedWeeks[key] = WeekData.fromJson(key, value);
    });

    return WeeklyTargetProjection(weeks: parsedWeeks);
  }

  Map<String, dynamic> toJson() => {
        for (var entry in weeks!.entries) entry.key: entry.value.toJson(),
      };
}

class WeekData {
  int? value;
  int? projection;

  WeekData({
    required this.value,
    required this.projection,
  });

  factory WeekData.fromJson(String key, Map<String, dynamic> json) {
    return WeekData(
      value: json[key] ?? 0,
      projection: json["${key}_projection"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "value": value,
        "projection": projection,
      };
}

class StaffTimesheetResponse {
  int? statusCode;
  bool? status;
  String? message;
  Map<String, StaffTimesheetData>? data;

  StaffTimesheetResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory StaffTimesheetResponse.fromJson(Map<String, dynamic> json) =>
      StaffTimesheetResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: Map.from(json["data"]).map((k, v) =>
            MapEntry<String, StaffTimesheetData>(
                k, StaffTimesheetData.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": Map.from(data!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class StaffTimesheetData {
  String? checkIn;
  String? checkOut;

  StaffTimesheetData({
    this.checkIn,
    this.checkOut,
  });

  factory StaffTimesheetData.fromJson(Map<String, dynamic> json) =>
      StaffTimesheetData(
        checkIn: json["check_in"],
        checkOut: json["check_out"],
      );

  Map<String, dynamic> toJson() => {
        "check_in": checkIn,
        "check_out": checkOut,
      };
}