import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/widgets/variant_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  List<ProductModel> products=[];
  String? name;
  bool isLoading = true;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    log('Option name : ${widget.optionName}');
  }
  @override
  void didUpdateWidget(covariant ProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _fetchProductsByCategory(widget.id);
    }
  }

  Future<void> _fetchInitialProducts() async {
    try {
      SubCategoryItem? subCategoryItem =
          widget.productsController.getInitialSubCategoryIdAndName();
      name = subCategoryItem?.subCategory ?? '';
      List<ProductModel> fetchedProducts = await widget.productsController
          .fetchProducts(subCategoryItem?.id ?? '');
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching initial products: $e');
      isLoading = false;
    }
  }

  Future<void> _fetchProductsByCategory(String categoryId) async {
    setState(() {
      isLoading = true;
    });
    try {
      products = await widget.productsController.fetchProducts(categoryId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching products for category: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
              style: GoogleFonts.poppins(
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
                  ? Center(
                      child: Text(
                      'No Data Available :${products.length}',
                      style: TextStyle(fontSize: 40),
                    ))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                            final double stockFontSize =
                                (constraints.maxWidth * 0.04).clamp(8, 12.0);
                            int pieces = 0;
                            List sellPrice = product.detail!
                                .map((e) => e.sellPrice)
                                .toList();
                            List<double> totalPrices = product.detail!.map((e) {
                              double sellPrice;
                              if (e.sellPrice is String) {
                                sellPrice =
                                    double.tryParse(e.sellPrice ?? '') ?? 0.0;
                              } else if (e.sellPrice is double) {
                                sellPrice = double.parse(e.sellPrice ?? '');
                              } else {
                                sellPrice = 0.0;
                              }
                              pieces = e.pieces != null ? e.pieces as int : 0;
                              return sellPrice * pieces;
                            }).toList();
                            double? firstTotal = totalPrices.isNotEmpty
                                ? totalPrices.first
                                : null;
                            double? lastTotal = totalPrices.isNotEmpty
                                ? totalPrices.last
                                : null;
                            List<double> sellPriceValues = sellPrice
                                .map((price) => double.tryParse(price) ?? 0.0)
                                .toList();
                            double smallestSellPrice =
                                sellPriceValues.isNotEmpty
                                    ? sellPriceValues
                                        .reduce((a, b) => a < b ? a : b)
                                    : 0.0;
                            double largestSellPrice = sellPriceValues.isNotEmpty
                                ? sellPriceValues
                                    .reduce((a, b) => a > b ? a : b)
                                : 0.0;
                            String firstSellPrice =
                                smallestSellPrice.toStringAsFixed(2);
                            String lastSellPrice =
                                largestSellPrice.toStringAsFixed(2);
                            num lowstockItem = 0;
                            num stock = 0;
                            num lowstock = 0;
                            product.detail?.forEach((detail) {
                              stock = detail.stock ?? 0;
                              lowstock = detail.lowstock ?? 0;
                              if (stock < lowstock) {
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
                                                ? Image.network(
                                                    '${ApiConstants.imageBaseUrl}/${product.imageUrl}')
                                                : Image.asset(
                                                    'assets/images/otp.png'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              product.productName ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
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
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color:
                                                          Colors.yellow[700]),
                                                  child: Text(
                                                    lowstockItem > 0
                                                        ? '$lowstockItem Low'
                                                        : '0 Low',
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
                                                      color:
                                                          Colors.red.shade800),
                                                  child: Text(
                                                    stock > 0 ||
                                                            stock < lowstock
                                                        ? '0 Nll'
                                                        : '1 Nll',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 7,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  product.detail!.length > 1
                                                      ? '${formatAmount(firstSellPrice)} - $lastSellPrice'
                                                      : formatAmount(
                                                          firstSellPrice),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                product.inclTax != '' &&
                                                      product.inclTax != null
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 3,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors.blue),
                                                        child: Text(
                                                          '(incl.tax)',
                                                          style: GoogleFonts
                                                              .poppins(
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: 12,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: Colors.green,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 3),
                                                      child: Text(
                                                        'Stock : ${product.stock}',
                                                        style: TextStyle(
                                                          fontSize: 7,
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.w600
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                                                        const SizedBox(
                                                            width: 5),
                                                        Flexible(
                                                          child: Text(
                                                            product.detail!
                                                                        .length >
                                                                    1
                                                                ? '${formatAmount(firstTotal)}(${pieces} pcs) - ${lastTotal}(${pieces} pcs)'
                                                                : '${formatAmount(firstTotal)}(${pieces} pcs)',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize:
                                                                  stockFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            overflow:
                                                                TextOverflow
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
                                              )),
                                        ],
                                      ),
                                    ),
                                    product.detail!.length == 0 &&
                                            lowstockItem == 0
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Center(
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
                                ));
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _getFormattedText(String text) {
    const int maxLength = 30;
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
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
