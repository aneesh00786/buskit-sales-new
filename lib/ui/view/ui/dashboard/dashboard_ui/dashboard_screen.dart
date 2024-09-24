// import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/widget/dashboard_bottom_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/widget/dashboard_middle_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/widget/dashboard_top_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../home/home_controller.dart';

// class DashBoardScreen extends StatefulWidget {
//   final HomeController homeController;

//   const DashBoardScreen({Key? key, 
//   required this.homeController
//   })
//       : super(key: key);

//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   DashBoardController controller = Get.put(DashBoardController());

//   @override
//   void initState() {
//     controller.loadTodayTasks;
//     controller.loadDahsbordData;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         AppDimensions.instance.height;
//         AppDimensions.instance.width;
//       });
//     });
//     return Scaffold(
//         body:
//            SafeArea(
//             minimum: nkRegularPadding(),
//             child:SingleChildScrollView
//               (
//               child:  Column(
//                 children: [
//                   DashboardTopWidget(dashBoardController: controller),
//                   nkMediumSizeBox(),
//                   DashBoardMiddleWidget(dashBoardController: controller,context: context),
//                   nkMediumSizeBox(),
//                   DashboardBottomWidget(
//                     dashBoardController: controller,
//                   )


//                   // ListView(
//                   //    shrinkWrap: true,
//                   //    primary: false,
//                   //
//                   //    //physics: NkGeneralSize.commonPysics(),
//                   //    children: [
//                   //
//                   //    ],
//                   //  ),

//                 ],
//               ),
//               scrollDirection: Axis.vertical,
//             )

//            ,
//           ),







//     );
//   }
// }
