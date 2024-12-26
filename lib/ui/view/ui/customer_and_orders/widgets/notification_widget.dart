import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/recent_count_response.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/home_controller.dart';
import '../../orders/order_screen.dart';
import 'notification_controller.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.loadNotificationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (notificationController.isNotificationLoading.value) {
        return const CircularProgressIndicator();
      }
      return GestureDetector(
        onTapDown: (TapDownDetails details) async {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          final notifi =
              notificationController.recentOrderCountData.mainNotification??MainNotification();

          await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + 40,
              0,
              0,
            ),
            items: [
              if (notifi.recentOrders != 0)
                PopupMenuItem(
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      homeController.sidebarXController.selectIndex(7);
                      homeController.selectedIndex.value = 7;
                      Get.to(() => OrderScreen(passIndex: 0), id: 2);
                    });
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Latest Orders'),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${notifi.recentOrders}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (notifi.waitingForApproval != 0)
                PopupMenuItem(
                  onTap: () {
                    homeController.sidebarXController.selectIndex(7);
                    homeController.selectedIndex.value = 7;
                    Get.to(() => OrderScreen(passIndex: 1), id: 2);
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Waiting for Approval'),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${notifi.waitingForApproval}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (notifi.quickSale != 0)
                PopupMenuItem(
                  onTap: () {
                    homeController.sidebarXController.selectIndex(7);
                    homeController.selectedIndex.value = 7;
                    Get.to(() => OrderScreen(passIndex: 2), id: 2);
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quick Sale'),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${notifi.quickSale}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (notifi.processingOrders != 0)
                PopupMenuItem(
                  onTap: () {
                    homeController.sidebarXController.selectIndex(7);
                    homeController.selectedIndex.value = 7;
                    Get.to(() => OrderScreen(passIndex: 3), id: 2);
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Processing Orders'),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${notifi.processingOrders}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (notifi.packedAndReadyForDelivery != 0)
                PopupMenuItem(
                  onTap: () {
                    homeController.sidebarXController.selectIndex(7);
                    homeController.selectedIndex.value = 7;
                    Get.to(() => OrderScreen(passIndex: 4), id: 2);
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Packed & Ready'),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${notifi.packedAndReadyForDelivery}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        child: Container(
          height: 40,
          width: 40,
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  EneftyIcons.notification_outline,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${calculateNotificationCount(notificationController)}',
                    style: const TextStyle(
                      fontSize: 13,
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

}
  int calculateNotificationCount(NotificationController controller) {
    final mainNotification =
        controller.recentOrderCountData.mainNotification;

    if (mainNotification == null) {
      return 0; // Return 0 if `mainNotification` is null.
    }

    return (mainNotification.recentOrders ?? 0) +
        (mainNotification.waitingForApproval ?? 0) +
        (mainNotification.quickSale ?? 0) +
        (mainNotification.processingOrders ?? 0) +
        (mainNotification.packedAndReadyForDelivery ?? 0);
  }
