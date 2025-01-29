import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/draft_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CartDialogue extends StatefulWidget {
  bool? active;
  int cartItemCount;
  ProductsController productsController;
  CustomerAndOrderController? customerOrderController;
  CartDialogue(
      {super.key,
      this.active,
      required this.cartItemCount,
      required this.productsController,
      this.customerOrderController});
  @override
  State<CartDialogue> createState() => CartDialogueState();
}

class CartDialogueState extends State<CartDialogue> {
  late List<CartItem> cartItems;
  late List<CartItem> combinedList;
  late List<CartItem> preorderItems;
  List<CartItem> draftItems = [];
  List<int> quantities = [];
  List<int> preorderQuantities = [];
  List<int> draftQuantity = [];
  double total = 0.0;
  double preorderTotal = 0.0;
  double tax = 0.0;
  double preorderTax = 0.0;
  double draftTotal = 0.0;
  double draftTax = 0.0;
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
  bool isOrder = true;
  bool isDraft = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    log('Customer ID in INitstate : ${widget.customerOrderController?.customerId.value ?? ''}');
    loadDraft(widget.customerOrderController!.customerId.value.isNotEmpty
        ? widget.customerOrderController?.customerId.value ?? ''
        : widget.productsController.selectedCustomerId.value ?? '');
    _loadCartItems();
    _loadPreorderItems();
    calculateAmount(cartItems);
    calculatePreorderAmount(preorderItems);
    calculateDraftAmount(draftItems);
    isOrder = cartItems.isEmpty && preorderItems.isNotEmpty ? false : true;
    _selectedValue = isOrder ? _options[0] : _options[2];
    setOptions();
  }

  void setOptions() {
    setState(() {
      filteredOptions = isOrder
          ? ['Sale Order', 'Quick Sale', 'Estimate']
          : ['Pre Order', 'Estimate'];
    });
  }

void _loadCartItems() {
  try {
    final customerId = widget.customerOrderController!.customerId.value.isNotEmpty
        ? widget.customerOrderController!.customerId.value
        : widget.productsController.selectedCustomerId.value;
    cartItems = CartDatabaseManager().getCartItems();
    final Draft? draft = CartDatabaseManager().draftBox.get(customerId);
    draftItems = draft?.items ?? [];
    setState(() {
      quantities = List.generate(cartItems.length, (index) => 1);
      total = Utils().getFinalAmount(cartItems);
      tax = Utils().getTotalTax(cartItems);
      _isLoading = false;
    });

    if (_options.isNotEmpty) {
      _selectedValue = _options[0];
    }
  } catch (e) {
    print('Error loading cart items: $e');
  }
}



  void loadDraft(String customerId) {
    try {
      final draft = CartDatabaseManager().draftBox.get(customerId);
      log('${draft?.items.toString()}');
      if (draft != null) {
        log('Draft loaded successfully for customer ID: $customerId');
        draftItems = draft.items;
        for (var item in draft.items) {
          log(
            'Draft Item: '
            'Product Name: ${item.productName}, '
            'Variation Name: ${item.detail.variationName}, '
            'Sell Price: ${item.detail.sellPrice}, '
            'Count: ${item.detail.count}, '
            'Total Price: ${item.totalPrice}, '
            'Is Pack: ${item.isPack}, '
            'Pieces: ${item.detail.pieces}',
          );
        }
        draftQuantity = List.generate(draftItems.length, (index) => 1);
        draftTotal = Utils().getFinalAmount(draftItems);
        draftTax = Utils().getTotalTax(draftItems);

        log('Draft Load Tax : $draftTax');
        if (_options.isNotEmpty) {
          _selectedValue = _options[0];
        }
        _isLoading = false;
      } else {
        log('No draft found for customer ID: $customerId');
        draftItems = [];
      }
    } catch (e) {
      log('Error loading draft for customer ID $customerId: $e');
      draftItems = [];
    }
  }

  void _loadPreorderItems() {
    try {
      List<CartItem> storedPreorderItems =
          CartDatabaseManager().getCartPreorderItems();
      preorderItems = storedPreorderItems;
      preorderQuantities = List.generate(preorderItems.length, (index) => 1);
      preorderTotal = Utils().getFinalAmount(preorderItems);
      preorderTax = Utils().getTotalTax(preorderItems);
      if (_options.isNotEmpty) {
        _selectedValue = _options[0];
      }
      _isLoading = false;
    } catch (e) {
      log('Error loading pre-order items: $e');
    }
  }

  Map<String, List<CartItem>> groupCartItemsByName(List<CartItem> cartItems) {
    return groupBy(cartItems, (CartItem item) => item.productName);
  }

  void performSpecificAction(bool isTab) async {
    log('Selected CustomerID :${customeController.customerId.isNotEmpty ? {
        customeController.customerId.value
      } : widget.productsController.selectedCustomerId.value}');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    List<Detail> detail = isOrder
        ? CartDatabaseManager().cartItems.map((e) => e.detail).toList()
        : CartDatabaseManager().cartPreorderItems.map((e) => e.detail).toList();
    setState(() {
      widget.cartItemCount = 0;
    });
    final productBYData = AddToCartModel(
      customerId: customeController.customerId.isNotEmpty
          ? customeController.customerId.value
          : widget.productsController.selectedCustomerId.value,
      salesmanId: SessionHelper.loginSavedData!.salesmanId!,
      cartId: '',
      cartList: detail
          .map((e) => SendCartData(
                productId: e.productId ??
                    widget.productsController.selectedCustomerId.value,
                variantId: e.variationId ?? '',
                pack: e.saleBy == 'Pack'
                    ? e.pieces.toString()
                    : e.count.toString(),
                packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                price: e.sellPrice.toString(),
                discount: '0',
                quantity: e.count.toInt(),
              ))
          .toList(),
      total: widget.productsController.finalAmount.value.toStringAsFixed(0),
      discount: '0',
    );
    CartOrderModel? cartOrder =
        await ApiWorker().addToCart(productBYData.toJson());
    log('CartId :${cartOrder?.cartId}');
    log('Pack or pcs :${productBYData.cartList.first.pack}');
    log('Pack or pcs :${productBYData.cartList.first.packType}');

    if (cartOrder != null) {
      int orderStatus = 4;
      log('Selected Customer ID :${customeController.customerId.isNotEmpty ? {
          customeController.customerId.value
        } : widget.productsController.selectedCustomerId.value}');
      CartOrderModel order = CartOrderModel(
        customerId: customeController.customerId.isNotEmpty
            ? customeController.customerId.value
            : widget.productsController.selectedCustomerId.value,
        salesmanId: SessionHelper.loginSavedData!.salesmanId!,
        cartId: cartOrder.cartId,
        orderStatus: orderStatus,
      );
      log('CartId :${cartOrder.cartId}');
      await placeOrder(order, (statusCode, message, response) {
        Navigator.pop(context);
        if (statusCode == 200) {
          final draftId = response?['id'];
          isOrder
              ? _clearCartItem(cartItems)
              : _clearPreorderCartItem(preorderItems);
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
                  content: 'Your order has been successfully saved as Draft',
                  fontSize: 18,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      isTab
                          ? Navigator.of(context, rootNavigator: true).pop()
                          : null;
                      isOrder
                          ? _clearCartItem(cartItems)
                          : _clearPreorderCartItem(preorderItems);
                      final cartProvider = Provider.of<CustomersProvider>(
                        context,
                      );
                      cartProvider.getCartItemCounts(
                        customeController.customerId.isNotEmpty
                            ? customeController.customerId.value
                            : widget
                                .productsController.selectedCustomerId.value,
                      );
                      cartProvider.updateCartCount(
                        customeController.customerId.isNotEmpty
                            ? customeController.customerId.value
                            : widget
                                .productsController.selectedCustomerId.value,
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          CartDatabaseManager().saveCartAsDraft(
              customeController.customerId.isNotEmpty
                  ? customeController.customerId.value
                  : widget.productsController.selectedCustomerId.value,
              cartOrder?.cartId ?? '',
              draftId);
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
                    child: Lottie.asset('assets/images/Warning_animation.json'),
                  ),
                ),
                content: CustomText(
                  content: "Couldn't save the order as draft please try again.",
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
      setState(() {
        if (isOrder) {
          CartDatabaseManager().cartItems.clear();
          CartDatabaseManager().clearCart();
        } else {
          CartDatabaseManager().cartPreorderItems.clear();
          CartDatabaseManager().clearPreorderCart();
        }

        widget.cartItemCount = 0;
      });
    }
  }

  double? finalAmount;
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

    if (isOrder && draftItems.isEmpty) {
      // finalAmount = total + tax;
      finalAmount = total;
    } else if (isDraft && cartItems.isEmpty && preorderItems.isEmpty) {
      log('Calculating for Draft...');
      double draftTotal =
          draftItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      // finalAmount = draftTotal + draftTax;
      finalAmount = draftTotal;
      log('Draft Total: $draftTotal, Draft Tax: $draftTax, Final Amount: $finalAmount');
    } else {
      // finalAmount = preorderTotal + preorderTax;
      finalAmount = preorderTotal;
    }
    widget.productsController.updateFinalAmount(finalAmount ?? 0);
    String formattedAmount = finalAmount?.toStringAsFixed(2) ?? '';
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
          double columnSpacing = availableWidth / 30;
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
                    if (cartItems.isNotEmpty || preorderItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      color: isOrder ? primaryColor : white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20))),
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
                                        color: !isOrder ? primaryColor : white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      color: !isOrder ? primaryColor : white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
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
                                        color: isOrder ? primaryColor : white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                    if (isOrder) ...[
                      (combinedList.isEmpty)
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
                          : Container(),
                      (combinedList.isNotEmpty)
                          ? Flexible(
                              child: SizedBox(
                                height: dialogHeight * 0.5,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: combinedList
                                        .map((item) => item.productName)
                                        .toSet()
                                        .toList()
                                        .map((productName) {
                                      List<CartItem> groupedItems = combinedList
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
                                                    Expanded(
                                                      child:
                                                          CustomHeaderContainer(
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
                                                                false);
                                                          },
                                                          icon: Icon(
                                                            EneftyIcons
                                                                .trash_bold,
                                                            size: 28,
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
                                                    child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0),
                                                  child: DataTable(
                                                    headingRowHeight: 30,
                                                    dataRowHeight: rowHeight,
                                                    horizontalMargin: 5,
                                                    columnSpacing: 15,
                                                    columns: DataTableColumns
                                                        .getColumns(fontSize),
                                                    rows: GroupedItemDataRows
                                                        .getRows(
                                                      groupedItems:
                                                          groupedItems,
                                                      fontSize:
                                                          availableWidth / 55,
                                                      availableWidth:
                                                          availableWidth,
                                                      context: context,
                                                      productQuantityManager:
                                                          productQuantityManager,
                                                      deleteConfirmationDialogue:
                                                          deleteConfirmationDialogue,
                                                    ),
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
                            )
                          : Container(),
                    ],
                    if (!isOrder) ...[
                      preorderItems.isEmpty
                          ? SizedBox(
                              height: 100,
                              child: Center(
                                child: CustomText(
                                  content: 'Your pre-order cart is empty.',
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
                                        .map((cartItem) => cartItem.productName)
                                        .toSet()
                                        .toList()
                                        .map((productName) {
                                      List<CartItem> groupedItems =
                                          preorderItems
                                              .where((item) =>
                                                  item.productName ==
                                                  productName)
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
                                                    Expanded(
                                                      child:
                                                          CustomHeaderContainer(
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
                                                                true,
                                                                false);
                                                          },
                                                          icon: Icon(
                                                            EneftyIcons
                                                                .trash_bold,
                                                            size: 28,
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
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0),
                                                    child: DataTable(
                                                      headingRowHeight: 30,
                                                      dataRowHeight: rowHeight,
                                                      horizontalMargin: 5,
                                                      columnSpacing:
                                                          columnSpacing,
                                                      columns: DataTableColumns
                                                          .getColumns(fontSize),
                                                      rows: GroupedItemDataRows
                                                          .getRows(
                                                        groupedItems:
                                                            groupedItems,
                                                        fontSize:
                                                            availableWidth / 55,
                                                        availableWidth:
                                                            availableWidth,
                                                        context: context,
                                                        productQuantityManager:
                                                            preorderQuantityManager,
                                                        deleteConfirmationDialogue:
                                                            deletePreorderConfirmationDialogue,
                                                      ),
                                                    ),
                                                  ),
                                                )
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
                    ],
                    // if (cartItems.isEmpty && preorderItems.isEmpty) ...[
                    //   draftItems.isEmpty
                    //       ? SizedBox()
                    //       : Flexible(
                    //           child: SizedBox(
                    //             height: dialogHeight * 0.5,
                    //             child: SingleChildScrollView(
                    //               child: Column(
                    //                 children: draftItems
                    //                     .map((cartItem) => cartItem.productName)
                    //                     .toSet()
                    //                     .toList()
                    //                     .map((productName) {
                    //                   List<CartItem> groupedDraftItems =
                    //                       draftItems
                    //                           .where((item) =>
                    //                               item.productName ==
                    //                               productName)
                    //                           .toList();
                    //                   return Padding(
                    //                     padding:
                    //                         const EdgeInsets.only(bottom: 20),
                    //                     child: Column(
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         Stack(
                    //                           alignment: Alignment.bottomCenter,
                    //                           children: [
                    //                             Row(
                    //                               mainAxisAlignment:
                    //                                   MainAxisAlignment
                    //                                       .spaceBetween,
                    //                               children: [
                    //                                 Expanded(
                    //                                   child:
                    //                                       CustomHeaderContainer(
                    //                                     text: productName,
                    //                                     fontSize: fontSize,
                    //                                   ),
                    //                                 ),
                    //                                 SizedBox(
                    //                                   width: 50,
                    //                                   child: Center(
                    //                                     child: IconButton(
                    //                                       onPressed: () {
                    //                                         showVariantDeleteDialog(
                    //                                             context,
                    //                                             productName,
                    //                                             false,
                    //                                             true);
                    //                                       },
                    //                                       icon: Icon(
                    //                                         EneftyIcons
                    //                                             .trash_bold,
                    //                                         size: 28,
                    //                                         color: Colors.red,
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                 )
                    //                               ],
                    //                             ),
                    //                             Container(
                    //                               height: 3.5,
                    //                               color: lightPrimaryColor,
                    //                               width: double.infinity,
                    //                             ),
                    //                           ],
                    //                         ),
                    //                         Row(
                    //                           children: [
                    //                             Expanded(
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets
                    //                                     .symmetric(
                    //                                     horizontal: 10.0),
                    //                                 child: DataTable(
                    //                                   headingRowHeight: 30,
                    //                                   dataRowHeight: rowHeight,
                    //                                   horizontalMargin: 5,
                    //                                   columnSpacing:
                    //                                       columnSpacing,
                    //                                   columns: DataTableColumns
                    //                                       .getColumns(fontSize),
                    //                                   rows: GroupedItemDataRows
                    //                                       .getRows(
                    //                                     groupedItems:
                    //                                         groupedDraftItems,
                    //                                     fontSize:
                    //                                         availableWidth / 55,
                    //                                     availableWidth:
                    //                                         availableWidth,
                    //                                     context: context,
                    //                                     productQuantityManager:
                    //                                         draftQuantityManager,
                    //                                     deleteConfirmationDialogue:
                    //                                         deleteDraftConfirmationDialogue,
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             )
                    //                           ],
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   );
                    //                 }).toList(),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    // ],
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
                              content: formatAmount(
                                  isOrder && draftItems.isEmpty
                                      ? total
                                      : isDraft &&
                                              cartItems.isEmpty &&
                                              preorderItems.isEmpty
                                          ? draftTotal
                                          : preorderTotal),
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
                              content: formatAmount(
                                  isOrder && draftItems.isEmpty
                                      ? tax
                                      : isDraft &&
                                              cartItems.isEmpty &&
                                              preorderItems.isEmpty
                                          ? draftTax
                                          : preorderTax),
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
                      content: double.parse(formattedAmount),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color2: Colors.green,
                    ),
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
                          _selectedValue != "Quick Sale"
                              ? CustomCartButton(
                                  text: 'Save as Draft',
                                  size: width > 1200 ? 14 : 10,
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const Center(
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
                                      customerId: customeController
                                              .customerId.isNotEmpty
                                          ? customeController.customerId.value
                                          : widget.productsController
                                              .selectedCustomerId.value,
                                      salesmanId: SessionHelper
                                          .loginSavedData!.salesmanId!,
                                      cartId: '',
                                      cartList: detail
                                          .map((e) => SendCartData(
                                                productId: e.productId ??
                                                    widget
                                                        .productsController
                                                        .selectedCustomerId
                                                        .value,
                                                variantId: e.variationId ?? '',
                                                pack: e.saleBy == 'Pack'
                                                    ? e.pieces.toString()
                                                    : e.count.toString(),
                                                packType: e.saleBy == 'Pack'
                                                    ? 'Pack'
                                                    : 'Pcs',
                                               price: e.sellPrice.toString(),
                                                discount: '0',
                                                quantity: e.count.toInt(),
                                              ))
                                          .toList(),
                                      total: widget
                                          .productsController.finalAmount.value
                                          .toStringAsFixed(0),
                                      discount: '0',
                                    );

                                    log('Customer Id for Save draft : ${widget.productsController.selectedCustomerId.value}');
                                    CartOrderModel? cartOrder =
                                        await ApiWorker()
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
                                          (statusCode, message, response) {
                                        Navigator.pop(context);
                                        if (statusCode == 200) {
                                          _clearCartItem(cartItems);
                                          final draftId = response?['id'];
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
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();

                                                      _clearCartItem(cartItems);
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          log('Draft ID : $draftId');
                                          CartDatabaseManager().saveCartAsDraft(
                                              widget.productsController
                                                  .selectedCustomerId.value,
                                              cartOrder.cartId,
                                              draftId);
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
                                                    child: const Text('OK'),
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
                                final customerId =
                                    customeController.customerId.isNotEmpty
                                        ? customeController.customerId.value
                                        : widget.productsController
                                            .selectedCustomerId.value;
                                final savedCartData = CartDatabaseManager()
                                    .getSavedCartData(customerId);
                                final cartId = savedCartData?['cart_id'] ?? '';
                                final draftId = savedCartData?['id'] ?? '';
                                if (_selectedValue == "Quick Sale") {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    await processSaveAndSend(
                                      finalAmount: finalAmount ?? 0,
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
                                    finalAmount: finalAmount ?? 0,
                                    context: context,
                                    cartId: cartId,
                                    draftId: draftId
                                  );
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

  Future<void> processSaveAndSend({
    required BuildContext context,
    required double finalAmount,
    int? paymentType,
    required String cartId,
    required String draftId,
  }) async {
    List<CartItem> itemList = [...cartItems, ...draftItems];
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
          isOrder ? _clearCartItem(itemList) : _clearPreorderCartItem(itemList);
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
                      isOrder
                          ? _clearCartItem(itemList)
                          : _clearPreorderCartItem(itemList);
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          log('[processSaveAndSend] Device is online. Proceeding with stock synchronization...');
          for (var cartItem in itemList) {
            var productId = cartItem.detail.productId;
            var productBox = await Hive.openBox('productBox');
            var rawProductList = productBox.get('products', defaultValue: []);
            log('[processSaveAndSend] Syncing stock for product ID: $productId');
            if (rawProductList is List) {
              var castedProductList = castToStringDynamic(Map.fromIterable(
                rawProductList,
                key: (e) => e['product_id'],
                value: (e) => e,
              ));
              var productJson = castedProductList[productId];
              if (productJson != null) {
                var parsedProduct = ProductModel.fromJson(productJson);
                int stockValue = int.tryParse(parsedProduct.stock ?? '') ?? 0;
                var detailItem = parsedProduct.detail?.firstWhere(
                  (detail) => detail.productId == productId,
                  orElse: () => Detail(),
                );
                int piecesValue =
                    detailItem != null ? (detailItem.pieces ?? 1).toInt() : 1;
                int decrementValue = cartItem.detail.saleBy == 'Pack'
                    ? piecesValue * cartItem.detail.count.toInt()
                    : cartItem.detail.count.toInt();

                parsedProduct.stock = (stockValue - decrementValue).toString();

                productBox.put(
                  'products',
                  castedProductList.values.map((e) {
                    return e['product_id'] == parsedProduct.productId
                        ? parsedProduct.toJson()
                        : e;
                  }).toList(),
                );

                log('[processSaveAndSend] Updated stock for product ${parsedProduct.productName}: ${parsedProduct.stock}');
              }
            }
          }

          log('[processSaveAndSend] Offline order saved successfully.');
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
          );
          await placeOrder(order, (statusCode, message, response) {
            Navigator.pop(context);
            if (statusCode == 200) {
              isOrder
                  ? _clearCartItem(itemList)
                  : _clearPreorderCartItem(itemList);
              log('ItemList Length ${itemList.length}');
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
                          isOrder
                              ? _clearCartItem(itemList)
                              : _clearPreorderCartItem(itemList);
                          _clearDraft(itemList);
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
                _clearCartItem(cartItems);
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

  Future<dynamic> deletePreorderConfirmationDialogue(
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
                content: 'Are you sure you want to delete this pre-order item?',
                fontSize: 17,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    _deletePreorderVariant(groupedItem, groupedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> deleteDraftConfirmationDialogue(
      BuildContext context, CartItem groupedItem, List<CartItem> groupedItems) {
    String customerId =
        widget.customerOrderController!.customerId.value.isNotEmpty
            ? widget.customerOrderController?.customerId.value ?? ''
            : widget.productsController.selectedCustomerId.value;
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
                content: 'Are you sure you want to delete this Draft item?',
                fontSize: 17,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    _deleteDraftderVariant(
                        groupedItem, groupedItems, customerId);
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
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
                if (isPreOrder) {
                  _deletePreorderItem(productName);
                } else if (!isDraft) {
                  _deleteItem(productName);
                  loadDraft(customerId);
                } else {
                  _deleteDraftItem(productName, customerId);
                  
                  log('Draft Delete Clicked : ${customerId}');
                }
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
  final String customerId = widget.customerOrderController!.customerId.value.isNotEmpty
      ? widget.customerOrderController!.customerId.value
      : widget.productsController.selectedCustomerId.value;
  setState(() {
    cartItems.removeWhere((item) =>
        item.productName == variantToDelete.productName &&
        item.detail.variationName == variantToDelete.detail.variationName);
    draftItems.removeWhere((item) =>
        item.productName == variantToDelete.productName &&
        item.detail.variationName == variantToDelete.detail.variationName);
    combinedList = [...cartItems, ...draftItems];
    if (draftItems.any((item) => item == variantToDelete)) {
      CartDatabaseManager().deleteDraftItem(
          customerId, variantToDelete.detail.variationId ?? '');
    } else {
      CartDatabaseManager().deleteCartItem(variantToDelete);
    }
    total = Utils().getFinalAmount(combinedList);
    tax = Utils().getTotalTax(combinedList);
  });
  provider.updateCartCount(customerId);
  log('Deleted variant: ${variantToDelete.detail.variationName}');
}


  void _deletePreorderVariant(
      CartItem variantToDelete, List<CartItem> groupedItems) {
    setState(() {
      groupedItems.remove(variantToDelete);
      preorderItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deletePreorderCartItem(variantToDelete);
      preorderTotal = Utils().getFinalAmount(preorderItems);
      preorderTax = Utils().getTotalTax(preorderItems);
    });
    log('Pre-order variant deleted: ${variantToDelete.detail.variationName}');
  }

  void _deleteDraftderVariant(
      CartItem variantToDelete, List<CartItem> draftItems, String customerId) {
    setState(() {
      draftItems.removeWhere((item) =>
          item.productName == variantToDelete.productName &&
          item.detail.variationName == variantToDelete.detail.variationName);
      CartDatabaseManager().deleteDraftItem(
          customerId, variantToDelete.detail.variationId ?? '');
      draftTotal = Utils().getFinalAmount(draftItems);
      draftTax = Utils().getTotalTax(draftItems);
      _loadCartItems();
    });

    log('Pre-order variant deleted: ${variantToDelete.detail.variationName}');
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
                        log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                        CartDatabaseManager().updateCart(cartItem);
                        calculateAmount(cartItems);
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
                    log("Updated count for item ${cartItem.detail.id}: ${cartItem.detail.count}");
                    CartDatabaseManager().updateCart(cartItem);
                    calculateAmount(cartItems);
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

  Container preorderQuantityManager(CartItem cartPreorderItem, String sellPrice,
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
                      if (cartPreorderItem.detail.count > 0) {
                        cartPreorderItem.detail.count--;
                        log("Updated count for pre-order item ${cartPreorderItem.detail.id}: ${cartPreorderItem.detail.count}");
                        CartDatabaseManager()
                            .updatePreorderCart(cartPreorderItem);
                        calculatePreorderAmount(preorderItems);
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
            content: cartPreorderItem.detail.count.toStringAsFixed(0),
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
                    cartPreorderItem.detail.count++;
                    log("Updated count for pre-order item ${cartPreorderItem.detail.id}: ${cartPreorderItem.detail.count}");
                    CartDatabaseManager().updatePreorderCart(cartPreorderItem);
                    calculatePreorderAmount(preorderItems);
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

  // Container draftQuantityManager(
  //   CartItem draftItem,
  //   String sellPrice,
  //   double fontSize,
  //   double availableWidth,
  // ) {
  //   double padding = availableWidth > 400 ? 6 : 3;
  //   return Container(
  //     width: availableWidth > 400 ? 80 : 50,
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(5),
  //         color: const Color.fromARGB(255, 241, 240, 240)),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Container(
  //           decoration: const BoxDecoration(
  //               color: primaryColor,
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(5),
  //                   bottomLeft: Radius.circular(5))),
  //           child: Padding(
  //             padding: const EdgeInsets.all(2),
  //             child: InkWell(
  //                 onTap: () {
  //                   setState(() {
  //                     if (draftItem.detail.count > 0) {
  //                       draftItem.detail.count--;
  //                       log("Updated count for draft item ${draftItem.detail.id}: ${draftItem.detail.count}");
  //                       CartDatabaseManager().updateDraftItem(
  //                           widget.customerOrderController?.customerId.value ??
  //                               '',
  //                           draftItem);
  //                       calculateDraftAmount(draftItems);
  //                     }
  //                   });
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.only(left: padding, right: padding),
  //                   child: CustomText(
  //                     color: white,
  //                     content: '-',
  //                     fontSize: fontSize,
  //                     fontWeight: FontWeight.bold,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 )),
  //           ),
  //         ),
  //         CustomText(
  //           content: draftItem.detail.count.toStringAsFixed(0),
  //           fontSize: fontSize,
  //         ),
  //         Container(
  //           decoration: const BoxDecoration(
  //               color: primaryColor,
  //               borderRadius: BorderRadius.only(
  //                   topRight: Radius.circular(5),
  //                   bottomRight: Radius.circular(5))),
  //           child: Padding(
  //             padding: const EdgeInsets.all(2),
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   draftItem.detail.count++;
  //                   log("Updated count for draft item ${draftItem.detail.id}: ${draftItem.detail.count}");
  //                   CartDatabaseManager().updateDraftItem(
  //                       widget.customerOrderController?.customerId.value ?? '',
  //                       draftItem);
  //                   calculateDraftAmount(draftItems);
  //                 });
  //               },
  //               child: Padding(
  //                 padding: EdgeInsets.only(left: padding, right: padding),
  //                 child: CustomText(
  //                   color: white,
  //                   content: '+',
  //                   fontSize: fontSize,
  //                   fontWeight: FontWeight.bold,
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void calculateAmount(List<CartItem> cartItems) {
    total = 0.0;
    tax = 0.0;
    for (var cartItem in cartItems) {
      double? price = cartItem.isPack == true
          ? cartItem.detail.sellingPackPrice!.toDouble()
          : cartItem.detail.sellingPrice!.toDouble();
      if (price != null) {
        cartItem.totalPrice = (price * cartItem.detail.count);
        total += cartItem.totalPrice;
        double? itemTax = cartItem.isPack == true
            ? double.tryParse(cartItem.detail.tax.toString())! *
                double.tryParse(cartItem.detail.pieces.toString())!
            : double.tryParse(cartItem.detail.tax.toString());
        if (itemTax != null) {
          tax += itemTax * cartItem.detail.count;
        }
      }
    }
    log("Total price for all items: \$${total.toStringAsFixed(2)}");
    log("Total tax for all items: \$${tax.toStringAsFixed(2)}");
  }

  void calculatePreorderAmount(List<CartItem> preorderItems) {
    preorderTotal = 0.0;
    preorderTax = 0.0;
    for (var cartItem in preorderItems) {
      double? price = cartItem.isPack == true
          ? cartItem.detail.sellingPackPrice!.toDouble()
          : cartItem.detail.sellingPrice!.toDouble();
      if (price != null) {
        preorderTotal += cartItem.totalPrice;
        double? itemTax = cartItem.isPack == true
            ? double.tryParse(cartItem.detail.tax.toString())! *
                double.tryParse(cartItem.detail.pieces.toString())!
            : double.tryParse(cartItem.detail.tax.toString());
        if (itemTax != null) {
          preorderTax += itemTax * cartItem.detail.count;
        }
      }
    }
    log("Total price for all items: \$${preorderTotal.toStringAsFixed(2)}");
    log("Total tax for all items: \$${preorderTax.toStringAsFixed(2)}");
  }

  void calculateDraftAmount(List<CartItem> draftItems) {
    draftTotal = 0.0;
    draftTax = 0.0;

    for (var cartItem in draftItems) {
      double? price = double.tryParse(cartItem.detail.sellPrice ?? '');
      if (price != null) {
        if (cartItem.isPack == true) {
          cartItem.totalPrice =
              (price * cartItem.detail.pieces! * cartItem.detail.count);
        } else {
          cartItem.totalPrice = (price * cartItem.detail.count);
        }
        draftTotal += cartItem.totalPrice;
        double? itemTax = cartItem.isPack == true
            ? double.tryParse(cartItem.detail.tax.toString())! *
                double.tryParse(cartItem.detail.pieces.toString())!
            : double.tryParse(cartItem.detail.tax.toString());
        if (itemTax != null) {
          draftTax += itemTax * cartItem.detail.count;
        }
      }
    }

    log("Total price for all draft items: \$${draftTotal.toStringAsFixed(2)}");
    log("Total tax for all draft items: \$${draftTax.toStringAsFixed(2)}");
  }

  void _clearCartItem(List<CartItem> cartItem) {
    CartDatabaseManager().clearCart();
    setState(() {
      cartItems.remove(cartItem);
      quantities.remove(cartItem);
    });
    log('Cart Item Cleared : $cartItem');
  }

  void _clearPreorderCartItem(List<CartItem> cartPreorderItem) {
    CartDatabaseManager().clearPreorderCart();
    setState(() {
      preorderItems.remove(cartPreorderItem);
      preorderQuantities.remove(cartPreorderItem);
    });
    log('Cart Item Cleared : $cartPreorderItem');
  }

  void _clearDraft(List<CartItem> draftItem) {
    CartDatabaseManager().clearDraftForCustomer(
        widget.customerOrderController!.customerId.value.isNotEmpty
            ? widget.customerOrderController?.customerId.value ?? ''
            : widget.productsController.selectedCustomerId.value);
    setState(() {
      preorderItems.remove(draftItem);
      preorderQuantities.remove(draftItem);
    });
    log('Cart Item Cleared : $draftItem');
  }

void _deleteItem(String productName) {
  setState(() {
    final itemsToDeleteFromCart = cartItems.where((item) => item.productName == productName).toList();
    for (var item in itemsToDeleteFromCart) {
      CartDatabaseManager().deleteCartItem(item);
    }
    cartItems.removeWhere((item) => item.productName == productName);
    final itemsToDeleteFromDraft = draftItems.where((item) => item.productName == productName).toList();
    for (var item in itemsToDeleteFromDraft) {
      String customerId = widget.customerOrderController!.customerId.value.isNotEmpty
          ? widget.customerOrderController!.customerId.value
          : widget.productsController.selectedCustomerId.value;
      CartDatabaseManager().deleteDraftItem(customerId, item.detail.variationId ?? '');
    }
    draftItems.removeWhere((item) => item.productName == productName);
    List<int> indicesToRemove = [];
    for (int i = 0; i < combinedList.length; i++) {
      if (combinedList[i].productName == productName) {
        indicesToRemove.add(i);
      }
    }
    for (int index in indicesToRemove.reversed) {
      quantities.removeAt(index);
    }
    combinedList = [...cartItems, ...draftItems];
    total = Utils().getFinalAmount(combinedList);
    tax = Utils().getTotalTax(combinedList);
  });

  log('Items deleted for product: $productName');
}


  void _deletePreorderItem(String productName) {
    final itemsToDelete =
        preorderItems.where((item) => item.productName == productName).toList();
    for (var item in itemsToDelete) {
      CartDatabaseManager().deletePreorderCartItem(item);
    }
    setState(() {
      List<int> indicesToRemove = [];
      for (int i = 0; i < preorderItems.length; i++) {
        if (preorderItems[i].productName == productName) {
          indicesToRemove.add(i);
        }
      }
      preorderItems.removeWhere((item) => item.productName == productName);
      for (int index in indicesToRemove.reversed) {
        preorderQuantities.removeAt(index);
      }
      preorderTotal = Utils().getFinalAmount(preorderItems);
      preorderTax = Utils().getTotalTax(preorderItems);
    });

    log('Pre-order items deleted for product: $productName');
  }

  void _deleteDraftItem(String productName, String customerId) {
    final itemsToDelete =
        draftItems.where((item) => item.productName == productName).toList();
    for (var item in itemsToDelete) {
      CartDatabaseManager().deleteDraftItems(customerId, item);
    }
    setState(() {
      List<int> indicesToRemove = [];
      for (int i = 0; i < draftItems.length; i++) {
        if (draftItems[i].productName == productName) {
          indicesToRemove.add(i);
        }
      }
      draftItems.removeWhere((item) => item.productName == productName);
      for (int index in indicesToRemove.reversed) {
        draftItems.removeAt(index);
      }
      draftTotal = Utils().getFinalAmount(draftItems);
      draftTax = Utils().getTotalTax(draftItems);
    });
    log('Pre-order items deleted for product: $productName');
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
      // Pass the response data to the callback
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
