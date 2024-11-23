
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
    notificationController.loadNotificationData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return notificationController.isNotificationLoading.value
          ? const CircularProgressIndicator()
          : GestureDetector(
              onTapDown: (TapDownDetails details) async {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset position = box.localToGlobal(Offset.zero);
                final notifi = notificationController
                    .recentOrderCountData.mainNotification!;

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
                          homeController.sidebarXController.selectIndex(7);
                          homeController.selectedIndex.value = 7;
                          // Get.toNamed(AppRoutes.ordersScreen, id: 2);
                          Get.to(() => OrderScreen(passIndex: 0), id: 2);
                        },
                        child: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Recent Orders'),
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
                        Icons.notifications_outlined,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${calculateNotificationCount()}',
                          style: const TextStyle(
                            fontSize: 10,
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
                .recentOrderCountData.mainNotification!.recentOrders ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification!.waitingForApproval ??
            0) +
        (notificationController.recentOrderCountData.mainNotification!.quickSale ??
            0) +
        (notificationController
                .recentOrderCountData.mainNotification!.processingOrders ??
            0) +
        (notificationController.recentOrderCountData.mainNotification!
                .packedAndReadyForDelivery ??
            0);
  }
}
