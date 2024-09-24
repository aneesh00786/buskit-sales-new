// import 'dart:developer';

// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/common/search_model.dart';
// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/today_tasks_response.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/model/dashboard_response.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class DashBoardController extends GetxController {
//   RxDouble totalRevenue = 0.20.obs;
//   RxString revenueAmount = "107,431".obs;

//   RxInt currentStep = 0.obs;

//   TextEditingController communicationController = TextEditingController();
//   RxInt selectedCommunicationIndex = (-1).obs;

//   RxList<TodayTasksData> todayTasks = <TodayTasksData>[].obs;

//   Rx<DateTime> selectedRevanueDate = DateTime.now().obs;

//   Rx<Data> dashbordData = Data().obs;

//   SearchModel searchModel = SearchModel();

//   RxList<Map<String, dynamic>> communicationList = [
//     {
//       "image":
//           "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
//       "name": "Andre Harmon",
//       "message":
//           "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
//     },
//     {
//       "image":
//           "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
//       "name": "Andre Harmon",
//       "message":
//           "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
//     },
//     {
//       "image":
//           "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
//       "name": "Andre Harmon",
//       "message":
//           "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
//     },
//     {
//       "image":
//           "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
//       "name": "Andre Harmon",
//       "message":
//           "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
//     },
//     {
//       "image":
//           "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
//       "name": "Andre Harmon",
//       "message":
//           "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
//     },
//   ].obs;
//   // ignore: unused_field
//   final ApiWorker _apiWorker = ApiWorker();

//   get loadTodayTasks async {
//     final sendData = {
//       'salesman_id': SessionHelper.loginSavedData?.salesmanId,
//     };
//     final data = await _apiWorker.getTodaySchedule(sendData);
//     todayTasks.assignAll(data.data ?? []);
//     refresh();
//   }

//   // List<CalenderData> calenderDataList = [];
//   // Future<void> calenderAllEvents() async {
//   //   final sendData = {
//   //     'salesman_id': SessionHelper.loginSavedData!.salesmanId,
//   //   };
//   //   _apiWorker.getTodaySchedule(sendData).then((value) {
//   //     calenderDataList = value.data!;
//   //     log("calenderAllEvents ${calenderDataList.length}");
//   //     loadCalenderEvent_v1(calenderDataList);
//   //     // loadCalenderEvent(value);
//   //   });
//   // }

//   updateRavanueDate(DateTime date) {
//     selectedRevanueDate.value = date;
//     refresh();
//   }

//   get loadDahsbordData async {
//     var data = await _apiWorker.dashboardData(
//         searchModel, SessionHelper.loginSavedData?.salesmanId??'');

//     //log("API DASHBORD DATA IS ${data.toJson()}");
//     dashbordData = data.data?.obs??Rx(Data());
//     log("Loded  DASHBORD DATA IS ${dashbordData.value.toJson()}");
//     refresh();
//   }

//   updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
//     if (startDate != null && endDate != null) {
//       searchModel.startDate = NKDateUtils.apiDayFormat(startDate);
//       searchModel.endDate = NKDateUtils.apiDayFormat(endDate);
//       loadDahsbordData;
//     } else {
//       searchModel.startDate = "";
//       searchModel.endDate = "";
//       loadDahsbordData;
//     }
//     refresh();
//   }

//   List<CartesianSeries<Month, String>> getDashbordData(
//       List<CategoryPerformance> categoryData) {
//     return [
//       for (var item in categoryData) ...[
//         StackedLine100Series<Month, String>(
//             dataSource: item.month,
//             xValueMapper: (Month sales, _) => NKDateUtils.months[_],
//             yValueMapper: (Month sales, _) => sales.totalCount,
//             name: item.category,
//             markerSettings: const MarkerSettings(isVisible: true))
//       ]
//     ];
//   }
// }
