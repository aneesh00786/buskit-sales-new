import 'dart:async';
import 'dart:developer';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart';
import '../../category_list.dart';
import '../../product_list/view/product_list.dart';

class OrderTaking extends StatefulWidget {
  final ProductsController productsController;

  OrderTaking({super.key, required this.productsController});

  @override
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
  bool isLoading = true;
  bool _isDrawerOpen = true;
  double _drawerWidth = 300.0;
  String _selectedCustomerName = '';
  String _selectedCustomerImageUrl = '';
  bool active = false;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    //category= widget.productsController.fetchCategoryData();
    fetchAndSetCustomers();
    _drawerTimer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _isDrawerOpen = false;
      });
    });

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
    cartItemCount = CartDatabaseManager().cartItems.length;
    CartDatabaseManager().addListener(_updateCartCount);
  }

  @override
  void dispose() {
    _drawerTimer?.cancel();
    animationController.dispose();
    CartDatabaseManager().removeListener(_updateCartCount);
    super.dispose();
  }

  void _updateCartCount() {
    setState(() {
      cartItemCount = CartDatabaseManager().cartItems.length;
    });
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
      return customer.fullname?.toLowerCase().contains(query.toLowerCase()) ??
          false;
    }).toList();
    setState(() {
      filteredCustomers = results;
    });
  }

  CustomerAndOrderController customeController =
      Get.find<CustomerAndOrderController>();
void handleBackNavigation(BuildContext context) {
  if (CartDatabaseManager().cartItems.isNotEmpty &&
      customeController.customerId.value.isNotEmpty) {
    _showCartDialog();
    
    Future.delayed(Duration(seconds: 1));
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Container(
              height: 150,
              width: 150,
              child: Lottie.asset('assets/images/Animation - cart_has_data.json'),
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

                    Future.delayed(Duration(milliseconds: 300), () {
                      homeController.sidebarXController.selectIndex(0);
                      homeController.selectedIndex.value = 0;
                      Get.toNamed(AppRoutes.dashboard, id: 2);
                    });

                    CartDatabaseManager().cartItems.clear();
                    CartDatabaseManager().clearCart();
                  },
                  child: Text('Clear cart'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context); 
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        );
      },
    );
  } else {
    Navigator.pop(context); 
  }
}


  void showSaveDraftConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Container(
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
                Future.delayed(Duration(milliseconds: 300), () {
                  triggerLeadingIcon();
                });
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void triggerLeadingIcon() {
    if (CartDatabaseManager().cartItems.isNotEmpty &&
        customeController.customerId.value.isNotEmpty) {
      handleBackNavigation(context);
    } else {
      homeController.sidebarXController.selectIndex(0);
      homeController.selectedIndex.value = 0;
      Get.toNamed(AppRoutes.dashboard, id: 2);
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
        title: Text(
          'Order Taking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            triggerLeadingIcon();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Obx(() {
        if (widget.productsController.categoryData.value == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (widget.productsController.categoryData.value.data == null) {
          return Center(child: CircularProgressIndicator());
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
                          SizedBox(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.43,
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
                            ? const Center(child: CircularProgressIndicator())
                            : customerSearchController.text.isNotEmpty
                                ? filteredCustomers.isEmpty
                                    ? const Center(
                                        child: Text('No customers found.'))
                                    : SizedBox(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filteredCustomers.length,
                                          itemBuilder: (context, index) {
                                            CustomerAndOrderData customer =
                                                filteredCustomers[index];
                                            return Container(
                                              color: Colors.white,
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      customer.imageUrl ?? ''),
                                                ),
                                                title: Text(
                                                    customer.fullname ?? ''),
                                                subtitle: Text(
                                                    customer.customerId ?? ''),
                                                onTap: () {
                                                  customerAndOrderController
                                                      .setCustomerId(
                                                          customer.customerId ??
                                                              '');
                                                  setState(() {
                                                    _selectedCustomerName =
                                                        customer.fullname ?? '';
                                                    _selectedCustomerImageUrl =
                                                        customer.imageUrl ?? '';
                                                    customerSearchController
                                                        .clear();
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                              _showCartDialog();
                            },
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 30,
                                ),
                                if (cartItemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${cartItemCount}',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IntrinsicWidth(
                            child: ListTile(
                                title: Text(_selectedCustomerName.isEmpty
                                    ? ''
                                    : _selectedCustomerName),
                                leading: _selectedCustomerName.isEmpty
                                    ? null
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            _selectedCustomerImageUrl.isEmpty
                                                ? ''
                                                : _selectedCustomerImageUrl),
                                        backgroundColor:
                                            _selectedCustomerImageUrl.isEmpty
                                                ? Colors.blueGrey
                                                : Color.fromARGB(
                                                    123, 194, 192, 192),
                                      )),
                          ),
                          SizedBox(
                            height: 40,
                            child: LiteRollingSwitch(
                              value: active,
                              textOn: 'Checked-in',
                              textOff: 'Checked out',
                              textOnColor: white,
                              textOffColor: white,
                              colorOn: Colors.greenAccent[700]!,
                              colorOff: Colors.redAccent[700]!,
                              width: 120,
                              iconOn: Icons.done,
                              iconOff: Icons.remove_circle_outline,
                              textSize: 10.0,
                              onTap: () {},
                              onDoubleTap: () {},
                              onSwipe: () {},
                              onChanged: (bool state) {
                                setState(() {
                                  active = state;
                                });
                                print('Current State of SWITCH IS: $state');
                                active == true
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                              'You are successfully checked-in'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      )
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'You are successfully checked-out'),
                                        duration: Duration(seconds: 3),
                                      ));
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
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
                                  ? categoryName[0]
                                  : '';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IconButton(
                                  icon: Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    String categoryId = selectedSubCategory(
                                        categories[index].categoryName ?? '');
                                    setState(() {
                                      _selectedOption =
                                          categories[index].categoryName ?? '';
                                      _id = categoryId;
                                    });

                                    log('Category Id: $categoryId');
                                    _fetchProductsByCategory(categoryId);
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
              left: _isDrawerOpen ? 0 : -_drawerWidth,
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
                    onOptionSelected: (selectedOption) {
                      String categoryId = selectedSubCategory(selectedOption);
                      setState(() {
                        _selectedOption = selectedOption;
                        _id = categoryId;
                      });

                      log('Category Id: $categoryId');
                      _fetchProductsByCategory(categoryId);
                    },
                    onDrawerToggle: _toggleDrawer,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
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

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CartDialogue(
        );
      },
    );
  }

  void playAddToCartAnimation() {
    animationController.forward().then((_) {
      animationController.reverse();
    });
  }
}

class CustomSearchBar extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final ValueChanged<String> onChange;
  final IconData icon;

  CustomSearchBar({
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
