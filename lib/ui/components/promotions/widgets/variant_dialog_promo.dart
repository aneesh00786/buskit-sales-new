import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProductVariantDialoguePromo extends StatefulWidget {
  final int index;
  final ProductModel product;
  final List<ProductModel> productList;
  final VoidCallback onDone;
  final List<Detail> detailsCopy;
  final ProductsController productController;
  final ValueChanged<List<Map<String, dynamic>>>? onVariantsSelected;

  const ProductVariantDialoguePromo({
    super.key,
    required this.index,
    required this.product,
    required this.productList,
    required this.onDone,
    required this.detailsCopy,
    required this.productController,
    this.onVariantsSelected,
  });

  @override
  State<ProductVariantDialoguePromo> createState() =>
      _ProductVariantDialoguePromoState();
}

class _ProductVariantDialoguePromoState
    extends State<ProductVariantDialoguePromo> {
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  List<String> droDownItem = ['Pack', 'Pcs'];
  double totalPrice = 0.0;
  late List<int> localCounts;
  @override
  void initState() {
    super.initState();
    localCounts = List<int>.filled(widget.detailsCopy.length, 0);
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.getCartItemCounts(
        customerAndOrderController.customerId.value.isNotEmpty
            ? customerAndOrderController.customerId.value
            : widget.productController.selectedCustomerId.value);
    CartDatabaseManager().addListener(() {
      cartProvider.updateCartCount(
          customerAndOrderController.customerId.value.isNotEmpty
              ? customerAndOrderController.customerId.value
              : widget.productController.selectedCustomerId.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
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
                      GestureDetector(
                        onTap: () {
                          if (widget.product.imageUrl == null) {
                            // Show asset image directly
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => AlertDialog(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusGeometry.circular(20)),
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(50.0),
                                content: SizedBox(
                                  width: constraints.maxWidth * 0.8,
                                  height: constraints.maxWidth * 0.8,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.black,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: Image.asset(
                                                'assets/images/otp.png'),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: dialogCloseButton1(context, red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show expanded image dialog directly
                            final imageUrl =
                                '${ApiConstants.imageBaseUrl}/${widget.product.imageUrl}';
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => AlertDialog(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusGeometry.circular(20)),
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(50.0),
                                content: SizedBox(
                                  width: constraints.maxWidth * 0.8,
                                  height: constraints.maxWidth * 0.8,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  const Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/Image-not-found.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: dialogCloseButton1(context, red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            SizedBox(
                              height: screenHeight * 0.12,
                              width: screenHeight * 0.12,
                              child: widget.product.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          '${ApiConstants.imageBaseUrl}/${widget.product.imageUrl}',
                                      placeholder: (context, url) =>
                                          const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: CircleAvatar(
                                            radius: 10,
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/images/Image-not-found.png'),
                                    )
                                  : Image.asset(
                                      'assets/images/Image-not-found.png'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
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
                          SizedBox(
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
                SizedBox(
                  width: double.maxFinite,
                  child: ScrollbarTheme(
                    data: const ScrollbarThemeData(
                      thumbColor: WidgetStatePropertyAll(Colors.blue),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: DataTable(
                            headingRowHeight: screenHeight * 0.03,
                            // ignore: deprecated_member_use
                            dataRowHeight: screenHeight * 0.05,
                            columnSpacing: columnSpacing,
                            headingRowColor:
                                const WidgetStatePropertyAll(secondaryColor),
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
                                      maxLine: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                                    DataCell(CustomText(
                                      content: '${detail.unitType}',
                                      fontSize: fontSize,
                                      maxLine: 1,
                                    )),
                                    DataCell(Center(
                                        child: CustomText(
                                      content: formatAmount(detail.sellPrice),
                                      fontSize: fontSize,
                                      maxLine: 1,
                                    ))),
                                    DataCell(Center(
                                        child: CustomText(
                                      content: formatAmount(detail.tax),
                                      fontSize: fontSize,
                                      maxLine: 1,
                                    ))),
                                    DataCell(Center(
                                        child: CustomText(
                                      content: '${detail.pieces ?? 0}',
                                      fontSize: fontSize,
                                      maxLine: 1,
                                    ))),
                                    DataCell(Center(
                                        child: CustomText(
                                      content:
                                          formatAmount(detail.sellingPackPrice),
                                      fontSize: fontSize,
                                      maxLine: 1,
                                    ))),
                                    DataCell(
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: detail.stock == 0
                                                ? Colors.red
                                                : (detail.stock ?? 0) <
                                                        detail.lowstock!
                                                    ? Colors.orange
                                                    : Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Icon(
                                              detail.stock == 0
                                                  ? Icons.close
                                                  : (detail.stock ?? 0) <
                                                          (detail.lowstock ?? 0)
                                                      ? Icons
                                                          .warning_amber_rounded
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
                                          value:
                                              detail.saleBy ?? droDownItem[0],
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromARGB(
                                              255, 240, 239, 239),
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
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (localCounts[i] > 0) {
                                                      localCounts[i]--;
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
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
                                              content: localCounts[i]
                                                  .toStringAsFixed(0),
                                              fontSize: fontSize,
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    detail.saleBy ??= 'Pack';
                                                    if (detail.stock == 0) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: const Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .info_outline,
                                                                    color: Colors
                                                                        .red),
                                                                SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  'Out of Stock',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content:
                                                                const Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  'This item is out of stock.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  'Do you want to add this as a booking?',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
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
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'No',
                                                                  style:
                                                                      TextStyle(
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
                                                                    localCounts[
                                                                        i]++;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Yes',
                                                                  style:
                                                                      TextStyle(
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
                                                    } else if (detail.stock ==
                                                        0) {
                                                      localCounts[i]++;
                                                    } else {
                                                      localCounts[i]++;
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
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
                      ElevatedButton(
                        onPressed: () async {
                          final customerId = customerAndOrderController
                                  .customerId.value.isNotEmpty
                              ? customerAndOrderController.customerId.value
                              : widget
                                  .productController.selectedCustomerId.value;

                          int totalCount = 0;

                          if ((customerAndOrderController
                                  .customerId.value.isNotEmpty) ||
                              (widget.productController.selectedCustomerName
                                  .value.isNotEmpty)) {
                            log("details copy : ${widget.detailsCopy.map((e) => e.toJson()).toList()}");
                            for (var i = 0;
                                i < widget.detailsCopy.length;
                                i++) {
                              if (localCounts[i] > 0) {
                                totalCount += localCounts[i];
                              } else {}
                            }
                            if (totalCount == 0) {
                              showCustomToastDisplay(
                                  context,
                                  "Choose at least one variant to add to cart",
                                  Colors.orange,
                                  Icons.warning);
                              return;
                            }
                            // Accumulate selections and return to parent instead of adding to cart
                            final List<Map<String, dynamic>> selections = [];
                            for (var i = 0;
                                i < widget.detailsCopy.length;
                                i++) {
                              Detail detail = widget.detailsCopy[i];
                              if (localCounts[i] > 0) {
                                selections.add({
                                  'detail': detail,
                                  'quantity': localCounts[i],
                                  'isPack': (detail.saleBy ?? 'Pack') == 'Pack',
                                  'productName':
                                      widget.product.productName ?? '',
                                  'inclTax': widget.product.inclTax ?? '',
                                  'catId': widget.product.catId ?? 0,
                                });
                                log('Selected variant ID: ${detail.variationId} with quantity ${localCounts[i]}');
                              }
                            }

                            if (widget.onVariantsSelected != null) {
                              widget.onVariantsSelected!(selections);
                            }

                            Navigator.pop(context);
                          } else {
                            showDialog(
                              barrierDismissible: false,
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
                                            content: "Please Select a Customer",
                                            fontSize: 18)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: CustomText(
                                          content: "Ok", color: primaryColor),
                                    ),
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
                        child: Row(
                          children: [
                            CustomText(
                              content: "Add to Selection",
                              fontSize: screenWidth * 0.02,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: screenWidth * 0.02,
                            ),
                            Icon(
                              Icons.shopping_bag,
                              size: screenWidth * 0.03,
                              color: white,
                            )
                          ],
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
}
