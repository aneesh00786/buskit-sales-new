import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ProductVariantDialogue extends StatefulWidget {
  final List<Detail> productDetail;
  final int index;
  final ProductModel product;
  final List<ProductModel> productList;
  final VoidCallback onDone;
  final List<Detail> detailsCopy;

  ProductVariantDialogue({
    super.key,
    required this.productDetail,
    required this.index,
    required this.product,
    required this.productList,
    required this.onDone,
    required this.detailsCopy,
  });

  @override
  State<ProductVariantDialogue> createState() => _ProductVariantDialogueState();
}

class _ProductVariantDialogueState extends State<ProductVariantDialogue> {
  CustomerAndOrderController customerAndOrderController =
      Get.find<CustomerAndOrderController>();

  List<String> droDownItem = ['Pack', 'Pcs'];
  double totalPrice = 0.0;
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
          final fontSize = constraints.maxWidth > 1000
              ? 13.0
              : (constraints.maxWidth > 800
                  ? 10.0
                  : (constraints.maxWidth > 400 ? 9.0 : 8.0));

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
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Hero(
                  tag: 'product_image',
                  child: Container(
                    height: screenHeight * 0.1,
                    width: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.product.imageUrl == null ||
                                widget.product.imageUrl!.contains('.jpg') ||
                                widget.product.imageUrl!.contains('.jpeg') ||
                                widget.product.imageUrl!.contains('.png') ||
                                widget.product.imageUrl!.contains('.webp')
                            ? AssetImage('assets/images/otp.png')
                                as ImageProvider
                            : NetworkImage(widget.product.imageUrl ?? ''),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: [
                    Text(
                      widget.product.productName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    Text('Product ID : ${widget.product.id}'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    
                    border: Border.all(color: secondaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: screenHeight * 0.03,
                      dataRowHeight: screenHeight * 0.05,
                      columnSpacing: screenWidth > 1000
                          ? screenWidth * 0.05
                          : (screenWidth > 800
                              ? screenWidth * 0.04
                              : (screenWidth > 400
                                  ? screenWidth * 0.02
                                  : screenWidth * 0.01)),
                      headingRowColor:
                          const MaterialStatePropertyAll(secondaryColor),
                      columns: [
                        DataColumn(
                          label: CustomText(
                            content: 'Variant',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Unit',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Sale price',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Tax',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Pack',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Total',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Stock',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Sale by',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        DataColumn(
                          label: CustomText(
                            content: 'Quantity',
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
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
                                content: detail.sellPrice ?? '',
                                fontSize: fontSize,
                              ))),
                              DataCell(Center(
                                  child: CustomText(
                                content: detail.tax ?? '',
                                fontSize: fontSize,
                              ))),
                              DataCell(Center(
                                  child: CustomText(
                                content: '${detail.pieces ?? 0}',
                                fontSize: fontSize,
                              ))),
                              DataCell(Center(
                                  child: CustomText(
                                content: '${detail.fullstock}',
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5))),
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (detail.count > 0) {
                                                detail.count--;
                                                calulateAmount(detail);
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            color: white,
                                            size: fontSize,
                                          )),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),
                                    CustomText(
                                      content:
                                          '${detail.count.toStringAsFixed(0)}',
                                      fontSize: fontSize,
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(5),
                                                bottomRight:
                                                    Radius.circular(5))),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                detail.saleBy ??= 'Pack';
                                                if (detail.stock == 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: CustomText(
                                                        content:
                                                            'This item is out of stock',
                                                        color: Colors.white,
                                                      ),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                } else {
                                                  detail.count++;
                                                  calulateAmount(detail);
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.add,
                                              color: white,
                                              size: fontSize,
                                            ))),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03,
                    horizontal: screenWidth * 0.025,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: CustomText(
                          content: 'Cancel',
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.02,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (customerAndOrderController
                              .customerId.isNotEmpty) {
                            List<CartItem> cartItems =
                                await CartDatabaseManager().getCartItems();
                            List<Detail> detailsFromCart = cartItems
                                .map((cartItem) => cartItem.detail)
                                .toList();
                            for (var detail in widget.detailsCopy) {
                              bool isProductAlreadyInCart = detailsFromCart.any(
                                  (item) =>
                                      item.variationId == detail.variationId);
                              if (detail.count > 0 && !isProductAlreadyInCart) {
                                final bool isPack =
                                    detail.saleBy == 'Pack' ? true : false;
                                CartDatabaseManager().addToCart(
                                    detail,
                                    widget.product.productName ?? '',
                                    detail.totalPrice!.toInt(),
                                    isPack);
                                log('Total Price: ${detail.totalPrice}');
                                log('Detail log is Pack: ${isPack}');
                                log('Product added to cart with ID: ${detail.variationId}');
                                log('Pack or Pieces : ${detail.saleBy}');
                              } else if (isProductAlreadyInCart) {
                                log('Product with ID: ${detail.variationId} is already in the cart');
                              }
                              widget.onDone();
                            }
                            Navigator.pop(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.warning_amber_outlined,
                                        size: 50,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: CustomText(
                                        content: "Please Select a Customer",
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: CustomText(
                                          content: "Ok",
                                          color: primaryColor,
                                        ))
                                  ],
                                );
                              },
                            );
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
                        child: CustomText(
                          content: "Done",
                          fontSize: screenWidth * 0.02,
                          color: Colors.white,
                        ),
                      ),
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

  void calulateAmount(Detail detail) {
    double? price = double.tryParse(detail.sellPrice ?? '');
    if (price != null && detail.saleBy == 'Pack') {
      detail.totalPrice = price * detail.pieces! * detail.count;
      log("Total price for ${detail.price}, Pieces: ${detail.pieces}: Total Price ${detail.totalPrice}");
    } else if (price != null) {
      detail.totalPrice = price * detail.count;
      log("Total price for ${detail.price}, Total Price: ${detail.totalPrice}");
    }
  }
}
