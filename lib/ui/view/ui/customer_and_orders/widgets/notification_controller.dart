
import 'package:get/get.dart';

import '../../../../../api_handler/api_worker.dart';
import '../csord_model/recent_count_response.dart';

class NotificationController extends GetxController {
  RecentOrderCountData recentOrderCountData = RecentOrderCountData();

  RxBool isNotificationLoading = false.obs;
  Future<RecentOrderCountData> loadNotificationData() async {
    try {
      isNotificationLoading.value = true;
      var data = await ApiWorker().fetchRecentOrderCount();
      recentOrderCountData = data.data!;
      return data.data!;
    } finally {
      isNotificationLoading.value = false;
    }
  }
}
