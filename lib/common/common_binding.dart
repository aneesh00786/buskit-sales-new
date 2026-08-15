import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/app_update_service.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/controller/cart_controller.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:get/get.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ApiWorker());
    Get.put(AppUpdateService(), permanent: true);
    Get.lazyPut(() => CustomerAndOrderController());
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
    Get.lazyPut(() => ProductsController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => NotificationController());
  }
}
