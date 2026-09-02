// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/app_update_service.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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
  ProductsController productController = Get.find<ProductsController>();
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

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        width: 58,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
        ),
        child: Column(
          children: [
            widget.headerWidget ?? const SizedBox(),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),
            Expanded(
              child: listGanrated(widget.itemList),
            ),
            widget.footerWidget ?? const SizedBox(),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget listGanrated(List<SidebarXItem> sideBarList) {
    return AnimatedBuilder(
      animation: widget.sidebarXController,
      builder: (context, _) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: sideBarList.length,
          itemBuilder: (context, index) {
            final bool showDividerAbove = index == 9;
            final Widget itemWidget = listComponent(sideBarList[index], index);
            if (showDividerAbove) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  itemWidget,
                ],
              );
            }
            return itemWidget;
          },
        );
      },
    );
  }

  Widget listComponent(SidebarXItem sideBarData, int index) {
    final NotificationController notificationController =
        Get.put(NotificationController());
    String customerId = customerOrderController.customerId.value.isNotEmpty
        ? customerOrderController.customerId.value
        : productController.selectedCustomerId.value;
    final subscriptionController = Get.find<SubscriptionController>();
    bool isRecentOrders = index == 3;
    bool isLeads = index == 6;
    bool isDirectProduct = index == 2;
    bool isCustomersAndOrders = index == 1;
    bool isDashboard = index == 0;
    bool isLogout = index == 10;
    final bool isSelected = widget.sidebarXController.selectedIndex == index;

    return Tooltip(
      message: sideBarData.label ?? '',
      preferBelow: false,
      verticalOffset: 20,
      child: GestureDetector(
        onTap: () async {
          bool hasDraftId = CartDatabaseManager()
              .cartItems
              .every((item) => item.draftId != null && item.draftId!.isNotEmpty);
          if (CartDatabaseManager().cartItems.isNotEmpty && !hasDraftId) {
            handleTabSwitchNavigation(
                context, false, productController, customerOrderController, () {
              subscriptionController.loadSubscriptionFeatures(
                  SessionHelper.loginSavedData?.company_id ?? 0);
              setState(() {
                widget.sidebarXController.selectIndex(index);
                sideBarData.onTap?.call();
                widget.onTap?.call(widget.sidebarXController.selectedIndex);
              });
              if (customerOrderController.isActive.value == false) {
                productController.selectedCustomerId.value = "";
                productController.selectedCustomerName.value = "";
                productController.selectedCustomerImageUrl.value = "";
              }
            }, cartItemCount, customerId, hasDraftId);
          } else if (isDirectProduct) {
            if (customerOrderController.isActive.value == false) {
              productController.selectedCustomerId.value = "";
              productController.selectedCustomerName.value = "";
              productController.selectedCustomerImageUrl.value = "";
            }
            subscriptionController.loadSubscriptionFeatures(
                SessionHelper.loginSavedData?.company_id ?? 0);
            if (isCustomersAndOrders) {
              Provider.of<CustomersProvider>(context, listen: false)
                  .resetFilters();
            }
            if (isDashboard) {
              Provider.of<DashboardProvider>(context, listen: false)
                  .resetFilter();
            }
            setState(() {
              widget.sidebarXController.selectIndex(index);
              sideBarData.onTap?.call();
              widget.onTap?.call(widget.sidebarXController.selectedIndex);
            });
          } else {
            // Check connectivity for recent orders
            if (isRecentOrders) {
              final isOnline = await ConnectivityService().isOnline();
              if (!isOnline) {
                showCustomToastDisplay(
                  context,
                  'You are offline. Recent orders will not function.',
                  red,
                  Icons.close,
                );
              }
            }
            subscriptionController.loadSubscriptionFeatures(
                SessionHelper.loginSavedData?.company_id ?? 0);
            if (isCustomersAndOrders) {
              Provider.of<CustomersProvider>(context, listen: false)
                  .resetFilters();
            }
            if (isDashboard) {
              Provider.of<DashboardProvider>(context, listen: false)
                  .resetFilter();
            }
            setState(() {
              widget.sidebarXController.selectIndex(index);
              sideBarData.onTap?.call();
              widget.onTap?.call(widget.sidebarXController.selectedIndex);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            children: [
              // Left selection accent indicator
              Container(
                width: 3.5,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEF2FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          getSidebarIconData(index, selected: isSelected),
                          size: 25,
                          color: isLogout
                              ? const Color(0xFFE15241)
                              : isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    // Recent Orders Count Badge
                    if (isRecentOrders)
                      Positioned(
                        top: -4,
                        right: 0,
                        child: Obx(() {
                          if (notificationController.isNotificationLoading.value) {
                            return const SizedBox.shrink();
                          }
                          final recentOrders = notificationController
                              .recentOrderCountData.mainNotification?.recentOrders;
                          if (recentOrders == null || recentOrders == 0) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              recentOrders.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          );
                        }),
                      ),
                    // Leads Count Badge
                    if (isLeads)
                      Positioned(
                        top: -4,
                        right: 0,
                        child: Obx(() {
                          if (notificationController.isLeadsCountLoading.value) {
                            return const SizedBox.shrink();
                          }
                          final count = notificationController.leadsCount.value;
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              count.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 10,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          );
                        }),
                      ),
                    // App Update Badge
                    if (index == 9)
                      Positioned(
                        top: -4,
                        right: 0,
                        child: Obx(() {
                          final hasUpdate =
                              Get.find<AppUpdateService>().isUpdateAvailable.value;
                          if (!hasUpdate) return const SizedBox.shrink();
                          return Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1.5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Text(
                              '1',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 9.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> handleTabSwitchNavigation(
  BuildContext context,
  bool toDashBoard,
  ProductsController productController,
  CustomerAndOrderController customerController,
  Function updateTabIndex,
  int cartItemCount,
  String customerId,
  bool hasDraft,
) async {
  String customerIdFinal = customerController.customerId.isNotEmpty
      ? customerController.customerId.value
      : productController.selectedCustomerId.value;

  if (!hasDraft && productController.isCartModified.value) {
    late BuildContext dialogContext;

    // Show loading dialog with its own captured context
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Builder(
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );

    try {
      final wasOnline = await productController.processCartBeforeNavigation(
        context: context,
        customerId: customerIdFinal,
      );

      // Pop the loading dialog using its own context
      Navigator.of(dialogContext).pop();

      await Future.delayed(const Duration(milliseconds: 300));

      if (wasOnline) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (successDialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actionsPadding:
                const EdgeInsets.only(bottom: 20, left: 16, right: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                    'assets/images/Animation - 1726906882515.json'),
              ),
            ),
            content: CustomText(
              content: 'Your order has been successfully saved as Draft'.tr,
            ),
            actions: [
              SizedBox(
                width: 150,
                height: 45,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(successDialogCtx).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'OK'.tr,
                    style: const TextStyle(
                      color: Color(0xFF727CF5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // await showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (_) => AlertDialog(
        //     title: Center(
        //       child: SizedBox(
        //         height: 200,
        //         width: 200,
        //         child: FittedBox(
        //             fit: BoxFit.fitHeight,
        //             child:
        //                 Lottie.asset('assets/images/Warning_animation.json')),
        //       ),
        //     ),
        //     content: const Text(
        //       "Couldn't save the draft online. Saved offline instead.",
        //       style: TextStyle(fontSize: 18),
        //     ),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Navigator.of(context, rootNavigator: true).pop();
        //         },
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
        showCustomToastDisplay(
          context,
          "Draft successfully saved Offline",
          Colors.green,
          Icons.check,
          duration: 5,
        );
      }

      updateTabIndex();
    } catch (e) {
      // Dismiss loading dialog if error occurs
      Navigator.of(dialogContext).pop();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (errorDialogCtx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(errorDialogCtx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      updateTabIndex();
    } finally {
      customerController.customerId.value = '';
      productController.selectedCustomerId.value = '';
    }
  } else {
    updateTabIndex();
  }
  final dashboardProvider =
      Provider.of<DashboardProvider>(context, listen: false);
  await dashboardProvider.fetchData();
  await dashboardProvider.fetchAllOrdersAtOnce();
  await CartDatabaseManager().getDraftItems();
  productController.isCartModified.value = false;
}

// void handleBackNavigation(
//   BuildContext context,
//   bool toDashBoard,
//   ProductsController productController,
//   CustomerAndOrderController customerController,
//   Function updateTabIndex,
//   int cartItemCount,
//   String customerId,
//   bool hasDraft,
// ) {
//   if (!hasDraft) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//     Future.delayed(const Duration(seconds: 2), () async {
//       try {
//         List<Detail> detail =
//             CartDatabaseManager().cartItems.map((e) => e.detail).toList();
//         String customerId = customerController.customerId.isNotEmpty
//             ? customerController.customerId.value
//             : productController.selectedCustomerId.value;
//         final cartDetails =
//             await CartDatabaseManager().getCartAndDraftIds(customerId);

//         final existingCartId = cartDetails?['cart_id'] ?? '';
//         final existingDraftId = cartDetails?['id'] ?? '';
//         final productBYData = AddToCartModel(
//           customerId: customerId,
//           salesmanId: SessionHelper.loginSavedData!.salesmanId!,
//           cartId: existingCartId.isNotEmpty ? existingCartId : '',
//           cartList: detail
//               .map((e) => SendCartData(
//                   productId:
//                       e.productId ?? productController.selectedCustomerId.value,
//                   variantId: e.variationId ?? '',
//                   pack: e.saleBy == 'Pack'
//                       ? e.pieces.toString()
//                       : e.count.toString(),
//                   packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                   price: e.sellPrice.toString(),
//                   discount: e.discount ?? 0,
//                   quantity: e.count.toInt(),
//                   variantName: e.variationName ?? ''))
//               .toList(),
//           total: productController.finalAmount.value.toStringAsFixed(0),
//         );

//         CartOrderModel? cartOrder =
//             await ApiWorker().addToCart(productBYData.toJson());

//         if (cartOrder != null) {
//           int orderStatus = 4;
//           CartOrderModel order = CartOrderModel(
//             customerId: customerId,
//             salesmanId: SessionHelper.loginSavedData!.salesmanId!,
//             cartId:
//                 existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
//             orderStatus: orderStatus,
//             draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
//           );

//           await ApiWorker().placeOrder(order, (statusCode, message, response) {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             }

//             if (statusCode == 200) {
//               CartDatabaseManager().moveCartItemsToDraft(customerId);
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Center(
//                       child: SizedBox(
//                         height: 100,
//                         width: 100,
//                         child: Lottie.asset(
//                             'assets/images/Animation - 1726906882515.json'),
//                       ),
//                     ),
//                     content: CustomText(
//                       content:
//                           'Your order has been successfully saved as Draft',
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           if (Navigator.canPop(context)) {
//                             Navigator.pop(context);
//                           }
//                           CartDatabaseManager()
//                               .clearCart(customerId: customerId);
//                           updateTabIndex();
//                         },
//                         child: const Text('OK'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             } else {
//               // Show failure dialog
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Center(
//                       child: SizedBox(
//                         height: 200,
//                         width: 200,
//                         child: Lottie.asset(
//                             'assets/images/Warning_animation.json'),
//                       ),
//                     ),
//                     content: const Text(
//                       "Couldn't save the order as draft. Please try again.",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           if (Navigator.canPop(context)) {
//                             Navigator.pop(context);
//                           }
//                           updateTabIndex();
//                         },
//                         child: const Text('OK'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             }
//           });
//         }
//       } catch (e) {
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//         log('Error: $e');
//       } finally {
//         customerController.customerId.value = '';
//         productController.selectedCustomerId.value = '';
//       }
//     });
//   } else {
//     log('No cart items or customer selected; directly update tab.');
//     updateTabIndex();
//   }
// }
