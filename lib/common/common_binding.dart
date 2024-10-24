import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/sqflite_database/database_helper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:get/get.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>  HomeController());
    Get.lazyPut(()=> ApiWorker());
    Get.lazyPut(()=>  CustomerAndOrderController());
    Get.lazyPut<ProductsController>(() => ProductsController(), fenix: true);
    Get.lazyPut(()=>  ProductsController());
    Get.lazyPut(()=> DatabaseHelper.database);
  }
}
