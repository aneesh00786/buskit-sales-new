// import 'dart:developer';

// import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
// import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_pie_chart.dart';
// import 'package:busskit_salesexecutive/ui/components/bar_and_chart/order_delevery_pie_chart.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/model/dashboard_response.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DashboardBottomWidget extends StatelessWidget {
//   final DashBoardController dashBoardController;
//   const DashboardBottomWidget({super.key, required this.dashBoardController});

//   @override
//   Widget build(BuildContext context) {
//     return

//     Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Flexible(child: bottomLeftSideComponent())
//             ,
//             nkSmallSizeBox(),
//             Flexible(child: communicationsDisplayWidget())

//           ],
//         )


//       ;
//   }

//   Widget bottomLeftSideComponent() {
//     return MyCommnonContainer(
//       height: AppDimensions.instance.height * 0.45,
//       color: buttonTextColor,
//       isCommonBorder: true,
//       padding: nkRegularPadding(),

//       child: Row(
//         children: [
//           Flexible(child: collectionChart()),
//           Flexible(child: orderDeliveryChart())
//         ],
//       ),
//     )


//       ;
//   }

//   Widget collectionChart() {
//     return MyCommnonContainer(
//       padding: nkSymmetricPadding(),
//       color: buttonTextColor,
//       isCommonBorder: false,
//       width: double.maxFinite,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           middleWidgetHeading(collection),
//           Obx(() {
//             return CollectionPieChart(
//               collectionData:
//                   dashBoardController.dashbordData.value.collection ??
//                       Collection(),
//             );
//           }),
//           nkMediumSizeBox()
//         ],
//       ),
//     );
//   }

//   Widget orderDeliveryChart() {
//    // log("${dashBoardController.dashbordData.value.delivery?.order?.percentage.toString()}");
//     return MyCommnonContainer(
//       color: buttonTextColor,
//       padding: nkSymmetricPadding(),
//       isCommonBorder: false,
//       width: double.maxFinite,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           middleWidgetHeading(orderDelivery),
//           Obx(() {
//             return OrderDeleveryPieChart(
//               deleveryData:
//                   dashBoardController.dashbordData.value.delivery ?? Delivery(),
//             );
            
//           }),
//            nkMediumSizeBox()
//         ],
//       ),
//     );
    
//   }

//   Widget middleWidgetHeading(String text) {
//     return MyRegularText(
//         label: text,
//         fontWeight: FontWeight.w500,
//         color: secondaryTextColor);
//   }

//   Widget communicationsDisplayWidget() {
//     return MyCommnonContainer(
//       isCommonBorder: true,
//       //padding: nkRegularPadding(),
//       color: buttonTextColor,
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 middleWidgetHeading(notifications),
//                 nkSmallSizeBox(),
//                 for (int i = 0; i < dashBoardController.communicationList.length; i++) ...[
//                   communicationsDisplayListWidget(
//                       dashBoardController.communicationList[i], i),
//                   nkSmallSizeBox()
//                 ],
//                 const Spacer(),
//               ],
//             ),
//           ),
//               sendReplay()
//         ],
//       ),
//       height: AppDimensions.instance.height * 0.45,

//     );
//   }

//   Widget sendReplay() {
//     double iconSize = 24.0;
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           Icon(
//             Icons.person,
//             color: primaryColor,
//             size: iconSize,
//           ),
//           nkSmallSizeBox(),
//           Flexible(
//               child: MyFormField(
//             controller: dashBoardController.communicationController,
//             labelText: 'Message..',
//             enableColor: primaryTextFieldColor,
//             focusedColor: primaryTextFieldColor,
//             disabledColor: primaryTextFieldColor,
//             maxLines: 1,
//           )),
//           nkSmallSizeBox(),
//           Icon(
//             Icons.camera_alt_outlined,
//             color: primaryColor,
//             size: iconSize,
//           ),
//           nkSmallSizeBox(),
//           InkResponse(
//             onTap: () {
//               if (dashBoardController.selectedCommunicationIndex.value == -1) {
//                 NkCommonFunction.showErrorToast(pleaseSelectAUserToSend);
//                 return;
//               }
//               if (dashBoardController.communicationController.text.isEmpty) {
//                 NkCommonFunction.showErrorToast(pleaseEnterMessage);
//                 return;
//               }
//               dashBoardController.communicationController.clear();
//             },
//             child: Icon(
//               Icons.send,
//               color: primaryColor,
//               size: iconSize,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget communicationsDisplayListWidget(Map<String, dynamic> data, int index) {
//     return Obx(
//       () => MyCommnonContainer(
//         color: buttonTextColor,
//         padding: dashBoardController.selectedCommunicationIndex.value == index
//             ? nkSmallPadding()
//             : null,
//         onTap: () {
//           dashBoardController.selectedCommunicationIndex.value = index;
//         },
//         isCommonBorder:
//             dashBoardController.selectedCommunicationIndex.value == index,
//         child: Row(
//           children: [
//             ClipOval(
//                 child: MyNetworkImage(
//               imageUrl: data["image"],
//               withoutBaseUrl: true,
//               height: AppDimensions.instance.height * 0.05,
//               width: AppDimensions.instance.height * 0.05,
//             )),
//             nkSmallSizeBox(),
//             Flexible(
//               child: Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MyRegularText(label: data["name"],  ),
//                       MyRegularText(
//                         label: data["message"],
                  
//                         color: primaryColor,
//                         align: TextAlign.start,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
