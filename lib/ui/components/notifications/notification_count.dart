import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
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

      return GestureDetector(
        onTapDown: (TapDownDetails details) async {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          final notifi =
              notificationController.recentOrderCountData.mainNotification!;

          await showMenu(
            context: context,
            color: white,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + 40,
              0,
              0,
            ),
            items: [
              if (notifi.recentOrders != 0)
                _buildPopupMenuItem('Recent Orders', notifi.recentOrders, 0),
              if (notifi.waitingForApproval != 0)
                _buildPopupMenuItem(
                    'Waiting for Approval', notifi.waitingForApproval, 1),
              if (notifi.quickSale != 0)
                _buildPopupMenuItem('Quick Sale', notifi.quickSale, 2),
              if (notifi.processingOrders != 0)
                _buildPopupMenuItem(
                    'Processing Orders', notifi.processingOrders, 3),
              if (notifi.packedAndReadyForDelivery != 0)
                _buildPopupMenuItem(
                    'Packed & Ready', notifi.packedAndReadyForDelivery, 4),
              if (notifi.delivered != 0)
                _buildPopupMenuItem('Delivered', notifi.delivered, 5),
              if (notifi.rejected != 0)
                _buildPopupMenuItem('Rejected', notifi.rejected, 6),
            ],
          );
        },
        child: SizedBox(
          height: 40,
          width: 40,
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  EneftyIcons.notification_outline,
                  size: 25,
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    calculateNotificationCount().toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
            Text(title),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.blue,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
