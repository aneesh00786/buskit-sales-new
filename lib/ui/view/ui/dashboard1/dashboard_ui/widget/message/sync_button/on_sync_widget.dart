// ignore_for_file: deprecated_member_use
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/sync_button/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SyncButtonWidget extends StatelessWidget {
  const SyncButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>()..loadLastSyncTime();

    return Obx(() {
      final isSyncing = syncController.isSyncing.value;
      final lastSync = syncController.lastSyncTime.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: fullScreenWidth(context) > 600 ? 100 : 70,
            decoration: BoxDecoration(
              color: isSyncing
                  ? Colors.orange
                  : const Color.fromARGB(255, 0, 187, 201),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(
                      context, "You are Offline!", red, Icons.warning);
                } else {
                  syncController.startSyncing(context);
                }
              },
              child: Center(
                child: isSyncing
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sync',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins_Regular",
                              fontSize:
                                  fullScreenWidth(context) > 600 ? null : 10,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.replay_outlined,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            lastSync == null
                ? ""
                : DateFormat('dd/MM/yyyy : hh:mm a').format(lastSync),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      );
    });
  }
}
