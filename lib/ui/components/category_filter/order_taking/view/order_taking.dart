// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_switch_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../category_list.dart';
import '../../product_list/view/product_list.dart';

// ignore: must_be_immutable
class OrderTaking extends StatefulWidget {
  final ProductsController productsController;
  final bool? isReached;
  final bool isFromCalender;
  final bool isDirectDialogue;
  final bool isFromOrder;
  int? year;
  dynamic startDate;
  dynamic endDate;
  OrderTaking({
    super.key,
    required this.productsController,
    this.isReached,
    this.isFromCalender = false,
    this.isDirectDialogue = false,
    this.isFromOrder = false,
    this.startDate,
    this.endDate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OrderTakingState createState() => _OrderTakingState();
}

class _OrderTakingState extends State<OrderTaking>
    with SingleTickerProviderStateMixin {
  String _selectedOption = '';
  String _id = '';
  Timer? _drawerTimer;
  late AnimationController animationController;
  late Animation<double> animation;
  List<CustomerAndOrderData> allCustomers = [];
  List<CustomerAndOrderData> filteredCustomers = [];
  TextEditingController customerSearchController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  HomeController homeController = Get.find<HomeController>();
  ApiWorker apiWorker = Get.put(ApiWorker());
  late CustomersProvider cartProvider;
  final GlobalKey<CartDialogueState> cartDialogKey =
      GlobalKey<CartDialogueState>();
  bool isLoading = true;
  bool _isDrawerOpen = true;
  final double _drawerWidth = 300.0;
  bool active = false;
  String _selectedCategory = '';
  int _expandedIndex = -1;
  final String _dialogMessage = '';
  var searchText = ''.obs;
  var selectedYear = '2023'.obs;
  var years = ['2023'].obs;
  @override
  void initState() {
    log('Customer ID in Order Taking : ${customerAndOrderController.customerId.value}');
    super.initState();
    CartDatabaseManager().getDraftItems();
    widget.productsController.fetchCategoryData();
    if (widget.isDirectDialogue) {
      customerAndOrderController.customerId.value = '';
      widget.productsController.selectedCustomerId.value = '';
    }
    fetchAndSetCustomers();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      ),
    );
    final customerId = customerAndOrderController.customerId.value.isNotEmpty
        ? customerAndOrderController.customerId.value
        : widget.productsController.selectedCustomerId.value;
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    CartDatabaseManager().getCartItems(customerId);
    cartProvider.getCartItemCounts(customerId);
    CartDatabaseManager().addListener(() {
      cartProvider.updateCartCount(customerId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDrawerOpen = true;
      });
      ever(widget.productsController.categoryData, (CategoryModel? value) {
        if (_isDrawerOpen &&
            _expandedIndex == -1 &&
            value != null &&
            value.data != null &&
            value.data!.isNotEmpty) {
          _selectFirstCategory();
        }
      });
      _drawerTimer = Timer(const Duration(seconds: 4), () {
        setState(() {
          _isDrawerOpen = false;
          _expandedIndex = -1;
          _selectedCategory = '';
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartProvider = Provider.of<CustomersProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _drawerTimer?.cancel();
    animationController.dispose();
    CartDatabaseManager().removeListener(() {
      cartProvider.updateCartCount(customerAndOrderController.customerId.value);
    });
    super.dispose();
  }

  void _selectFirstCategory() {
    List<CategoryData> categories =
        widget.productsController.categoryData.value.data ?? [];
    if (categories.isNotEmpty) {
      _expandedIndex = 0;
      _selectedCategory = categories[0].categoryName ?? '';
      if (categories[0].subCategoryItem != null &&
          categories[0].subCategoryItem!.isNotEmpty) {
        final firstSubCategory =
            categories[0].subCategoryItem![0].subCategory ?? '';
        _selectedOption = firstSubCategory;
        _loadProductsForSubCategory(firstSubCategory);
      }
    }
  }

  void _loadProductsForSubCategory(String subCategory) {
    widget.productsController.fetchProducts(subCategory);
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  Future<void> _fetchProductsByCategory(String categoryId) async {
    setState(() {
      _id = categoryId;
      log('Fetching products for category ID: $categoryId');
    });
  }

  int getCartItemCount() {
    return CartDatabaseManager().cartItems.length;
  }

  Future<void> fetchAndSetCustomers() async {
    try {
      List<CustomerAndOrderData> customers =
          await customerAndOrderController.loadCustomer();
      setState(() {
        allCustomers = customers;
        filteredCustomers = customers;
        isLoading = false;
      });
    } catch (error) {
      log("Error fetching customers: $error");
    }
  }

  void filterCustomers(String query) {
    List<CustomerAndOrderData> results = allCustomers.where((customer) {
      return customer.businessName
              ?.toLowerCase()
              .startsWith(query.toLowerCase()) ??
          false;
    }).toList();
    setState(() {
      filteredCustomers = results;
    });
  }

  void showSaveDraftConfirmationDialog() {
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
                    'assets/images/Animation - 1726906882515.json')),
          ),
          content: CustomText(
            content: 'Your cart has been successfully saved as a draft.',
            fontSize: 25,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveDraftOffline({
    required String customerId,
    required String salesmanId,
    required double totalAmount,
    required List<Detail> details,
  }) async {
    try {
      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      int existingDraftIndex =
          drafts.indexWhere((draft) => draft['customer_id'] == customerId);
      if (existingDraftIndex != -1) {
        var existingDraft = drafts[existingDraftIndex];
        List<dynamic> existingDetails = existingDraft['details'];
        for (var detail in details) {
          int existingVariantIndex = existingDetails.indexWhere(
            (d) => d['variant_id'] == detail.variationId,
          );
          if (existingVariantIndex != -1) {
            existingDetails[existingVariantIndex]['quantity'] +=
                detail.count.toInt();
          } else {
            existingDetails.add({
              'product_id': detail.productId ?? '',
              'variant_id': detail.variationId ?? '',
              'pack': detail.saleBy == 'Pack'
                  ? detail.pieces.toString()
                  : detail.count.toString(),
              'packType': detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': detail.sellPrice.toString(),
              'discount': detail.discount,
              'quantity': detail.count.toInt(),
              'variant_name': detail.variationName ?? '',
            });
          }
        }
      } else {
        final orderId = DateTime.now().millisecondsSinceEpoch.toString();
        final newDraft = {
          'order_id': orderId,
          'customer_id': customerId,
          'salesman_id': salesmanId,
          'total_amount': totalAmount,
          'details': details.map((e) {
            return {
              'product_id': e.productId ?? '',
              'variant_id': e.variationId ?? '',
              'pack':
                  e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString(),
              'packType': e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': e.sellPrice.toString(),
              'discount': e.discount,
              'quantity': e.count.toInt(),
              'variant_name': e.variationName ?? '',
            };
          }).toList(),
        };
        drafts.add(newDraft);
      }
      await offlineDraftsBox.put('drafts', drafts);
      log('[saveDraftOffline] All drafts after saving: $drafts');
    } catch (e) {
      log('[saveDraftOffline] Error saving draft locally: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Final Amount${widget.productsController.finalAmount.value.toStringAsFixed(0)}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: SingleChildScrollView(
          child: IconButton(
            onPressed: () async {
              final connectivityService = ConnectivityService();
              final toDash = widget.isDirectDialogue &&
                  (!widget.isFromOrder || !widget.isFromCalender);
              final customerId =
                  customerAndOrderController.customerId.isNotEmpty
                      ? customerAndOrderController.customerId.value
                      : widget.productsController.selectedCustomerId.value;
              log('Cart Items Count: ${CartDatabaseManager().cartItems.length}');
              if (CartDatabaseManager().cartItems.isNotEmpty &&
                  customerId.isNotEmpty &&
                  !toDash) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );
                log('Log 1');
                log('To Dash $toDash');
                List<Detail> detail = [
                  ...CartDatabaseManager().cartItems.map((e) => e.detail),
                  ...CartDatabaseManager()
                      .getDraftItemsForCustomer(customerId)
                      .map((e) => e.detail),
                ];
                bool isOnline = await connectivityService.isOnline();
                if (!isOnline) {
                  log('[saveDraftOffline] Device is offline. Saving draft locally...');
                  await saveDraftOffline(
                    customerId: customerId,
                    salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                    totalAmount: widget.productsController.finalAmount.value,
                    details: detail,
                  );
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Offline Mode'),
                      content: const Text(
                          'The draft has been saved locally. It will be synced when the internet is available.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  CartDatabaseManager().cartItems.clear();
                  CartDatabaseManager().clearCart(customerId: customerId);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  return;
                }
                final cartDetails = await CartDatabaseManager()
                    .getDraftAndCartIdsFromApi(customerId);
                await Future.delayed(const Duration(seconds: 1));
                final firstOrder = cartDetails.isNotEmpty
                    ? cartDetails.last
                    : {'cart_id': '', 'draft_id': ''};
                final existingCartId = firstOrder['cart_id'] ?? '';
                final existingDraftId = firstOrder['draft_id'] ?? '';
                log('Existing cart ID $existingCartId');
                log('Existing Draft ID $existingDraftId');
                final productBYData = AddToCartModel(
                  customerId: customerId,
                  salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                  cartId: existingCartId.isNotEmpty ? existingCartId : '',
                  cartList: detail
                      .map((e) => SendCartData(
                          productId: e.productId ??
                              widget
                                  .productsController.selectedCustomerId.value,
                          variantId: e.variationId ?? '',
                          pack: e.saleBy == 'Pack'
                              ? e.pieces.toString()
                              : e.count.toString(),
                          packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                          price: e.sellPrice.toString(),
                          discount: e.discount ?? 0,
                          quantity: e.count.toInt(),
                          variantName: e.variationName ?? ''))
                      .toList(),
                  total: widget.productsController.finalAmount.value
                      .toStringAsFixed(0),
                );
                CartOrderModel? cartOrder =
                    await ApiWorker().addToDraft(productBYData.toJson());
                log('Add to Draft Datas : ${productBYData.toJson()}');
                if (cartOrder != null) {
                  int orderStatus = 4;
                  CartOrderModel order = CartOrderModel(
                    customerId: customerId,
                    salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                    cartId: existingCartId.isNotEmpty
                        ? existingCartId
                        : cartOrder.cartId,
                    orderStatus: orderStatus,
                    draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
                  );
                  await apiWorker.placeOrder(order,
                      (statusCode, message, response) async {
                    CartDatabaseManager().moveCartItemsToDraft(customerId);
                    Navigator.pop(context);
                    if (statusCode == 200) {
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
                              fontSize: 18,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      CartDatabaseManager().cartItems.clear();
                      CartDatabaseManager().clearCart(customerId: customerId);
                    } else {
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
                            content: CustomText(
                              content:
                                  "Couldn't save the order as draft please try again.",
                              fontSize: 18,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  CartDatabaseManager()
                                      .clearCart(customerId: customerId);
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
                CartDatabaseManager().cartItems.clear();
                CartDatabaseManager().clearCart(customerId: customerId);
              } else if (CartDatabaseManager().cartItems.isNotEmpty &&
                  customerId.isNotEmpty &&
                  toDash) {
                log('Log 2');
                log('Log NO : 4 : Simply popping back');
                List<Detail> detail = [
                  ...CartDatabaseManager().cartItems.map((e) => e.detail),
                  ...CartDatabaseManager()
                      .getDraftItemsForCustomer(customerId)
                      .map((e) => e.detail),
                ];
                bool isOnline = await connectivityService.isOnline();
                if (!isOnline) {
                  log('[saveDraftOffline] Device is offline. Saving draft locally...');
                  await saveDraftOffline(
                    customerId: customerId,
                    salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                    totalAmount: widget.productsController.finalAmount.value,
                    details: detail,
                  );
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Offline Mode'),
                      content: const Text(
                          'The draft has been saved locally. It will be synced when the internet is available.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  Future.delayed(const Duration(milliseconds: 300), () {
                    homeController.sidebarXController.selectIndex(0);
                    homeController.selectedIndex.value = 0;
                    Get.toNamed(AppRoutes.dashboard, id: 2);
                    widget.productsController.selectedCustomerName.value = '';
                    widget.productsController.selectedCustomerImageUrl.value =
                        '';
                  });
                  CartDatabaseManager().cartItems.clear();
                  CartDatabaseManager().clearCart(customerId: customerId);
                  return;
                }
                final cartDetails = await CartDatabaseManager()
                    .getDraftAndCartIdsFromApi(customerId);
                await Future.delayed(const Duration(seconds: 1));
                final firstOrder = cartDetails.isNotEmpty
                    ? cartDetails.first
                    : {'cart_id': '', 'draft_id': ''};
                final existingCartId = firstOrder['cart_id'] ?? '';
                final existingDraftId = firstOrder['draft_id'] ?? '';
                log('Existing cart ID $existingCartId');
                log('Existing Draft ID $existingDraftId');
                final productBYData = AddToCartModel(
                  customerId: customerId,
                  salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                  cartId: existingCartId.isNotEmpty ? existingCartId : '',
                  cartList: detail
                      .map((e) => SendCartData(
                          productId: e.productId ??
                              widget
                                  .productsController.selectedCustomerId.value,
                          variantId: e.variationId ?? '',
                          pack: e.saleBy == 'Pack'
                              ? e.pieces.toString()
                              : e.count.toString(),
                          packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                          price: e.sellPrice.toString(),
                          discount: e.discount ?? 0,
                          quantity: e.count.toInt(),
                          variantName: e.variationName ?? ''))
                      .toList(),
                  total: widget.productsController.finalAmount.value
                      .toStringAsFixed(0),
                );
                CartOrderModel? cartOrder =
                    await ApiWorker().addToDraft(productBYData.toJson());
                if (cartOrder != null) {
                  int orderStatus = 4;
                  CartOrderModel order = CartOrderModel(
                      customerId: customerId,
                      salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                      cartId: existingCartId.isNotEmpty
                          ? existingCartId
                          : cartOrder.cartId,
                      orderStatus: orderStatus,
                      draftId:
                          existingDraftId.isNotEmpty ? existingDraftId : '',
                      selctedItemCount: 1);
                  await apiWorker.placeOrder(order,
                      (statusCode, message, response) {
                    if (statusCode == 200) {
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
                              fontSize: 18,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
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
                            content: CustomText(
                              content:
                                  "Couldn't save the order as draft please try again.",
                              fontSize: 18,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
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

                Future.delayed(const Duration(milliseconds: 300), () {
                  homeController.sidebarXController.selectIndex(0);
                  homeController.selectedIndex.value = 0;
                  Get.toNamed(AppRoutes.dashboard, id: 2);
                  widget.productsController.selectedCustomerName.value = '';
                  widget.productsController.selectedCustomerImageUrl.value = '';
                });
                CartDatabaseManager().cartItems.clear();
                CartDatabaseManager().clearCart(customerId: customerId);
              } else if (toDash) {
                log('Log 3');
                Future.delayed(const Duration(milliseconds: 300), () {
                  homeController.sidebarXController.selectIndex(0);
                  homeController.selectedIndex.value = 0;
                  Get.toNamed(AppRoutes.dashboard, id: 2);
                  widget.productsController.selectedCustomerName.value = '';
                  widget.productsController.selectedCustomerImageUrl.value = '';
                });
                CartDatabaseManager().cartItems.clear();
                CartDatabaseManager().clearCart(customerId: customerId);
                Navigator.pop(context);
              } else {
                log('Log 4');
                Navigator.pop(context);
                CartDatabaseManager().cartItems.clear();
                //CartDatabaseManager().clearCart(customerId);
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (widget.productsController.selectedCustomerName
                                .isNotEmpty)
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: widget.productsController
                                        .selectedCustomerImageUrl.isEmpty
                                    ? Colors.blueGrey
                                    : const Color.fromARGB(123, 194, 192, 192),
                                child: widget.productsController
                                        .selectedCustomerImageUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : CachedNetworkImage(
                                        imageUrl:
                                            '${ApiConstants.imageBaseUrl}/${widget.productsController.selectedCustomerImageUrl.value}',
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                          radius: 20,
                                          backgroundImage: imageProvider,
                                        ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[300],
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          log('Failed to load image');
                                          return const CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.blueGrey,
                                            child: Icon(Icons.person,
                                                color: Colors.white),
                                          );
                                        },
                                      ),
                              ),
                            const SizedBox(width: 8),
                            widget.productsController.selectedCustomerName
                                    .isEmpty
                                ? Container()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.productsController
                                            .selectedCustomerName.value,
                                      ),
                                      const MyRegularText(
                                        label: "Customer",
                                        fontSize: 9,
                                      ),
                                    ],
                                  ),
                            const SizedBox(width: 10),
                          ],
                        ))),
                const NotificationWidget(startDate: '', endDate: ''),
                profiloe(),
              ],
            ),
          )
        ],
      ),
      body: Obx(() {
        if (widget.productsController.categoryData.value.data == null) {
          return const Center(
            child: SpinKitFadingCube(
              color: primaryColor,
              size: 20.0,
            ),
          );
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 86),
                Expanded(
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 55,
                          ),
                          Expanded(
                            child: ProductGrid(
                              optionName: _selectedOption,
                              productsController: widget.productsController,
                              id: _id,
                              playAddToCartAnimation: playAddToCartAnimation,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Obx(
              () => Padding(
                padding: EdgeInsets.only(
                  left: widget.productsController.selectedCustomerName.isEmpty
                      ? 45
                      : 0,
                  top: 10,
                ),
                child: Consumer<CustomersProvider>(
                  builder: (context, provider, child) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSearchBar(
                              text: "Search customer...",
                              controller: customerSearchController,
                              onChange: (value) {
                                filterCustomers(value);
                              },
                              icon: EneftyIcons.profile_outline,
                            ),
                            Expanded(
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : customerSearchController.text.isNotEmpty
                                      ? filteredCustomers.isEmpty
                                          ? Align(
                                              alignment: Alignment.topCenter,
                                              child: Material(
                                                child: Container(
                                                  width: 300,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                                  child: const Text(
                                                    'No customers found.',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  filteredCustomers.length,
                                              itemBuilder: (context, index) {
                                                CustomerAndOrderData customer =
                                                    filteredCustomers[index];
                                                return Container(
                                                  color: Colors.white,
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                        '${ApiConstants.imageBaseUrlss}/${customer.imageUrl}',
                                                      ),
                                                    ),
                                                    title: Text(
                                                        customer.businessName ??
                                                            ''),
                                                    subtitle: Text(
                                                        customer.customerId ??
                                                            ''),
                                                    onTap: () async {
                                                      await provider
                                                          .updateCartCount(customer
                                                                  .customerId ??
                                                              '');
                                                      if (active == true) {
                                                        _showWarningDialog(
                                                          // ignore: use_build_context_synchronously
                                                          context,
                                                          'Please check out from the current customer',
                                                          const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .warning_amber_outlined,
                                                              size: 40,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        customerAndOrderController
                                                            .setCustomerId(customer
                                                                    .customerId ??
                                                                '');
                                                        widget
                                                            .productsController
                                                            .updateSelectedCustomer(
                                                                id: customer
                                                                        .customerId ??
                                                                    '',
                                                                imageUrl: customer
                                                                        .imageUrl ??
                                                                    '',
                                                                name: customer
                                                                        .businessName ??
                                                                    '');
                                                        widget
                                                            .productsController
                                                            .selectedCustomerId
                                                            .value = customer
                                                                .customerId ??
                                                            '';
                                                        customerSearchController
                                                            .clear();
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                      : const SizedBox.shrink(),
                            ),
                            if (widget.productsController.showDialog.value)
                              AlertDialog(
                                title: const Text('Warning'),
                                content: Text(_dialogMessage),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        widget.productsController.closeDialog,
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IntrinsicWidth(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Hero(
                            tag: 'product_image',
                            child: AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, animation.value),
                                  child: child,
                                );
                              },
                              child: IconButton(
                                onPressed: () {
                                  _showCartDialog(cartDialogKey);
                                },
                                icon: Stack(
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 30,
                                    ),
                                    if (provider.cartItemCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${provider.cartItemCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          IntrinsicWidth(
                            child: CustomSwitch(
                              initialValue: active,
                              onChanged: (value) {
                                active = value;
                              },
                              active: active,
                              selectedName: widget.productsController
                                  .selectedCustomerName.value,
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: primaryColor.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 20,
                          color: primaryColor,
                        ),
                        onPressed: _toggleDrawer,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListView.builder(
                            itemCount: widget.productsController.categoryData
                                    .value.data?.length ??
                                0,
                            itemBuilder: (context, index) {
                              List<CategoryData> categories = widget
                                      .productsController
                                      .categoryData
                                      .value
                                      .data ??
                                  [];
                              String categoryName =
                                  categories[index].categoryName ?? '';
                              String initial = categoryName.isNotEmpty
                                  ? categoryName[0].toUpperCase()
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IconButton(
                                  icon: Text(
                                    initial,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    log("CategoryName : $categoryName");
                                    _selectCategory(categoryName);
                                    CategoryData selectedCategory =
                                        categories[index];
                                    if (selectedCategory.subCategoryItem !=
                                            null &&
                                        selectedCategory
                                            .subCategoryItem!.isNotEmpty) {
                                      String firstSubCategoryId =
                                          selectedCategory
                                                  .subCategoryItem!.first.id ??
                                              '';
                                      widget.productsController
                                              .selectedSubCategoryName.value =
                                          selectedCategory.subCategoryItem!
                                              .first.subCategory
                                              .toString();
                                      _fetchProductsByCategory(
                                          firstSubCategoryId);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleDrawer,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 0,
              bottom: 0,
              left: _isDrawerOpen ? 50 : -_drawerWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                  width: _drawerWidth,
                  color: Colors.white,
                  child: CategoryList(
                    productsController: widget.productsController,
                    categories: widget
                        .productsController.categoryData.value.data!
                        .map((entry) {
                      return CategoryItem(
                        title: entry.categoryName ?? '',
                        options: entry.subCategoryItem ?? [],
                      );
                    }).toList(),
                    onOptionSelected: (selectedSubcategoryId) {
                      String categoryId =
                          selectedSubCategory(selectedSubcategoryId);
                      log('Selected Subcategory ID: $categoryId');
                      _fetchProductsByCategory(categoryId);
                    },
                    onDrawerToggle: _toggleDrawer,
                    selectedCategory: _selectedCategory,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _selectCategory(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      _isDrawerOpen = true;
    });
    log('Selected Category: $_selectedCategory');
  }

  String selectedSubCategory(String selectedOption) {
    var selectedCategory = widget.productsController.categoryData.value.data!
        .firstWhere((e) =>
            e.subCategoryItem
                ?.any((sub) => sub.subCategory == selectedOption) ??
            false);
    var selectedSubcategory = selectedCategory.subCategoryItem?.firstWhere(
        (sub) => sub.subCategory == selectedOption,
        orElse: () => SubCategoryItem());
    return selectedSubcategory?.id ?? '';
  }

  void _showCartDialog(GlobalKey<CartDialogueState> dialogKey) {
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CartDialogue(
          key: dialogKey,
          active: active,
          cartItemCount: cartProvider.cartItemCount,
          productsController: widget.productsController,
          customerOrderController: customerAndOrderController,
          isDashboard: false,
        );
      },
    );
  }

  void playAddToCartAnimation() {
    animationController.forward().then((_) {
      animationController.reverse();
    });
  }

  void _showWarningDialog(BuildContext context, String message, Widget widget) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.all(8.0), child: widget),
              Center(
                child: CustomText(
                  content: message,
                  fontSize: 17,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    customerSearchController.clear();
                    //cartItemCount = 0;
                  });
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }
}

class CustomSearchBar extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final ValueChanged<String> onChange;
  final IconData icon;

  const CustomSearchBar({
    super.key,
    required this.text,
    required this.controller,
    required this.onChange,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChange,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
            width: 1.5,
          ),
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class WarningDialog extends StatelessWidget {
  final String message;
  final VoidCallback onOkPressed;

  const WarningDialog({
    super.key,
    required this.message,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 50,
            ),
          ),
        ),
        Center(
          child: CustomText(
            content: message,
            fontSize: 17,
          ),
        ),
        TextButton(
          onPressed: onOkPressed,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
