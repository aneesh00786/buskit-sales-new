import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:dio/dio.dart';
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
  });
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
  double orderFinalAmount = 0.0;
  double preorderSubtotal = 0.0;
  double preorderTax = 0.0;
  double preorderFinalAmount = 0.0;
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
  final TextEditingController totalQuickController = TextEditingController();
  final TextEditingController chequeOrTransactionNumberController =
      TextEditingController();
  final TextEditingController cashRemarkController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  bool _isLoading = true;
  bool isDraft = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    log('Customer ID in INitstate : ${widget.customerOrderController?.customerId.value ?? ''}');
    _loadCartItems();
    calculateAmounts();
    _selectedValue = isOrder ? _options[0] : _options[2];
    setOptions();
    log('CartList Length : ${cartItems.length}');
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
      final customerId =
          widget.customerOrderController!.customerId.value.isNotEmpty
              ? widget.customerOrderController!.customerId.value
              : widget.productsController.selectedCustomerId.value;
      cartItems = await CartDatabaseManager().getCartItems(customerId);
      List<CartItem> draftItems = !widget.isDashboard
          ? await CartDatabaseManager().getDraftItems(customerId)
          : await CartDatabaseManager().getAllDraftItems();
      final Map<String, CartItem> uniqueItems = {
        for (var item in cartItems)
          '${item.detail.variationName}_${item.detail.sellPrice}': item,
        for (var draft in draftItems)
          '${draft.detail.variationName}_${draft.detail.sellPrice}': draft,
      };
      cartItems = uniqueItems.values.toList();
      orderItems = cartItems.where((item) => item.detail.stock! > 0).toList();
      preorderItems =
          cartItems.where((item) => item.detail.stock == 0).toList();
      double orderSubtotal = Utils().calculateSubtotal(orderItems);
      double orderTax = Utils().calculateTotalTax(orderItems);
      double preorderSubtotal = Utils().calculateSubtotal(preorderItems);
      double preorderTax = Utils().calculateTotalTax(preorderItems);
      setState(() {
        quantities = List.generate(cartItems.length, (index) => 1);
        _isLoading = false;
        this.orderSubtotal = orderSubtotal;
        this.orderTax = orderTax;
        this.orderFinalAmount = orderSubtotal;
        this.preorderSubtotal = preorderSubtotal;
        this.preorderTax = preorderTax;
        this.preorderFinalAmount = preorderSubtotal;
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
    double dialogWidth;
    double dialogHeight;
    if (width > 1200) {
      dialogWidth = width * 0.6;
      dialogHeight = height * 0.8;
    } else if (width > 650) {
      dialogWidth = width * 0.85;
      dialogHeight = height * 0.7;
    } else {
      dialogWidth = width * 0.9;
      dialogHeight = height * 0.5;
    }
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double availableHeight = constraints.maxHeight;
          double fontSize = availableWidth / 50;
          double rowHeight = availableHeight / 14;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
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
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  if (orderItems.isNotEmpty)
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: primaryColor),
                                              color: isOrder
                                                  ? primaryColor
                                                  : white,
                                              borderRadius: preorderItems
                                                      .isNotEmpty
                                                  ? const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      bottomLeft:
                                                          Radius.circular(20),
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
                                                  color: isOrder
                                                      ? white
                                                      : primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Order count
                                          Positioned(
                                            right: 8,
                                            top: 8,
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
                                              border: Border.all(
                                                  color: primaryColor),
                                              color: !isOrder
                                                  ? primaryColor
                                                  : white,
                                              borderRadius: orderItems
                                                      .isNotEmpty
                                                  ? const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(20),
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
                                                  color: isOrder
                                                      ? primaryColor
                                                      : white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Pre-order count
                                          Positioned(
                                            right: 8,
                                            top: 8,
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
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(),
                    ],
                    if (isOrder) ...[
                      (cartItems
                              .where((item) => item.detail.stock! > 0)
                              .isEmpty)
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
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: orderItems
                                        .where((item) => item.detail.stock! > 0)
                                        .map((item) => item.productName)
                                        .toSet()
                                        .toList()
                                        .map((productName) {
                                      List<CartItem> groupedItems = cartItems
                                          .where((item) =>
                                              item.productName == productName &&
                                              item.detail.stock! > 0)
                                          .toList();

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: _buildGroupedItems(
                                          productName: productName,
                                          groupedItems: groupedItems,
                                          availableWidth: availableWidth,
                                          fontSize: fontSize,
                                          rowHeight: rowHeight,
                                          context: context,
                                          productQuantityManager:
                                              productQuantityManager,
                                          deleteConfirmationDialogue:
                                              deleteConfirmationDialogue,
                                          isPreOrder: false,
                                          calCulateAmount: calculateAmounts,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
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
                        content: double.parse(
                            orderFinalAmount.toStringAsFixed(2) ?? ''),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color2: Colors.green,
                      ),
                    ],
                    if (!isOrder) ...[
                      (cartItems
                              .where((item) => item.detail.stock == 0)
                              .isEmpty)
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
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: preorderItems
                                        .where((item) => item.detail.stock == 0)
                                        .map((item) => item.productName)
                                        .toSet()
                                        .toList()
                                        .map((productName) {
                                      List<CartItem> groupedItems = cartItems
                                          .where((item) =>
                                              item.productName == productName &&
                                              item.detail.stock == 0)
                                          .toList();

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: _buildGroupedItems(
                                          productName: productName,
                                          groupedItems: groupedItems,
                                          availableWidth: availableWidth,
                                          fontSize: fontSize,
                                          rowHeight: rowHeight,
                                          context: context,
                                          productQuantityManager:
                                              productQuantityManager,
                                          deleteConfirmationDialogue:
                                              deleteConfirmationDialogue,
                                          isPreOrder: true,
                                          calCulateAmount: calculateAmounts,
                                        ),
                                      );
                                    }).toList(),
                                  ),
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
                        content: double.parse(
                            preorderFinalAmount?.toStringAsFixed(2) ?? ''),
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
                                  ? '\$${double.parse(orderSubtotal.toString())}'
                                  : '\$${double.parse(preorderSubtotal.toString())}';
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
                                        setState(() {
                                          _selectedValue = value!;
                                          _dropdownValue = null;
                                          totalQuickController.clear();
                                        });
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0),
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    hint: const Text(
                                                        "Payment method"),
                                                    value: _dropdownValue,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        _dropdownValue =
                                                            newValue!;
                                                        switch (
                                                            _dropdownValue) {
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
                                                    color: Colors.blue,
                                                    width: 1),
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
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
                                                      initialDate:
                                                          DateTime.now(),
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
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
                            text: 'Save & Send',
                            size: width > 1200 ? 14 : 10,
                            onTap: () async {
                              if (widget.active == true) {
                                final customerId =
                                    customeController.customerId.isNotEmpty
                                        ? customeController.customerId.value
                                        : widget.productsController
                                            .selectedCustomerId.value;
                                final savedCartData =
                                    await CartDatabaseManager()
                                        .getCartAndDraftIds(customerId);
                                final cartId = savedCartData?['cart_id'] ?? '';
                                final draftId = savedCartData?['id'] ?? '';
                                if (_selectedValue == "Quick Sale") {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    await processSaveAndSend(
                                      finalAmount: 0,
                                      //finalAmount ?? 0,
                                      paymentType: paymentType,
                                      context: context,
                                      cartId: cartId,
                                      draftId: draftId,
                                    );
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
                                      finalAmount: 0,
                                      //finalAmount ?? 0,
                                      context: context,
                                      cartId: cartId,
                                      draftId: draftId);
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
                          const SizedBox(width: 30),
                          CustomCartButton(
                            text: 'Continue Shopping',
                            size: width > 1200 ? 14 : 10,
                            color: primaryColor,
                            onTap: () {
                              if (widget.isFromCustomerDach == true) {
                                Navigator.pop(context);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                widget.onContinueShopping!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomHeaderContainer(
                    text: productName,
                    fontSize: fontSize,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showVariantDeleteDialog(
                          context,
                          productName,
                          false,
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
    List<CartItem> itemList =
        cartItems.where((item) => item.isChecked ?? true).toList();
    final connectivityService = ConnectivityService();

    if (itemList.isNotEmpty &&
        (customeController.customerId.value.isNotEmpty ||
            widget.productsController.selectedCustomerId.value.isNotEmpty)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        log('[processSaveAndSend] Checking connectivity...');
        bool isOnline = await connectivityService.isOnline();

        if (!isOnline) {
          log('[processSaveAndSend] Device is offline. Saving order offline...');
          await saveOrderOffline(finalAmount, paymentType);
          Navigator.pop(context);
          _clearCartItem(itemList, true);

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
                      _clearCartItem(itemList, true);
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
          customerId: customeController.customerId.isNotEmpty
              ? customeController.customerId.value
              : widget.productsController.selectedCustomerId.value,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          cartId: cartId.isNotEmpty ? cartId : '',
          cartList: await Future.wait(detail.map((e) async {
            String packValue = e.saleBy == 'Pack'
                ? (await _getPackPiecesValue(
                        e.productId ?? '', e.count.toInt()))
                    .toString()
                : e.count.toString();

            return SendCartData(
              productId: e.productId ?? '',
              variantId: e.variationId ?? '',
              pack: packValue,
              price: e.sellPrice.toString(),
              packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              discount: '0',
              quantity: e.count.toInt(),
            );
          }).toList()),
          total: finalAmount.toStringAsFixed(0),
          discount: '0',
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
            customerId: customeController.customerId.isNotEmpty
                ? customeController.customerId.value
                : widget.productsController.selectedCustomerId.value,
            salesmanId: SessionHelper.loginSavedData!.salesmanId!,
            cartId: cartId.isNotEmpty ? cartId : cartOrder.cartId,
            orderStatus: orderStatus,
            orderPrice: finalAmount,
            paymentType: paymentType.toString(),
            companyId: companyId,
            paymentDetail: remarkController.text.trim(),
            transactionNumber: chequeOrTransactionNumberController.text.trim(),
            transactionDate: dateController.text.trim(),
            draftId: draftId.isNotEmpty ? draftId : '',
          );
          log('ItemList Sent List: ${itemList.map((e) => 'ProductName: ${e.productName}, '
              'Cart ID: ${e.cartId}, '
              'Customer ID: ${e.customerId}, '
              'Draft ID: ${e.draftId}, '
              'Variation: ${e.detail.variationName}, '
              'Price: ${e.detail.sellPrice}, '
              'Quantity: ${e.detail.count}, '
              'Total: ${e.totalPrice}, '
              'IsPack: ${e.isPack}, '
              'Pieces: ${e.detail.pieces ?? 'N/A'}').join('\n')}');
          await placeOrder(order, (statusCode, message, response) {
            Navigator.pop(context);
            if (statusCode == 200) {
              log('ItemList Length ${itemList.length}');

              _clearCartItem(itemList, true);
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
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true).pop();
                          _clearCartItem(itemList, true);
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
      if (customeController.customerId.value.isEmpty ||
          widget.productsController.selectedCustomerId.value.isEmpty) {
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
            content: Text('Your cart is empty'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<int> _getPackPiecesValue(String productId, int quantity) async {
    var productBox = await Hive.openBox('productBox');
    var rawProductList = productBox.get('products', defaultValue: []);
    if (rawProductList is List) {
      var castedProductList = castToStringDynamic(Map.fromIterable(
        rawProductList,
        key: (e) => e['product_id'],
        value: (e) => e,
      ));
      var productJson = castedProductList[productId];
      if (productJson != null) {
        var parsedProduct = ProductModel.fromJson(productJson);
        if (parsedProduct.detail is List<Detail>) {
          var detailItem = parsedProduct.detail?.firstWhereOrNull(
            (item) => item.productId == productId,
          );
          if (detailItem != null) {
            int piecesValue = (detailItem.pieces ?? 1).toInt();
            return piecesValue * quantity;
          }
        }
      }
    }
    return quantity;
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Container(
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
                _clearCartItem(cartItems, true);
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
            child: Container(
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

    final orderData = {
      'customer_id': customeController.customerId.isNotEmpty
          ? customeController.customerId.value
          : widget.productsController.selectedCustomerId.value,
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
                'price': e.detail.price.toString(),
                'discount': '0',
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
    await offlineBox.add(orderData);
    log('[saveOrderOffline] Order saved locally: $orderData');
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
    String customerId =
        widget.customerOrderController!.customerId.value.isNotEmpty
            ? widget.customerOrderController?.customerId.value ?? ''
            : widget.productsController.selectedCustomerId.value;
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
              onPressed: () {
                _deleteProduct(productName, isPreorder: isPreOrder);
                _loadCartItems();
                log('Draft Delete Clicked : ${customerId}');
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
    final String customerId =
        widget.customerOrderController!.customerId.value.isNotEmpty
            ? widget.customerOrderController!.customerId.value
            : widget.productsController.selectedCustomerId.value;

    setState(() {
      cartItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deleteDraftItem(
          customerId, variantToDelete.detail.variationId ?? '');
      CartDatabaseManager().deleteCartItem(variantToDelete);
      _loadCartItems();
    });

    log('Deleted variant: ${variantToDelete.detail.variationName}');
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
                    if (cartItem.detail.count > 0) {
                      cartItem.detail.count--;
                      cartItem.totalPrice =
                          Utils().calculateTotalPrice(cartItem);
                      log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                      CartDatabaseManager().updateCart(cartItem);
                      setState(() {
                        calculateAmounts();
                      });
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
                    cartItem.totalPrice = Utils().calculateTotalPrice(cartItem);
                    log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                    CartDatabaseManager().updateCart(cartItem);
                    setState(() {
                      calculateAmounts();
                    });
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
    List<CartItem> orderItems =
        cartItems.where((item) => item.detail.stock! > 0).toList();
    List<CartItem> preorderItems =
        cartItems.where((item) => item.detail.stock == 0).toList();
    log("Order Items: ${orderItems.length}");
    log("Preorder Items: ${preorderItems.length}");
    setState(() {
      if (isOrder) {
        orderSubtotal = Utils().calculateSubtotal(orderItems);
        orderTax = Utils().calculateTotalTax(orderItems);
        orderFinalAmount = orderSubtotal;
        log("Order Subtotal: $orderSubtotal, Order Tax: $orderTax, Final Amount: $orderFinalAmount");
      } else {
        preorderSubtotal = Utils().calculateSubtotal(preorderItems);
        preorderTax = Utils().calculateTotalTax(preorderItems);
        preorderFinalAmount = preorderSubtotal;
        log("Preorder Subtotal: $preorderSubtotal, Preorder Tax: $preorderTax, Final Amount: $preorderFinalAmount");
      }
    });
  }

  void _clearCartItem(List<CartItem> cartItem, bool isSave) {
    if (isSave) {
      CartDatabaseManager().clearCartOnSave(
        customeController.customerId.isNotEmpty
            ? customeController.customerId.value
            : widget.productsController.selectedCustomerId.value,
      );
    } else {
      CartDatabaseManager().clearCart(
        customeController.customerId.isNotEmpty
            ? customeController.customerId.value
            : widget.productsController.selectedCustomerId.value,
      );
    }

    setState(() {
      cartItems.remove(cartItem);
      quantities.remove(cartItem);
    });
    log('Cart Item Cleared : $cartItem');
  }

  void _deleteProduct(String productName, {required bool isPreorder}) async {
    // final String customerId =
    //     widget.customerOrderController!.customerId.value.isNotEmpty
    //         ? widget.customerOrderController!.customerId.value
    //         : widget.productsController.selectedCustomerId.value;
    final List<CartItem> itemsToDelete = isPreorder
        ? preorderItems.where((item) {
            return item.productName == productName;
          }).toList()
        : orderItems.where((item) {
            return item.productName == productName;
          }).toList();

    if (itemsToDelete.isEmpty) {
      log('No items found for product: $productName to delete.');
      return;
    }

    setState(() {
      for (CartItem item in itemsToDelete) {
        log('Checking variant: ${item.detail.variationName}, stock: ${item.detail.stock}');
        item.detail.count = 0;
        if (item.detail.stock == 0) {
          preorderItems.removeWhere((preorderItem) =>

              preorderItem.detail.variationName == item.detail.variationName);
          log('Deleted from preorder: ${item.detail.variationName}');
        } else {
          orderItems.removeWhere((orderItem) =>
              orderItem.detail.variationName == item.detail.variationName);
          log('Deleted from order: ${item.detail.variationName}');
        }
        CartDatabaseManager().deleteCartItem(item);
      }
      _loadCartItems();
      log('Deleted all variants of product: $productName and reset quantities to 0');
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

Future<void> placeOrder(
  CartOrderModel cartOrder,
  Function(int statusCode, String message, Map<String, dynamic>? responseData)
      onResponse,
) async {
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  cartOrder.companyId = companyId;
  try {
    log('Assigned companyId: ${cartOrder.companyId}');
    log('Place Order Payload: ${cartOrder.toJson()}');
    final response = await Dio().post(
      "http://16.50.232.153:3000/place_order",
      data: cartOrder.toJson(),
    );
    log('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      log('Order placed successfully: ${response.data}');
      onResponse(
          200, 'Your order has been successfully placed.', response.data);
    } else {
      log('Failed to place order: ${response.data}');
      onResponse(
        response.statusCode ?? 500,
        'Failed to place your order.',
        response.data,
      );
    }
  } catch (e) {
    log('Error placing order: $e');
    onResponse(500, 'An error occurred while placing the order.', null);
  }
}
