import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_totalamount_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_cart_button.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/custom_header_container.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CartDialogue extends StatefulWidget {
  CartDialogue({super.key,});

  @override
  State<CartDialogue> createState() => _CartDialogueState();
}

class _CartDialogueState extends State<CartDialogue> {
  late List<CartItem> cartItems;
  List<int> quantities = [];
  double total = 0.0;
  double tax = 0.0;
  String? _selectedValue;
  final List<String> _options = ['Sale Order', 'Pre Order', 'Estimate'];
  ProductsController productsController = Get.find<ProductsController>();
  CustomerAndOrderController customeController =
      Get.find<CustomerAndOrderController>();
  @override
  void initState() {
    super.initState();
    cartItems = CartDatabaseManager().cartItems;
    quantities = List.generate(cartItems.length, (index) => 1);
    total = Utils().getFinalAmount(cartItems);
    tax = Utils().getTotalTax(cartItems);
    if (_options.isNotEmpty) {
      _selectedValue = _options[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    double finalAmount = total + tax;
    productsController.updateFinalAmount(finalAmount);
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
      backgroundColor: white,
      insetPadding: EdgeInsets.all(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 50),
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                    width: double.infinity,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.01, horizontal: height * 0.04),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: CustomText(
                          content: 'My Cart',
                          fontSize: width > 1200 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamilyName,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        radius: 15,
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
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
                        : SizedBox(
                            height: dialogHeight * 0.5,
                            child: SingleChildScrollView(
                              child: Column(
                                children: cartItems.map((cartItem) {
                                  final index = cartItems.indexOf(cartItem);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
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
                                                  text: cartItem.productName,
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: CustomText(
                                                                content:
                                                                    'Delete ${cartItem.productName}..?',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              actions: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      CustomText(
                                                                    content:
                                                                        'Are you sure you want to delete this item?',
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child:
                                                                          CustomText(
                                                                        content:
                                                                            'Cancel',
                                                                        color:
                                                                            primaryColor,
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        _deleteItem(
                                                                            index);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          CustomText(
                                                                        content:
                                                                            'Confirm',
                                                                        color:
                                                                            primaryColor,
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        EneftyIcons
                                                            .trash_outline,
                                                        size: 20,
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
                                                dataRowHeight: 40,
                                                horizontalMargin: 5,
                                                columns: const [
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text: 'Variant')),
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text: 'Pack')),
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text: 'Price')),
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text: 'Tax')),
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text:
                                                                  'Quantity')),
                                                  DataColumn(
                                                      label:
                                                          DialogTableHeaderText(
                                                              text: 'Total')),
                                                ],
                                                rows: [
                                                  DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100), 
                                                            child: Text(
                                                              '${cartItem.detail.unitType}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100), 
                                                            child: Text(
                                                              '${cartItem.detail.packtype}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100),
                                                            child: Text(
                                                              '\$${double.parse(cartItem.detail.price ?? '0').toStringAsFixed(2)}',
                                                              textAlign: TextAlign
                                                                  .right,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100), 
                                                            child: Text(
                                                              '${formatAmountToMatch(cartItem.detail.tax ?? '0', 2)}',
                                                              textAlign: TextAlign
                                                                  .right, 
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100),
                                                            child:
                                                                productQuantityManager(
                                                              cartItem,
                                                              cartItem
                                                                  .totalPrice
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        50,
                                                                    maxWidth:
                                                                        100), 
                                                            child: Text(
                                                              '\$${formatAmountToMatch(cartItem.totalPrice.toString(), 2)}',
                                                              textAlign: TextAlign
                                                                  .right, 
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                    const SizedBox(height: 10.0),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: lightPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: CustomText(
                          content: 'Subtotal',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    CartTotalWidget(
                      title: 'Total',
                      content: total,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _options.map((option) {
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
                                      _selectedValue = value;
                                    });
                                  },
                                ),
                                Text(option),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CustomCartButton(
                            text: 'Save as Draft',
                            size: width > 1200 ? 14 : 10,
                            onTap: ()async {
                              List<Detail> detail = CartDatabaseManager()
                          .cartItems
                          .map((e) => e.detail)
                          .toList();

                      final productBYData = AddToCartModel(
                        customerId: customeController.customerId.value,
                        salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                        cartId: '',
                        cartList: detail
                            .map((e) => SendCartData(
                                  productId: e.productId ?? '',
                                  variantId: e.variationId ?? '',
                                  pack: '2',
                                  price: e.price.toString(),
                                  discount: '0',
                                  quantity: e.count.toInt(),
                                ))
                            .toList(),
                        total: productsController.finalAmount.value
                            .toStringAsFixed(0),
                        discount: '0',
                      );
                      CartOrderModel? cartOrder =
                          await ApiWorker().addToCart(productBYData.toJson());
                      log('CartId :${cartOrder?.cartId}');
                      if (cartOrder != null) {
                        int orderStatus = 4;
                        CartOrderModel order = CartOrderModel(
                          customerId: customeController.customerId.value,
                          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                          cartId: cartOrder.cartId,
                          orderStatus: orderStatus,
                        );
                        log('CartId :${cartOrder.cartId}');
                        await productsController.placeOrder(order);
                        CartDatabaseManager().cartItems.clear();
                        CartDatabaseManager().clearCart();
                        Navigator.pop(context);
                      }
                      // homeController.sidebarXController.selectIndex(0);
                      // homeController.selectedIndex.value = 0;
                      // Get.toNamed(AppRoutes.dashboard, id: 2);
                      // showSaveDraftConfirmationDialog();
                            },
                          ),
                          const SizedBox(width: 30),
                          CustomCartButton(
                            text: 'Save & Send',
                            size: width > 1200 ? 14 : 10,
                            onTap: () async {
                              if (cartItems.isNotEmpty &&
                                  customeController
                                      .customerId.value.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                                await Future.delayed(Duration(seconds: 2));
                                List<Detail> detail =
                                    cartItems.map((e) => e.detail).toList();

                                final productBYData = AddToCartModel(
                                  customerId:
                                      customeController.customerId.value,
                                  salesmanId:
                                      SessionHelper.loginSavedData!.salesmanId!,
                                  cartId: '',
                                  cartList: detail
                                      .map((e) => SendCartData(
                                            productId: e.productId ?? '',
                                            variantId: e.variationId ?? '',
                                            pack: '2',
                                            price: e.price.toString(),
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
                                  int orderStatus;
                                  if (_selectedValue == 'Sale Order') {
                                    orderStatus = 11;
                                  } else if (_selectedValue == 'Pre Order') {
                                    orderStatus = 0;
                                  } else if (_selectedValue == 'Estimate') {
                                    orderStatus = 7;
                                  } else {
                                    orderStatus = -1;
                                  }
                                  CartOrderModel order = CartOrderModel(
                                    customerId:
                                        customeController.customerId.value,
                                    salesmanId: SessionHelper
                                        .loginSavedData!.salesmanId!,
                                    cartId: cartOrder.cartId,
                                    orderStatus: orderStatus,
                                  );

                                  log('CartId :${cartOrder.cartId}');
                                  await productsController.placeOrder(order);
                                  _clearCartItem();
                                }
                                Navigator.pop(context);
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
                                                'assets/images/Animation - 1726906882515.json')),
                                      ),
                                      content: CustomText(
                                        content:
                                            'Your order has been successfully placed.',
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
                              } else if (customeController
                                  .customerId.value.isEmpty) {
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
                                    content: Text('Ypur cart is Empty'),
                                    duration: Duration(seconds: 3),
                                  ),
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
          ],
        ),
      ),
    );
  }

  Container productQuantityManager(CartItem cartItem, String sellPrice) {
    return Container(
      width: 80,
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
                        calulateAmount(cartItem);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: CustomText(
                      color: white,
                      content: '-',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
          ),
          Text('${cartItem.detail.count.toStringAsFixed(0)}'),
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
                    calulateAmount(cartItem);
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  calulateAmount(CartItem cartItem) {
    double? price = double.tryParse(cartItem.detail.sellPrice ?? '');
    if (price != null) {
      cartItem.totalPrice =
          (price * cartItem.detail.pieces! * cartItem.detail.count).toInt();
      log("Total price for ${cartItem.detail.price}, Pieces: ${cartItem.detail.pieces}: Total Price ${cartItem.totalPrice}");
    }
  }

  void _clearCartItem() {
    CartDatabaseManager().clearCart();
    setState(() {
      cartItems.clear();
      quantities.clear();
    });
  }

  void _deleteItem(int index) {
    final itemToDelete = cartItems[index];
    CartDatabaseManager().deleteCartItem(itemToDelete);
    setState(() {
      cartItems.removeAt(index);
      quantities.removeAt(index);
    });
  }

  String formatAmountToMatch(String price, int maxIntegerDigits) {
    if (price == null || price.isEmpty) return '0.00';
    final double amount = double.parse(price);
    int integerDigits = amount.floor().toString().length;

    int decimalPlaces = maxIntegerDigits - integerDigits;

    if (decimalPlaces > 0) {
      return amount.toStringAsFixed(decimalPlaces + 2);
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
