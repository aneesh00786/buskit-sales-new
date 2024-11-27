// import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_pie_chart.dart';
// import 'package:busskit_salesexecutive/ui/components/bar_and_chart/order_delevery_pie_chart.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart'; 
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path/path.dart';

// class DashboardBottomWidget extends StatelessWidget {
//   final DashBoardController dashBoardController;

//   const DashboardBottomWidget({super.key, required this.dashBoardController});

//   @override
//   Widget build(BuildContext context) {
//     return bottomLeftSideComponent(context);
//   }

//   Widget bottomLeftSideComponent(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Flexible(child: collectionChart(context)),
//         nkSmallSizeBox(),
//         Flexible(child: orderDeliveryChart(context))
//       ],
//     );
//   }

//   Widget collectionChart(BuildContext context) {
//     return MyCommnonContainer(
//       height: MediaQuery.of(context).size.height * 0.3,
//       padding: nkSymmetricPadding(),
//       isCommonBorder: true,
//       width: double.maxFinite,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           middleWidgetHeading(collection),
//           nkSmallSizeBox(),
//           Obx(() {
//             return CollectionPieChart(
//               collectionData:
//                   dashBoardController.dashbordData.value.collection as Collection(),
//             );
//           }),
//           //    nkMediumSizeBox()
//         ],
//       ),
//     );
//   }

//   Widget orderDeliveryChart(BuildContext context) {
//     return MyCommnonContainer(
//       height: MediaQuery.of(context).size.height * 0.3,
//       padding: nkSymmetricPadding(),
//       isCommonBorder: true,
//       width: double.maxFinite,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           middleWidgetHeading(orderDelivery),
//           nkSmallSizeBox(),
//           Obx(() {
//             return OrderDeleveryPieChart(
//               deleveryData:
//                   dashBoardController.dashbordData.value.delivery as Delivery(),
//             );
//           }),
//           //   nkMediumSizeBox()
//         ],
//       ),
//     );
//   }

//   Widget middleWidgetHeading(String text) {
//     return MyRegularText(
//         label: text,
//         fontSize: NkFontSize.largeFont(),
//         fontWeight: FontWeight.w500,
//         color: secondaryTextColor);
//   }
// }
