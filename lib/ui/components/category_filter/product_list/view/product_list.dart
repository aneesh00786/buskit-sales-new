import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/widgets/variant_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class ProductGrid extends StatefulWidget {
  String optionName;
  final ProductsController productsController;
  String id;
  final VoidCallback playAddToCartAnimation;

  ProductGrid({
    super.key,
    required this.optionName,
    required this.productsController,
    required this.id,
    required this.playAddToCartAnimation,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  List<ProductModel> products = [];
  String? name;
  bool isLoading = true;
  bool hasInternet = true;

  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    log('Option name : ${widget.optionName}');
  }

  Future<void> _checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    hasInternet = !connectivityResult.contains(ConnectivityResult.none);
    log('Has Internet: $hasInternet');

    if (hasInternet) {
      _fetchInitialProducts();
    } else {
      _loadProductsFromHive();
    }
  }

  Future<void> _loadProductsFromHive() async {
    final selectedSubCatId =
        widget.productsController.selectedSubCategoryId.value;

    try {
      Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      // Check if the box has any data
      if (scidGroupBox.isEmpty) {
        setState(() {
          products = [];
          isLoading = false;
        });
        return;
      }

      final scidGroup = scidGroupBox.get(selectedSubCatId);
      if (scidGroup != null) {
        setState(() {
          products = scidGroup.products;
          isLoading = false;
        });
      } else {
        var productBox = Hive.box<ProductModel>('products');
        if (productBox.isNotEmpty) {

          final allScids =
              productBox.values.map((p) => p.scid).toSet().toList();
          log('All scids available in legacy cache: $allScids');

          List<ProductModel> offlineProducts = productBox.values
              .where((product) => product.scid == selectedSubCatId)
              .toList();
          log("Loaded ${offlineProducts.length} products for subcategory $selectedSubCatId from legacy cache");

          if (offlineProducts.isNotEmpty) {
            log('Product scids found in legacy cache: ${offlineProducts.map((p) => p.scid).toSet().toList()}');
          }

          setState(() {
            products = offlineProducts;
            isLoading = false;
          });
        } else {
          log("No products available offline for subcategory $selectedSubCatId");
          setState(() {
            products = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      log('Error loading products from Hive: $e');
      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchProductsByCategory(widget.id);
      });
    }
  }

  Future<void> _fetchInitialProducts() async {
    try {
      SubCategoryItem? subCategoryItem =
          widget.productsController.getInitialSubCategoryIdAndName();
      name = subCategoryItem?.subCategory ?? '';

      log('_fetchInitialProducts: SubCategoryItem - ID: ${subCategoryItem?.id}, Name: ${subCategoryItem?.subCategory}');
      log('_fetchInitialProducts: Current selectedSubCategoryId: ${widget.productsController.selectedSubCategoryId.value}');

      if (subCategoryItem?.id != null && subCategoryItem!.id!.isNotEmpty) {
        log('_fetchInitialProducts: Fetching products for SCID: ${subCategoryItem.id}');
        List<ProductModel> fetchedProducts = await widget.productsController
            .fetchProducts(subCategoryItem.id.toString());

        log('_fetchInitialProducts: API returned ${fetchedProducts.length} products');
        log('_fetchInitialProducts: Product SCIDs: ${fetchedProducts.map((p) => p.scid).toSet().toList()}');
        log('_fetchInitialProducts: Product names: ${fetchedProducts.map((p) => p.productName).toList()}');

        setState(() {
          products = fetchedProducts;
          isLoading = false;
        });

        log('_fetchInitialProducts: Final product count: ${products.length} for subcategory: ${subCategoryItem.subCategory}');
      } else {
        log('_fetchInitialProducts: No valid subcategory ID found');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching initial products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProductsByCategory(String categoryId) async {
    if (categoryId.isEmpty) {
      log('Category ID is empty, skipping product fetch');
      return;
    }

    log('_fetchProductsByCategory: Fetching products for categoryId: $categoryId');
    log('_fetchProductsByCategory: Current selectedSubCategoryId: ${widget.productsController.selectedSubCategoryId.value}');

    setState(() {
      widget.productsController.isLoading.value = true;
    });

    try {
      List<ProductModel> fetchedProducts =
          await widget.productsController.fetchProducts(categoryId);

      log('_fetchProductsByCategory: API returned ${fetchedProducts.length} products');
      log('_fetchProductsByCategory: Product SCIDs: ${fetchedProducts.map((p) => p.scid).toSet().toList()}');
      log('_fetchProductsByCategory: Product names: ${fetchedProducts.map((p) => p.productName).toList()}');

      setState(() {
        products = fetchedProducts;
        widget.productsController.isLoading.value = false;
      });

      log('_fetchProductsByCategory: Final product count: ${products.length} for category: $categoryId');
    } catch (e) {
      log('Error fetching products for category: $e');
      setState(() {
        widget.productsController.isLoading.value = false;
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _checkInternetConnection();
  //   log('Option name : ${widget.optionName}');
  // }

  // Future<void> _checkInternetConnection() async {
  //   final List<ConnectivityResult> connectivityResult =
  //       await (Connectivity().checkConnectivity());
  //   hasInternet = !connectivityResult.contains(ConnectivityResult.none);
  //   log('Has Internet: $hasInternet');

  //   if (hasInternet) {
  //     _fetchInitialProducts();
  //   } else {
  //     _loadProductsFromHive();
  //   }
  // }

  // Future<void> _loadProductsFromHive() async {
  //   final selectedSubCatId =
  //       widget.productsController.selectedSubCategoryId.value;
  //   log('Loading products from Hive for subcategory: $selectedSubCatId');

  //   try {
  //     // Try to load from scid-based cache first
  //     Box<ScidProductGroup> scidGroupBox;
  //     if (Hive.isBoxOpen('scidProductGroups')) {
  //       scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
  //       log('Using existing scidProductGroups box');
  //     } else {
  //       scidGroupBox =
  //           await Hive.openBox<ScidProductGroup>('scidProductGroups');
  //       log('Created new scidProductGroups box');
  //     }

  //     // Check if the box has any data
  //     if (scidGroupBox.isEmpty) {
  //       log('ScidProductGroups cache is empty');
  //       setState(() {
  //         products = [];
  //         isLoading = false;
  //       });
  //       return;
  //     }

  //     log('ScidProductGroups cache has ${scidGroupBox.length} entries');
  //     log('Available scid keys: ${scidGroupBox.keys.toList()}');

  //     final scidGroup = scidGroupBox.get(selectedSubCatId);
  //     if (scidGroup != null) {
  //       log('Found scid group: ${scidGroup.scid} with ${scidGroup.products.length} products');
  //       setState(() {
  //         products = scidGroup.products;
  //         isLoading = false;
  //       });
  //       return;
  //     }

  //     log('No scid group found for subcategory: $selectedSubCatId');
  //     // Fallback to legacy cache - filter by scid
  //     var productBox = Hive.box<ProductModel>('products');
  //     if (productBox.isNotEmpty) {
  //       log('Legacy cache has ${productBox.length} products');

  //       // Show all available scids in legacy cache for debugging
  //       final allScids =
  //           productBox.values.map((p) => p.scid).toSet().toList();
  //       log('All scids available in legacy cache: $allScids');

  //       List<ProductModel> offlineProducts = productBox.values
  //           .where((product) => product.scid == selectedSubCatId)
  //           .toList();
  //       log("Loaded ${offlineProducts.length} products for subcategory $selectedSubCatId from legacy cache");

  //       if (offlineProducts.isNotEmpty) {
  //         log('Product scids found in legacy cache: ${offlineProducts.map((p) => p.scid).toSet().toList()}');
  //       }

  //       setState(() {
  //         products = offlineProducts;
  //         isLoading = false;
  //       });
  //     } else {
  //       log("No products available offline for subcategory $selectedSubCatId");
  //       setState(() {
  //         products = [];
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     log('Error loading products from Hive: $e');
  //     setState(() {
  //       products = [];
  //       isLoading = false;
  //     });
  //   }
  // }

  // @override
  // void didUpdateWidget(covariant ProductGrid oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.id != oldWidget.id) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _fetchProductsByCategory(widget.id);
  //     });
  //   }
  // }

  // Future<void> _fetchInitialProducts() async {
  //   try {
  //     SubCategoryItem? subCategoryItem =
  //         widget.productsController.getInitialSubCategoryIdAndName();
  //     name = subCategoryItem?.subCategory ?? '';

  //     log('_fetchInitialProducts: SubCategoryItem - ID: ${subCategoryItem?.id}, Name: ${subCategoryItem?.subCategory}');
  //     log('_fetchInitialProducts: Current selectedSubCategoryId: ${widget.productsController.selectedSubCategoryId.value}');

  //     if (subCategoryItem?.id != null && subCategoryItem!.id!.isNotEmpty) {
  //       log('_fetchInitialProducts: Fetching products for SCID: ${subCategoryItem.id}');
  //       List<ProductModel> fetchedProducts = await widget.productsController
  //           .fetchProducts(subCategoryItem.id.toString());

  //       log('_fetchInitialProducts: API returned ${fetchedProducts.length} products');
  //       log('_fetchInitialProducts: Product SCIDs: ${fetchedProducts.map((p) => p.scid).toSet().toList()}');
  //       log('_fetchInitialProducts: Product names: ${fetchedProducts.map((p) => p.productName).toList()}');

  //       setState(() {
  //         products = fetchedProducts;
  //         isLoading = false;
  //       });

  //       log('_fetchInitialProducts: Final product count: ${products.length} for subcategory: ${subCategoryItem.subCategory}');
  //     } else {
  //       log('_fetchInitialProducts: No valid subcategory ID found');
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     log('Error fetching initial products: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _fetchProductsByCategory(String categoryId) async {
  //   if (categoryId.isEmpty) {
  //     log('Category ID is empty, skipping product fetch');
  //     return;
  //   }

  //   log('_fetchProductsByCategory: Fetching products for categoryId: $categoryId');
  //   log('_fetchProductsByCategory: Current selectedSubCategoryId: ${widget.productsController.selectedSubCategoryId.value}');

  //   setState(() {
  //     widget.productsController.isLoading.value = true;
  //   });

  //   try {
  //     List<ProductModel> fetchedProducts =
  //         await widget.productsController.fetchProducts(categoryId);

  //     log('_fetchProductsByCategory: API returned ${fetchedProducts.length} products');
  //     log('_fetchProductsByCategory: Product SCIDs: ${fetchedProducts.map((p) => p.scid).toSet().toList()}');
  //     log('_fetchProductsByCategory: Product names: ${fetchedProducts.map((p) => p.productName).toList()}');

  //     setState(() {
  //       products = fetchedProducts;
  //       widget.productsController.isLoading.value = false;
  //     });

  //     log('_fetchProductsByCategory: Final product count: ${products.length} for category: $categoryId');
  //   } catch (e) {
  //     log('Error fetching products for category: $e');
  //     setState(() {
  //       widget.productsController.isLoading.value = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    const double desiredItemWidth = 250.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double fontSize =
                (constraints.maxWidth * 0.06).clamp(11.0, 16.0);
            return Text(
              widget.productsController.selectedSubCategoryName.value.isEmpty
                  ? name ?? ''
                  : widget.productsController.selectedSubCategoryName.value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? const Center(
                      child: Text(
                      'No Products Available',
                      style: TextStyle(fontSize: 25),
                    ))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: desiredItemWidth,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 10 / 9,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final double imageHeight =
                                constraints.maxHeight * 0.45;
                            final double nameFontSize =
                                (constraints.maxWidth * 0.06).clamp(11.0, 16.0);
                            (constraints.maxWidth * 0.05).clamp(10.0, 14.0);
                            final double stockFontSize =
                                (constraints.maxWidth * 0.04).clamp(8, 12.0);

                            int piecesLow = 0;
                            int piecesHigh = 0;
                            double sellingPackPriceLow = 0;
                            double sellingPackPriceHigh = 0;

                            List<double> sellPriceValues = product.detail!
                                .where((e) => e.stock != null
                                    //  && e.stock! > 0
                                    )
                                .map((e) =>
                                    double.tryParse(
                                        e.sellingPrice.toString()) ??
                                    0.0)
                                .toList();

                            product.detail?.forEach((e) {
                              double price =
                                  double.tryParse(e.sellingPrice.toString()) ??
                                      0.0;
                              if (sellPriceValues.isNotEmpty &&
                                  price ==
                                      sellPriceValues
                                          .reduce((a, b) => a < b ? a : b)) {
                                piecesLow = e.pieces!.toInt();
                                sellingPackPriceLow =
                                    e.sellingPackPrice?.toDouble() ?? 0;
                              }
                              if (sellPriceValues.isNotEmpty &&
                                  price ==
                                      sellPriceValues
                                          .reduce((a, b) => a > b ? a : b)) {
                                piecesHigh = e.pieces!.toInt();
                                sellingPackPriceHigh =
                                    e.sellingPackPrice?.toDouble() ?? 0;
                              }
                            });

                            double smallestSellPrice =
                                sellPriceValues.isNotEmpty
                                    ? sellPriceValues
                                        .reduce((a, b) => a < b ? a : b)
                                    : 0.0;
                            double largestSellPrice = sellPriceValues.isNotEmpty
                                ? sellPriceValues
                                    .reduce((a, b) => a > b ? a : b)
                                : 0.0;

                            num lowstockItem = 0;
                            num outOfStockItem = 0;

                            product.detail?.forEach((detail) {
                              num stock = detail.stock ?? 0;
                              num lowstock = detail.lowstock ?? 0;
                              if (stock == 0) {
                                outOfStockItem++;
                              } else if (stock < lowstock) {
                                lowstockItem++;
                              }
                            });

                            return GestureDetector(
                              onTap: () {
                                _showProductVariantDialog(
                                    product.detail ?? [],
                                    index,
                                    product,
                                    products,
                                    widget.playAddToCartAnimation);
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          color: const Color.fromARGB(
                                              255, 247, 247, 247),
                                          height: imageHeight,
                                          width: double.maxFinite,
                                          child: product.imageUrl != null
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      '${ApiConstants.imageBaseUrl}/${product.imageUrl}',
                                                  placeholder: (context, url) =>
                                                      const Padding(
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    child: CircleAvatar(
                                                        radius: 10,
                                                        child:
                                                            CircularProgressIndicator()),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Image.asset(
                                                          'assets/images/Image-not-found.png'),
                                                )
                                              : Image.asset(
                                                  'assets/images/Image-not-found.png'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            product.productName ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: nameFontSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (subscriptionController
                                                      .productAvailabilityStatus
                                                      .value ==
                                                  "true") ...[
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.yellow[700],
                                                  ),
                                                  child: Text(
                                                    '$lowstockItem Low',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 7,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.red.shade800,
                                                  ),
                                                  child: Text(
                                                    '$outOfStockItem Nil',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 7,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const Spacer(),
                                              Text(
                                                smallestSellPrice ==
                                                        largestSellPrice
                                                    ? '${formatAmount(smallestSellPrice.toString())} '
                                                    : '${formatAmount(smallestSellPrice.toString())} - ${formatAmountOnly(largestSellPrice.toString())} ',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              product.inclTax != '' &&
                                                      product.inclTax != null
                                                  ? Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.blue),
                                                      child: Text(
                                                        '(incl.tax)',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 6,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                              top: 5,
                                              bottom: 8),
                                          child: Row(
                                            children: [
                                              subscriptionController
                                                          .productAvailabilityStatus
                                                          .value ==
                                                      "true"
                                                  ? Container(
                                                      height: 12,
                                                      width: 12,
                                                      color: subscriptionController
                                                                  .productBuyingPatternIndicator
                                                                  .value ==
                                                              "true"
                                                          ? Colors.red
                                                          : Colors.grey,
                                                    )
                                                  : SizedBox(),
                                              const SizedBox(width: 5),
                                              subscriptionController
                                                          .productAvailabilityStatus
                                                          .value ==
                                                      "true"
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: Colors
                                                            .green.shade700,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 3),
                                                        child: Text(
                                                          'Stock : ${product.stock}',
                                                          style: const TextStyle(
                                                              fontSize: 7,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/cart_box.png",
                                                      height: 10,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                      child: Text(
                                                        smallestSellPrice ==
                                                                largestSellPrice
                                                            ? '${formatAmount(sellingPackPriceLow)}($piecesLow pcs)'
                                                            : '${formatAmount(sellingPackPriceLow)}($piecesLow pcs) - ${formatAmount(sellingPackPriceHigh)}($piecesHigh pcs)',
                                                        style: TextStyle(
                                                          fontSize:
                                                              stockFontSize,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  product.detail!.isEmpty ||
                                          product.detail!.every(
                                              (detail) => (detail.stock) == 0)
                                      ? Positioned(
                                          top: 20,
                                          right: -26,
                                          child: Transform.rotate(
                                            angle: 0.785398,
                                            child: ClipPath(
                                              clipper: RibbonClipper(),
                                              child: Container(
                                                width: 120,
                                                color: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: const Center(
                                                  child: Text(
                                                    "Not Available",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showProductVariantDialog(
      List<Detail> productDetail,
      int index,
      ProductModel product,
      List<ProductModel> productList,
      VoidCallback onDone) {
    List<Detail> detailsCopy = List.from(productDetail);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProductVariantDialogue(
          index: index,
          product: product,
          productList: productList,
          onDone: onDone,
          detailsCopy: detailsCopy,
          productController: widget.productsController,
        );
      },
    );
  }
}

class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.22, 0);
    path.lineTo(size.width * 0.78, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
