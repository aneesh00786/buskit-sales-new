// import 'dart:developer';
// import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
// import 'package:busskit_salesexecutive/generated/assets.dart';
// import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
// import 'package:busskit_salesexecutive/routes/routes.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/top_shortcusts_diloag/order_status_diloag.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/week_picker.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
// import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';

// class CustomerAndOrdersMiddelWidget extends StatefulWidget {
//   final CustomerAndOrderController custAndOrdController;
//   final LeadsController leadsController;

//   const CustomerAndOrdersMiddelWidget(
//       {super.key,
//       required this.custAndOrdController,
//       required this.leadsController});

//   @override
//   State<CustomerAndOrdersMiddelWidget> createState() =>
//       _CustomerAndOrdersMiddelWidgetState();
// }

// class _CustomerAndOrdersMiddelWidgetState
//     extends State<CustomerAndOrdersMiddelWidget> {


//   String dropdownvalue = '2024';

//   // List of items in our dropdown menu
//   var items = [
//     '2024',
//     '2023',
//     '2022',
//     '2021',
//     '2020',
//   ];

//   bool showvalue=false;

//   @override
//   Widget build(BuildContext context) {
//     return
      
//       Obx(() {
//       return NkWidgetExceptionHandel(
//         onRetryPressed: () => widget.custAndOrdController.loadCustomer,
//         data: widget.custAndOrdController.customerAndOrderList,
//         child:  _buildDataTableHeader,
//           // Flexible(child: orderBottomTableWidget)





//       );
//     });








//     ;
//   }

//   Widget get _buildDataTableHeader =>  Container(

//         child: DataTable(
//           // horizontalMargin:(MediaQuery.of(context).orientation == Orientation.portrait)? 5:5,
//           // columnSpacing:(MediaQuery.of(context).orientation == Orientation.portrait)? 12 :5,
//             headingRowColor:
//             MaterialStateColor.resolveWith((states) => primaryColor),

//             headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
//                 color: buttonTextColor,
//                 fontSize: NkFontSize.smallFont(),
//                 fontWeight: FontWeight.bold),
//             dataRowMaxHeight: ResponsiveInfo.isMobileDimension(context)?75:100,
//             columnSpacing: ResponsiveInfo.isMobileDimension(context)?0.5:1,
//             checkboxHorizontalMargin: 1,
//             horizontalMargin:  ResponsiveInfo.isMobileDimension(context)?0.5:1,
//             columns: widget.custAndOrdController.coustomerTabelsHeadersList
//                 .map((element) => DataColumn(
//                 label: MyRegularText(
//                   label: element,
//                   maxlines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   color: buttonTextColor,
//                   fontSize: ResponsiveInfo.isMobileDimension(context)?6:13,
//                 )))
//                 .toList(),
//             rows: genratedRows),
//         width: double.infinity,

//       );

//   // Widget get leadBottomTabelWidget => SingleChildScrollView(
//   //     child:
//   //
//   //     SingleChildScrollView(
//   //
//   //
//   //
//   //       child:  Theme(
//   //         data: Get.theme.copyWith(
//   //           highlightColor: Colors.transparent,
//   //           hoverColor: Colors.transparent,
//   //           splashColor: Colors.transparent,
//   //           splashFactory: NoSplash.splashFactory,
//   //         ),
//   //         child:  DataTable(
//   //           headingRowHeight: 0,
//   //           // clipBehavior: Clip.antiAlias,
//   //           dataRowMaxHeight: 130,
//   //           headingRowColor:
//   //           MaterialStateColor.resolveWith((states) => primaryColor),
//   //           columns: leadBottomTabelColumnsWidget,
//   //           rows: genratedRows,
//   //         ),
//   //
//   //       ),
//   //
//   //
//   //
//   //
//   //       scrollDirection: Axis.vertical,
//   //     ),
//   //
//   //
//   //
//   //     scrollDirection: Axis.horizontal
//   // );

//   List<DataColumn> get leadBottomTabelColumnsWidget =>
//       widget.custAndOrdController.coustomerTabelsHeadersList
//           .map((element) => DataColumn(
//                   label: MyRegularText(
//                 label: element,
//                 color: buttonTextColor,
//               )))
//           .toList();

//   List<DataRow> get genratedRows =>
//       widget.custAndOrdController.customerAndOrderList
//           .map(
//             (e) => DataRow(
//               cells: List.generate(
//                 rowsWidget(
//                         e,
//                         widget.custAndOrdController.customerAndOrderList
//                             .indexOf(e))
//                     .length,
//                 (index) => DataCell(rowsWidget(e, index)[index]),
//               ),
//             ),
//           )
//           .toList();

//   List<Widget> rowsWidget(CustomerAndOrderData leadCustomerData, int index) => [
//  ResponsiveInfo.isMobileDimension(context)?customerDetailsWidgetFormobile(leadCustomerData): customerDetailsWidget(leadCustomerData),
//     Container(
//       width: (MediaQuery.of(context).orientation == Orientation.portrait) ?(ResponsiveInfo.isMobileDimension(context)?45:60) : (ResponsiveInfo.isMobileDimension(context)?75:90),
//       height: (MediaQuery.of(context).orientation == Orientation.portrait) ?(ResponsiveInfo.isMobileDimension(context)?90:110) : (ResponsiveInfo.isMobileDimension(context)?110:130),

//       child: Column(

//         children: [

//           DropdownButton(

//             value: dropdownvalue,

//             icon: const Icon(Icons.keyboard_arrow_down),

//             // Array list of items
//             items: items.map((String items) {
//               return DropdownMenuItem(
//                 value: items,
//                 child: Text(items,maxLines: 1,style: TextStyle(fontFamily: 'Poppins_Regular',fontSize:(MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?5:13 ) :(ResponsiveInfo.isMobileDimension(context)?10:13 )    ),),
//               );
//             }).toList(),
//             // After selecting the desired option,it will
//             // change button value to selected value
//             onChanged: (String? newValue) {
//               setState(() {
//                 dropdownvalue = newValue!;
//               });
//             },
//           ),

//           MyRegularText(
//             label: '\$556.00',
//             color: primaryColor,
//             maxlines: 1,
//             overflow: TextOverflow.ellipsis,
//           )




//         ],
//       ),






//     )

//     ,
//         customerTotalSalesWidget(leadCustomerData),
//         customerSalesWidget(leadCustomerData),
//         customerDeliveryWidget(leadCustomerData),
//         customerPaymentWidget(leadCustomerData),
//         customerEstimatesWidget(leadCustomerData),
//         customerPreOrderWidget(leadCustomerData),
//     //     customerDraftsWidget(leadCustomerData),
//     //
//     // //
//     //  showCheckBox(),
//     //
//     //     /* customerCancelledWidget(leadCustomerData),*/
//     //     customerVisitWidget(leadCustomerData),
//       ];



//   Widget showCheckBox()
//   {
//     return MediaQuery.removePadding(context: context, child: Transform.scale(
//       scale: ResponsiveInfo.isMobileDimension(context)? 0.3:0.7,
//       child:Checkbox(
//         value: this.showvalue,

//         onChanged: (bool? value) {
//           setState(() {
//             this.showvalue = value!;
//           });
//         },
//       ) ,

//     )

//     ,removeTop: true,removeRight: true,removeLeft: true,removeBottom: true,)

//       ;
//   }








//   Widget editOrDeleteWidget(CustomerAndOrderData leadCustomerData, int index) {
//     return Container(

//         height: ResponsiveInfo.isMobileDimension(context)?50:60,

//         child: Wrap(
//           spacing: 18,
//           children: [
//             InkResponse(
//                 onTap: () => {
//                   Get.dialog<LeadCustomerData>(AddLeadsDiloag(
//                     leadsController: widget.leadsController,
//                     leadCustomerData: LeadCustomerData(
//                       customerId: leadCustomerData.customerId!,
//                       oldImageUrl: leadCustomerData.imageUrl,
//                       fullname: leadCustomerData.fullname!,
//                       mobileno: leadCustomerData.mobileno!,
//                       email: leadCustomerData.email!,
//                       imageUrl: leadCustomerData.imageUrl!,
//                       id: leadCustomerData.id!,
//                       address: leadCustomerData.address!,
//                       town: leadCustomerData.town!,
//                       state: leadCustomerData.state!,
//                       businessName: leadCustomerData.businessName!,
//                       businessNo: leadCustomerData.businessNo!,
//                       remark: leadCustomerData.remark!,
//                       salesmanId: leadCustomerData.salesmanId!,
//                       salesmanName: leadCustomerData.salesmanName!,
//                       zipcode: leadCustomerData.zipcode!,
//                       status: leadCustomerData.status!,
//                     ),
//                     isUpdate: true,
//                   )).then((value) {
//                     if (value != null) {
//                       leadCustomerData.address = value.address;
//                       leadCustomerData.town = value.town;
//                       leadCustomerData.state = value.state;
//                       leadCustomerData.zipcode = value.zipcode;
//                       leadCustomerData.businessName = value.businessName;
//                       leadCustomerData.businessNo = value.businessNo;
//                       leadCustomerData.remark = value.remark;
//                       leadCustomerData.salesmanId = value.salesmanId;
//                       leadCustomerData.salesmanName = value.salesmanName;
//                       leadCustomerData.status = value.status;
//                       leadCustomerData.imageUrl = value.imageUrl;
//                       leadCustomerData.fullname = value.fullname;
//                       leadCustomerData.mobileno = value.mobileno;
//                       leadCustomerData.email = value.email;
//                       leadCustomerData.id = value.id;
//                     }
//                     log("Calll back Data ${value.toString()}");
//                   })
//                 },
//                 child: SvgPicture.asset(Assets.iconsIcEdit,width: ResponsiveInfo.isMobileDimension(context)? 6:15,height: ResponsiveInfo.isMobileDimension(context)? 6:15)),
//             InkResponse(
//                 onTap: () {
//                   // NkCommonFunction.showDeleteSnakBar(
//                   //   onYesPressed: () {
//                   //     Get.back();
//                   //     widget.custAndOrdController
//                   //         .deleteCustomer(leadCustomerData.customerId!, index);
//                   //   },
//                   // );
//                 },
//                 child: SvgPicture.asset(Assets.iconsIcDelete,width:ResponsiveInfo.isMobileDimension(context)? 6:15,height: ResponsiveInfo.isMobileDimension(context)? 6:15,)),
//           ],
//         ));
//   }

//   Widget customerDetailsWidget(CustomerAndOrderData leadCustomerData) {
//     return Container(

//         height: ResponsiveInfo.isMobile()?70:100,


//         child: GestureDetector(
//           onTap: () =>
//               Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData)
//                   ?.then((value) async {
//                 leadCustomerData = await widget.custAndOrdController
//                     .loadSelectedCustomer(leadCustomerData.customerId!);
//               }),
//           child: Container(

//             height: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?70 :100) : (ResponsiveInfo.isMobileDimension(context)?90 :120) ,

//               child: Row(
// mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(padding: EdgeInsets.all(4),

//                 child: CircleAvatar(
//                   radius:(MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?6 :16) : (ResponsiveInfo.isMobileDimension(context)?13 :22) ,
//              // Image radius
//                   backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHdLZAJzeEA2iYjsrN4CEXrg8ATQ1tB04blQ&usqp=CAU'),
//                 ) ,
//                 )

//                ,
//             Container(
//               width: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?70 :100) : (ResponsiveInfo.isMobileDimension(context)?90 :120) ,

//                 child:  Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       MyRegularText(
//                         align: TextAlign.start,
//                         label: leadCustomerData
//                             .fullname ??
//                             '',
//                         fontWeight: NkGeneralSize.nkBoldFontWeight(),
//                         fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?8 :12) : (ResponsiveInfo.isMobileDimension(context)?10 :17) ,

//                         maxlines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       MyRegularText(
//                         align: TextAlign.start,
//                         label: leadCustomerData.mobileno ?? '',
//                         fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?11 :13) : (ResponsiveInfo.isMobileDimension(context)?13 :16) ,

//                         maxlines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                      Text(leadCustomerData.email.toString(),
//                         style: TextStyle(fontSize:(MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?11 :13) : (ResponsiveInfo.isMobileDimension(context)?13 :16) ,overflow: TextOverflow.ellipsis ),maxLines: 1,overflow: TextOverflow.ellipsis,),

//                       // editOrDeleteWidget(leadCustomerData,0),



//                     ])),
//               ],
//             )



//           ),
//         ));
//   }

//   Widget customerDetailsWidgetFormobile(CustomerAndOrderData leadCustomerData) {
//     return  GestureDetector(
//           onTap: () =>
//               Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData)
//                   ?.then((value) async {
//                 leadCustomerData = await widget.custAndOrdController
//                     .loadSelectedCustomer(leadCustomerData.customerId!);
//               }),
//           child: Container(
//             width:(MediaQuery.of(context).orientation == Orientation.portrait) ?30:80,

//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(child: Padding(padding: EdgeInsets.all(1),

//                     child: CircleAvatar(
//                       radius:(MediaQuery.of(context).orientation == Orientation.portrait) ? 6 :13, // Image radius
//                       backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHdLZAJzeEA2iYjsrN4CEXrg8ATQ1tB04blQ&usqp=CAU'),
//                     ) ,
//                   ),flex: 1,)



//                   ,
//                   Expanded(child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         MyRegularText(
//                           align: TextAlign.start,
//                           label: leadCustomerData
//                               .fullname??
//                               '',
//                           fontWeight: NkGeneralSize.nkBoldFontWeight(),
//                           fontSize:(MediaQuery.of(context).orientation == Orientation.portrait) ? 6 :12,
//                           maxlines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         MyRegularText(
//                           align: TextAlign.start,
//                           label: leadCustomerData.mobileno ?? '',
//                           fontSize:(MediaQuery.of(context).orientation == Orientation.portrait) ? 5:13,
//                           maxlines: 1,

//                           overflow: TextOverflow.ellipsis,
//                         ),




//                         Text(leadCustomerData.email.toString(),style: TextStyle(fontSize:(MediaQuery.of(context).orientation == Orientation.portrait) ?5:10,overflow: TextOverflow.ellipsis ),maxLines: 1,overflow: TextOverflow.ellipsis,),

//                         // editOrDeleteWidget(leadCustomerData,0),



//                       ]),flex: 2)


//                   ,
//                 ],
//               )



//           ),
//         );
//   }

//   Widget customerTotalSalesWidget(CustomerAndOrderData leadCustomerData) {
//     return         commonViewOfCustomerDetails(
//       /*  onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),*/
//         leadCustomerData.totalSales.toString().nkValueWithCurrencySymbol,
//         onTap: () {
//           if (leadCustomerData.totalSales == 0) {
//             // NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//             return;
//           } else {
//             Get.dialog(OrderStatusDiloag(
//               orderStatus: OrderStatus.preOrder,
//               heading: widget.custAndOrdController.coustomerTabelsHeadersList[2],
//               userType: UserType.customer,
//               userId: leadCustomerData.customerId!,
//             ));
//           }
//         });
//   }

//   Widget customerSalesWidget(
//     CustomerAndOrderData leadCustomerData,
//   ) {
//     return commonViewOfCustomerDetails(leadCustomerData.sales.toString(),
//         /*  onTap: () => Get.toNamed(AppRoutes.customerDashbord,
//             arguments: leadCustomerData),*/
//         isTotalValueShow: true,
//         totalValue: leadCustomerData.totalSales
//             .toString()
//             .nkValueWithCurrencySymbol, onTap: () {
//       if (leadCustomerData.sales == 0) {
//        // NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           orderStatus: OrderStatus.outOfDelivery,
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[3],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
//   }

//   Widget customerDeliveryWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(leadCustomerData.delivery.toString(),
//         /*onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),*/
//         onTap: () {
//       if (leadCustomerData.delivery == 0) {
//       //  NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           orderStatus: OrderStatus.delivered,
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[4],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
//   }

//   Widget customerPaymentWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(leadCustomerData.payment.toString(),
//         /* onTap: () => Get.toNamed(AppRoutes.customerDashbord,
//             arguments: leadCustomerData),*/
//         isTotalValueShow: true,
//         totalValue: leadCustomerData.payment
//             .toString()
//             .nkValueWithCurrencySymbol, onTap: () {
//       if (leadCustomerData.payment == 0) {
//        // NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[5],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
//   }

//   Widget customerEstimatesWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(
//         (leadCustomerData.estimates ?? "0").toString(),
//         /*onTap: () => Get.toNamed(AppRoutes.customerDashbord,
//             arguments: leadCustomerData),*/
//         isTotalValueShow: true,
//         totalValue: (leadCustomerData.estimates ?? "0")
//             .toString()
//             .nkValueWithCurrencySymbol, onTap: () {
//       if (leadCustomerData.estimates == 0) {
//        // NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[6],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
//   }

//   Widget customerPreOrderWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(leadCustomerData.preOrder.toString(),
//         /*onTap: () => Get.toNamed(AppRoutes.customerDashbord,
//             arguments: leadCustomerData),*/

//         isTotalValueShow: true,
//         totalValue: leadCustomerData.totalSales
//             .toString()
//             .nkValueWithCurrencySymbol, onTap: () {
//       if (leadCustomerData.totalSales == -1) {
//    //     NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           orderStatus: OrderStatus.preOrder,
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[7],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
//   }

//   Widget customerDraftsWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(
//       leadCustomerData.drafts?.toString() ?? "0",
//       /*  onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),*/
//       onTap: () {
//         if (leadCustomerData.drafts == -1 || leadCustomerData.drafts == null) {
//       //    NkCommonFunction.showSimpleToast(thereAreNoDraftOrdersNow);
//           return;
//         } else {
//           Get.dialog(OrderStatusDiloag(
//             orderStatus: OrderStatus.draft,
//             heading: widget.custAndOrdController.coustomerTabelsHeadersList[8],
//             userType: UserType.customer,
//             userId: leadCustomerData.customerId!,
//           ));
//         }
//       },
//     );
//   }

//   /*Widget customerCancelledWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(
//       leadCustomerData.cancelled.toString(),
//       onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),
//     );
//   }*/

//   Widget customerVisitWidget(CustomerAndOrderData leadCustomerData) {
//     return visitWidgetDropDown(leadCustomerData);
//   }

//   Widget visitWidgetDropDown(CustomerAndOrderData leadCustomerData) {
//     return Container(
//         width: (ResponsiveInfo.isMobileDimension(context))? 15: 67,
//         height: ResponsiveInfo.isMobile()?100:150,

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             nkMediumSizeBox(),
//             MyPopUpMenu<int>(
//                 items: List.generate(
//                     widget.custAndOrdController.visitTypeList.length,
//                         (index) => PopupMenuItem<int>(
//                       value: index,
//                       onTap: () {
//                         if (index == 2 || index == 3) {
//                           Get.defaultDialog(
//                               barrierDismissible: false,
//                               content: WeekPicker(
//                                 onChanged: (p0, selectedWeek) {
//                                   leadCustomerData.selectedWeekDay =
//                                       selectedWeek;
//                                 },
//                               ),
//                               title: "Select Week",
//                               cancel: TextButton(
//                                   onPressed: () {
//                                     leadCustomerData.selectedWeekDay.clear();
//                                     Get.back();
//                                   },
//                                   child: MyRegularText(
//                                     label: "Cancel",
//                                     color: errorColor,
//                                     fontSize:  ResponsiveInfo.isMobile()?10:13,
//                                   )),
//                               confirm: TextButton(
//                                   onPressed: () async {
//                                     if (leadCustomerData
//                                         .selectedWeekDay.isNotEmpty) {
//                                       setState(() {
//                                         leadCustomerData.visitType = index;
//                                       });
//                                       await widget.custAndOrdController
//                                           .assignCustomerVisit(
//                                           leadCustomerData.customerId!,
//                                           leadCustomerData.fullname!,
//                                           leadCustomerData.visitType
//                                               .toString(),
//                                           selectedWeekDay: leadCustomerData
//                                               .selectedWeekDay)
//                                           .whenComplete(() {
//                                         Get.back();
//                                       });
//                                     }
//                                   },
//                                   child: MyRegularText(
//                                     label: "Done",
//                                     fontSize: ResponsiveInfo.isMobile()?12:15,
//                                   )));
//                         } /* else if (index == 4) {
//                           showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime.now(),
//                                   lastDate: DateTime.now()
//                                       .add(const Duration(days: 365 * 2)))
//                               .then((value) async {
//                             if (value != null) {
//                               setState(() {
//                                 leadCustomerData.visitType = index;
//                               });
//                               await widget.custAndOrdController
//                                   .assignCustomerVisit(
//                                       leadCustomerData.customerId!,
//                                       leadCustomerData.fullname!,
//                                       leadCustomerData.visitType.toString(),
//                                       selectedWeekDay:
//                                           leadCustomerData.selectedWeekDay)
//                                   .whenComplete(() {
//                                 Get.back();
//                               });
//                             }
//                           });
//                         }*/
//                       },
//                       child: MyCommnonContainer(
//                         color: Colors.transparent,
//                         child: MyRegularText(
//                           label:
//                           widget.custAndOrdController.visitTypeList[index],
//                           fontSize:  ResponsiveInfo.isMobile()?10:13,
//                         ),
//                       ),
//                     )).toList(),
//                 onItemSelected: (value) {
//                   setState(() {
//                     if (value == 1 || value == 5 || value == 4) {
//                       leadCustomerData.visitType = value;
//                       widget.custAndOrdController.assignCustomerVisit(
//                           leadCustomerData.customerId!,
//                           leadCustomerData.fullname!,
//                           leadCustomerData.visitType.toString(),
//                           selectedWeekDay: leadCustomerData.selectedWeekDay);
//                     }
//                   });

//                   /*  leadCustomerData.visitType.obs.value =
//                   widget.custAndOrdController.updateVisitType(value);
//               widget.custAndOrdController.update([leadCustomerData]);*/
//                 },
//                 buttonChild: MyCommnonContainer(
//                   padding: nkRegularPadding(),
//                   width: ResponsiveInfo.isMobileDimension(context)?75:120,
//                   color: secondaryColor,
//                   child: MyRegularText(
//                     label: widget.custAndOrdController
//                         .visitType(leadCustomerData.visitType ?? -1),
//                   ),
//                 )),
//           ],
//         ));
//   }

//   Widget commonViewOfCustomerDetails(String label,
//       {Function()? onTap, bool isTotalValueShow = false, String? totalValue}) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           nkMediumSizeBox(),
//           MyCommnonContainer(
//             onTap: onTap,
//             color: Colors.transparent,


//             padding: nkRegularPadding(),
//             child: MyRegularText(
//               label: label,
//               maxlines: 1,
//               fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?7:11) :(ResponsiveInfo.isMobileDimension(context)?10:13),
//               overflow: TextOverflow.ellipsis,
//               color: primaryColor,
//             ),
//           ),
//           nkSmallSizeBox(),
//           isTotalValueShow
//               ?  MyCommnonContainer(
//               onTap: onTap,
// color: Colors.transparent,

//               padding: nkRegularPadding(),
//               child:MyRegularText(
//                 label: totalValue ?? '',
//                 color: primaryColor,
//                 fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? (ResponsiveInfo.isMobileDimension(context)?7:11) :(ResponsiveInfo.isMobileDimension(context)?10:13)  ,
//                 maxlines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ))
//               : nkChildWrappedSizeBox()
//         ],
//       )



//       ;
//   }
// }
