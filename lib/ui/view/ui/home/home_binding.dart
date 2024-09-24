import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(()=>HomeController());
  }
}
