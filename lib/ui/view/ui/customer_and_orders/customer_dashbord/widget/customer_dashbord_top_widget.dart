// import 'package:busskit_salesexecutive/routes/routes.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
// import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CustomerDashbordTopWidget extends StatelessWidget {
//   final CustomerDashbordController customerDashbordController;
//   const CustomerDashbordTopWidget(
//       {super.key, required this.customerDashbordController});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         topHeadingRow(),
//         nkMediumSizeBox(),
//       ],
//     );
//   }

//   Widget topHeadingRow() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         InkResponse(
//             onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios)),
//         const Spacer(),
//         MyThemeButton(
//           buttonText: orderTaking,
//           onPressed: () {
//             customerDashbordController.customerAndOrderData.value.cart = null;
//             customerDashbordController
//                 .getCustomerCartData(customerDashbordController
//                     .customerAndOrderData.value.customerId!)
//                 .then((value) {
//               if (value.data != null && value.data!.isNotEmpty) {
//                 customerDashbordController.customerAndOrderData.value.cart =
//                     value.data?.first.cart;
//               }
//               Get.toNamed(AppRoutes.customerOrderDetails,
//                   arguments:
//                       customerDashbordController.customerAndOrderData.value);
//             });
//           },
//           height: 26,
//           width: AppDimensions.instance.width * 0.12,
//         ),
//         nkSmallSizeBox(width: 6),
//         topHeadingCustomerSection(
//             customerDashbordController.customerAndOrderData.value.imageUrl ??
//                 "",
//             customerDashbordController.customerAndOrderData.value.fullname
//                 .toString())
//       ],
//     );
//   }

//   Widget topHeadingCustomerSection(String imageUrl, String customerName,
//       {Function()? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Wrap(
//         direction: Axis.horizontal,
//         alignment: WrapAlignment.spaceAround,
//         crossAxisAlignment: WrapCrossAlignment.center,
//         spacing: 10,
//         children: [
//           Hero(
//             tag: imageUrl + customerName,
//             child: ClipOval(
//                 child: MyNetworkImage(
//               imageUrl: imageUrl,
//               height: AppDimensions.instance.height * 0.05,
//               width: AppDimensions.instance.height * 0.05,
//             )),
//           ),
//           MyRegularText(label: customerName),
//         ],
//       ),
//     );
//   }
// }
