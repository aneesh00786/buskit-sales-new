//Cart Dialog

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_heading.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/dialogue_heading_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_totalamount_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_cart_button.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_header_container.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CartDialogue extends StatefulWidget {
  bool? active;
  int cartItemCount;
  ProductsController productsController;
  CustomerAndOrderController? customerOrderController;
  bool isDashboard;
  final bool isFromCalender;
  final bool isDirectDialogue;
  final bool isFromOrder;
  final bool? isFromCustomerDach;
  final VoidCallback? onContinueShopping;
  String? customerId;
  CartDialogue(
      {super.key,
      this.active,
      required this.cartItemCount,
      required this.productsController,
      required this.isDashboard,
      this.isFromCalender = false,
      this.isDirectDialogue = false,
      this.isFromOrder = false,
      this.customerOrderController,
      this.onContinueShopping,
      this.isFromCustomerDach = false,
      this.customerId});
  @override
  State<CartDialogue> createState() => CartDialogueState();
}

class CartDialogueState extends State<CartDialogue> {
  List<CartItem> cartItems = [];
  List<CartItem> orderItems = [];
  List<CartItem> preorderItems = [];
  List<int> quantities = [];
  List<int> preorderQuantities = [];
  List<int> draftQuantity = [];
  double orderSubtotal = 0.0;
  double orderTax = 0.0;
  double preorderSubtotal = 0.0;
  double preorderTax = 0.0;
  double totalDiscount = 0.0;
  double totalDiscountPreorder = 0.0;
  bool isOrder = true;
  String? _selectedValue;
  String? _dropdownValue;
  int? paymentType;
  final List<String> _options = [
    'Sale Order',
    "Quick Sale",
    'Pre Order',
    'Estimate'
  ];
  List<String> filteredOptions = [];
  CustomerAndOrderController customeController =
      Get.put(CustomerAndOrderController());
  final subscriptionController = Get.find<SubscriptionController>();

  final TextEditingController totalQuickController = TextEditingController();
  final TextEditingController chequeOrTransactionNumberController =
      TextEditingController();
  final TextEditingController cashRemarkController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  bool _isLoading = true;
  bool isDraft = true;

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  ScrollController _scrollController3 = ScrollController();
  ScrollController _scrollController4 = ScrollController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<int> localCounts;
  @override
  void initState() {
    super.initState();

    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    _scrollController4 = ScrollController();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });

    _scrollController3.addListener(() {
      if (_scrollController4.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController4.position.pixels) {
        _scrollController4.jumpTo(_scrollController3.position.pixels);
      }
    });

    _scrollController4.addListener(() {
      if (_scrollController3.hasClients &&
          _scrollController4.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController4.position.pixels);
      }
    });

    localCounts = List<int>.filled(cartItems.length, 0);
    log('Customer ID in INitstate : ${widget.customerId ?? ''}');
    _loadCartItems();
    Provider.of<CustomersProvider>(context, listen: false).getCartItemCounts(
        // widget.customerOrderController?.customerId.value ?? ''
        widget.customerId ?? '');
    calculateAmounts();
    _selectedValue = isOrder ? _options[0] : _options[2];
    setOptions();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _scrollController4.dispose();
    super.dispose();
  }

  void setOptions() {
    setState(() {
      filteredOptions = isOrder
          ? ['Sale Order', 'Quick Sale', 'Estimate']
          : ['Pre Order', 'Estimate'];
    });
  }

  void _loadCartItems() async {
    try {
      final customerId = widget.customerId;

      // (widget.customerOrderController!.customerId.value.isNotEmpty
      //     ? widget.customerOrderController!.customerId.value
      //     : widget.productsController.selectedCustomerId.value);
      cartItems = await CartDatabaseManager().getCartItems(customerId ?? '');
      log('CartItems Length : ${cartItems.length}');
      orderItems = cartItems.where((item) => item.detail.stock! > 0).toList();
      preorderItems =
          cartItems.where((item) => item.detail.stock == 0).toList();
      orderSubtotal = orderItems.fold(0.0, (sum, item) {
        return item.isChecked! ? sum + (item.totalPrice) : sum;
      });
      preorderSubtotal = preorderItems.fold(0.0, (sum, item) {
        return sum + (item.totalPrice);
      });
      orderTax = orderItems.fold(
        0.0,
        (sum, item) {
          if (item.isChecked == true) {
            final double itemTax = item.detail.tax?.toDouble() ?? 0.0;
            if (item.isPack == true || item.detail.packtype == "Pack") {
              log('Item Tax ${itemTax * (item.detail.pieces ?? 1)}');
              return sum +
                  (itemTax * (item.detail.pieces ?? 1) * (item.detail.count));
            } else {
              return sum + (itemTax * (item.detail.count));
            }
          } else {
            return 0;
          }
        },
      );
      preorderTax = preorderItems.fold(
        0.0,
        (sum, item) {
          if (item.isChecked == true) {
            final double itemTax = item.detail.tax?.toDouble() ?? 0.0;
            if (item.isPack == true || item.detail.packtype == "Pack") {
              return sum +
                  (itemTax * (item.detail.pieces ?? 1) * (item.detail.count));
            } else {
              return sum + (itemTax * (item.detail.count));
            }
          } else {
            return 0;
          }
        },
      );
      totalDiscount = orderItems.fold(
        0.0,
        (sum, item) {
          final discountPrice = (((double.tryParse(
                          item.detail.sellPrice?.toString() ?? '0') ??
                      0.0) *
                  ((double.tryParse(item.detail.discount?.toString() ?? '0') ??
                          0.0) /
                      100)) *
              ((item.isPack == true || item.detail.packtype == 'Pack')
                  ? (item.detail.pieces?.toDouble() ?? 1) *
                      item.detail.count.toDouble()
                  : item.detail.count.toDouble()));
          if (item.isChecked == true) {
            if (item.isPack == true || item.detail.packtype == "Pack") {
              return sum + discountPrice;
            } else {
              return 0;
            }
          } else {
            return 0;
          }
        },
      );
      totalDiscountPreorder = preorderItems.fold(
        0.0,
        (sum, item) {
          final discountPrice = (((double.tryParse(
                          item.detail.sellPrice?.toString() ?? '0') ??
                      0.0) *
                  ((double.tryParse(item.detail.discount?.toString() ?? '0') ??
                          0.0) /
                      100)) *
              ((item.isPack == true || item.detail.packtype == 'Pack')
                  ? (item.detail.pieces?.toDouble() ?? 1) *
                      item.detail.count.toDouble()
                  : item.detail.count.toDouble()));
          if (item.isChecked == true) {
            if (item.isPack == true || item.detail.packtype == "Pack") {
              return sum + discountPrice;
            } else {
              return 0;
            }
          } else {
            return 0;
          }
        },
      );
      setState(() {
        quantities = List.generate(cartItems.length, (index) => 1);
        _isLoading = false;
        orderItems = orderItems;
        preorderItems = preorderItems;
        orderSubtotal = orderSubtotal;
        orderTax = orderTax;
        preorderSubtotal = preorderSubtotal;
        preorderTax = preorderTax;
      });
      if (orderItems.isNotEmpty) {
        isOrder = true;
        _selectedValue = _options[0];
      } else if (preorderItems.isNotEmpty) {
        isOrder = false;
        _selectedValue = _options[2];
      }
      setOptions();
    } catch (e) {
      log('Error loading cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('preOrder items : ${preorderItems.length}');
    log('preOrder items : $isOrder');
    if (_isLoading) {
      return const Center(
        child: SpinKitFadingCube(
          color: primaryColor,
          size: 20.0,
        ),
      );
    }
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    double dialogHeight;
    if (width > 1200) {
      dialogHeight = height * 0.8;
    } else if (width > 650) {
      dialogHeight = height * 0.7;
    } else {
      dialogHeight = height * 0.5;
    }
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double availableHeight = constraints.maxHeight;
          double fontSize = availableWidth / 50;
          double rowHeight = availableHeight / 14;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: availableWidth,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogueHedingWidget(
                    height: height,
                    width: width,
                    title: 'My Cart',
                  ),
                  if (orderItems.isNotEmpty || preorderItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            if (orderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: isOrder ? primaryColor : white,
                                        borderRadius: preorderItems.isNotEmpty
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                              )
                                            : BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isOrder = true;
                                            _selectedValue = _options[0];
                                          });
                                          setOptions();
                                        },
                                        child: Center(
                                          child: CustomText(
                                            content: 'ORDERS',
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isOrder ? white : primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                            '${orderItems.length}',
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
                            if (preorderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: !isOrder ? primaryColor : white,
                                        borderRadius: orderItems.isNotEmpty
                                            ? const BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                              )
                                            : BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isOrder = false;
                                            _selectedValue = _options[2];
                                          });
                                          setOptions();
                                        },
                                        child: Center(
                                          child: CustomText(
                                            content: 'PRE-ORDERS',
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isOrder ? primaryColor : white,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                            '${preorderItems.length}',
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
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(),
                  ],
                  if (isOrder) ...[
                    (orderItems.isEmpty)
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: CustomText(
                                content: 'Your cart is empty.',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          )
                        : Flexible(
                            child: SizedBox(
                              height: dialogHeight * 0.5,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          width:
                                              fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: orderItems
                                                      .where((item) =>
                                                          item.detail.stock! >
                                                          0)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem>
                                                        groupedItems =
                                                        orderItems
                                                            .where((item) =>
                                                                item.productName ==
                                                                    productName &&
                                                                item.detail
                                                                        .stock! >
                                                                    0)
                                                            .toList();

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child: _buildGroupedItems(
                                                        productName:
                                                            productName,
                                                        groupedItems:
                                                            groupedItems,
                                                        availableWidth:
                                                            availableWidth,
                                                        fontSize: fontSize,
                                                        rowHeight: rowHeight,
                                                        context: context,
                                                        productQuantityManager:
                                                            productQuantityManager,
                                                        deleteConfirmationDialogue:
                                                            deleteConfirmationDialogue,
                                                        isPreOrder: false,
                                                        calCulateAmount:
                                                            calculateAmounts,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 0,
                                    child: ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.dragged)) {
                                              return primaryColor
                                                  .withOpacity(0.5);
                                            }
                                            return primaryColor
                                                .withOpacity(0.5);
                                          }),
                                          trackColor: WidgetStateProperty.all(
                                              primaryColor.withOpacity(0.2)),
                                          trackBorderColor:
                                              WidgetStateProperty.all(
                                                  primaryColor
                                                      .withOpacity(0.2)),
                                          thickness:
                                              WidgetStateProperty.all(10),
                                          radius: const Radius.circular(10),
                                          minThumbLength: 50,
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                          trackVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                        child: Scrollbar(
                                            thickness: 6,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            controller: _scrollController3,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              controller: _scrollController3,
                                              child: Column(
                                                children: orderItems
                                                    .where((item) =>
                                                        item.detail.stock! > 0)
                                                    .map((item) =>
                                                        item.productName)
                                                    .toSet()
                                                    .toList()
                                                    .map((productName) {
                                                  List<CartItem> groupedItems =
                                                      orderItems
                                                          .where((item) =>
                                                              item.productName ==
                                                                  productName &&
                                                              item.detail
                                                                      .stock! >
                                                                  0)
                                                          .toList();

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: _buildGroupedItems(
                                                      productName: productName,
                                                      groupedItems:
                                                          groupedItems,
                                                      availableWidth:
                                                          availableWidth,
                                                      fontSize: fontSize,
                                                      rowHeight: rowHeight,
                                                      context: context,
                                                      productQuantityManager:
                                                          productQuantityManager,
                                                      deleteConfirmationDialogue:
                                                          deleteConfirmationDialogue,
                                                      isPreOrder: false,
                                                      calCulateAmount:
                                                          calculateAmounts,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.dragged)) {
                            return primaryColor.withOpacity(0.5);
                          }
                          return primaryColor.withOpacity(0.5);
                        }),
                        trackColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        trackBorderColor: WidgetStateProperty.all(
                            primaryColor.withOpacity(0.2)),
                        thickness: WidgetStateProperty.all(6),
                        radius: const Radius.circular(10),
                        minThumbLength: 50,
                        thumbVisibility: WidgetStateProperty.all(true),
                        trackVisibility: WidgetStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 6,
                        controller: _scrollController2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController2,
                          child: Container(
                            width: fullScreenWidth(context) * 1.15,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: lightPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Subtotal',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(orderSubtotal),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Discount',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(totalDiscount),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Tax',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(orderTax),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    CartTotalWidget(
                      title: 'Final Amount',
                      content: orderSubtotal,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color2: Colors.green,
                    ),
                  ],
                  if (!isOrder) ...[
                    (preorderItems.isEmpty)
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: CustomText(
                                content: 'No pre-order items available.',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          )
                        : Flexible(
                            child: SizedBox(
                              height: dialogHeight * 0.5,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          width:
                                              fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: preorderItems
                                                      .where((item) =>
                                                          item.detail.stock ==
                                                          0)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem>
                                                        groupedItems =
                                                        preorderItems
                                                            .where((item) =>
                                                                item.productName ==
                                                                    productName &&
                                                                item.detail
                                                                        .stock ==
                                                                    0)
                                                            .toList();
                                                    return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 20),
                                                        child:
                                                            _buildGroupedItems(
                                                          productName:
                                                              productName,
                                                          groupedItems:
                                                              groupedItems,
                                                          availableWidth:
                                                              availableWidth,
                                                          fontSize: fontSize,
                                                          rowHeight: rowHeight,
                                                          context: context,
                                                          productQuantityManager:
                                                              productQuantityManager,
                                                          deleteConfirmationDialogue:
                                                              deleteConfirmationDialogue,
                                                          isPreOrder: true,
                                                          calCulateAmount:
                                                              calculateAmounts,
                                                        ));
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: lightPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Subtotal',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(preorderSubtotal),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Discount',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(totalDiscountPreorder),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: 'Tax',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              content: formatAmount(preorderTax),
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    CartTotalWidget(
                      title: 'Final Amount',
                      content: preorderSubtotal,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color2: Colors.green,
                    ),
                  ],
                  SizedBox(
                    height: _selectedValue == "Quick Sale"
                        ? (_dropdownValue == "Cheque" ||
                                _dropdownValue == "Bank Transfer"
                            ? 210
                            : (_dropdownValue == null ||
                                    _dropdownValue == "Cash"
                                ? 140
                                : 60))
                        : 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: filteredOptions.map((option) {
                            totalQuickController.text = isOrder
                                ? '\$${orderSubtotal.toStringAsFixed(2)}'
                                : '\$${preorderSubtotal.toStringAsFixed(2)}';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    splashRadius: 20,
                                    activeColor: Colors.green,
                                    value: option,
                                    groupValue: _selectedValue,
                                    onChanged: (value) {
                                      if (value == _options[1]) {
                                        if (subscriptionController
                                                .appQuickSale.value ==
                                            "true") {
                                          setState(() {
                                            _selectedValue = value!;
                                            _dropdownValue = null;
                                            totalQuickController.clear();
                                          });
                                        } else {
                                          showUpgradePlanDialog(context);
                                        }
                                      } else {
                                        setState(() {
                                          _selectedValue = value!;
                                          _dropdownValue = null;
                                          totalQuickController.clear();
                                        });
                                      }
                                    },
                                  ),
                                  Text(option),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedValue == "Quick Sale")
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 40, right: 40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 130,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  hint: const Text(
                                                      "Payment method"),
                                                  value: _dropdownValue,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _dropdownValue =
                                                          newValue!;
                                                      switch (_dropdownValue) {
                                                        case 'Cash':
                                                          paymentType = 0;
                                                          break;
                                                        case 'Cheque':
                                                          paymentType = 1;
                                                          break;
                                                        case 'Bank Transfer':
                                                          paymentType = 2;
                                                          break;
                                                        default:
                                                          paymentType = null;
                                                      }
                                                    });
                                                  },
                                                  items: <String>[
                                                    'Cash',
                                                    'Cheque',
                                                    'Bank Transfer',
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select a payment method';
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration
                                                          .collapsed(
                                                          hintText: ''),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 150,
                                        child: MyFormField(
                                          controller: totalQuickController,
                                          labelText: "Total Amount",
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.blue, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the total amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_dropdownValue == "Cheque" ||
                                          _dropdownValue == "Bank Transfer")
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            controller:
                                                chequeOrTransactionNumberController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText:
                                                  _dropdownValue == "Cheque"
                                                      ? "Cheque Number"
                                                      : "Transaction Number",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter the number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      if (_dropdownValue == "Cash" ||
                                          _dropdownValue == null)
                                        SizedBox(
                                          width: 200,
                                          child: TextFormField(
                                            controller: remarkController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Remark",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please provide a remark';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (_dropdownValue == "Cheque" ||
                                          _dropdownValue == "Bank Transfer")
                                        Expanded(
                                          child: TextFormField(
                                            controller: dateController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Date",
                                              suffixIcon: IconButton(
                                                icon: const Icon(
                                                    Icons.calendar_today),
                                                onPressed: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      dateController
                                                          .text = DateFormat(
                                                              'dd/MM/yyyy')
                                                          .format(pickedDate);
                                                    });
                                                  }
                                                },
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select a date';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_dropdownValue == "Cheque" ||
                                      _dropdownValue == "Bank Transfer")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: TextFormField(
                                            controller: remarkController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              labelText: "Remark",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please provide a remark';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomCartButton(
                          text: 'Continue Shopping',
                          size: width > 1200 ? 14 : 10,
                          color: primaryColor,
                          onTap: () {
                            if (widget.isFromCustomerDach == true ||
                                widget.isDashboard == true) {
                              widget.onContinueShopping!();
                              Navigator.pop(context);
                              Navigator.of(context, rootNavigator: true).pop();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 30),
                        CustomCartButton(
                          text: 'Save & Send',
                          size: width > 1200 ? 14 : 10,
                          color: const Color(0xff5bc0de),
                          onTap: () async {
                            final cartProvider = Provider.of<CustomersProvider>(
                                context,
                                listen: false);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            );
                            final hasCheckInOutPermission =
                                subscriptionController
                                        .customerCheckInOut.value ==
                                    "true";
                            final isCheckedIn = widget.active == true;

                            log("isCheckedIn: $isCheckedIn");
                            log("hasCheckInOutPermission: $hasCheckInOutPermission");

                            if (isCheckedIn ||
                                (!isCheckedIn && !hasCheckInOutPermission)) {
                              final sanitizedText = totalQuickController.text
                                  .replaceAll(RegExp(r'[^\d.]'), '')
                                  .trim();
                              if (sanitizedText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('Invalid amount entered'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }

                              final finalAmount = double.parse(sanitizedText);
                              final customerId = widget.customerId;
                              // customeController.customerId.isNotEmpty
                              //     ? customeController.customerId.value
                              //     :
                              // widget.productsController
                              //         .selectedCustomerId.value;

                              log("new customerId : $customerId");
                              final cartDetails = await CartDatabaseManager()
                                  .getDraftAndCartIdsFromApi(customerId ?? '');
                              await Future.delayed(const Duration(seconds: 1));
                              final firstOrder = cartDetails.isNotEmpty
                                  ? cartDetails.last
                                  : {'cart_id': '', 'draft_id': ''};
                              final cartIdPrefs = firstOrder['cart_id'] ?? '';
                              final draftIdPrefs = firstOrder['draft_id'] ?? '';
                              // log('Existing cart ID $existingCartId');
                              // log('Existing Draft ID $existingDraftId');
                              if (_selectedValue == "Quick Sale") {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  await processSaveAndSend(
                                    finalAmount: finalAmount,
                                    paymentType: paymentType,
                                    context: context,
                                    cartId: cartIdPrefs,
                                    draftId: draftIdPrefs,
                                  );
                                  cartProvider
                                      .getCartItemCounts(customerId ?? '');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          'Please fill all required fields'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                log('CustomerIdz : $customerId');
                                await processSaveAndSend(
                                  finalAmount: finalAmount,
                                  context: context,
                                  cartId: cartIdPrefs,
                                  draftId: draftIdPrefs,
                                );
                                cartProvider
                                    .getCartItemCounts(customerId ?? '');
                              }
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Center(
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                        size: 60,
                                      ),
                                    ),
                                    content: CustomText(
                                      content:
                                          'Please check-in before processing the order',
                                      fontSize: 18,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedItems({
    required String productName,
    required List<CartItem> groupedItems,
    required double availableWidth,
    required double fontSize,
    required double rowHeight,
    required BuildContext context,
    required dynamic Function(CartItem, String, double, double)
        productQuantityManager,
    required Function(BuildContext, CartItem, List<CartItem>)
        deleteConfirmationDialogue,
    required bool isPreOrder,
    required Function calCulateAmount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Row(
              children: [
                CustomHeaderContainer(
                  text: productName,
                  fontSize: fontSize,
                ),
                const Spacer(),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showVariantDeleteDialog(
                          context,
                          productName,
                          !isOrder,
                          false,
                        );
                      },
                      icon: const Icon(
                        EneftyIcons.trash_bold,
                        size: 28,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 3.5,
              color: lightPrimaryColor,
              width: double.infinity,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: DataTable(
                    headingRowHeight: 30,
                    dataRowHeight: rowHeight,
                    horizontalMargin: 5,
                    columnSpacing: 15,
                    columns: DataTableColumns.getColumns(fontSize),
                    rows: GroupedItemDataRows.getRows(
                      groupedItems: groupedItems,
                      fontSize: availableWidth / 55,
                      availableWidth: availableWidth,
                      context: context,
                      productQuantityManager: productQuantityManager,
                      deleteConfirmationDialogue: deleteConfirmationDialogue,
                      calculateAmount: calCulateAmount,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> processSaveAndSend({
    required BuildContext context,
    required double finalAmount,
    int? paymentType,
    required String cartId,
    required String draftId,
  }) async {
    List<CartItem> itemList = [
      ...orderItems.where((item) => item.isChecked == true),
      ...preorderItems.where((item) => item.isChecked == true),
    ];
    String customerId = widget.customerId ?? '';
    // customeController.customerId.isNotEmpty
    //     ? customeController.customerId.value
    //     : widget.productsController.selectedCustomerId.value;
    final connectivityService = ConnectivityService();
    if (itemList.isNotEmpty &&
        (widget.customerId != ''
        // customeController.customerId.value.isNotEmpty ||
        //   widget.productsController.selectedCustomerId.value.isNotEmpty
        )) {
      try {
        log('[processSaveAndSend] Checking connectivity...');
        bool isOnline = await connectivityService.isOnline();
        if (!isOnline) {
          log('[processSaveAndSend] Device is offline. Saving order offline...');
          await saveOrderOffline(finalAmount, paymentType);
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Offline Mode'),
              content: const Text(
                  'The order will be placed automatically when connected to the internet.'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).pop();
                      _clearCartItem(itemList, customerId);
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
        log('[processSaveAndSend] Preparing data for API call...');
        List<Detail> detail = itemList.map((e) => e.detail).toList();
        log('[processSaveAndSend] Number of items in the order: ${itemList.length}');
        final productBYData = AddToCartModel(
          customerId: customerId,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          cartId: '',
          cartList: await Future.wait(detail.map((e) async {
            String packValue =
                e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();
            return SendCartData(
                productId: e.productId ?? '',
                variantId: e.variationId ?? '',
                pack: packValue,
                price: e.sellPrice.toString(),
                packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                discount: e.discount ?? 0,
                quantity: e.count.toInt(),
                variantName: e.variationName ?? '');
          }).toList()),
          total: finalAmount.toStringAsFixed(0),
        );
        log('[processSaveAndSend] Sending API request with payload: ${productBYData.toJson()}');
        CartOrderModel? cartOrder =
            await ApiWorker().addToCart(productBYData.toJson());
        log('[processSaveAndSend] API response received. Cart ID: ${cartOrder?.cartId}');
        if (cartOrder != null) {
          log('[processSaveAndSend] Preparing order placement...');
          final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
          int orderStatus = _selectedValue == 'Sale Order'
              ? 11
              : _selectedValue == 'Pre Order'
                  ? 0
                  : _selectedValue == 'Estimate'
                      ? 7
                      : 14;

          CartOrderModel order = CartOrderModel(
            customerId: customerId,
            salesmanId: SessionHelper.loginSavedData!.salesmanId!,
            cartId: cartOrder.cartId,
            orderStatus: orderStatus,
            orderPrice: finalAmount,
            paymentType: paymentType.toString(),
            companyId: companyId,
            paymentDetail: remarkController.text.trim(),
            transactionNumber: chequeOrTransactionNumberController.text.trim(),
            transactionDate: dateController.text.trim(),
            draftId: draftId.isNotEmpty ? draftId : '',
          );

          await ApiWorker().placeOrder(order, (statusCode, message, response) {
            Navigator.pop(context);
            if (statusCode == 200) {
              _clearCartItem(itemList, customerId);
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
                      content: message,
                      fontSize: 18,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true).pop();
                          final cartProvider = Provider.of<CustomersProvider>(
                              context,
                              listen: false);
                          cartProvider.getCartItemCounts(customerId);
                          CartDatabaseManager().addListener(() {
                            cartProvider.updateCartCount(customerId);
                          });
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          if (widget.isDashboard == true) {
                            Provider.of<DashboardProvider>(context,
                                    listen: false)
                                .fetchData();
                          } else {
                            Provider.of<CustomersProvider>(context,
                                    listen: false)
                                .fetchCustomerDashboardCountData(customerId);
                          }
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
                      content: message,
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
      } catch (e) {
        Navigator.pop(context);
        log('[processSaveAndSend] Error: $e');
        showFailureDialog(context, 'An unexpected error occurred.');
      }
    } else {
      Navigator.pop(context);
      if (
          // customeController.customerId.value.isEmpty ||
          //   widget.productsController.selectedCustomerId.value.isEmpty
          widget.customerId == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No Customer Selected'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Your cart is empty.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child:
                  Lottie.asset('assets/images/Animation - 1726906882515.json'),
            ),
          ),
          content: CustomText(content: message, fontSize: 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop();
                //_clearCartItem(itemList);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset('assets/images/Warning_animation.json'),
            ),
          ),
          content: CustomText(content: message, fontSize: 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> saveOrderOffline(double finalAmount, int? paymentType) async {
    final isQuickSale = _selectedValue == "Quick Sale";
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderData = {
      'order_id': orderId,
      'customer_id': widget.customerId ?? '',
      // customeController.customerId.isNotEmpty
      //     ? customeController.customerId.value
      //     : widget.productsController.selectedCustomerId.value,
      'salesman_id': SessionHelper.loginSavedData!.salesmanId!,
      'order_price': finalAmount,
      'paymentType': paymentType,
      'cart_list': cartItems
          .map((e) => {
                'product_id': e.detail.productId,
                'variant_id': e.detail.variationId,
                'pack': e.detail.saleBy == 'Pack'
                    ? (e.detail.count * e.detail.pieces!).toString()
                    : e.detail.count.toString(),
                'packType': e.detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                'price': e.detail.sellPrice.toString(),
                'discount': e.detail.discount.toString(),
                'quantity': e.detail.count.toInt(),
              })
          .toList(),
      if (isQuickSale) ...{
        'paymentDetail': remarkController.text.trim(),
        'transactionNumber': chequeOrTransactionNumberController.text.trim(),
        'transactionDate': dateController.text.trim(),
      }
    };

    var offlineBox = await Hive.openBox('offlineOrders');
    await offlineBox.put(orderId, orderData);
    log('[saveOrderOffline] Order saved locally with ID $orderId: $orderData');
  }

  Map<String, dynamic> castToStringDynamic(Map<dynamic, dynamic> input) {
    return input.map((key, value) {
      final newKey = key is String ? key : key.toString();
      final newValue = value is Map
          ? castToStringDynamic(Map<dynamic, dynamic>.from(value))
          : (value is List
              ? value
                  .map((e) => e is Map
                      ? castToStringDynamic(Map<dynamic, dynamic>.from(e))
                      : e)
                  .toList()
              : value);
      return MapEntry<String, dynamic>(newKey, newValue);
    });
  }

  Future<dynamic> deleteConfirmationDialogue(
      BuildContext context, CartItem groupedItem, List<CartItem> groupedItems) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomText(
            content: 'Delete ${groupedItem.detail.variationName}..?',
            fontWeight: FontWeight.w700,
          ),
          actions: [
            Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  content: 'Are you sure you want to delete..?',
                  fontSize: 17,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      final provider = Provider.of<CustomersProvider>(context,
                          listen: false);
                      _deleteVariant(groupedItem, provider);
                      _loadCartItems();
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'))
              ],
            )
          ],
        );
      },
    );
  }

  Future<dynamic> showVariantDeleteDialog(
      BuildContext context, String productName, bool isPreOrder, bool isDraft) {
    String customerId = widget.customerId ?? '';
    // widget.customerOrderController!.customerId.value.isNotEmpty
    //     ? widget.customerOrderController?.customerId.value ?? ''
    //     : widget.productsController.selectedCustomerId.value;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  content: 'Delete "$productName"?',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: CustomText(
            content: 'Are you sure you want to delete this item?',
            fontSize: 15,
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                content: 'Cancel',
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                final provider =
                    Provider.of<CustomersProvider>(context, listen: false);
                _deleteProduct(productName, isPreorder: isPreOrder);
                await provider.updateCartCount(customerId);
                _loadCartItems();
                log('Draft Delete Clicked : $customerId');
                Navigator.pop(context);
                showCustomToastDisplay(
                  context,
                  'Item deleted successfully',
                  Colors.green,
                  Icons.check,
                );
              },
              child: CustomText(
                content: 'Confirm',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteVariant(CartItem variantToDelete, CustomersProvider provider) {
    final String customerId = widget.customerId ?? '';
    // widget.customerOrderController!.customerId.value.isNotEmpty
    //     ? widget.customerOrderController!.customerId.value
    //     : widget.productsController.selectedCustomerId.value;
    setState(() {
      variantToDelete.detail.count = 0;
      CartDatabaseManager().updateCart(variantToDelete);
      cartItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deleteCartItem(variantToDelete);
      List<CartItem> orderItems =
          cartItems.where((item) => item.detail.stock! > 0).toList();
      List<CartItem> preorderItems =
          cartItems.where((item) => item.detail.stock == 0).toList();
      orderSubtotal = Utils().calculateSubtotal(orderItems);
      orderTax = Utils().calculateTotalTax(orderItems);
      preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      preorderTax = Utils().calculateTotalTax(preorderItems);
      provider.updateCartCount(customerId);
    });

    log('Deleted variant: ${variantToDelete.detail.variationName} with stock set to 0');
  }

  Container productQuantityManager(CartItem cartItem, String sellPrice,
      double fontSize, double availableWidth) {
    double padding = availableWidth > 400 ? 6 : 3;
    return Container(
      width: availableWidth > 400 ? 80 : 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromARGB(255, 241, 240, 240)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (cartItem.detail.count > 1) {
                      cartItem.detail.count--;
                      cartItem.totalPrice = Utils().calculateTotalPrice(
                          cartItem, cartItem.detail.count.toInt());
                      calculateAmounts();
                      log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                      log('Draft ID On Cart ${cartItem.draftId}');
                      CartDatabaseManager().updateCart(cartItem);
                      CartDatabaseManager()
                          .getCartItems(cartItem.customerId ?? '');
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: CustomText(
                    color: white,
                    content: '-',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          CustomText(
            content: cartItem.detail.count.toStringAsFixed(0),
            fontSize: fontSize,
          ),
          Container(
            decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    cartItem.detail.count++;
                    cartItem.totalPrice = Utils().calculateTotalPrice(
                        cartItem, cartItem.detail.count.toInt());
                    calculateAmounts();
                    log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                    log('Draft ID On Cart ${cartItem.draftId}');
                    CartDatabaseManager().updateCart(cartItem);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: CustomText(
                    color: white,
                    content: '+',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calculateAmounts() {
    setState(() {
      if (isOrder) {
        orderSubtotal = Utils().calculateSubtotal(orderItems);
        orderTax = Utils().calculateTotalTax(orderItems);
        totalDiscount = Utils().calculateTotalDiscount(orderItems);
      } else {
        preorderSubtotal = Utils().calculateSubtotal(preorderItems);
        preorderTax = Utils().calculateTotalTax(preorderItems);
        totalDiscountPreorder = Utils().calculateTotalDiscount(preorderItems);
      }
    });
  }

  void _clearCartItem(List<CartItem> cartItem, String customerId) async {
    await CartDatabaseManager().clearCart(customerId: customerId);
    log('Cart Item Cleared : $cartItem');
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(customerId);
  }

  void _deleteProduct(String productName, {bool isPreorder = false}) {
    setState(() {
      final variantsToDelete = cartItems.where((item) {
        final isMatchingProduct = item.productName == productName;
        final isPreorderItem = item.detail.stock == 0;
        final isOrderItem = item.detail.stock! > 0;
        return isMatchingProduct &&
            ((isPreorder && isPreorderItem) || (!isPreorder && isOrderItem));
      }).toList();

      if (variantsToDelete.isEmpty) {
        log('No ${isPreorder ? "preorder" : "order"} variants found for product: $productName');
        return;
      }

      for (var variant in variantsToDelete) {
        variant.detail.count = 0;
        CartDatabaseManager().deleteCartItem(variant);
        CartDatabaseManager().updateCart(variant);
      }
      cartItems.removeWhere((item) =>
          item.productName == productName &&
          ((isPreorder && item.detail.stock == 0) ||
              (!isPreorder && item.detail.stock! > 0)));
      final orderItems =
          cartItems.where((item) => item.detail.stock! > 0).toList();
      final preorderItems =
          cartItems.where((item) => item.detail.stock == 0).toList();

      orderSubtotal = Utils().calculateSubtotal(orderItems);
      orderTax = Utils().calculateTotalTax(orderItems);
      preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      preorderTax = Utils().calculateTotalTax(preorderItems);
    });

    log('Deleted all ${isPreorder ? "preorder" : "order"} variants for product: $productName');
  }
}

class CartTextFields extends StatelessWidget {
  const CartTextFields({
    super.key,
    required this.controller,
    required this.text,
  });

  final TextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
