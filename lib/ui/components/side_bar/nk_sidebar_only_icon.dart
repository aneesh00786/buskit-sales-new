//nk Side Bar

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
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
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());
  HomeController homeController = Get.put(HomeController());
  int cartItemCount = 0;
  late NavigatorState navigatorState;
  @override
  void initState() {
    super.initState();
    widget.onTap?.call(widget.sidebarXController.selectedIndex);
    cartItemCount = CartDatabaseManager().cartItems.length;
   // CartDatabaseManager().addListener(_updateCartCount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigatorState = Navigator.of(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _updateCartCount() {
  //   setState(() {
  //     cartItemCount = CartDatabaseManager().cartItems.length;
  //   });
  // }

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
              const SizedBox(width: 20),
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
    String customerId = customerOrderController.customerId.value.isNotEmpty
        ? customerOrderController.customerId.value
        : productController.selectedCustomerId.value;
    bool isRecentOrders = index == 7;
    bool isLeads = index == 4;
    bool isDirectProduct = index == 2;
    return GestureDetector(
      onTap: () {
        bool hasDraftId = CartDatabaseManager()
            .cartItems
            .every((item) => item.draftId != null && item.draftId!.isNotEmpty);
        if (CartDatabaseManager().cartItems.isNotEmpty && !hasDraftId) {
          handleBackNavigation(
              context, false, productController, customerOrderController, () {
            setState(() {
              widget.sidebarXController.selectIndex(index);
              sideBarData.onTap?.call();
              widget.onTap?.call(widget.sidebarXController.selectedIndex);
            });
            log('Tab updated after clearing cart.');
            productController.selectedCustomerId.value = "";
            productController.selectedCustomerName.value = "";
            productController.selectedCustomerImageUrl.value = "";
          }, cartItemCount, customerId, hasDraftId);
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
                              notificationController.recentOrderCountData
                                      .mainNotification!.recentOrders
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
                child: CircleAvatar(
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

// final GlobalKey<CartDialogueState> cartDialogKey =
//     GlobalKey<CartDialogueState>();

// void _showCartDialog(
//     BuildContext context,
//     int cartItemCount,
//     ProductsController productController,
//     GlobalKey<CartDialogueState> dialogKey) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return CartDialogue(
//         key: dialogKey,
//         active: false,
//         cartItemCount: cartItemCount,
//         productsController: productController,
//       );
//     },
//   );
// }

void handleBackNavigation(
  BuildContext context,
  bool toDashBoard,
  ProductsController productController,
  CustomerAndOrderController customerController,
  Function updateTabIndex,
  int cartItemCount,
  String customerId,
  bool hasDraft,
) {
  if (!hasDraft) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        List<Detail> detail =
            CartDatabaseManager().cartItems.map((e) => e.detail).toList();
        String customerId = customerController.customerId.isNotEmpty
            ? customerController.customerId.value
            : productController.selectedCustomerId.value;
        final cartDetails =
            await CartDatabaseManager().getCartAndDraftIds(customerId);

        final existingCartId = cartDetails?['cart_id'] ?? '';
        final existingDraftId = cartDetails?['id'] ?? '';
        final productBYData = AddToCartModel(
          customerId: customerId,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          cartId: existingCartId.isNotEmpty ? existingCartId : '',
          cartList: detail
              .map((e) => SendCartData(
                  productId:
                      e.productId ?? productController.selectedCustomerId.value,
                  variantId: e.variationId ?? '',
                  pack: e.saleBy == 'Pack'
                      ? e.pieces.toString()
                      : e.count.toString(),
                  packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                  price: e.sellPrice.toString(),
                  discount: e.discount??0,
                  quantity: e.count.toInt(),
                  variantName: e.variationName ?? ''))
              .toList(),
          total: productController.finalAmount.value.toStringAsFixed(0),
          
        );

        CartOrderModel? cartOrder =
            await ApiWorker().addToCart(productBYData.toJson());

        if (cartOrder != null) {
          int orderStatus = 4;
          CartOrderModel order = CartOrderModel(
            customerId: customerId,
            salesmanId: SessionHelper.loginSavedData!.salesmanId!,
            cartId:
                existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
            orderStatus: orderStatus,
            draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
          );

          await placeOrder(order, (statusCode, message, response) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            if (statusCode == 200) {
              CartDatabaseManager().moveCartItemsToDraft(customerId);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Lottie.asset(
                            'assets/images/Animation - 1726906882515.json'),
                      ),
                    ),
                    content: CustomText(
                      content:
                          'Your order has been successfully saved as Draft',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          CartDatabaseManager().clearCart(customerId: customerId);
                          updateTabIndex();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Show failure dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset(
                            'assets/images/Warning_animation.json'),
                      ),
                    ),
                    content: const Text(
                      "Couldn't save the order as draft. Please try again.",
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          updateTabIndex();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          });
        }
      } catch (e) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        log('Error: $e');
      } finally {
        customerController.customerId.value = '';
        productController.selectedCustomerId.value = '';
      }
    });
  } else {
    log('No cart items or customer selected; directly update tab.');
    updateTabIndex();
  }
}
