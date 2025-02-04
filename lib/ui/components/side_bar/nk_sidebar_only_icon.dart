import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
  ProductsController productController = Get.put(ProductsController());
  HomeController homeController = Get.put(HomeController());
  int cartItemCount = 0;
  @override
  void initState() {
    super.initState();
    widget.onTap?.call(widget.sidebarXController.selectedIndex);
    cartItemCount = CartDatabaseManager().cartItems.length +
        CartDatabaseManager().cartPreorderItems.length;

    CartDatabaseManager().addListener(_updateCartCount);
  }

  void _updateCartCount() {
    setState(() {
      cartItemCount = CartDatabaseManager().cartItems.length +
          CartDatabaseManager().cartPreorderItems.length;
    });
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
    bool isDirectProduct = index == 2;
    return GestureDetector(
      onTap: () {
        if (CartDatabaseManager().cartItems.isNotEmpty) {
          handleBackNavigation(context, false, productController, () {
            setState(() {
              widget.sidebarXController.selectIndex(index);
              sideBarData.onTap?.call();
              widget.onTap?.call(widget.sidebarXController.selectedIndex);
            });
            log('Tab updated after clearing cart.');
            productController.selectedCustomerId.value = "";
            productController.selectedCustomerName.value = "";
            productController.selectedCustomerImageUrl.value = "";
          }, cartItemCount);
          log('Condition1');
        } else if (isDirectProduct) {
          productController.selectedCustomerId.value = "";
          productController.selectedCustomerName.value = "";
          productController.selectedCustomerImageUrl.value = "";
          setState(() {
            widget.sidebarXController.selectIndex(index);
            sideBarData.onTap?.call();
            widget.onTap?.call(widget.sidebarXController.selectedIndex);
          });
        } else {
          setState(() {
            widget.sidebarXController.selectIndex(index);
            sideBarData.onTap?.call();
            widget.onTap?.call(widget.sidebarXController.selectedIndex);
          });
        }
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
                child:
                    CircleAvatar(
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

final GlobalKey<CartDialogueState> cartDialogKey =
    GlobalKey<CartDialogueState>();

void _showCartDialog(
    BuildContext context,
    int cartItemCount,
    ProductsController productController,
    GlobalKey<CartDialogueState> dialogKey) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CartDialogue(
        key: dialogKey,
        active: false,
        cartItemCount: cartItemCount,
        productsController: productController,
      );
    },
  );
}

void handleBackNavigation(
    BuildContext context,
    bool toDashBoard,
    ProductsController productController,
    Function updateTabIndex,
    int cartItemCount) {
  final GlobalKey<CartDialogueState> cartDialogKey =
      GlobalKey<CartDialogueState>();

  if (CartDatabaseManager().cartItems.isNotEmpty ||
      CartDatabaseManager().cartPreorderItems.isNotEmpty ||
      productController.selectedCustomerId.value.isNotEmpty) {
    _showCartDialog(context, cartItemCount, productController, cartDialogKey);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Lottie.asset(
                'assets/images/Animation - cart_has_data.json',
                repeat: false,
              ),
            ),
          ),
          content: CustomText(
            content: 'Would you like to save this as a draft?',
            fontSize: 25,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).pop();
                    CartDatabaseManager().cartItems.clear();
                    CartDatabaseManager().cartPreorderItems.clear();
                    CartDatabaseManager().clearCartOnSave('');
                    CartDatabaseManager().clearPreorderCart();
                    log('Cart Cleared');
                    updateTabIndex();
                  },
                  child: const Text('Clear cart'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    if (cartDialogKey.currentState != null) {
                      cartDialogKey.currentState!.performSpecificAction(true);
                    }
                    log('Dialog dismissed without clearing cart');
                    updateTabIndex();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          ],
        );
      },
    );
  } else {
    log('No cart items or customer selected; directly update tab.');
    updateTabIndex();
  }
}
