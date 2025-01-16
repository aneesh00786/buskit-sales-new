import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

class NkSideBarOnlyIcon extends StatefulWidget {
  final List<SidebarXItem> itemList;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final Size? sideBarSize;

  final Function(int selectedIndex)? onTap;
  final SidebarXController sidebarXController;
  const NkSideBarOnlyIcon({
    super.key,
    required this.itemList,
    this.onTap,
    this.headerWidget,
    this.footerWidget,
    this.sideBarSize = const Size(50, double.maxFinite),
    required this.sidebarXController,
  });

  @override
  State<NkSideBarOnlyIcon> createState() => NkSideBarOnlyIconState();
}

class NkSideBarOnlyIconState extends State<NkSideBarOnlyIcon> {
  @override
  void initState() {
    widget.onTap?.call(widget.sidebarXController.selectedIndex);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          AppDimensions.instance.height;
          AppDimensions.instance.width;
        });
      });
      return nkMediumSizeBox(
        width: widget.sideBarSize?.width,
        height: widget.sideBarSize?.height,
        child: Container(
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.headerWidget ?? const SizedBox(),
              SizedBox(width: 20),
              listGanrated(widget.itemList),
              widget.footerWidget ?? const SizedBox(),
            ],
          ),
        ),
      );
    });
  }

  Widget listGanrated(List<SidebarXItem> sideBarList) {
    return ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return listComponent(sideBarList[index], index);
        },
        separatorBuilder: (context, index) {
          return nkMediumSizeBox(height: AppDimensions.instance.height * .020);
        },
        itemCount: sideBarList.length);
  }

  Widget listComponent(SidebarXItem sideBarData, int index) {
    final NotificationController notificationController =
        Get.put(NotificationController());

    bool isRecentOrders = index == 7;
    bool isLeads = index == 4;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.sidebarXController.selectIndex(index);
          sideBarData.onTap?.call();
          widget.onTap?.call(widget.sidebarXController.selectedIndex);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: widget.sidebarXController.selectedIndex == index ? 12 : 15,
        ),
        decoration: BoxDecoration(
          border: widget.sidebarXController.selectedIndex == index
              ? Border(
                  left: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                )
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale:
                  widget.sidebarXController.selectedIndex == index ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                sideBarData.icon!,
                size: 24,
                color: widget.sidebarXController.selectedIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
            if (isRecentOrders)
              Positioned(
                top: -12,
                left: 12,
                child: notificationController.isNotificationLoading.value
                    ? const SizedBox.shrink()
                    : notificationController
                                .recentOrderCountData.mainNotification !=
                            null
                        ? CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              notificationController
                                      .recentOrderCountData.notificationCreated
                                      ?.toString() ??
                                  '0',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            if (isLeads)
              Positioned(
                top: -12,
                left: 12,
                child: notificationController.isLeadsCountLoading.value ||
                        notificationController.leadsCount.value <= 0
                    ? const SizedBox.shrink()
                    : CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          notificationController.leadsCount.value.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              )
          ],
        ),
      ),
    );
  }
}
