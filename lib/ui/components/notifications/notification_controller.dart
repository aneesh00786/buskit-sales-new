
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  RecentOrderCountData recentOrderCountData = RecentOrderCountData();

  RxInt leadsCount = 0.obs;

  RxBool isNotificationLoading = false.obs;
  Future<RecentOrderCountData> loadNotificationData(
    String startDate,
    String endDate,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isNotificationLoading.value = true;
    });

    try {
      var data =
          await ApiWorker().fetchRecentOrderCount(startDate: '', endDate: '');
      recentOrderCountData = data.data!;
      return data.data!;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isNotificationLoading.value = false;
      });
    }
  }

  /// LEADS COUNT

  RxBool isLeadsCountLoading = false.obs;
  Future<int> loadLeadsCountData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLeadsCountLoading.value = true;
    });

    try {
      final data = await ApiWorker().fetchLeadsCount();

      if (data.data != null) {
        leadsCount.value = data.data!;
        return data.data!;
      } else {
        leadsCount.value = 0;
        return 0;
      }
    } catch (e) {
      leadsCount.value = 0;
      return 0;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLeadsCountLoading.value = false;
      });
    }
  }
}
