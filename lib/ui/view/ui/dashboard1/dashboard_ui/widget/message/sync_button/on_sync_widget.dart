import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/sync_button/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SyncButtonWidget extends StatefulWidget {
  const SyncButtonWidget({super.key});

  @override
  State<SyncButtonWidget> createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends State<SyncButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>()..loadLastSyncTime();

    return Obx(() {
      final isSyncing = syncController.isSyncing.value;
      final lastSync = syncController.lastSyncTime.value;
      final statusMsg = syncController.syncStatusMessage.value;

      if (isSyncing) {
        if (!_animController.isAnimating) {
          _animController.repeat();
        }
      } else {
        if (_animController.isAnimating) {
          _animController.stop();
          _animController.reset();
        }
      }

      return Tooltip(
        message: isSyncing && statusMsg.isNotEmpty
            ? statusMsg
            : (lastSync != null
                ? "Last synced: ${DateFormat('dd/MM/yyyy hh:mm a').format(lastSync)}"
                : "Tap to synchronize all data"),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: isSyncing
                    ? null
                    : () async {
                        bool isOnline = await ConnectivityService().isOnline();
                        if (!isOnline) {
                          showCustomToastDisplay(
                            context,
                            "You are offline! Please check your internet connection.".tr,
                            red,
                            Icons.cloud_off_rounded,
                          );
                        } else {
                          syncController.startSyncing(context);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 40,
                  width: fullScreenWidth(context) > 600 ? 105 : 78,
                  decoration: BoxDecoration(
                    color: isSyncing
                        ? Colors.orange.shade700
                        : const Color.fromARGB(255, 0, 187, 201),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (isSyncing
                                ? Colors.orange.shade300
                                : const Color.fromARGB(255, 0, 187, 201))
                            .withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSyncing ? 'Syncing...'.tr : 'Sync'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins_Medium",
                            fontWeight: FontWeight.w600,
                            fontSize: fullScreenWidth(context) > 600 ? 13 : 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        RotationTransition(
                          turns: _animController,
                          child: const Icon(
                            Icons.sync_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }
}
