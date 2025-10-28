//Cart Dialog

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
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
  final VoidCallback? onDraftUpdated; // Add callback for draft updates
  CartDialogue({
    super.key,
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
    this.customerId,
    this.onDraftUpdated, // Add callback parameter
  });
  @override
  State<CartDialogue> createState() => CartDialogueState();
}

class CartDialogueState extends State<CartDialogue> {
  List<int> quantities = [];
  List<int> preorderQuantities = [];
  List<int> draftQuantity = [];
  double orderSubtotal = 0.0;
  double orderTax = 0.0;
  double totalDiscount = 0.0;
  double preorderSubtotal = 0.0;
  double preorderTax = 0.0;
  double totalDiscountPreorder = 0.0;
  bool isOrder = true;
  String? _selectedValue;
  String? _dropdownValue;
  int? paymentType;
  final List<String> _options = [
    'Sale Order',
    "Quick Sale",
    'Booking',
    'Estimate'
  ];
  List<String> filteredOptions = [];
  CustomerAndOrderController customeController =
      Get.find<CustomerAndOrderController>();
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

    localCounts =
        List<int>.filled(widget.productsController.cartItems.length, 0);

    _loadCartItems();
    Provider.of<CustomersProvider>(context, listen: false).getCartItemCounts(
        widget.customerId ??
            widget.productsController.selectedCustomerId.value);
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
          : ['Booking', 'Estimate'];
    });
  }

  void _loadCartItems() async {
    try {
      final isOnline = await ConnectivityService().isOnline();

      final customerId = widget.customerId ??
          widget.productsController.selectedCustomerId.value;
      final bool isDraftView = widget.isFromCustomerDach == true && isOnline;

      if (isDraftView) {
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
              draftBox.get(key);
              await draftBox.delete(key);
            }

            for (var detail in details) {
              final cartItem = CartItem(
                detail: Detail(
                  productId: detail['product_id'],
                  variationId: detail['variant_id'],
                  sellPrice: detail['price'],
                  discount: detail['discount'],
                  count: (detail['quantity'] as num?)?.toDouble() ?? 0,
                  pieces: int.tryParse(detail['pack'] ?? '0'),
                  variationName: detail['variant_name'],
                  saleBy: detail['packType'],
                  stock: detail['stock'] ?? 0,
                  unitType: detail['unitType'],
                ),
                productName: detail['variant_name'] ?? '',
                totalPrice:
                    double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
                isPack: detail['packType'] == 'Pack',
                customerId: customerId,
                salesmanId: salesmanId,
                catId: 0,
              );
              await draftBox.add(cartItem);
            }
          }
        }
      }

      // --- End offline draft loading ---

      widget.productsController.cartItems = await CartDatabaseManager()
          .getCartItems(customerId, draftsOnly: isDraftView);

      await setCartToOrderAndPreorder();

      for (var item in widget.productsController.cartItems) {
        item.isChecked = true;
        final count = item.detail.count;
        final pieces = item.detail.pieces ?? 1;
        final sellPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        final tax = item.detail.tax?.toDouble() ?? 0.0;
        final inclTax = item.detail.inclTax;
        if (item.isPack == true || item.detail.packtype == 'Pack') {
          item.totalPrice = (count * pieces * sellPrice);
        } else {
          item.totalPrice = (count * sellPrice);
        }
        if (inclTax != 'incl_tax') {
          if (item.isPack == true || item.detail.packtype == 'Pack') {
            item.totalPrice += (count * pieces * tax);
          } else {
            item.totalPrice += (count * tax);
          }
        }
      }
      for (var item in widget.productsController.preorderItems) {
        item.isChecked = true;
        final count = item.detail.count;
        final pieces = item.detail.pieces ?? 1;
        final sellPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        final tax = item.detail.tax?.toDouble() ?? 0.0;
        final inclTax = item.detail.inclTax;
        if (item.isPack == true || item.detail.packtype == 'Pack') {
          item.totalPrice = (count * pieces * sellPrice);
        } else {
          item.totalPrice = (count * sellPrice);
        }
        if (inclTax != 'incl_tax') {
          if (item.isPack == true || item.detail.packtype == 'Pack') {
            item.totalPrice += (count * pieces * tax);
          } else {
            item.totalPrice += (count * tax);
          }
        }
      }
      orderSubtotal =
          widget.productsController.orderItems.fold(0.0, (sum, item) {
        return item.isChecked! ? sum + (item.totalPrice) : sum;
      });
      preorderSubtotal =
          widget.productsController.preorderItems.fold(0.0, (sum, item) {
        return item.isChecked! ? sum + (item.totalPrice) : sum;
      });
      orderTax = widget.productsController.orderItems.fold(
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
      preorderTax = widget.productsController.preorderItems.fold(
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
      totalDiscount = widget.productsController.orderItems.fold(
        0.0,
        (sum, item) {
          if (item.isChecked != true) return sum;

          final double sellPrice =
              double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
          final double discountPercentage =
              double.tryParse(item.detail.discount?.toString() ?? '0') ?? 0.0;
          final double? maxDiscount = item.detail.maxDiscount?.toDouble();

          // Calculate total quantity
          final double totalQuantity =
              (item.isPack == true || item.detail.packtype == 'Pack')
                  ? (item.detail.pieces?.toDouble() ?? 1) *
                      item.detail.count.toDouble()
                  : item.detail.count.toDouble();

          // Calculate total price before discount
          final double totalPrice = sellPrice * totalQuantity;

          // Calculate discount amount
          double discountAmount = totalPrice * (discountPercentage / 100);

          // Apply max discount cap if applicable
          if (maxDiscount != null &&
              maxDiscount > 0 &&
              discountAmount > maxDiscount) {
            discountAmount = maxDiscount;
          }

          return sum + discountAmount;
        },
      );
      totalDiscountPreorder = widget.productsController.preorderItems.fold(
        0.0,
        (sum, item) {
          if (item.isChecked != true) return sum;

          final double sellPrice =
              double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
          final double discountPercentage =
              double.tryParse(item.detail.discount?.toString() ?? '0') ?? 0.0;
          final double? maxDiscount = item.detail.maxDiscount?.toDouble();

          // Calculate total quantity
          final double totalQuantity =
              (item.isPack == true || item.detail.packtype == 'Pack')
                  ? (item.detail.pieces?.toDouble() ?? 1) *
                      item.detail.count.toDouble()
                  : item.detail.count.toDouble();

          // Calculate total price before discount
          final double totalPrice = sellPrice * totalQuantity;

          // Calculate discount amount
          double discountAmount = totalPrice * (discountPercentage / 100);

          // Apply max discount cap if applicable
          if (maxDiscount != null &&
              maxDiscount > 0 &&
              discountAmount > maxDiscount) {
            discountAmount = maxDiscount;
          }

          return sum + discountAmount;
        },
      );
      setState(() {
        quantities = List.generate(
            widget.productsController.cartItems.length, (index) => 1);
        _isLoading = false;
        widget.productsController.orderItems =
            widget.productsController.orderItems;
        widget.productsController.preorderItems =
            widget.productsController.preorderItems;
        orderSubtotal =
            Utils().calculateSubtotal(widget.productsController.orderItems);
        orderTax =
            Utils().calculateTotalTax(widget.productsController.orderItems);
        preorderSubtotal =
            Utils().calculateSubtotal(widget.productsController.preorderItems);
        preorderTax =
            Utils().calculateTotalTax(widget.productsController.preorderItems);
      });
      if (widget.productsController.orderItems.isNotEmpty) {
        isOrder = true;
        _selectedValue = _options[0];
      } else if (widget.productsController.preorderItems.isNotEmpty) {
        isOrder = false;
        _selectedValue = _options[2];
      }
      setOptions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> setCartToOrderAndPreorder() async {
    List<CartItem> orderItems = [];
    List<CartItem> preorderItems = [];

    for (var item in widget.productsController.cartItems) {
      if ((item.detail.stock ?? 0) > 0) {
        orderItems.add(item);
      } else {
        preorderItems.add(item);
      }
    }

    setState(() {
      widget.productsController.orderItems = orderItems;
      widget.productsController.preorderItems = preorderItems;
    });

    // log("[setCartToOrderAndPreorder] controller preorderItems : ${preorderItems.map((e) => e.toJson()).toList()}");
  }

  @override
  Widget build(BuildContext context) {
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
                  if (widget.productsController.orderItems.isNotEmpty ||
                      widget.productsController.preorderItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            if (widget.productsController.orderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: isOrder ? primaryColor : white,
                                        borderRadius: widget.productsController
                                                .preorderItems.isNotEmpty
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
                                            '${widget.productsController.orderItems.length}',
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
                            if (widget
                                .productsController.preorderItems.isNotEmpty)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                        color: !isOrder ? primaryColor : white,
                                        borderRadius: widget.productsController
                                                .orderItems.isNotEmpty
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
                                            content: 'BOOKINGS',
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
                                            '${widget.productsController.preorderItems.length}',
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
                    (widget.productsController.orderItems.isEmpty)
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
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          height: double.maxFinite,
                                          width: isPhonePortrait(context)
                                              ? fullScreenWidth(context) * 2
                                              : fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: widget
                                                      .productsController
                                                      .orderItems
                                                      .where((item) =>
                                                          (item.detail.stock ??
                                                              0) >
                                                          0)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem> groupedItems = widget
                                                        .productsController
                                                        .orderItems
                                                        .where((item) =>
                                                            item.productName ==
                                                                productName &&
                                                            (item.detail.stock ??
                                                                    0) >
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
                                                children: widget
                                                    .productsController
                                                    .orderItems
                                                    .where((item) =>
                                                        (item.detail.stock ??
                                                            0) >
                                                        0)
                                                    .map((item) =>
                                                        item.productName)
                                                    .toSet()
                                                    .toList()
                                                    .map((productName) {
                                                  List<CartItem> groupedItems =
                                                      widget.productsController
                                                          .orderItems
                                                          .where((item) =>
                                                              item.productName ==
                                                                  productName &&
                                                              (item.detail.stock ??
                                                                      0) >
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
                            width: isPhonePortrait(context)
                                ? fullScreenWidth(context) * 2
                                : fullScreenWidth(context) * 1.15,
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
                    // Container(
                    //   height: 40,
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(10),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 10, left: 10),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         CustomText(
                    //           content: 'Discount',
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //         CustomText(
                    //           content: formatAmount(totalDiscount),
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Flat discount (cart-level)
                    Builder(builder: (context) {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      // if (flatDisc <= 0) return const SizedBox.shrink();
                      return Container(
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
                                content: formatAmount(totalDiscount + flatDisc),
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    // CartTotalWidget(
                    //   title: 'Final Amount',
                    //   content: orderSubtotal,
                    //   fontSize: 20,
                    //   fontWeight: FontWeight.w700,
                    //   color2: Colors.green,
                    // ),
                    Builder(builder: (context) {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      final double finalAmt = (orderSubtotal - flatDisc)
                          .clamp(0.0, double.infinity);
                      return CartTotalWidget(
                        title: 'Final Amount',
                        content: finalAmt,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color2: Colors.green,
                      );
                    }),
                  ],
                  if (!isOrder) ...[
                    (widget.productsController.preorderItems.isEmpty)
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: CustomText(
                                content: 'No bookings items available.',
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
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: _scrollController4,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          // color: red,
                                          height: double.maxFinite,
                                          width: isPhonePortrait(context)
                                              ? fullScreenWidth(context) * 2
                                              : fullScreenWidth(context) * 1.15,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: widget
                                                      .productsController
                                                      .preorderItems
                                                      .where((item) =>
                                                          item.detail.stock ==
                                                              0 ||
                                                          item.detail.stock ==
                                                              null)
                                                      .map((item) =>
                                                          item.productName)
                                                      .toSet()
                                                      .toList()
                                                      .map((productName) {
                                                    List<CartItem>
                                                        groupedItems = widget
                                                            .productsController
                                                            .preorderItems
                                                            .where((item) =>
                                                                item.productName ==
                                                                productName)
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
                                                        isPreOrder: true,
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
                                                children: widget
                                                    .productsController
                                                    .preorderItems
                                                    .where((item) =>
                                                        item.detail.stock ==
                                                            0 ||
                                                        item.detail.stock ==
                                                            null)
                                                    .map((item) =>
                                                        item.productName)
                                                    .toSet()
                                                    .toList()
                                                    .map((productName) {
                                                  List<CartItem> groupedItems =
                                                      widget.productsController
                                                          .preorderItems
                                                          .where((item) =>
                                                              item.productName ==
                                                              productName)
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
                            width: isPhonePortrait(context)
                                ? fullScreenWidth(context) * 2
                                : fullScreenWidth(context) * 1.15,
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
                    // Container(
                    //   height: 40,
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(10),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 10, left: 10),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         CustomText(
                    //           content: 'Discount',
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //         CustomText(
                    //           content: formatAmount(totalDiscountPreorder),
                    //           fontSize: 16,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Flat discount (cart-level)
                    Builder(builder: (context) {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      // if (flatDisc <= 0) return const SizedBox.shrink();
                      return Container(
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
                                content: formatAmount(totalDiscount + flatDisc),
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    // CartTotalWidget(
                    //   title: 'Final Amount',
                    //   content: preorderSubtotal,
                    //   fontSize: 20,
                    //   fontWeight: FontWeight.w700,
                    //   color2: Colors.green,
                    // ),
                    Builder(builder: (context) {
                      final String cid =
                          widget.productsController.selectedCustomerId.value;
                      final double flatDisc = widget
                              .productsController.flatDiscountByCustomer[cid] ??
                          0.0;
                      final double finalAmt = (preorderSubtotal - flatDisc)
                          .clamp(0.0, double.infinity);
                      return CartTotalWidget(
                        title: 'Final Amount',
                        content: finalAmt,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color2: Colors.green,
                      );
                    }),
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
                            final hasCheckInOutPermission =
                                subscriptionController
                                        .customerCheckInOut.value ==
                                    "true";
                            final isCheckedIn = widget.active == true;

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
                              final customerId = widget.customerId ??
                                  widget.productsController.selectedCustomerId
                                      .value;

                              final cartDetails = await CartDatabaseManager()
                                  .getDraftAndCartIdsFromApi(customerId);
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
                                  cartProvider.getCartItemCounts(customerId);
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
                                await processSaveAndSend(
                                  finalAmount: finalAmount,
                                  context: context,
                                  cartId: cartIdPrefs,
                                  draftId: draftIdPrefs,
                                );
                                cartProvider.getCartItemCounts(customerId);
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
                  text:
                      productName.startsWith('Bundle') ? "Bundle" : productName,
                  fontSize: isPhonePortrait(context) ? 14 : fontSize,
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
                child: DataTable(
                  headingRowHeight: 30,
                  dataRowHeight: rowHeight,
                  horizontalMargin: 5,
                  columnSpacing: 15,
                  columns: DataTableColumns.getColumns(
                      isPhonePortrait(context) ? 12 : fontSize,
                      isBundle: productName.startsWith('Bundle')),
                  rows: GroupedItemDataRows.getRows(
                    groupedItems: groupedItems,
                    fontSize:
                        isPhonePortrait(context) ? 12 : availableWidth / 55,
                    availableWidth: isPhonePortrait(context)
                        ? fullScreenWidth(context) * 2
                        : availableWidth,
                    context: context,
                    productQuantityManager: productQuantityManager,
                    deleteConfirmationDialogue: deleteConfirmationDialogue,
                    calculateAmount: calCulateAmount,
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
    // Determine which items to process based on the active tab (_selectedValue)
    List<CartItem> itemList;
    String customerId = (widget.customerId != null && widget.customerId != '')
        ? widget.customerId ??
            widget.productsController.selectedCustomerId.value
        : widget.productsController.selectedCustomerId.value;
    if (_selectedValue == 'Sale Order' ||
        _selectedValue == 'Quick Sale' ||
        _selectedValue == 'Estimate') {
      itemList = [
        ...widget.productsController.orderItems
            .where((item) => item.isChecked == true)
      ];
    } else if (_selectedValue == 'Booking') {
      itemList = [
        ...widget.productsController.preorderItems
            .where((item) => item.isChecked == true)
      ];
    } else {
      itemList = [];
    }
    // Debug logging
    final connectivityService = ConnectivityService();
    if (itemList.isNotEmpty &&
        (customeController.customerId.value.isNotEmpty ||
            widget.productsController.selectedCustomerId.value.isNotEmpty)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      try {
        bool isOnline = await connectivityService.isOnline();

        if (!isOnline) {
          int status = _selectedValue == 'Sale Order'
              ? 11
              : _selectedValue == 'Booking'
                  ? 0
                  : _selectedValue == 'Estimate'
                      ? 7
                      : 14;
          await saveOrderOffline(finalAmount, paymentType, status);
          Navigator.pop(context);
          showDialog(
            barrierDismissible: false,
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
                    // Call the callback to refresh the draft list
                    if (widget.onDraftUpdated != null) {
                      widget.onDraftUpdated!();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (widget.productsController.orderItems.isEmpty &&
              widget.productsController.preorderItems.isEmpty) {
            clearEntireCartForCustomer();
          }
          return;
        } else {
          final productBYData = AddToCartModel(
            customerId: customerId,
            salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
            cartId: '',
            cartList: await Future.wait(itemList.map((item) async {
              final e = item.detail; // for easier reference

              String packValue =
                  e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();

              if (item.isPromo == true) {
                bool isBundle = item.promoMsg != null &&
                    item.promoMsg!.startsWith("Bundle");

                if (isBundle) {
                  return SendCartData(
                    productId: e.productId ?? '',
                    variantId: e.variationId ?? '',
                    pack: packValue,
                    price: e.sellPrice.toString(),
                    packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                    discount: e.discount ?? 0,
                    quantity: e.count.toInt(),
                    variantName: e.variationName ?? '',
                    maxDiscount: e.maxDiscount?.toInt(),
                    isPromo: true,
                    promoCode: item.promoCode ?? '',
                    promoMsg: "Bundle: ${e.variationName}",
                    isBundle: isBundle,
                    bundleDetails:
                        isBundle ? "Bundle: ${e.variationName}" : null,
                  );
                } else {
                  return SendCartData(
                    productId: e.productId ?? '',
                    variantId: e.variationId ?? '',
                    pack: packValue,
                    price: e.sellPrice.toString(),
                    packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                    discount: e.discount ?? 0,
                    quantity: e.count.toInt(),
                    variantName: e.variationName ?? '',
                    maxDiscount: e.maxDiscount?.toInt(),
                    isPromo: true,
                    promoCode: item.promoCode ?? '',
                    promoMsg: item.promoMsg ?? '',
                  );
                }
              } else {
                // ✅ Normal items
                return SendCartData(
                  productId: e.productId ?? '',
                  variantId: e.variationId ?? '',
                  pack: packValue,
                  price: e.sellPrice.toString(),
                  packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                  discount: e.discount ?? 0,
                  quantity: e.count.toInt(),
                  variantName: e.variationName ?? '',
                  isPromo: false,
                  promoCode: "",
                );
              }
            }).toList()),
            total: finalAmount.toStringAsFixed(0),
          );

          List<String> variantIdsPass = [];

          final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

          for (var item in itemList) {
            final variantId = item.detail.variationId ?? '';
            if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
              variantIdsPass.add(variantId);
            }

            if (item.isPromo == true &&
                (item.promoMsg?.startsWith('Bundle') ?? false)) {
              final promoMsg = item.promoMsg ?? '';
              for (final m in variantIdRegex.allMatches(promoMsg)) {
                final extracted = m.group(1);
                if (extracted != null && extracted.isNotEmpty) {
                  variantIdsPass.add(extracted);
                }
              }
            }
          }

          variantIdsPass = variantIdsPass.toSet().toList();

          CartOrderModel? cartOrder =
              await ApiWorker().addToCart(productBYData.toJson());

          if (cartOrder != null) {
            final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
            int orderStatus = _selectedValue == 'Sale Order'
                ? 11
                : _selectedValue == 'Booking'
                    ? 0
                    : _selectedValue == 'Estimate'
                        ? 7
                        : 14;

            CartOrderModel order = CartOrderModel(
              customerId: customerId,
              salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
              cartId: cartOrder.cartId,
              orderStatus: orderStatus,
              orderPrice: finalAmount,
              paymentType: paymentType.toString(),
              companyId: companyId,
              paymentDetail: remarkController.text.trim(),
              transactionNumber:
                  chequeOrTransactionNumberController.text.trim(),
              transactionDate: dateController.text.trim(),
              draftId: draftId.isNotEmpty ? draftId : '',
              varientIds: variantIdsPass,
            );

            await ApiWorker().placeOrder(order,
                (statusCode, message, response) async {
              Navigator.pop(context);
              if (statusCode == 200) {
                _clearCartItem(itemList, customerId);

                // Update cached drafts after successful order placement
                try {
                  final apiService = ApiService();
                  final salesmanId =
                      SessionHelper.loginSavedData?.salesmanId ?? '';

                  final now = DateTime.now();
                  final startDate = DateTime(now.year, 1, 1);
                  final endDate = DateTime(now.year, 12 + 1, 0);

                  final formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);

                  // Determine order type based on _selectedValue
                  String orderType;
                  switch (_selectedValue) {
                    case 'Sale Order':
                      orderType = 'sale_order';
                      break;
                    case 'Quick Sale':
                      orderType = 'quick_sale';
                      break;
                    case 'Booking':
                      orderType = 'booking';
                      break;
                    case 'Estimate':
                      orderType = 'estimate';
                      break;
                    default:
                      orderType = 'draft';
                  }

                  await apiService.updateCachedDraftsAfterSaveAndSend(
                    context,
                    customerId: customerId,
                    draftId: draftId.isNotEmpty ? draftId : '',
                    salesmanId: salesmanId,
                    startDate: formattedStartDate,
                    endDate: formattedEndDate,
                    orderType: orderType,
                    sentCartIds: [
                      cartOrder.cartId
                    ], // The cart ID that was just sent
                    sentAmount: finalAmount,
                  );
                } catch (e) {
                  // Don't show error to user as this is a background operation
                }

                showDialog(
                  barrierDismissible: false,
                  context: context,
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
                            // Navigator.pop(context);
                            final cartProvider = Provider.of<CustomersProvider>(
                                context,
                                listen: false);

                            CartDatabaseManager().addListener(() {
                              cartProvider.updateCartCount(customerId);
                            });
                            if (widget.isDashboard == true) {
                              Provider.of<DashboardProvider>(context,
                                      listen: false)
                                  .fetchData();
                            } else {
                              Provider.of<CustomersProvider>(context,
                                      listen: false)
                                  .fetchCustomerDashboardCountData(customerId);
                            }

                            // if (cartItemCount != 0) {
                            //   // final cartItems = await CartDatabaseManager()
                            //   //     .getCartItems(customerId);

                            //   // bool hasRelevantItems;
                            //   // if (isOrder) {
                            //   //   hasRelevantItems = cartItems.any(
                            //   //       (item) => (item.detail.stock ?? 0) > 0);
                            //   // } else {
                            //   //   hasRelevantItems = cartItems.any(
                            //   //       (item) => (item.detail.stock ?? 0) == 0);
                            //   // }

                            //   // if (!hasRelevantItems) {
                            //   //   setState(() {
                            //   //     isOrder = !isOrder;
                            //   //   });
                            //   // }
                            //   bool isOnline =
                            //       await ConnectivityService().isOnline();
                            //   if (isOnline) {
                            //     Navigator.of(context, rootNavigator: true)
                            //         .pop();
                            //     if (Navigator.canPop(context)) {
                            //       Navigator.pop(context);
                            //     }
                            //     widget.onDraftUpdated;
                            //   }
                            // }

                            // if (cartItemCount == 0) {
                            //   Navigator.of(context, rootNavigator: true).pop();
                            //   if (Navigator.canPop(context)) {
                            //     Navigator.pop(context);
                            //   }
                            // }
                            setState(() {
                              Navigator.pop(context);
                              Navigator.of(context, rootNavigator: true).pop();
                            });
                            if (widget.onDraftUpdated != null) {
                              widget.onDraftUpdated!();
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
                  barrierDismissible: false,
                  context: context,
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
        }
      } catch (e) {
        Navigator.pop(context);
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

  Future<void> clearEntireCartForCustomer() async {
    String customerId = customeController.customerId.isNotEmpty
        ? customeController.customerId.value
        : widget.productsController.selectedCustomerId.value;
    await CartDatabaseManager().clearAllItemsForCustomer(customerId);
    setState(() {
      widget.productsController.cartItems.clear();
      widget.productsController.orderItems.clear();
      widget.productsController.preorderItems.clear();
    });
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(customerId);
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

  Future<void> saveOrderOffline(
      double finalAmount, int? paymentType, int? status) async {
    final isQuickSale = _selectedValue == "Quick Sale";
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final businessName = widget.productsController.selectedCustomerName.value;
    final email = (widget.productsController.selectedCustomerEmail.value);
    final mobileNo = (widget.productsController.selectedCustomerMobileNo.value);
    final imageUrl = widget.productsController.selectedCustomerImageUrl.value;
    final createdAt = DateTime.now().toIso8601String();

    // Determine which items to process based on the active tab
    List<CartItem> processedItems;
    if (_selectedValue == 'Sale Order' ||
        _selectedValue == 'Quick Sale' ||
        _selectedValue == 'Estimate') {
      // For order tab - process order items (items with stock > 0)
      processedItems = widget.productsController.orderItems
          .where((item) => item.isChecked == true)
          .toList();
    } else {
      // For booking tab - process booking items (items with stock == 0)
      processedItems = widget.productsController.preorderItems
          .where((item) => item.isChecked == true)
          .toList();
    }

    // Save the order to offline orders box
    Map<String, dynamic> orderData = {
      'order_id': orderId,
      'customer_id': widget.productsController.selectedCustomerId.value,
      'businessName': businessName,
      'email': email,
      'mobileNo': mobileNo,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'salesman_id': SessionHelper.loginSavedData?.salesmanId ?? '',
      'order_price': Utils().calculateSubtotal(processedItems),
      // finalAmount,
      'paymentType': paymentType,
      'order_status': status,
      'cart_list': processedItems
          .map((e) => {
                'product_id': e.detail.productId,
                'product_name': e.productName,
                'variant_id': e.detail.variationId,
                'variant_name': e.detail.variationName,
                'pack': e.detail.saleBy == 'Pack'
                    ? (e.detail.count * (e.detail.pieces ?? 1)).toString()
                    : e.detail.count.toString(),
                'perPack': e.detail.saleBy == 'Pack'
                    ? (e.detail.pieces).toString()
                    : e.detail.count.toString(),
                'packType': e.detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                'price': e.detail.sellPrice.toString(),
                'discount': '0',
                'quantity': e.detail.count.toInt(),
                'tax': e.detail.tax?.toInt(),
                'unitTax': e.detail.unitTax?.toInt(),
                'inclTax': e.detail.inclTax,
                'totalTax': (e.detail.tax ?? 0) *
                    (e.isPack == true || e.detail.packtype == 'Pack'
                        ? (e.detail.pieces ?? 0) * e.detail.count
                        : 1),
                'discountPrice':
                    (((double.tryParse(e.detail.sellPrice?.toString() ?? '0') ??
                                0.0) *
                            ((double.tryParse(
                                        e.detail.discount?.toString() ?? '0') ??
                                    0.0) /
                                100)) *
                        ((e.isPack == true || e.detail.packtype == 'Pack')
                            ? (e.detail.pieces?.toDouble() ?? 1) *
                                e.detail.count.toDouble()
                            : e.detail.count.toDouble())),
                'totalPrice': e.detail.totalPrice,
                'isPack': e.isPack,
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

    for (final item in processedItems) {
      CartDatabaseManager().deleteCartItem(item);
    }

    setState(() {
      widget.productsController.cartItems
          .removeWhere((item) => processedItems.contains(item));
      widget.productsController.orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      widget.productsController.preorderItems = widget
          .productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();
    });

    // Update cached drafts after offline save
    try {
      final apiService = ApiService();
      final customerId = widget.productsController.selectedCustomerId.value;
      final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

      final now = DateTime.now();
      final startDate = DateTime(now.year, 1, 1);
      final endDate = DateTime(now.year, 12 + 1, 0);

      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // Determine order type based on _selectedValue
      String orderType;
      switch (_selectedValue) {
        case 'Sale Order':
          orderType = 'sale_order';
          break;
        case 'Quick Sale':
          orderType = 'quick_sale';
          break;
        case 'Booking':
          orderType = 'booking';
          break;
        case 'Estimate':
          orderType = 'estimate';
          break;
        default:
          orderType = 'draft';
      }

      // For offline orders, we don't have a cart ID yet, so we'll use the order ID
      // The actual cart ID will be assigned when the order is synced online
      await apiService.updateCachedDraftsAfterSaveAndSend(
        context,
        customerId: customerId,
        draftId: orderId,
        salesmanId: salesmanId,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        orderType: orderType,
        sentCartIds: [orderId],
        sentAmount: finalAmount,
      );
    } catch (e) {
      //
    }

    {
      String checkCustomerId = customeController.customerId.isNotEmpty
          ? customeController.customerId.value
          : widget.productsController.selectedCustomerId.value;

      // Get remaining items that were not processed (not in the current order)
      List<CartItem> remainingItems = widget.productsController.cartItems
          .where((item) => !processedItems.contains(item))
          .toList();

      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      int existingDraftIndex =
          drafts.indexWhere((draft) => draft['customer_id'] == checkCustomerId);

      if (existingDraftIndex != -1) {
        List<dynamic> detailsAfterProcessing = [];

        var newCartItems = remainingItems;

        for (var item in newCartItems) {
          item.isChecked = true;
        }

        if (newCartItems.isEmpty || newCartItems == []) {
          drafts.removeAt(existingDraftIndex);
        } else {
          drafts[existingDraftIndex]['displayData'] = {
            'customerId': checkCustomerId,
            'customerName': businessName,
            'mobileNo': mobileNo,
            'email': email,
            'imageUrl': imageUrl,
            'displayTotal': Utils().calculateSubtotal(newCartItems),
            'createdDate': DateTime.now().toIso8601String(),
          };

          for (var detail in newCartItems) {
            detailsAfterProcessing.add({
              'product_id': detail.detail.productId ?? '',
              'variant_id': detail.detail.variationId ?? '',
              'pack': detail.detail.saleBy == 'Pack'
                  ? detail.detail.pieces.toString()
                  : detail.detail.count.toString(),
              'packType': detail.detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': detail.detail.sellPrice.toString(),
              'discount': detail.detail.discount,
              'quantity': detail.detail.count.toInt(),
              'variant_name': detail.detail.variationName ?? '',
              'stock': detail.detail.stock ?? 0,
              'unitType': detail.detail.unitType,
              'product_name': detail.detail.productName,
              'tax': detail.detail.tax,
              'incl_tax': detail.detail.inclTax,
              'pieces': detail.detail.pieces,
            });
          }

          drafts[existingDraftIndex]['details'] = detailsAfterProcessing;
        }

        await offlineDraftsBox.put('drafts', drafts);
      }
    }
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
                      widget.productsController.isCartModified.value = true;
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
                Navigator.pop(context);
                widget.productsController.isCartModified.value = true;
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
    setState(() {
      variantToDelete.detail.count = 0;
      CartDatabaseManager().updateCart(variantToDelete);
      widget.productsController.cartItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deleteCartItem(variantToDelete);
      List<CartItem> orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      List<CartItem> preorderItems = widget.productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();
      orderSubtotal = Utils().calculateSubtotal(orderItems);
      orderTax = Utils().calculateTotalTax(orderItems);
      preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      preorderTax = Utils().calculateTotalTax(preorderItems);
      provider.updateCartCount(customerId);
    });

    // If no remaining items carry a flat discount promo, clear it
    _maybeClearFlatDiscountForCustomer(customerId);
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
                      CartDatabaseManager().updateCart(cartItem);
                      CartDatabaseManager()
                          .getCartItems(cartItem.customerId ?? '');
                      widget.productsController.isCartModified.value = true;
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
                    CartDatabaseManager().updateCart(cartItem);
                    widget.productsController.isCartModified.value = true;
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
        orderSubtotal =
            Utils().calculateSubtotal(widget.productsController.orderItems);
        orderTax =
            Utils().calculateTotalTax(widget.productsController.orderItems);
        totalDiscount = Utils()
            .calculateTotalDiscount(widget.productsController.orderItems);
      } else {
        preorderSubtotal =
            Utils().calculateSubtotal(widget.productsController.preorderItems);
        preorderTax =
            Utils().calculateTotalTax(widget.productsController.preorderItems);
        totalDiscountPreorder = Utils()
            .calculateTotalDiscount(widget.productsController.preorderItems);
      }
    });
  }

  void _clearCartItem(List<CartItem> cartItem, String customerId) async {
    for (final item in cartItem) {
      CartDatabaseManager().deleteCartItem(item);
    }
    setState(() {
      widget.productsController.cartItems
          .removeWhere((item) => cartItem.contains(item));
      widget.productsController.orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      widget.productsController.preorderItems = widget
          .productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();
    });
    // Clear flat discount if its source items are gone
    _maybeClearFlatDiscountForCustomer(customerId);
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(customerId);
  }

  void _deleteProduct(String productName, {bool isPreorder = false}) {
    setState(() {
      final variantsToDelete =
          widget.productsController.cartItems.where((item) {
        final isMatchingProduct = item.productName == productName;
        final isPreorderItem = item.detail.stock == 0;
        final isOrderItem = (item.detail.stock ?? 0) > 0;
        return isMatchingProduct &&
            ((isPreorder && isPreorderItem) || (!isPreorder && isOrderItem));
      }).toList();

      if (variantsToDelete.isEmpty) {
        return;
      }

      for (var variant in variantsToDelete) {
        variant.detail.count = 0;
        CartDatabaseManager().deleteCartItem(variant);
        CartDatabaseManager().updateCart(variant);
      }
      widget.productsController.cartItems.removeWhere((item) =>
          item.productName == productName &&
          ((isPreorder && item.detail.stock == 0) ||
              (!isPreorder && (item.detail.stock ?? 0) > 0)));
      final orderItems = widget.productsController.cartItems
          .where((item) => (item.detail.stock ?? 0) > 0)
          .toList();
      final preorderItems = widget.productsController.cartItems
          .where((item) => item.detail.stock == 0)
          .toList();

      orderSubtotal = Utils().calculateSubtotal(orderItems);
      orderTax = Utils().calculateTotalTax(orderItems);
      preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      preorderTax = Utils().calculateTotalTax(preorderItems);
    });

    // Clear flat discount if its source items are gone
    final String cid =
        widget.customerId ?? widget.productsController.selectedCustomerId.value;
    _maybeClearFlatDiscountForCustomer(cid);
  }

  /// Clears cart-level flat discount for a customer if no remaining items
  /// are associated with the flat discount promo (based on promoMsg marker).
  void _maybeClearFlatDiscountForCustomer(String customerId) {
    try {
      final hasFlatPromoItems = widget.productsController.cartItems.any((item) {
        final msg = item.promoMsg?.toLowerCase() ?? '';
        return msg.contains('flat discount');
      });
      if (!hasFlatPromoItems) {
        if (widget.productsController.flatDiscountByCustomer
            .containsKey(customerId)) {
          widget.productsController.flatDiscountByCustomer.remove(customerId);
          setState(() {});
        }
      }
    } catch (_) {}
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
