import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  RecentOrderCountData recentOrderCountData = RecentOrderCountData();

  RxBool isNotificationLoading = false.obs;
  Future<RecentOrderCountData> loadNotificationData(
    String startDate,
    String endDate,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isNotificationLoading.value = true;
    });

    try {
      var data = await ApiWorker().fetchRecentOrderCount(startDate: startDate, endDate: endDate);
      recentOrderCountData = data.data!;
      return data.data!;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isNotificationLoading.value = false;
      });
    }
  }
}