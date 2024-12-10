import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_heading.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CartDialogue extends StatefulWidget {
  bool? active;
  int cartItemCount;
  ProductsController productsController;
  CartDialogue(
      {super.key,
      this.active,
      required this.cartItemCount,
      required this.productsController});
  @override
  State<CartDialogue> createState() => _CartDialogueState();
}

class _CartDialogueState extends State<CartDialogue> {
  late List<CartItem> cartItems;
  List<int> quantities = [];
  double total = 0.0;
  double tax = 0.0;
  String? _selectedValue;
  String? _dropdownValue;
  final List<String> _options = [
    'Sale Order',
    "Quick Sale",
    'Pre Order',
    'Estimate'
  ];
  CustomerAndOrderController customeController =
      Get.put(CustomerAndOrderController());
  final TextEditingController totalQuickController = TextEditingController();
  final TextEditingController chequeOrTransactionNumberController =
      TextEditingController();
  final TextEditingController cashRemarkController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    try {
      List<CartItem> storedItems = CartDatabaseManager().getCartItems();
      // setState(() {
      cartItems = storedItems;
      quantities = List.generate(cartItems.length, (index) => 1);
      total = Utils().getFinalAmount(cartItems);
      tax = Utils().getTotalTax(cartItems);
      if (_options.isNotEmpty) {
        _selectedValue = _options[0];
      }
      _isLoading = false;
      // });
    } catch (e) {
      return null;
    }
  }

  Future<void> placeOrder(
    CartOrderModel cartOrder,
    Function(int statusCode, String message) onResponse,
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
        onResponse(200, 'Your order has been successfully placed.');
      } else {
        log('Failed to place order: ${response.data}');
        onResponse(response.statusCode ?? 500, 'Failed to place your order.');
      }
    } catch (e) {
      log('Error placing order: $e');
      onResponse(500, 'An error occurred while placing the order.');
    }
  }

  Map<String, List<CartItem>> groupCartItemsByName(List<CartItem> cartItems) {
    return groupBy(cartItems, (CartItem item) => item.productName);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    double finalAmount = total + tax;
    widget.productsController.updateFinalAmount(finalAmount);
    String formattedAmount = finalAmount.toStringAsFixed(2);
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
          double columnSpacing = availableWidth / 40;
          double rowHeight = availableHeight / 10;
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
                    cartItems.isEmpty
                        ? Container(
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
                                  children: cartItems
                                      .map((cartItem) => cartItem.productName)
                                      .toSet()
                                      .toList()
                                      .map((productName) {
                                    List<CartItem> groupedItems = cartItems
                                        .where((item) =>
                                            item.productName == productName)
                                        .toList();
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomHeaderContainer(
                                                    text: productName,
                                                    fontSize: fontSize,
                                                  ),
                                                  SizedBox(
                                                    width: 50,
                                                    child: Center(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          showVariantDeleteDIalog(
                                                              context,
                                                              productName);
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          size: 30,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  )
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
                                                  child: DataTable(
                                                headingRowHeight: 40,
                                                dataRowHeight: rowHeight,
                                                horizontalMargin: 5,
                                                columnSpacing: columnSpacing,
                                                columns:
                                                    DataTableColumns.getColumns(
                                                        fontSize),
                                                rows:
                                                    GroupedItemDataRows.getRows(
                                                  groupedItems: groupedItems,
                                                  fontSize: fontSize,
                                                  availableWidth:
                                                      availableWidth,
                                                  context: context,
                                                  productQuantityManager:
                                                      productQuantityManager,
                                                  deleteConfirmationDialogue:
                                                      deleteConfirmationDialogue,
                                                ),
                                              ))
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 20,
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
                              content: '${total.toStringAsFixed(2)}',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    CartTotalWidget(
                      title: 'Tax',
                      content: tax,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    const Divider(),
                    CartTotalWidget(
                      title: 'Final Amount',
                      content: double.parse(formattedAmount),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color2: Colors.green,
                    ),
                    SizedBox(
                    height: _selectedValue == "Quick Sale" ? 230 : 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _options.map((option) {
                            totalQuickController.text =
                                '\$${double.parse(formattedAmount)}';
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
                                top: 16.0, left: 30, right: 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child:
                                              DropdownButtonFormField<String>(
                                            hint: const Text("Payment method"),
                                            value: _dropdownValue,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _dropdownValue = newValue!;
                                              });
                                            },
                                            items: <String>[
                                              'Cash',
                                              'Cheque',
                                              'Bank Transfer',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
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
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 150,
                                        child: MyFormField(
                                          controller: totalQuickController,
                                          labelText: "Total Amount",
                                          decoration: InputDecoration(
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
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
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
                                            decoration: InputDecoration(
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
                                            decoration: InputDecoration(
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
                                  if (_dropdownValue == "Cheque" ||
                                      _dropdownValue == "Bank Transfer")
                                    const SizedBox(height: 8),
                                  if (_dropdownValue == "Cheque" ||
                                      _dropdownValue == "Bank Transfer")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            controller: dateController,
                                            readOnly: true,
                                            decoration: InputDecoration(
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
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 200,
                                          child: TextFormField(
                                            decoration: InputDecoration(
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
                        _selectedValue != "Quick Sale"
                            ? CustomCartButton(
                                text: 'Save as Draft',
                                size: width > 1200 ? 14 : 10,
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                  List<Detail> detail = CartDatabaseManager()
                                      .cartItems
                                      .map((e) => e.detail)
                                      .toList();
                                  setState(() {
                                    widget.cartItemCount = 0;
                                  });
                                  final productBYData = AddToCartModel(
                                    customerId:
                                        customeController.customerId.isNotEmpty
                                            ? customeController.customerId.value
                                            : widget.productsController
                                                .selectedCustomerId.value,
                                    salesmanId: SessionHelper
                                        .loginSavedData!.salesmanId!,
                                    cartId: '',
                                    cartList: detail
                                        .map((e) => SendCartData(
                                              productId: e.productId ??
                                                  widget.productsController
                                                      .selectedCustomerId.value,
                                              variantId: e.variationId ?? '',
                                              pack: e.saleBy == 'Pack'
                                                  ? e.pieces.toString()
                                                  : e.count.toString(),
                                              packType: e.saleBy == 'Pack'
                                                  ? 'Pack'
                                                  : 'Pcs',
                                              price: e.price.toString(),
                                              discount: '0',
                                              quantity: e.count.toInt(),
                                            ))
                                        .toList(),
                                    total: widget
                                        .productsController.finalAmount.value
                                        .toStringAsFixed(0),
                                    discount: '0',
                                  );
                                  CartOrderModel? cartOrder = await ApiWorker()
                                      .addToCart(productBYData.toJson());
                                  log('CartId :${cartOrder?.cartId}');
                                  log('Pack or pcs :${productBYData.cartList.first.pack}');
                                  log('Pack or pcs :${productBYData.cartList.first.packType}');
                                  if (cartOrder != null) {
                                    int orderStatus = 4;
                                    CartOrderModel order = CartOrderModel(
                                      customerId: customeController
                                              .customerId.isNotEmpty
                                          ? customeController.customerId.value
                                          : widget.productsController
                                              .selectedCustomerId.value,
                                      salesmanId: SessionHelper
                                          .loginSavedData!.salesmanId!,
                                      cartId: cartOrder.cartId,
                                      orderStatus: orderStatus,
                                    );

                                    log('CartId :${cartOrder.cartId}');
                                    await placeOrder(order,
                                        (statusCode, message) {
                                      Navigator.pop(context);

                                      if (statusCode == 200) {
                                        _clearCartItem(cartItems);
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Center(
                                                child: Container(
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
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                    _clearCartItem(cartItems);
                                                  },
                                                  child: Text('OK'),
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
                                                child: Container(
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
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    });
                                    setState(() {
                                      CartDatabaseManager().cartItems.clear();
                                      CartDatabaseManager().clearCart();
                                      widget.cartItemCount = 0;
                                    });
                                  }
                                },
                              )
                            : Container(),
                        const SizedBox(width: 30),
                        CustomCartButton(
                          text: 'Save & Send',
                          size: width > 1200 ? 14 : 10,
                          onTap: () async {
                            if (widget.active == true) {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (cartItems.isNotEmpty &&
                                    (customeController
                                            .customerId.value.isNotEmpty ||
                                        widget
                                            .productsController
                                            .selectedCustomerId
                                            .value
                                            .isNotEmpty)) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                  );
                                  await Future.delayed(Duration(seconds: 2));
                                  List<Detail> detail =
                                      cartItems.map((e) => e.detail).toList();
                                  final productBYData = AddToCartModel(
                                    customerId:
                                        customeController.customerId.isNotEmpty
                                            ? customeController.customerId.value
                                            : widget.productsController
                                                .selectedCustomerId.value,
                                    salesmanId: SessionHelper
                                        .loginSavedData!.salesmanId!,
                                    cartId: '',
                                    cartList: detail
                                        .map((e) => SendCartData(
                                              productId: e.productId ?? '',
                                              variantId: e.variationId ?? '',
                                              pack: e.saleBy == 'Pack'
                                                  ? e.pieces.toString()
                                                  : e.count.toString(),
                                              price: e.price.toString(),
                                              packType: e.saleBy == 'Pack'
                                                  ? 'Pack'
                                                  : 'Pcs',
                                              discount: '0',
                                              quantity: e.count.toInt(),
                                            ))
                                        .toList(),
                                    total: finalAmount.toStringAsFixed(0),
                                    discount: '0',
                                  );
                                  CartOrderModel? cartOrder = await ApiWorker()
                                      .addToCart(productBYData.toJson());
                                  log('CartId :${cartOrder?.cartId}');

                                  if (cartOrder != null) {
                                    int orderStatus = 0;
                                    if (_selectedValue == 'Sale Order') {
                                      orderStatus = 11;
                                    } else if (_selectedValue == 'Pre Order') {
                                      orderStatus = 0;
                                    } else if (_selectedValue == 'Estimate') {
                                      orderStatus = 7;
                                    } else if (_selectedValue == 'Quick Sale') {
                                      orderStatus = 14;
                                    }
                                    CartOrderModel order = CartOrderModel(
                                      customerId: customeController
                                              .customerId.isNotEmpty
                                          ? customeController.customerId.value
                                          : widget.productsController
                                              .selectedCustomerId.value,
                                      salesmanId: SessionHelper
                                          .loginSavedData!.salesmanId!,
                                      cartId: cartOrder.cartId,
                                      orderStatus: orderStatus,
                                    );
                                    log('CartId :${cartOrder.cartId}');
                                    await placeOrder(order,
                                        (statusCode, message) {
                                      Navigator.pop(context);
                                      if (statusCode == 200) {
                                        _clearCartItem(cartItems);
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Center(
                                                child: Container(
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
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                    _clearCartItem(cartItems);
                                                  },
                                                  child: Text('OK'),
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
                                                child: Container(
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
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    });
                                  }
                                } else {
                                 
                                  Navigator.pop(
                                      context); 
                                  if (customeController
                                          .customerId.value.isEmpty ||
                                      widget.productsController
                                          .selectedCustomerId.value.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text('No Customer Selected'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text('Your cart is empty'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Center(
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
                                          Navigator.pop(
                                              context); 
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(); 
                                        },
                                        child: Text('OK'),
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
                            Navigator.pop(context);
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
                    child: Text('No')),
                TextButton(
                    onPressed: () {
                      _deleteVariant(groupedItem, groupedItems);
                      Navigator.pop(context);
                    },
                    child: Text('Yes'))
              ],
            )
          ],
        );
      },
    );
  }

  Future<dynamic> showVariantDeleteDIalog(
      BuildContext context, String productName) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomText(
            content: 'Delete ${productName}..?',
            fontWeight: FontWeight.bold,
          ),
          actions: [
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                content: 'Are you sure you want to delete this item?',
                fontSize: 15,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CustomText(
                    content: 'Cancel',
                    color: primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _deleteItem(productName);

                    Navigator.pop(context);
                  },
                  child: CustomText(
                    content: 'Confirm',
                    color: primaryColor,
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void _deleteVariant(CartItem variantToDelete, List<CartItem> groupedItems) {
    setState(() {
      groupedItems.remove(variantToDelete);
      cartItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deleteCartItem(variantToDelete);
      total = Utils().getFinalAmount(cartItems);
      tax = Utils().getTotalTax(cartItems);
    });
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
              padding: EdgeInsets.all(2),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      if (cartItem.detail.count > 0) {
                        cartItem.detail.count--;
                        log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                        CartDatabaseManager().updateCart(cartItem);
                        calulateAmount(cartItems);
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: padding, right: padding),
                    child: CustomText(
                      color: white,
                      content: '-',
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
          ),
          CustomText(
            content: '${cartItem.detail.count.toStringAsFixed(0)}',
            fontSize: fontSize,
          ),
          Container(
            decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    cartItem.detail.count++;
                    log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                    CartDatabaseManager().updateCart(cartItem);
                    calulateAmount(cartItems);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(left: padding, right: padding),
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

  void calulateAmount(List<CartItem> cartItems) {
    total = 0.0;
    tax = 0.0;
    for (var cartItem in cartItems) {
      double? price = double.tryParse(cartItem.detail.sellPrice ?? '');
      if (price != null) {
        if (cartItem.isPack == true) {
          cartItem.totalPrice =
              (price * cartItem.detail.pieces! * cartItem.detail.count).toInt();
        } else {
          cartItem.totalPrice = (price * cartItem.detail.count).toInt();
        }
        total += cartItem.totalPrice;
        double? itemTax = double.tryParse(cartItem.detail.tax ?? '');
        if (itemTax != null) {
          tax += itemTax * cartItem.detail.count;
        }
      }
    }

    log("Total price for all items: \$${total.toStringAsFixed(2)}");
    log("Total tax for all items: \$${tax.toStringAsFixed(2)}");
  }

  void _clearCartItem(List<CartItem> cartItem) {
    CartDatabaseManager().clearCart();
    setState(() {
      cartItems.remove(cartItem);
      quantities.remove(cartItem);
    });
    log('CartItem Cleared : $cartItem');
  }

  void _deleteItem(String productName) {
    final itemsToDelete =
        cartItems.where((item) => item.productName == productName).toList();
    for (var item in itemsToDelete) {
      CartDatabaseManager().deleteCartItem(item);
    }
    setState(() {
      List<int> indicesToRemove = [];
      for (int i = 0; i < cartItems.length; i++) {
        if (cartItems[i].productName == productName) {
          indicesToRemove.add(i);
        }
      }
      cartItems.removeWhere((item) => item.productName == productName);
      for (int index in indicesToRemove.reversed) {
        quantities.removeAt(index);
      }
      total = Utils().getFinalAmount(cartItems);
      tax = Utils().getTotalTax(cartItems);
    });

    log('Cart items deleted for product: $productName');
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
