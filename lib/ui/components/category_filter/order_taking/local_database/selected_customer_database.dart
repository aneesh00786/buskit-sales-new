import 'package:hive_flutter/hive_flutter.dart';

class SelectedCustomerDatabase {
  Future<void> storeCustomerData(String customerId, String customerName, String imageUrl) async {
    var box = await Hive.openBox('customerBox');
    box.put('customerId', customerId);
    box.put('customerName', customerName);
    box.put('imageUrl', imageUrl);
    await box.close();
  }
  Future<Map<String, String?>> getCustomerData() async {
    var box = await Hive.openBox('customerBox');
    String? customerId = box.get('customerId');
    String? customerName = box.get('customerName');
    String? imageUrl = box.get('imageUrl');
    await box.close();
    return {
      'customerId': customerId,
      'customerName': customerName,
      'imageUrl': imageUrl,
    };
  }
}

