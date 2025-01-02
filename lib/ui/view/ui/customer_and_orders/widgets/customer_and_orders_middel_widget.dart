// import 'dart:developer';

// import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
// import 'package:busskit_salesexecutive/generated/assets.dart';
// import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
// import 'package:busskit_salesexecutive/routes/routes.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/top_shortcusts_diloag/order_status_diloag.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/week_picker.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
// import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';

// import '../../leads/leads_controller.dart';
// import '../../leads/leads_responce/lead_responce.dart';

// class CustomerAndOrdersMiddelWidget extends StatefulWidget {
//   final CustomerAndOrderController custAndOrdController;
//   final LeadsController leadsController;
//   BuildContext context;

//   CustomerAndOrdersMiddelWidget(
//       {super.key,
//       required this.custAndOrdController,
//       required this.leadsController,
//       required this.context});

//   @override
//   State<CustomerAndOrdersMiddelWidget> createState() =>
//       _CustomerAndOrdersMiddelWidgetState();
// }

// class _CustomerAndOrdersMiddelWidgetState
//     extends State<CustomerAndOrdersMiddelWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return NkWidgetExceptionHandel(
//           onRetryPressed: () => widget.custAndOrdController.loadCustomer,
//           data: widget.custAndOrdController.customerAndOrderList,
//           child: Column(children: [
//             // _buildDataTableHeader

//             Stack(
//               children: [
//                 Align(
//                   alignment: FractionalOffset.topCenter,
//                   child: Container(
//                     width: double.infinity,
//                     height: (MediaQuery.of(context).orientation ==
//                             Orientation.portrait)
//                         ? (ResponsiveInfo.isMobileDimension(context) ? 50 : 65)
//                         : (ResponsiveInfo.isMobileDimension(context) ? 70 : 80),
//                     color: Color(0xff727df5),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Customer",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 2,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Edit",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Total Sales",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Sales",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Delivery",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Payment",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Estimates",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Pre-Order",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Drafts",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         ),
//                         Expanded(
//                           child: Padding(
//                             child: Text(
//                               "Visits",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   fontSize:
//                                       (MediaQuery.of(context).orientation ==
//                                               Orientation.portrait)
//                                           ? (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 3
//                                               : 6)
//                                           : (ResponsiveInfo.isMobileDimension(
//                                                   context)
//                                               ? 6
//                                               : 10),
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins_Regular',
//                                   fontWeight: FontWeight.bold),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             padding: EdgeInsets.all(2),
//                           ),
//                           flex: 1,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: FractionalOffset.topCenter,
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(
//                         0,
//                         (MediaQuery.of(context).orientation ==
//                                 Orientation.portrait)
//                             ? (ResponsiveInfo.isMobileDimension(context)
//                                 ? 60
//                                 : 75)
//                             : (ResponsiveInfo.isMobileDimension(context)
//                                 ? 75
//                                 : 80),
//                         0,
//                         0),
//                     child: ListView.builder(
//                         itemCount: widget
//                             .custAndOrdController.customerAndOrderList.length,
//                         primary: false,
//                         shrinkWrap: true,
//                         itemBuilder: (BuildContext context, int index) {
//                           CustomerAndOrderData leadCustomerData = widget
//                               .custAndOrdController.customerAndOrderList[index];
//                           return Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                   child:
//                                       customerDetailsWidget(leadCustomerData),
//                                   flex: 2),
//                               Expanded(
//                                   child: editOrDeleteWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child: customerTotalSalesWidget(
//                                       leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child: customerSalesWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child:
//                                       customerDeliveryWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child:
//                                       customerPaymentWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child:
//                                       customerEstimatesWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                   child:
//                                       customerPreOrderWidget(leadCustomerData),
//                                   flex: 1),
//                               Expanded(
//                                 child: customerDraftsWidget(leadCustomerData),
//                                 flex: 1,
//                               ),
//                               //customerCancelledWidget(leadCustomerData),
//                               Expanded(
//                                   child: customerVisitWidget(leadCustomerData),
//                                   flex: 1)
//                             ],
//                           );
//                         }),
//                   ),
//                 )
//               ],
//             )

//             // leadBottomTabelWidget,
//           ]));
//     });
//   }

//   Widget get _buildDataTableHeader => DataTable(
//       horizontalMargin: 10,
//       columnSpacing: 40.0,
//       headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor),
//       headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
//           color: buttonTextColor,
//           fontSize: NkFontSize.largeFont(),
//           fontWeight: FontWeight.bold),
//       // dataRowMaxHeight: AppDimensions.instance!.height * 0.11,
//       columns: widget.custAndOrdController.coustomerTabelsHeadersList
//           .map((element) => DataColumn(
//                   label: MyRegularText(
//                 label: element,
//                 color: buttonTextColor,
//               )))
//           .toList(),
//       rows: []);

//   Widget get leadBottomTabelWidget => SingleChildScrollView(
//         child: Theme(
//           data: Get.theme.copyWith(
//             highlightColor: Colors.transparent,
//             hoverColor: Colors.transparent,
//             splashColor: Colors.transparent,
//             splashFactory: NoSplash.splashFactory,
//           ),
//           child: DataTable(
//             headingRowHeight: 0,
//             // clipBehavior: Clip.antiAlias,
//             dataRowMaxHeight: 50,
//             headingRowColor:
//                 MaterialStateColor.resolveWith((states) => primaryColor),
//             columns: leadBottomTabelColumnsWidget,
//             rows: genratedRows,
//           ),
//         ),
//       );

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

//   // List<DataRow> get genratedRows =>
//   //     widget.custAndOrdController.customerAndOrderList
//   //         .map((e) => DataRow(
//   //         cells: List.generate(
//   //             rowsWidget(e).length,
//   //                 (index) => DataCell(
//   //               rowsWidget(e)[index],
//   //             ))))
//   //         .toList();
//   List<Widget> rowsWidget(CustomerAndOrderData leadCustomerData, int index) => [
//         Expanded(child: customerDetailsWidget(leadCustomerData), flex: 1),
//         Expanded(child: editOrDeleteWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerTotalSalesWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerSalesWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerDeliveryWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerPaymentWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerEstimatesWidget(leadCustomerData), flex: 1),
//         Expanded(child: customerPreOrderWidget(leadCustomerData), flex: 1),
//         Expanded(
//           child: customerDraftsWidget(leadCustomerData),
//           flex: 1,
//         ),
//         //customerCancelledWidget(leadCustomerData),
//         Expanded(child: customerVisitWidget(leadCustomerData), flex: 1),
//       ];

//   Widget customerDetailsWidget(CustomerAndOrderData leadCustomerData) {
//     return GestureDetector(
//       onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData)
//               ?.then((value) async {
//         leadCustomerData = await widget.custAndOrdController
//             .loadSelectedCustomer(leadCustomerData.customerId!);
//       }),
//       child: nkChildWrappedSizeBox(
//         width: AppDimensions.instance!.width * 0.1,
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               MyRegularText(
//                 maxlines: 2,
//                 align: TextAlign.start,
//                 fontSize:
//                     (MediaQuery.of(context).orientation == Orientation.portrait)
//                         ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                         : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//                 label: leadCustomerData
//                         .fullname?.nkStringCapitalizeFirstCaracter ??
//                     '',
//                 fontWeight: NkGeneralSize.nkBoldFontWeight(),
//               ),
//               MyRegularText(
//                 align: TextAlign.start,
//                 label: leadCustomerData.mobileno ?? '',
//                 fontSize:
//                     (MediaQuery.of(context).orientation == Orientation.portrait)
//                         ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                         : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//               ),
//               Flexible(
//                 child: MyRegularText(
//                   align: TextAlign.start,
//                   // maxlines: leadCustomerData.email?.length,
//                   label: leadCustomerData.email ?? '',
//                   fontSize: (MediaQuery.of(context).orientation ==
//                           Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//                 ),
//               ),
//             ]),
//       ),
//     );
//   }

//   Widget editOrDeleteWidget(CustomerAndOrderData leadCustomerData) {
//     return Wrap(
//       spacing: 18,
//       children: [
//         InkResponse(
//             onTap: () => {
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
//             child: SvgPicture.asset(
//               Assets.iconsIcEdit,
//               height:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 13 : 16)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 16 : 20),
//               width:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 13 : 16)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 16 : 20),
//             )),
//       ],
//     );
//   }

//   /* Widget customerTotalSalesWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(
//       onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),
//       leadCustomerData.totalSales.toString().nkValueWithCurrencySymbol,
//     );
//   }*/
//   Widget customerTotalSalesWidget(CustomerAndOrderData leadCustomerData) {
//     return commonViewOfCustomerDetails(
//         /*  onTap: () =>
//           Get.toNamed(AppRoutes.customerDashbord, arguments: leadCustomerData),*/
//         leadCustomerData.totalSales.toString().nkValueWithCurrencySymbol,
//         onTap: () {
//       if (leadCustomerData.totalSales == 0) {
//         NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
//         return;
//       } else {
//         Get.dialog(OrderStatusDiloag(
//           orderStatus: OrderStatus.preOrder,
//           heading: widget.custAndOrdController.coustomerTabelsHeadersList[2],
//           userType: UserType.customer,
//           userId: leadCustomerData.customerId!,
//         ));
//       }
//     });
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
//         NkCommonFunction.showSimpleToast("${thereAreNoOrdersNow}");
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
//         NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
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
//         NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
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
//         NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
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
//         NkCommonFunction.showSimpleToast(thereAreNoOrdersNow);
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
//           NkCommonFunction.showSimpleToast(thereAreNoDraftOrdersNow);
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

//   Widget customerVisitWidget(CustomerAndOrderData leadCustomerData) {
//     return visitWidgetDropDown(leadCustomerData);
//   }

//   Widget visitWidgetDropDown(CustomerAndOrderData leadCustomerData) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         nkMediumSizeBox(),
//         MyPopUpMenu<int>(
//             items: List.generate(
//                 widget.custAndOrdController.visitTypeList.length,
//                 (index) => PopupMenuItem<int>(
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
//                                     fontSize: NkFontSize.largeFont(),
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
//                                               leadCustomerData.customerId!,
//                                               leadCustomerData.fullname!,
//                                               leadCustomerData.visitType
//                                                   .toString(),
//                                               selectedWeekDay: leadCustomerData
//                                                   .selectedWeekDay)
//                                           .whenComplete(() {
//                                         Get.back();
//                                       });
//                                     }
//                                   },
//                                   child: MyRegularText(
//                                     label: "Done",
//                                     fontSize: NkFontSize.largeFont(),
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
//                               widget.custAndOrdController.visitTypeList[index],
//                           fontSize: (MediaQuery.of(context).orientation ==
//                                   Orientation.portrait)
//                               ? (ResponsiveInfo.isMobileDimension(context)
//                                   ? 3
//                                   : 6)
//                               : (ResponsiveInfo.isMobileDimension(context)
//                                   ? 6
//                                   : 10),
//                         ),
//                       ),
//                     )).toList(),
//             onItemSelected: (value) {
//               setState(() {
//                 if (value == 1 || value == 5 || value == 4) {
//                   leadCustomerData.visitType = value;
//                   widget.custAndOrdController.assignCustomerVisit(
//                       leadCustomerData.customerId!,
//                       leadCustomerData.fullname!,
//                       leadCustomerData.visitType.toString(),
//                       selectedWeekDay: leadCustomerData.selectedWeekDay);
//                 }
//               });

//               /*  leadCustomerData.visitType.obs.value =
//                   widget.custAndOrdController.updateVisitType(value);
//               widget.custAndOrdController.update([leadCustomerData]);*/
//             },
//             buttonChild: MyCommnonContainer(
//               padding: nkRegularPadding(),
//               color: secondaryColor,
//               child: MyRegularText(
//                 label: widget.custAndOrdController
//                     .visitType(leadCustomerData.visitType ?? -1),
//                 fontSize:
//                     (MediaQuery.of(context).orientation == Orientation.portrait)
//                         ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                         : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//               ),
//             )),
//       ],
//     );
//   }

//   // Widget customerSalesWidget(
//   Widget commonViewOfCustomerDetails(String label,
//       {Function()? onTap, bool isTotalValueShow = false, String? totalValue}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         nkMediumSizeBox(),
//         MyCommnonContainer(
//           onTap: onTap,
//           color: secondaryColor,
//           padding: nkRegularPadding(),
//           child: MyRegularText(
//             label: label,
//             color: primaryColor,
//             fontSize:
//                 (MediaQuery.of(context).orientation == Orientation.portrait)
//                     ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                     : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//           ),
//         ),
//         nkSmallSizeBox(),
//         isTotalValueShow
//             ? MyRegularText(
//                 label: totalValue ?? '',
//                 color: primaryColor,
//                 fontSize:
//                     (MediaQuery.of(context).orientation == Orientation.portrait)
//                         ? (ResponsiveInfo.isMobileDimension(context) ? 3 : 6)
//                         : (ResponsiveInfo.isMobileDimension(context) ? 6 : 10),
//               )
//             : nkChildWrappedSizeBox()
//       ],
//     );
//   }
// }
