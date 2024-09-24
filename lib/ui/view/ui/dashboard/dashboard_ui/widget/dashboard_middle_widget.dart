// import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
// import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
// import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/map/location_permission.dart';
// import 'package:busskit_salesexecutive/ui/components/stepper/nk_stepper.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_selecteble_text.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/today_tasks_response.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';

// class DashBoardMiddleWidget extends StatelessWidget {
//   final DashBoardController dashBoardController;
//   BuildContext context;

//    DashBoardMiddleWidget({Key? key, required this.dashBoardController,required this.context})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return  Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(child: middleTopLeftComponet())
//           ,
//           nkSmallSizeBox(),

//           Flexible(child: middleRightComponet(context))

//         ],
//       )


//       ;
//   }

//   Widget middleTopLeftComponet() {
//     return MyCommnonContainer(
//         // height: AppDimensions.instance!.height*1.2 ,
//         color: buttonTextColor,
//         height: AppDimensions.instance.height * 0.45,
//         isCommonBorder: true,
//         padding: nkRegularPadding(),
//         child: SingleChildScrollView(

//           child:
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
                  
//                   Flexible(
//                     child: MyRegularText(
//                         label: projectionsVsActual.toUpperCase(),
//                         fontWeight: NkGeneralSize.nkBoldFontWeight(),

//                         color: secondaryTextColor),
//                   ),
//                   const Icon(Icons.menu)
//                 ],
//               ),
//               nkMediumSizeBox(height: AppDimensions.instance.height*0.1),
//               Obx(() {
//                 return StackedLine100Chart(
//                   series: dashBoardController.getDashbordData(dashBoardController
//                       .dashbordData.value.categoryPerformance ??
//                       []),
//                 );
//                 /* return BarChartSample2(
//                     categoryData: dashBoardController
//                             .dashbordData.value.categoryPerformance ??
//                         [],
//                   );*/
//               })
//             ],
//           ) ,
//           scrollDirection: Axis.vertical,
//         )


//         );
//   }

//   Widget middleWidgetHeading(String text) {
//     return MyRegularText(
//         label: text,
//         align: TextAlign.start,
//         fontSize: (MediaQuery.of(
//             context)
//             .orientation ==
//             Orientation
//                 .portrait)
//             ? (ResponsiveInfo
//             .isMobileDimension(
//             context)
//             ? 3
//             : 6)
//             : (ResponsiveInfo
//             .isMobileDimension(
//             context)
//             ? 6
//             : 10),
//         fontWeight: FontWeight.w500,
//         color: secondaryTextColor);
//   }

//   Widget middleRightComponet(BuildContext context) {
//     return MyCommnonContainer(
//          height: AppDimensions.instance.height *0.45,
//           color: buttonTextColor,

//         isCommonBorder: true,
//         padding: nkRegularPadding(),
//         child: revenueDiplayWidget(context)


//         // Row(
//         //   crossAxisAlignment: CrossAxisAlignment.start,
//         //   children: [
//         //     Flexible(child: revenueDiplayWidget(context)),
//         //
//         //     //Flexible(child: communicationsDisplayWidget()),
//         //   ],
//         // )


//     );
//   }

//   Widget revenueDiplayWidget(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             middleWidgetHeading("${today}’s ${routesString}"),

//             Padding(

//                 padding: EdgeInsets.all((MediaQuery.of(
//                     context)
//                     .orientation ==
//                     Orientation
//                         .portrait)
//                     ? (ResponsiveInfo
//                     .isMobileDimension(
//                     context)
//                     ? 2
//                     : 3)
//                     : (ResponsiveInfo
//                     .isMobileDimension(
//                     context)
//                     ? 4
//                     : 6)),

//                 child:  Container(

//                   width: (MediaQuery.of(
//                       context)
//                       .orientation ==
//                       Orientation
//                           .portrait)
//                       ? (ResponsiveInfo
//                       .isMobileDimension(
//                       context)
//                       ? 40
//                       : 60)
//                       : (ResponsiveInfo
//                       .isMobileDimension(
//                       context)
//                       ? 60
//                       : 70),
//                   height:(MediaQuery.of(
//                       context)
//                       .orientation ==
//                       Orientation
//                           .portrait)
//                       ? (ResponsiveInfo
//                       .isMobileDimension(
//                       context)
//                       ? 30
//                       : 45)
//                       : (ResponsiveInfo
//                       .isMobileDimension(
//                       context)
//                       ? 45
//                       : 50),

//                   decoration: BoxDecoration(
//                     color: Color(0xff747ced),
//                     borderRadius: BorderRadius.circular(ResponsiveInfo.isMobileDimension(context)?5:7),
//                   ),

//                   child:  TextButton(

//                     child:       Text(
//                       "Map",
//                       textAlign: TextAlign.start,
//                       style: TextStyle(
//                           fontSize: (MediaQuery.of(
//                               context)
//                               .orientation ==
//                               Orientation
//                                   .portrait)
//                               ? (ResponsiveInfo
//                               .isMobileDimension(
//                               context)
//                               ? 4
//                               : 7)
//                               : (ResponsiveInfo
//                               .isMobileDimension(
//                               context)
//                               ? 7
//                               : 11),
//                           color: Colors.white,
//                           fontFamily:
//                           'Poppins_Regular'),
//                       maxLines: 1,
//                       overflow:
//                       TextOverflow.ellipsis,
//                     ),
//                     onPressed: ()async{

//                       if (await AccesLocation.locationPermission == false) {
//                         NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
//                         return;
//                       }
//                       try {
//                         Position position = await Geolocator.getCurrentPosition(
//                           desiredAccuracy: LocationAccuracy.high,
//                         );
//                         NkCommonFunction.openMap(
//                             position.latitude, position.longitude);
//                       } catch (e) {
//                         NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
//                         print("Error getting location: $e");
//                       }
//                     },
//                   ),







//                   // MyThemeButton(
//                   //   buttonText: go,
//                   //   onPressed: () {
//                   //     widget.onChanged?.call(
//                   //         selectedIndex,
//                   //         FilterDateEnum.values[selectedIndex].selectDateRange(context,
//                   //             endDate: selectedEndDate, startDate: selectedStartDate));
//                   //   },
//                   // ),
//                 ))


//             // MyThemeButton(
//             //   //height: 20,
//             //   buttonText: mapStr,
//             //   onPressed: () async {
//             //     if (await AccesLocation.locationPermission == false) {
//             //       NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
//             //       return;
//             //     }
//             //     try {
//             //       Position position = await Geolocator.getCurrentPosition(
//             //         desiredAccuracy: LocationAccuracy.high,
//             //       );
//             //       NkCommonFunction.openMap(
//             //           position.latitude, position.longitude);
//             //     } catch (e) {
//             //       NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
//             //       print("Error getting location: $e");
//             //     }
//             //     // Get.toNamed(AppRoutes.mapScreen);
//             //   },
//             // )
//           ],
//         ),
//         Obx(() {
//           return Flexible(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // AppDimensions.instance!.orientation == Orientation.landscape
//                 //     ? Flexible(
//                 //         child: CalendarDatePicker(
//                 //             currentDate: DateTime.now(),
//                 //             initialDate: DateTime.now(),
//                 //             firstDate: DateTime.now(),
//                 //             lastDate:
//                 //                 DateTime.now().add(const Duration(days: 365)),
//                 //             onDateChanged: (DateTime date) {}),
//                 //       )
//                 //     :


//                 Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Padding(

//                               padding: EdgeInsets.all((MediaQuery.of(
//                                   context)
//                                   .orientation ==
//                                   Orientation
//                                       .portrait)
//                                   ? (ResponsiveInfo
//                                   .isMobileDimension(
//                                   context)
//                                   ? 2
//                                   : 3)
//                                   : (ResponsiveInfo
//                                   .isMobileDimension(
//                                   context)
//                                   ? 4
//                                   : 6)),

//                               child:  Container(

//                                 width: (MediaQuery.of(
//                                     context)
//                                     .orientation ==
//                                     Orientation
//                                         .portrait)
//                                     ? (ResponsiveInfo
//                                     .isMobileDimension(
//                                     context)
//                                     ? 40
//                                     : 60)
//                                     : (ResponsiveInfo
//                                     .isMobileDimension(
//                                     context)
//                                     ? 60
//                                     : 70),
//                                 height:(MediaQuery.of(
//                                     context)
//                                     .orientation ==
//                                     Orientation
//                                         .portrait)
//                                     ? (ResponsiveInfo
//                                     .isMobileDimension(
//                                     context)
//                                     ? 30
//                                     : 45)
//                                     : (ResponsiveInfo
//                                     .isMobileDimension(
//                                     context)
//                                     ? 45
//                                     : 50),

//                                 decoration: BoxDecoration(
//                                   color: Color(0xff747ced),
//                                   borderRadius: BorderRadius.circular(ResponsiveInfo.isMobileDimension(context)?5:7),
//                                 ),

//                                 child:  GestureDetector(

//                                   child: Icon(Icons.date_range,size: ResponsiveInfo.isMobile()? 10:15,color: Colors.white,),
//                                   onTap: (){

//                                     showDatePicker(
//                                         context: context,
//                                         initialDate: dashBoardController
//                                             .selectedRevanueDate.value,
//                                         firstDate: DateTime.now(),
//                                         lastDate: DateTime.now()
//                                             .add(const Duration(days: 365)))
//                                         .then((value) {
//                                       if (value != null) {
//                                         dashBoardController.updateRavanueDate(value);
//                                       }
//                                     });
//                                   },

//                                 )







//                                 // MyThemeButton(
//                                 //   buttonText: go,
//                                 //   onPressed: () {
//                                 //     widget.onChanged?.call(
//                                 //         selectedIndex,
//                                 //         FilterDateEnum.values[selectedIndex].selectDateRange(context,
//                                 //             endDate: selectedEndDate, startDate: selectedStartDate));
//                                 //   },
//                                 // ),
//                               )),
//                           // MyThemeButton(
//                           //   width: ,
//                           //   buttonText: '',
//                           //   onPressed: () {
//                           //     showDatePicker(
//                           //             context: context,
//                           //             initialDate: dashBoardController
//                           //                 .selectedRevanueDate.value,
//                           //             firstDate: DateTime.now(),
//                           //             lastDate: DateTime.now()
//                           //                 .add(const Duration(days: 365)))
//                           //         .then((value) {
//                           //       if (value != null) {
//                           //         dashBoardController.updateRavanueDate(value);
//                           //       }
//                           //     });
//                           //   },
//                           //   child: const Icon(
//                           //     Icons.calendar_month,
//                           //     color: secondaryIconColor,
//                           //     size: 20,
//                           //   ),
//                           // ),
//                           nkMediumSizeBox(),
//                           MyRegularText(
//                             align: TextAlign.start,
//                             label:
//                                 'Selected Date \n${NKDateUtils.apiDayFormat(dashBoardController.selectedRevanueDate.value)}',
//                             fontSize: (MediaQuery.of(
//                                 context)
//                                 .orientation ==
//                                 Orientation
//                                     .portrait)
//                                 ? (ResponsiveInfo
//                                 .isMobileDimension(
//                                 context)
//                                 ? 3
//                                 : 6)
//                                 : (ResponsiveInfo
//                                 .isMobileDimension(
//                                 context)
//                                 ? 6
//                                 : 10),
//                           )
//                         ],
//                       ),
//                 nkMediumSizeBox(),
//                 NkWidgetExceptionHandel(
//                   isShowRetrySection: false,
//                   data: dashBoardController.todayTasks,
//                   child: Flexible(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Flexible(
//                             child:
//                                 middleWidgetHeading("$today's $routesString")),
//                         MyRegularText(
//                           label:
//                               "$totalString ${dashBoardController.todayTasks.length} $stops",
//                           fontWeight: NkGeneralSize.nkBoldFontWeight(),
//                           fontSize:(MediaQuery.of(
//                               context)
//                               .orientation ==
//                               Orientation
//                                   .portrait)
//                               ? (ResponsiveInfo
//                               .isMobileDimension(
//                               context)
//                               ? 3
//                               : 6)
//                               : (ResponsiveInfo
//                               .isMobileDimension(
//                               context)
//                               ? 6
//                               : 10),
//                         ),
//                         //nkMediumSizeBox(),
//                         Obx(
//                           () =>  NkStepper(
//                               stepsData: dashBoardController.todayTasks
//                                   .map((element) => Step(
//                                       title: todaysTasksStepperTitleWidget(
//                                           element),
//                                       content: todaysTasksStepperContentWidget(
//                                           element)))
//                                   .toList(),
//                               onStepTapped: (p0) {
//                                 dashBoardController.currentStep.call(p0);
//                               },
//                               currentStep:
//                                   dashBoardController.currentStep.value,
//                             ),

//                         ),

//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         })
//       ],
//     );
//   }

//   Widget todaysTasksStepperTitleWidget(TodayTasksData element) {
//     return MyRegularText(
//       label: element.customer?.first.fullname ?? '',
//       fontWeight: NkGeneralSize.nkBoldFontWeight(),
//     );
//   }

//   Widget todaysTasksStepperContentWidget(TodayTasksData element) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         MyRegularSelectableText(
//           align: TextAlign.start,
//           label: "$address- ${element.customer?.first.address?.trim() ?? ''}",
//         ),
//         const Divider(
//           color: skyBlueColor,
//         ),
//         MyRegularSelectableText(
//           align: TextAlign.start,
//           label: "$contactNumber- ${element.customer?.first.mobileno ?? ''}",
//         ),
//       ],
//     );
//   }
// }
