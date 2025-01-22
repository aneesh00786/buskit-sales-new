import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ProductVariantDialogue extends StatefulWidget {
  final int index;
  final ProductModel product;
  final List<ProductModel> productList;
  final VoidCallback onDone;
  final List<Detail> detailsCopy;
  final productController;

  ProductVariantDialogue({
    super.key,
    required this.index,
    required this.product,
    required this.productList,
    required this.onDone,
    required this.detailsCopy,
    required this.productController,
  });

  @override
  State<ProductVariantDialogue> createState() => _ProductVariantDialogueState();
}

class _ProductVariantDialogueState extends State<ProductVariantDialogue> {
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  List<String> droDownItem = ['Pack', 'Pcs'];
  double totalPrice = 0.0;
  late List<int> localCounts;

  bool canAddQuantity = false;

  @override
  void initState() {
    super.initState();
    localCounts = List<int>.filled(widget.detailsCopy.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      insetPadding: EdgeInsets.all(40),
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fontSize = constraints.maxWidth / 55;
          final iconSize = constraints.maxWidth / 45;
          final columnSpacing = screenWidth / 40;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Container(
                        height: 12,
                        decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100))),
                        width: double.infinity,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.02,
                              right: screenWidth * 0.1,
                            ),
                            child: CustomText(
                              content: 'Product Variant',
                              fontSize: screenWidth * 0.03,
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
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'product_image',
                        child: Container(
                          height: screenHeight * 0.12,
                          width: screenHeight * 0.12,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: widget.product.imageUrl == null
                                  ? AssetImage('assets/images/otp.png')
                                      as ImageProvider
                                  : NetworkImage(
                                      '${ApiConstants.imageBaseUrl}/${widget.product.imageUrl}' ??
                                          ''),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: constraints.maxWidth < 800
                                ? screenWidth * 0.55
                                : screenWidth * 0.65,
                            child: CustomText(
                              content: widget.product.productName ?? '',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                          CustomText(
                            content: 'Product ID : ${widget.product.id}',
                            fontSize: screenWidth * 0.02,
                          ),
                          Container(
                            width: constraints.maxWidth < 800
                                ? screenWidth * 0.55
                                : screenWidth * 0.65,
                            child: CustomText(
                              content: widget.product.description ?? '',
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              fontSize: screenWidth * 0.015,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: screenWidth * 0.85,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: screenWidth * 0.85,
                      child: DataTable(
                        headingRowHeight: screenHeight * 0.03,
                        dataRowHeight: screenHeight * 0.05,
                        columnSpacing: columnSpacing,
                        headingRowColor:
                            const MaterialStatePropertyAll(secondaryColor),
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Variant',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Unit',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Sale price',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Tax',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Pack',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Total',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Stock',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Sale by',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: CustomText(
                                  content: 'Quantity',
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: List.generate(
                          widget.detailsCopy.length,
                          (i) {
                            Detail detail = widget.detailsCopy[i];
                            return DataRow(
                              cells: [
                                DataCell(Center(
                                    child: CustomText(
                                  content: detail.variationName ?? '',
                                  fontSize: fontSize,
                                ))),
                                DataCell(CustomText(
                                    content: '${detail.unitType}',
                                    fontSize: fontSize)),
                                DataCell(Center(
                                    child: CustomText(
                                  content: formatAmount(detail.sellPrice),
                                  fontSize: fontSize,
                                ))),
                                DataCell(Center(
                                    child: CustomText(
                                  content:
                                      formatAmount(detail.tax),
                                  fontSize: fontSize,
                                ))),
                                DataCell(Center(
                                    child: CustomText(
                                  content: '${detail.pieces ?? 0}',
                                  fontSize: fontSize,
                                ))),
                                DataCell(Center(
                                    child: CustomText(
                                  content:
                                      formatAmount(detail.sellingPackPrice),
                                  fontSize: fontSize,
                                ))),
                                DataCell(
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: detail.stock == 0
                                            ? Colors.red
                                            : detail.stock! < detail.lowstock!
                                                ? Colors.orange
                                                : Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Icon(
                                          detail.stock == 0
                                              ? Icons.close
                                              : detail.stock! < detail.lowstock!
                                                  ? Icons.warning_amber_rounded
                                                  : Icons.check,
                                          color: Colors.white,
                                          size: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: DropdownButton<String>(
                                      dropdownColor: white,
                                      value: detail.saleBy ?? droDownItem[0],
                                      items: droDownItem
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: CustomText(
                                            content: value,
                                            fontSize: fontSize,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          detail.saleBy = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color.fromARGB(255, 240, 239, 239),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5),
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (localCounts[i] > 0) {
                                                  localCounts[i]--;
                                                  detail.count =
                                                      localCounts[i].toDouble();
                                                  calculateAmount(detail);
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.5),
                                              child: Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                                size: iconSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CustomText(
                                          content:
                                              localCounts[i].toStringAsFixed(0),
                                          fontSize: fontSize,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                detail.saleBy ??= 'Pack';

                                                if (detail.stock == 0 &&
                                                    canAddQuantity == false) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        backgroundColor:
                                                            Colors.white,
                                                        title: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .info_outline,
                                                                color:
                                                                    Colors.red),
                                                            const SizedBox(
                                                                width: 8),
                                                            const Text(
                                                              'Out of Stock',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Text(
                                                              'This item is out of stock.',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            const Text(
                                                              'Do you want to add this as a pre-order?',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                canAddQuantity =
                                                                    true; // Allow adding to cart now
                                                                localCounts[
                                                                    i]++; // Increment quantity by 1
                                                                detail.count =
                                                                    localCounts[
                                                                            i]
                                                                        .toDouble(); // Update the count
                                                                calculateAmount(
                                                                    detail); // Recalculate the price
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Yes',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (detail.stock == 0 &&
                                                    canAddQuantity == true) {
                                                  localCounts[i]++;
                                                  detail.count =
                                                      localCounts[i].toDouble();
                                                  calculateAmount(detail);
                                                } else {
                                                  localCounts[i]++;
                                                  detail.count =
                                                      localCounts[i].toDouble();
                                                  calculateAmount(detail);
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.5),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: iconSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //     vertical: screenHeight * 0.03,
                //     horizontal: screenWidth * 0.025,
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       ElevatedButton(
                //           onPressed: () {
                //             log('Customer ID: ${customerAndOrderController.customerId.value}');
                //             log('Selected Customer Name: ${widget.productController.selectedCustomerName.value}');
                //             log('Selected Customer Id: ${widget.productController.selectedCustomerId.value}');

                //             if ((customerAndOrderController.customerId.value !=
                //                         null &&
                //                     customerAndOrderController
                //                         .customerId.value.isNotEmpty) ||
                //                 (widget.productController.selectedCustomerName
                //                             .value !=
                //                         null &&
                //                     widget
                //                         .productController
                //                         .selectedCustomerName
                //                         .value
                //                         .isNotEmpty)) {
                //               List<CartItem> cartItems =
                //                   CartDatabaseManager().getCartItems();
                //               List<Detail> detailsFromCart = cartItems
                //                   .map((cartItem) => cartItem.detail)
                //                   .toList();

                //               bool anyProductProcessed = false;

                //               for (var i = 0;
                //                   i < widget.detailsCopy.length;
                //                   i++) {
                //                 Detail detail = widget.detailsCopy[i];
                //                 log('Processing detail with variationId: ${detail.variationId}, localCounts[i]: ${localCounts[i]}');

                //                 bool isProductAlreadyInCart =
                //                     detailsFromCart.any(
                //                   (item) =>
                //                       item.variationName ==
                //                           detail.variationName &&
                //                       item.sellPrice == detail.sellPrice,
                //                 );

                //                 if (localCounts[i] > 0) {
                //                   anyProductProcessed = true;
                //                   if (!isProductAlreadyInCart) {
                //                     final bool isPack = detail.saleBy == 'Pack';
                //                     CartDatabaseManager().addToCart(
                //                       detail,
                //                       widget.product.productName ?? '',
                //                       detail.totalPrice!.toInt(),
                //                       isPack,
                //                       localCounts[i],
                //                     );
                //                     log('Product added to cart with ID: ${detail.variationId}');
                //                   } else {
                //                     log('Product with ID: ${detail.variationId} is already in the cart. Updating count.');
                //                     CartDatabaseManager().updateCartItemCount(
                //                         detail, localCounts[i]);
                //                   }
                //                 }
                //               }
                //               if (!anyProductProcessed) {
                //                 showDialog(
                //                   context: context,
                //                   builder: (context) {
                //                     return AlertDialog(
                //                       actions: [
                //                         SizedBox(height: 20),
                //                         Center(
                //                             child: Icon(
                //                                 Icons.warning_amber_outlined,
                //                                 size: 50,
                //                                 color: Colors.blue)),
                //                         SizedBox(height: 20),
                //                         Center(
                //                           child: CustomText(
                //                               content: "Please add a variant",
                //                               fontSize: 18),
                //                         ),
                //                         TextButton(
                //                           onPressed: () {
                //                             Navigator.pop(context);
                //                           },
                //                           child: CustomText(
                //                               content: "Ok",
                //                               color: primaryColor),
                //                         ),
                //                       ],
                //                     );
                //                   },
                //                 );
                //                 return; // Prevent further execution
                //               }

                //               widget.onDone();
                //               Navigator.pop(context);
                //             } else {
                //               showDialog(
                //                 context: context,
                //                 builder: (context) {
                //                   return AlertDialog(
                //                     actions: [
                //                       SizedBox(height: 20),
                //                       Center(
                //                           child: Icon(
                //                               Icons.warning_amber_outlined,
                //                               size: 50,
                //                               color: Colors.orange)),
                //                       SizedBox(height: 20),
                //                       Center(
                //                         child: CustomText(
                //                             content: "Please Select a Customer",
                //                             fontSize: 18),
                //                       ),
                //                       TextButton(
                //                         onPressed: () {
                //                           Navigator.pop(context);
                //                         },
                //                         child: CustomText(
                //                             content: "Ok", color: primaryColor),
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               );
                //             }
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: primaryButtonColor,
                //             padding: EdgeInsets.symmetric(
                //               horizontal: screenWidth * 0.04,
                //               vertical: screenHeight * 0.01,
                //             ),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //           ),
                //           child: Row(
                //             children: [
                //               CustomText(
                //                 content: "Add",
                //                 fontSize: screenWidth * 0.02,
                //                 color: Colors.white,
                //               ),
                //               SizedBox(
                //                 width: 4,
                //               ),
                //               Icon(
                //                 EneftyIcons.shopping_cart_outline,
                //                 color: white,
                //                 size: screenWidth * 0.02,
                //               )
                //             ],
                //           )),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03,
                    horizontal: screenWidth * 0.025,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (canAddQuantity == false) {
                              log('Customer ID: ${customerAndOrderController.customerId.value}');
                              log('Selected Customer Name: ${widget.productController.selectedCustomerName.value}');
                              log('Selected Customer Id: ${widget.productController.selectedCustomerId.value}');
                              if ((customerAndOrderController
                                      .customerId.value.isNotEmpty) ||
                                  (widget.productController.selectedCustomerName
                                      .value.isNotEmpty)) {
                                List<CartItem> cartItems =
                                    CartDatabaseManager().getCartItems();
                                List<Detail> detailsFromCart = cartItems
                                    .map((cartItem) => cartItem.detail)
                                    .toList();
                                for (var i = 0;
                                    i < widget.detailsCopy.length;
                                    i++) {
                                  Detail detail = widget.detailsCopy[i];
                                  bool isProductAlreadyInCart =
                                      detailsFromCart.any(
                                    (item) =>
                                        item.variationName ==
                                            detail.variationName &&
                                        item.sellPrice == detail.sellPrice,
                                  );
                                  if (localCounts[i] > 0) {
                                    if (!isProductAlreadyInCart) {
                                      final bool isPack =
                                          detail.saleBy == 'Pack';
                                      CartDatabaseManager().addToCart(
                                        detail,
                                        widget.product.productName ?? '',
                                        detail.totalPrice!.toInt(),
                                        isPack,
                                        localCounts[i],
                                      );
                                      log('Product added to cart with ID: ${detail.variationId}');
                                    } else {
                                      log('Product with ID: ${detail.variationId} is already in the cart. Updating count.');
                                      CartDatabaseManager().updateCartItemCount(
                                          detail, localCounts[i]);
                                    }
                                  } else {
                                    log('Cannot add product with ID: ${detail.variationId} because the count is zero or less.');
                                  }
                                }

                                widget.onDone();
                                Navigator.pop(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        const SizedBox(height: 20),
                                        const Center(
                                            child: Icon(
                                                Icons.warning_amber_outlined,
                                                size: 50,
                                                color: Colors.orange)),
                                        const SizedBox(height: 20),
                                        Center(
                                            child: CustomText(
                                                content:
                                                    "Please Select a Customer",
                                                fontSize: 18)),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: CustomText(
                                              content: "Ok",
                                              color: primaryColor),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else if (canAddQuantity == true) {
                              // for checking
                              // showCustomToastDisplay(context,
                              //     'PRE ORDER ACTION', Colors.blue, Icons.check);
                              // ~~~~~~~~~~~~~~~~~~~~

                              log('Customer ID: ${customerAndOrderController.customerId.value}');
                              log('Selected Customer Name: ${widget.productController.selectedCustomerName.value}');
                              log('Selected Customer Id: ${widget.productController.selectedCustomerId.value}');
                              if ((customerAndOrderController
                                      .customerId.value.isNotEmpty) ||
                                  (widget.productController.selectedCustomerName
                                      .value.isNotEmpty)) {
                                List<CartItem> cartPreorderItems =
                                    CartDatabaseManager()
                                        .getCartPreorderItems();
                                List<Detail> detailsFromCart = cartPreorderItems
                                    .map((cartPreorderItem) =>
                                        cartPreorderItem.detail)
                                    .toList();
                                // for (var i = 0;
                                //     i < widget.detailsCopy.length;
                                //     i++) {
                                //   Detail detail = widget.detailsCopy[i];
                                //   bool isProductAlreadyInCart =
                                //       detailsFromCart.any(
                                //     (item) =>
                                //         item.variationName ==
                                //             detail.variationName &&
                                //         item.sellPrice == detail.sellPrice,
                                //   );
                                //   if (localCounts[i] > 0) {
                                //     if (!isProductAlreadyInCart) {
                                //       final bool isPack =
                                //           detail.saleBy == 'Pack';
                                //       CartDatabaseManager().addToPreorderCart(
                                //         detail,
                                //         widget.product.productName ?? '',
                                //         detail.totalPrice!.toInt(),
                                //         isPack,
                                //         localCounts[i],
                                //       );
                                //       log('Product added to cart with ID: ${detail.variationId}');
                                //     } else {
                                //       log('Product with ID: ${detail.variationId} is already in the cart. Updating count.');
                                //       CartDatabaseManager().updateCartItemCount(
                                //           detail, localCounts[i]);
                                //     }
                                //   } else {
                                //     log('Cannot add product with ID: ${detail.variationId} because the count is zero or less.');
                                //   }
                                // }

                                for (var i = 0;
                                    i < widget.detailsCopy.length;
                                    i++) {
                                  Detail detail = widget.detailsCopy[i];
                                  final bool isPack = detail.saleBy == 'Pack';

                                  if (localCounts[i] > 0) {
                                    if ((detail.stock ?? 0) > 0) {
                                      bool isProductAlreadyInCart =
                                          detailsFromCart.any(
                                        (item) =>
                                            item.variationName ==
                                                detail.variationName &&
                                            item.sellPrice == detail.sellPrice,
                                      );

                                      if (!isProductAlreadyInCart) {
                                        CartDatabaseManager().addToCart(
                                          detail,
                                          widget.product.productName ?? '',
                                          detail.totalPrice!.toInt(),
                                          isPack,
                                          localCounts[i],
                                        );
                                        log('Product added to regular cart with ID: ${detail.variationId}');
                                      } else {
                                        log('Product with ID: ${detail.variationId} is already in the regular cart. Updating count.');
                                        CartDatabaseManager()
                                            .updateCartItemCount(
                                                detail, localCounts[i]);
                                      }
                                    } else if (canAddQuantity) {
                                      bool isProductAlreadyInPreorderCart =
                                          detailsFromCart.any(
                                        (item) =>
                                            item.variationName ==
                                                detail.variationName &&
                                            item.sellPrice == detail.sellPrice,
                                      );

                                      if (!isProductAlreadyInPreorderCart) {
                                        CartDatabaseManager().addToPreorderCart(
                                          detail,
                                          widget.product.productName ?? '',
                                          detail.totalPrice!.toInt(),
                                          isPack,
                                          localCounts[i],
                                        );
                                        log('Product added to pre-order cart with ID: ${detail.variationId}');
                                      } else {
                                        log('Product with ID: ${detail.variationId} is already in the pre-order cart. Updating count.');
                                        CartDatabaseManager()
                                            .updatePreorderCartItemCount(
                                                detail, localCounts[i]);
                                      }
                                    }
                                  } else {
                                    log('Cannot add product with ID: ${detail.variationId} because the count is zero or less.');
                                  }
                                }

                                widget.onDone();
                                Navigator.pop(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        const SizedBox(height: 20),
                                        const Center(
                                            child: Icon(
                                                Icons.warning_amber_outlined,
                                                size: 50,
                                                color: Colors.orange)),
                                        const SizedBox(height: 20),
                                        Center(
                                            child: CustomText(
                                                content:
                                                    "Please Select a Customer",
                                                fontSize: 18)),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: CustomText(
                                              content: "Ok",
                                              color: primaryColor),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomText(
                                content: canAddQuantity
                                    ? "Add to Cart"
                                    : "Add to Cart",
                                fontSize: screenWidth * 0.02,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              Icon(
                                EneftyIcons.shopping_cart_outline,
                                size: screenWidth * 0.03,
                                color: white,
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void incrementCount(int index) {
    setState(() {
      localCounts[index]++;
    });
  }

  void decrementCount(int index) {
    setState(() {
      if (localCounts[index] > 0) {
        localCounts[index]--;
      }
    });
  }

  void calculateAmount(Detail detail) {
    double? price = double.tryParse(detail.sellPrice ?? '');
    if (detail.count != null && detail.count > 0) {
      if (price != null && detail.saleBy == 'Pack') {
        detail.totalPrice = price * detail.pieces! * detail.count;
        log("Total price for Pack: ${detail.sellPrice}, Pieces: ${detail.pieces}, Count: ${detail.count}, Total Price: ${detail.totalPrice}");
      } else if (price != null) {
        detail.totalPrice = price * detail.count;
        log("Total price for Pieces: ${detail.sellPrice}, Count: ${detail.count}, Total Price: ${detail.totalPrice}");
      }
    } else {
      detail.totalPrice = 0;
      log("Count is zero or negative for product: ${detail.variationName}. Total Price set to: ${detail.totalPrice}");
    }
  }
}
