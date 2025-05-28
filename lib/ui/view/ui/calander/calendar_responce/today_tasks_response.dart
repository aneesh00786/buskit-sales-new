import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';

// class TodayTasksResponse {
//   int? statusCode;
//   bool? status;
//   String? message;
//   List<TodayTasksData>? data;

//   TodayTasksResponse({
//     this.statusCode,
//     this.status,
//     this.message,
//     this.data,
//   });

//   TodayTasksResponse.fromJson(Map<String, dynamic> json) {
//     statusCode = json['status_code'] as int?;
//     status = json['status'] as bool?;
//     message = json['message'] as String?;
//     data = (json['data'] as List?)
//         ?.map((dynamic e) => TodayTasksData.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = <String, dynamic>{};
//     json['status_code'] = statusCode;
//     json['status'] = status;
//     json['message'] = message;
//     json['data'] = data?.map((e) => e.toJson()).toList();
//     return json;
//   }
// }

// class TodayTasksData {
//   int? id;
//   String? eventId;
//   String? customerId;
//   String? salesmanId;
//   String? title;
//   String? start;
//   String? end;
//   int? type;
//   dynamic eventCancel;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   List<CustomerDetails>? customer;

//   TodayTasksData({
//     this.id,
//     this.eventId,
//     this.customerId,
//     this.salesmanId,
//     this.title,
//     this.start,
//     this.end,
//     this.type,
//     this.eventCancel,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.customer,
//   });

//   TodayTasksData.fromJson(Map<String, dynamic> json) {
//     id = json['id'] as int?;
//     eventId = json['event_id'] as String?;
//     customerId = json['customer_id'] as String?;
//     salesmanId = json['salesman_id'] as String?;
//     title = json['title'] as String?;
//     start = json['start'] as String?;
//     end = json['end'] as String?;
//     type = json['type'] as int?;
//     eventCancel = json['event_cancel'];
//     status = json['status'] as int?;
//     createdAt = json['created_at'] as String?;
//     updatedAt = json['updated_at'] as String?;
//     customer = (json['customer'] as List?)
//         ?.map(
//             (dynamic e) => CustomerDetails.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = <String, dynamic>{};
//     json['id'] = id;
//     json['event_id'] = eventId;
//     json['customer_id'] = customerId;
//     json['salesman_id'] = salesmanId;
//     json['title'] = title;
//     json['start'] = start;
//     json['end'] = end;
//     json['type'] = type;
//     json['event_cancel'] = eventCancel;
//     json['status'] = status;
//     json['created_at'] = createdAt;
//     json['updated_at'] = updatedAt;
//     json['customer'] = customer?.map((e) => e.toJson()).toList();
//     return json;
//   }
// }
