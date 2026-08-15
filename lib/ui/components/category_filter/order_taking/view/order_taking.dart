// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_import

import 'dart:async';
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/view/bulk_screen.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_search_warning_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_switch_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_screen.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:provider/provider.dart';
import '../../category_list.dart';
import '../../product_list/view/product_list.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class OrderTaking extends StatefulWidget {
  final ProductsController productsController;
  final String? selectedCustId;
  final String? selectedCustName;
  final String? selectedCustImageUrl;
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
    this.selectedCustId = '',
    this.selectedCustName = '',
    this.selectedCustImageUrl = '',
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
      Get.find<CustomerAndOrderController>();
  HomeController homeController = Get.find<HomeController>();
  ApiWorker apiWorker = Get.put(ApiWorker());
  late CustomersProvider cartProvider;
  final GlobalKey<CartDialogueState> cartDialogKey =
      GlobalKey<CartDialogueState>();
  bool isLoading = true;
  bool _isDrawerOpen = true;
  final double _drawerWidth = 300.0;
  // bool active = false;
  String _selectedCategory = '';
  int _expandedIndex = -1;
  final String _dialogMessage = '';
  var searchText = ''.obs;
  var selectedYear = '2023'.obs;
  var years = ['2023'].obs;
  bool isCartCountLoading = true; // <-- Add this line
  bool _isCartCountFetched = false;

  int selectedIndex = 0;

  @override
  void initState() {

    {
      final cartProvider =
          Provider.of<CustomersProvider>(context, listen: false);
      final customerId = widget.productsController.selectedCustomerId.value;
      customerAndOrderController
          .setCustomerId(widget.productsController.selectedCustomerId.value);

      CartDatabaseManager().getCartItems(customerId);
      cartProvider.getCartItemCounts(customerId);
      CartDatabaseManager().addListener(() {
        cartProvider.updateCartCount(customerId);
      });
    }

    super.initState();
    CartDatabaseManager().getDraftItems();
    widget.productsController.fetchCategoryData();
    if (widget.isDirectDialogue) {}
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
    final customerId = widget.productsController.selectedCustomerId.value;
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);

    _loadOfflineDraftsIfNeeded(customerId);

    CartDatabaseManager().getCartItems(customerId);
    isCartCountLoading = true;
    cartProvider.getCartItemCounts(customerId).then((_) {
      if (mounted) {
        setState(() {
          isCartCountLoading = false;
        });
      }
    });
    CartDatabaseManager().addListener(() {
      cartProvider.updateCartCount(customerId);
    });
    apiWorker.getBulkVolumes();
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
    if (!_isCartCountFetched) {
      isCartCountLoading = true;
      cartProvider
          .getCartItemCounts(widget.productsController.selectedCustomerId.value)
          .then((_) {
        if (mounted) {
          setState(() {
            isCartCountLoading = false;
          });
        }
      });
      _isCartCountFetched = true;
    }
  }

  @override
  void dispose() {
    _drawerTimer?.cancel();
    animationController.dispose();
    CartDatabaseManager().removeListener(() {
      cartProvider
          .updateCartCount(widget.productsController.selectedCustomerId.value);
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
        final firstSubCategoryId = categories[0].subCategoryItem![0].id ?? '';
        _selectedOption = firstSubCategory;

        // Set the selected subcategory ID in the controller
        widget.productsController.selectedSubCategoryId.value =
            firstSubCategoryId;
        widget.productsController.selectedSubCategoryName.value =
            firstSubCategory;

        // Update the _id variable so ProductGrid can detect the change
        setState(() {
          _id = firstSubCategoryId;
          _selectedOption =
              firstSubCategory; // Ensure the option name is updated
        });

        _loadProductsForSubCategory(firstSubCategoryId);
      }
    }
  }

  void _loadProductsForSubCategory(String subCategoryId) {
    widget.productsController.fetchProducts(subCategoryId);
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  Future<void> _fetchProductsByCategory(String categoryId) async {
    setState(() {
      _id = categoryId;
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
      //
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

  @override
  Widget build(BuildContext context) {
    // log('Final Amount${widget.productsController.finalAmount.value.toStringAsFixed(0)}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: 
       AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        toolbarHeight: isPhonePortrait(context) ? 120 : null,
        leading: homeController.selectedIndex.value == 2
            ? SizedBox.shrink()
            : SingleChildScrollView(
                child: 
                IconButton(
                   onPressed: () async {
                     widget.productsController.handleBackNavigation(
                      context: context,
                      isDirectDialogue: widget.isDirectDialogue,
                       isFromOrder: widget.isFromOrder,
                      isFromCalender: widget.isFromCalender,
                      // isFromProducts: widget.isFromProducts,
                      customerId:
                          widget.productsController.selectedCustomerId.value,
                      homeController: homeController,
                    );
                   
                    await Provider.of<CustomersProvider>(context, listen: false)
                        .fetchOrdersForCustomDash(
                      OrderStatus.draft,
                      widget.productsController.selectedCustomerId.value,
                    );
                    await Provider.of<DashboardProvider>(context, listen: false)
                        .fetchData();
                    await Provider.of<DashboardProvider>(context, listen: false)
                        .fetchOrdersData(OrderStatus.draft);
                    await CartDatabaseManager().getDraftItems();
                    Provider.of<CustomersProvider>(context, listen: false)
                        .fetchCustomerDashboardCountData(
                            widget.productsController.selectedCustomerId.value);
                  },
                  // onPressed: () async {
                  //   widget.productsController.handleBackNavigation(
                  //     context: context,
                  //     isDirectDialogue: widget.isDirectDialogue,
                  //     isFromProducts: widget.isFromProducts,
                  //     customerId:
                  //         widget.productsController.selectedCustomerId.value,
                  //     homeController: homeController,
                  //   );
                  //   await Provider.of<CustomersProvider>(context, listen: false)
                  //       .fetchOrdersForCustomDash(
                  //     OrderStatus.draft,
                  //     widget.productsController.selectedCustomerId.value,
                  //   );
                  //   await Provider.of<DashboardProvider>(context, listen: false)
                  //       .fetchData();
                  //   await Provider.of<DashboardProvider>(context, listen: false)
                  //       .fetchOrdersData(OrderStatus.draft);
                  //   await CartDatabaseManager().getDraftItems();
                  //   Provider.of<CustomersProvider>(context, listen: false)
                  //       .fetchCustomerDashboardCountData(
                  //           widget.productsController.selectedCustomerId.value);
                  // },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ),
        actions: isPhonePortrait(context)
            ? [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          Flexible(
                            child: Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (widget.productsController
                                      .selectedCustomerName.isNotEmpty)
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: widget.productsController
                                              .selectedCustomerImageUrl.isEmpty
                                          ? Colors.blueGrey
                                          : const Color.fromARGB(
                                              123, 194, 192, 192),
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
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) {
                                                return const CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Colors.blueGrey,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                              ),
                            ),
                          ),
                          const NotificationWidget(startDate: '', endDate: ''),
                          // profiloe(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: fullScreenWidth(context) * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Row(
                              children: [
                                // Products tab
                                Expanded(
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    onTap: () {
                                      setState(() => selectedIndex = 0);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedIndex == 0
                                            ? skyBlueColor
                                            : Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        "Products".tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 0
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Promotions tab
                                Expanded(
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    onTap: () async {
                                      widget.productsController
                                          .fetchPromotions();
                                      setState(() => selectedIndex = 1);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedIndex == 1
                                            ? skyBlueColor
                                            : Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        "Promotions".tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 1
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              onTap: () {
                                setState(() => selectedIndex = 2);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedIndex == 2
                                      ? skyBlueColor
                                      : Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "Bulk".tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: selectedIndex == 2
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                                

                                
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ]
            : [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: fullScreenWidth(context) * 0.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Products tab
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                onTap: () {
                                  setState(() => selectedIndex = 0);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedIndex == 0
                                        ? skyBlueColor
                                        : Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "Products".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedIndex == 0
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Promotions tab
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                onTap: () async {
                                  widget.productsController.fetchPromotions();
                                  setState(() => selectedIndex = 1);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedIndex == 1
                                        ? skyBlueColor
                                        : Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "Promotions".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedIndex == 1
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              
                            ),

                            Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          onTap: () {
                            setState(() => selectedIndex = 2);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == 2
                                  ? skyBlueColor
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Bulk".tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selectedIndex == 2
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (widget.productsController.selectedCustomerName
                                  .isNotEmpty)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: widget.productsController
                                          .selectedCustomerImageUrl.isEmpty
                                      ? Colors.blueGrey
                                      : const Color.fromARGB(
                                          123, 194, 192, 192),
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
                                  : Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.productsController
                                                .selectedCustomerName.value,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                           MyRegularText(
                                            label: "Customer".tr,
                                            fontSize: 9,
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      const NotificationWidget(startDate: '', endDate: ''),
                      // profiloe(),
                    ],
                  ),
                )
              ],
      ),
    
      body: 
      Obx(() {
  if (selectedIndex == 0) {
    if (widget.productsController.categoryData.value.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 76),
            Expanded(
              child: Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 60),
                      Expanded(
                        child: ProductGrid(
                          optionName: _selectedOption,
                          productsController: widget.productsController,
                          id: _id,
                          playAddToCartAnimation: playAddToCartAnimation,
                        ),
                      ),
                      const SizedBox(width: 10),
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
              left: widget.productsController.selectedCustomerName.isEmpty ? 45 : 0,
              top: 10,
              right: 20,
            ),
            child: Consumer<CustomersProvider>(
              builder: (context, provider, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: isTabletOrPhoneLandscape(context)
                        ? MediaQuery.of(context).size.width * 0.40
                        : MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSearchBar(
                          text: "Search customer...".tr,
                          controller: customerSearchController,
                          onChange: (value) {
                            filterCustomers(value);
                          },
                          icon: EneftyIcons.profile_outline,
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : customerSearchController.text.isNotEmpty
                                  ? filteredCustomers.isEmpty
                                      ? Align(
                                          alignment: Alignment.topCenter,
                                          child: Material(
                                            child: Container(
                                              width: 300,
                                              decoration: const BoxDecoration(color: Colors.white),
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                              child: const Text(
                                                'No customers found.',
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filteredCustomers.length,
                                          itemBuilder: (context, index) {
                                            CustomerAndOrderData customer = filteredCustomers[index];
                                            return Container(
                                              color: Colors.white,
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    '${ApiConstants.imageBaseUrlss}/${customer.imageUrl}',
                                                  ),
                                                ),
                                                title: Text(customer.businessName ?? ''),
                                                subtitle: Text(customer.customerId ?? ''),
                                                onTap: () async {
                                                  await provider.updateCartCount(customer.customerId ?? '');
                                                  if (customerAndOrderController.isActive.value == true) {
                                                    _showWarningDialog(
                                                      context,
                                                      'Please check out from the current customer',
                                                      const Center(
                                                        child: Icon(
                                                          Icons.warning_amber_outlined,
                                                          size: 40,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    customerAndOrderController.setCustomerId(customer.customerId ?? '');
                                                    widget.productsController.updateSelectedCustomer(
                                                      id: customer.customerId ?? '',
                                                      imageUrl: customer.imageUrl ?? '',
                                                      name: customer.businessName ?? '',
                                                    );
                                                    widget.productsController.selectedCustomerId.value = customer.customerId ?? '';
                                                    customerSearchController.clear();
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Text('Warning'),
                            content: Text(_dialogMessage),
                            actions: [
                              SizedBox(
                                width: 150,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: widget.productsController.closeDialog,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    'OK'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Color(0xFF727CF5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        const ChatbotTopBarButton(routeName: "/order_taking"),
                        const SizedBox(width: 8),
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
                            child: Consumer<CustomersProvider>(
                              builder: (context, provider, child) => IconButton(
                                onPressed: () {
                                  _showCartDialog(cartDialogKey);
                                },
                                icon: Stack(
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, size: 30),
                                    if (isCartCountLoading)
                                      const Positioned(
                                        right: 0,
                                        top: 0,
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                          ),
                                        ),
                                      )
                                    else if (provider.cartItemCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
                        ),
                        Consumer<CustomersProvider>(
                          builder: (context, provider, child) {
                            if (provider.cartItemCount > 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '${addCurrencySymbol()}${provider.cartTotalAmount.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(width: 10),
                        IntrinsicWidth(
                          child: CustomSwitch(
                            initialValue: customerAndOrderController.isActive.value,
                            onChanged: (value) {
                              print('customer id in check out switch:${widget.selectedCustId.toString()}');
                              customerAndOrderController.isActive.value = value;
                            },
                            active: customerAndOrderController.isActive.value,
                            selectedName: widget.productsController.selectedCustomerName.value,
                            customerId:  widget.productsController.selectedCustomerId.value.toString(),
                          ),
                        )
                      ],
                    ),
                  )
                    ),
                  )
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
                    icon: const Icon(Icons.menu, size: 20, color: primaryColor),
                    onPressed: _toggleDrawer,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        itemCount: widget.productsController.categoryData.value.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          List<CategoryData> categories = widget.productsController.categoryData.value.data ?? [];
                          String categoryName = categories[index].categoryName ?? '';
                          String initial = categoryName.isNotEmpty ? categoryName[0].toUpperCase() : '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: IconButton(
                              icon: Text(
                                initial,
                                style: const TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _selectCategory(categoryName);
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
              onTap: () {
                setState(() {
                  _isDrawerOpen = false;
                });
                _drawerTimer?.cancel();
              },
              child: Container(color: Colors.transparent),
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
                categories: widget.productsController.categoryData.value.data!
                    .map((entry) {
                  return CategoryItem(
                    title: entry.categoryName ?? '',
                    options: entry.subCategoryItem ?? [],
                  );
                }).toList(),
                onOptionSelected: (selectedSubcategoryId) {
                  _fetchProductsByCategory(selectedSubcategoryId);
                },
                onDrawerToggle: _toggleDrawer,
                selectedCategory: _selectedCategory,
              ),
              
            ),
          ),
        ),
      
      ],
    );
  } else {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            SizedBox(height: 76),
            Expanded(
              child: selectedIndex == 1
                  ? PromotionScreen(controller: widget.productsController)
                  : selectedIndex == 2
                      ? BulkScreen()
                      : SizedBox.shrink(),
            ),
          ],
        ),
        Obx(
          () => Padding(
            padding: EdgeInsets.only(
              left: widget.productsController.selectedCustomerName.isEmpty ? 40 : 0,
              top: 10,
              right: 20,
            ),
            child: Consumer<CustomersProvider>(
              builder: (context, provider, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: isTabletOrPhoneLandscape(context)
                        ? MediaQuery.of(context).size.width * 0.40
                        : MediaQuery.of(context).size.width * 0.25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSearchBar(
                          text: "Search customer...".tr,
                          controller: customerSearchController,
                          onChange: (value) {
                            filterCustomers(value);
                          },
                          icon: EneftyIcons.profile_outline,
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : customerSearchController.text.isNotEmpty
                                  ? filteredCustomers.isEmpty
                                      ? Align(
                                          alignment: Alignment.topCenter,
                                          child: Material(
                                            child: Container(
                                              width: 300,
                                              decoration: const BoxDecoration(color: Colors.white),
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                              child: const Text(
                                                'No customers found.',
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filteredCustomers.length,
                                          itemBuilder: (context, index) {
                                            CustomerAndOrderData customer = filteredCustomers[index];
                                            return Container(
                                              color: Colors.white,
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    '${ApiConstants.imageBaseUrlss}/${customer.imageUrl}',
                                                  ),
                                                ),
                                                title: Text(customer.businessName ?? ''),
                                                subtitle: Text(customer.customerId ?? ''),
                                                onTap: () async {
                                                  await provider.updateCartCount(customer.customerId ?? '');
                                                  if (customerAndOrderController.isActive.value == true) {
                                                    _showWarningDialog(
                                                      context,
                                                      'Please check out from the current customer',
                                                      const Center(
                                                        child: Icon(
                                                          Icons.warning_amber_outlined,
                                                          size: 40,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    customerAndOrderController.setCustomerId(customer.customerId ?? '');
                                                    widget.productsController.updateSelectedCustomer(
                                                      id: customer.customerId ?? '',
                                                      imageUrl: customer.imageUrl ?? '',
                                                      name: customer.businessName ?? '',
                                                    );
                                                    widget.productsController.selectedCustomerId.value = customer.customerId ?? '';
                                                    customerSearchController.clear();
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Text('Warning'),
                            content: Text(_dialogMessage),
                            actions: [
                              SizedBox(
                                width: 150,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: widget.productsController.closeDialog,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    'OK'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Color(0xFF727CF5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
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
                        const ChatbotTopBarButton(routeName: "/order_taking"),
                        const SizedBox(width: 8),
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
                            child: Consumer<CustomersProvider>(
                              builder: (context, provider, child) => IconButton(
                                onPressed: () {
                                  _showCartDialog(cartDialogKey);
                                },
                                icon: Stack(
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, size: 30),
                                    if (isCartCountLoading)
                                      const Positioned(
                                        right: 0,
                                        top: 0,
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                          ),
                                        ),
                                      )
                                    else if (provider.cartItemCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
                        ),
                        Consumer<CustomersProvider>(
                          builder: (context, provider, child) {
                            if (provider.cartItemCount > 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '${addCurrencySymbol()}${provider.cartTotalAmount.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(width: 10),
                        IntrinsicWidth(
                          child: CustomSwitch(
                            initialValue: customerAndOrderController.isActive.value,
                            onChanged: (value) {
                               print('customer id in check out switch:${widget.selectedCustId.toString()}');
                              customerAndOrderController.isActive.value = value;
                            },
                            active: customerAndOrderController.isActive.value,
                            selectedName: widget.productsController.selectedCustomerName.value,
                            customerId: widget.productsController.selectedCustomerId.value.toString(),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}),
     
    );
  }

  void _selectCategory(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      _isDrawerOpen = true;
    });

    // Cancel any existing drawer timer before starting a new one
    _drawerTimer?.cancel();

    _drawerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isDrawerOpen = false;
        });
      }
    });

    // Find the category and automatically select its first subcategory
    List<CategoryData> categories =
        widget.productsController.categoryData.value.data ?? [];
    CategoryData? selectedCategory = categories.firstWhere(
      (category) => category.categoryName == categoryName,
      orElse: () => CategoryData(),
    );

    if (selectedCategory.subCategoryItem != null &&
        selectedCategory.subCategoryItem!.isNotEmpty) {
      final firstSubCategory = selectedCategory.subCategoryItem![0];
      final firstSubCategoryId = firstSubCategory.id ?? '';
      final firstSubCategoryName = firstSubCategory.subCategory ?? '';

      // Set the selected subcategory in the controller
      widget.productsController.selectedSubCategoryId.value =
          firstSubCategoryId;
      widget.productsController.selectedSubCategoryName.value =
          firstSubCategoryName;

      // Update the _id variable so ProductGrid can detect the change
      setState(() {
        _id = firstSubCategoryId;
      });

      // Load products for the first subcategory
      _loadProductsForSubCategory(firstSubCategoryId);
    }
  }

  void _showCartDialog(GlobalKey<CartDialogueState> dialogKey) {
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CartDialogue(
          key: dialogKey,
          active: customerAndOrderController.isActive.value,
          cartItemCount: cartProvider.cartItemCount,
          productsController: widget.productsController,
          customerOrderController: customerAndOrderController,
          isDashboard: false,
          customerId: widget.productsController.selectedCustomerId.value,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.all(8.0), child: widget),
              Center(
                child: CustomText(
                  content: message,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 150,
                height: 45,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      customerSearchController.clear();
                    });
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
                      fontFamily: 'Poppins_Regular',
                      color: Color(0xFF727CF5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadOfflineDraftsIfNeeded(String? customerId) async {
    if (customerId == null || customerId.isEmpty) return;
    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        var offlineDraftsBox = await Hive.openBox('offlineDrafts');
        List<dynamic> drafts =
            offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
        final draft = drafts.firstWhere(
          (d) => d['customer_id'] == customerId,
          orElse: () => null,
        );
        if (draft != null && draft['details'] != null) {
          final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
          final List details = draft['details'];
          final draftBox = Hive.box<CartItem>('draftBox');
          final keysToRemove = draftBox.keys.where((key) {
            final item = draftBox.get(key);
            return item != null && item.customerId == customerId;
          }).toList();
          for (var key in keysToRemove) {
            await draftBox.delete(key);
          }
          for (var detail in details) {
            final String packTypeStr = (detail['packType'] ?? detail['packtype'] ?? detail['pack_type'] ?? '') as String;
            final cartItem = CartItem(
              detail: Detail(
                productId: detail['product_id'],
                variationId: detail['variant_id'],
                sellPrice: detail['price'],
                discount: detail['discount'],
                count: (detail['quantity'] as num?)?.toDouble() ?? 0,
                pieces: int.tryParse(detail['pack'] ?? '0'),
                variationName: detail['variant_name'],
                saleBy: packTypeStr,
                stock: detail['stock'] ?? 0,
                unitType: detail['unitType'],
                packtype: packTypeStr,
                productName: detail['product_name'],
                tax: detail['tax'],
                inclTax: detail['incl_tax'],
              ),
              productName: detail['product_name'],
              totalPrice:
                  double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
              isPack: packTypeStr == 'Pack' || packTypeStr == 'Bulk',
              customerId: customerId,
              salesmanId: salesmanId,
              catId: 0,
            );
            await draftBox.add(cartItem);
          }
        }
      }
    } catch (e) {
      //
    }
  }
}
