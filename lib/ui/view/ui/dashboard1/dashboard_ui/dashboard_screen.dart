import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardScreen extends StatefulWidget {
  final HomeController homeController;
  const DashBoardScreen({super.key, required this.homeController});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}
class _DashBoardScreenState extends State<DashBoardScreen> {
  CalenderMapController calenderMapController =
      Get.put(CalenderMapController());
  final DashBoardController controller = Get.put(DashBoardController());
  ApiWorker apiWorker = Get.put(ApiWorker());
  @override
  void initState() {
    super.initState();
    calenderMapController.requestLocationPermission();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            DashboardTopWidget(
              dashBoardController: controller,
              homeController: widget.homeController,
            ),
            nkSmallSizeBox(),
            Flexible(
              fit: FlexFit.tight,
              child: SingleChildScrollView(
                child: DashBoardMiddleWidget(
                  dashBoardController: controller,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
