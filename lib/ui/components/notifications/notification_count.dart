import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_screen.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationWidget extends StatefulWidget {
  final String? startDate;
  final String? endDate;

  const NotificationWidget({super.key, required this.startDate, required this.endDate});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final NotificationController notificationController =
      Get.put(NotificationController());
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    notificationController.loadNotificationData();
    notificationController.loadLeadsCountData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (notificationController.isNotificationLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final int notifCount = calculateNotificationCount();

      return GestureDetector(
        onTapDown: (TapDownDetails details) async {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          final notifi =
              notificationController.recentOrderCountData.mainNotification;
          if (notifi == null) return;

          await showMenu(
            context: context,
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + 44,
              0,
              0,
            ),
            items: [
              if (notifi.recentOrders != null && notifi.recentOrders != 0)
                _buildPopupMenuItem('Recent Orders'.tr, notifi.recentOrders, 0),
              if (notifi.waitingForApproval != null && notifi.waitingForApproval != 0)
                _buildPopupMenuItem(
                    'Waiting for Approval'.tr, notifi.waitingForApproval, 1),
              if (notifi.quickSale != null && notifi.quickSale != 0)
                _buildPopupMenuItem('Quick Sale'.tr, notifi.quickSale, 2),
              if (notifi.processingOrders != null && notifi.processingOrders != 0)
                _buildPopupMenuItem(
                    'Processing Orders'.tr, notifi.processingOrders, 3),
              if (notifi.packedAndReadyForDelivery != null && notifi.packedAndReadyForDelivery != 0)
                _buildPopupMenuItem(
                    'Packed & Ready'.tr, notifi.packedAndReadyForDelivery, 4),
              if (notifi.delivered != null && notifi.delivered != 0)
                _buildPopupMenuItem('Delivered'.tr, notifi.delivered, 5),
              if (notifi.rejected != null && notifi.rejected != 0)
                _buildPopupMenuItem('Rejected'.tr, notifi.rejected, 6),
            ],
          );
        },
        child: SizedBox(
          height: 40,
          width: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    EneftyIcons.notification_outline,
                    size: 20,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (notifCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      notifCount > 99 ? '99+' : notifCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  int calculateNotificationCount() {
    return (notificationController
                .recentOrderCountData.mainNotification?.recentOrders ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification?.waitingForApproval ??
            0) +
        (notificationController.recentOrderCountData.mainNotification?.quickSale ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification?.processingOrders ??
            0) +
        (notificationController.recentOrderCountData.mainNotification
                ?.packedAndReadyForDelivery ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification?.delivered ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification?.rejected ??
            0);
  }

  void _onMenuItemTap(int passIndex) {
    homeController.sidebarXController.selectIndex(7);
    homeController.selectedIndex.value = 7;
    Get.to(() => OrderScreen(passIndex: passIndex), id: 2);
  }

  PopupMenuItem _buildPopupMenuItem(String title, int? count, int passIndex) {
    return PopupMenuItem(
      onTap: () => _onMenuItemTap(passIndex),
      child: SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
