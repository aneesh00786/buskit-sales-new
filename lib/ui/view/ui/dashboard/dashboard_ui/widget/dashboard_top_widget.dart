// import 'dart:developer';

// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/range_selector.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
// import 'package:flutter/material.dart';

// import '../../dashboard_controller.dart';

// class DashboardTopWidget extends StatefulWidget {
//   final DashBoardController dashBoardController;
//   const DashboardTopWidget({Key? key, required this.dashBoardController})
//       : super(key: key);

//   @override
//   State<DashboardTopWidget> createState() => _DashboardTopWidgetState();
// }

// class _DashboardTopWidgetState extends State<DashboardTopWidget> {
//   String? startDate;
//   String? endDate;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         calender(today),
//         /*RangeSelector(
//           onChanged:
//               (selectedIndex, (DateTime? startDate, DateTime? endDate) label) {
//             widget.dashBoardController
//                 .updateCustomerVisitScheduleSet(label.$1, label.$2);
//             */ /*customerAndOrderController.updateCustomerVisitScheduleSet(
//                 label.$1, label.$2);*/ /*
//             //customerAndOrderController.updateCustomerVisitScheduleSet(label);
//           },
//         ),*/
//         nkMediumSizeBox(),

//         Container(
//           //color: Colors.amber,
//           width: double.infinity,
//           child: SingleChildScrollView(
          
//             child:         OptionWidget(
//               customType: "",
//               customOrderStatusType: OrderStatus.preOrder,
//               draftCount: widget.dashBoardController.dashbordData.value
//                   .orderCountList?.draftOrder ??
//                   0,
//               orderCount: widget.dashBoardController.dashbordData.value
//                   .orderCountList?.totalOrder ??
//                   0,
//               preOrderCount: widget.dashBoardController.dashbordData.value
//                   .orderCountList?.preorderOrder ??
//                   0,
//               estimatesCount: widget.dashBoardController.dashbordData.value
//                   .orderCountList?.estimateOrder ??
//                   0,
//               userType: UserType.salesman,
//               userId: SessionHelper.loginSavedData?.salesmanId??'',
//               startDate: startDate,
//               endDate: endDate,
//             ),
          
//             scrollDirection: Axis.horizontal,
//           ),
//         )



//         /* calender(today),
//         nkMediumSizeBox(),
//         OptionWidget(
//           userType: UserType.salesman,
//           userId: SessionHelper.loginSavedData!.salesmanId!,
//         ),*/
//       ],
//     );
//   }

// /*  Widget calender(String calender) {
//     return RangeSelector(
//       onChanged:
//           (selectedIndex, (DateTime? startDate, DateTime? endDate) label) {
//         widget.dashBoardController
//             .updateCustomerVisitScheduleSet(label.$1, label.$2);
//         //customerAndOrderController.updateCustomerVisitScheduleSet(label);
//       },
//     );
//   }*/
//   Widget calender(String calender) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Flexible(
//           child: RangeSelector(
//             onChanged: (selectedIndex,
//                 (DateTime? startDateN, DateTime? endDateN) label) {
//               widget.dashBoardController
//                   .updateCustomerVisitScheduleSet(label.$1, label.$2);
//               log('selected index ${selectedIndex}');
//               if (selectedIndex == 0) {
//                 startDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.todayDate.$1);
//                 endDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.todayDate.$2);
//               } else if (selectedIndex == 1) {
//                 startDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.yesterdayDate.$1);
//                 endDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.yesterdayDate.$2);
//               } else if (selectedIndex == 2) {
//                 startDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.thisWeekDate.$1);
//                 endDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.thisWeekDate.$2);
//               } else if (selectedIndex == 3) {
//                 startDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.thisMonthDate.$1);
//                 log('3333startDate++++ +++ ++ ${startDate}');
//                 endDate =
//                     NKDateUtils.apiDayFormat(NkCommonFunction.thisMonthDate.$2);
//               } else if (selectedIndex == 4) {
//                 startDate = NKDateUtils.apiDayFormat(label.$1!);
//                 // NKDateUtils.apiDayFormat(NkCommonFunction.thisYear.$1);

//                 endDate = NKDateUtils.apiDayFormat(label.$2!);
//                 log('startDate++++ +++ ++ ${startDate} : ${label.$2!}');
//                 // NKDateUtils.apiDayFormat(NkCommonFunction.thisYear.$2);
//                 log('startDateasa++++ +++ ++ ${endDate}');
//               }
//               log('start+++Date++++ +++ ++ ${label.$1} ${label.$2}');
//               widget.dashBoardController
//                   .updateCustomerVisitScheduleSet(label.$1, label.$2);
//               //customerAndOrderController.updateCustomerVisitScheduleSet(label);
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
