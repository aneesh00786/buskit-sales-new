// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/variant_dialog_promo.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_responce/product_frequency_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ProductGridPromoByBrand extends StatefulWidget {
  final String optionName;
  final ProductsController productsController;
  final String id;
  final VoidCallback playAddToCartAnimation;
  final List<ProductModel> products; // ✅ directly passed
  final ValueChanged<List<Map<String, dynamic>>>? onVariantsSelected;
  final PromotionReponse? promo;

  const ProductGridPromoByBrand({
    super.key,
    required this.optionName,
    required this.productsController,
    required this.id,
    required this.playAddToCartAnimation,
    required this.products,
    this.onVariantsSelected,
    this.promo,
  });

  @override
  _ProductGridPromoByBrandState createState() =>
      _ProductGridPromoByBrandState();
}

class _ProductGridPromoByBrandState extends State<ProductGridPromoByBrand> {
  bool isLoading = true;
  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    // Since products are directly provided, just set loading = false
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    const double desiredItemWidth = 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double fontSize =
                (constraints.maxWidth * 0.06).clamp(11.0, 16.0);
            return Text(
              widget.optionName,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Obx(() {
          final selectedCustomerId =
              widget.productsController.selectedCustomerId.value;

          List<ProductFrequencyData> productFrequencyCustomer = widget
              .productsController.productFrequencyList
              .where((e) => e.customerId == selectedCustomerId)
              .toList();

          return Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.products.isEmpty
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
                        itemCount: widget.products.length,
                        itemBuilder: (context, index) {
                          final product = widget.products[index];

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final double imageHeight =
                                  constraints.maxHeight * 0.45;
                              final double nameFontSize =
                                  (constraints.maxWidth * 0.06)
                                      .clamp(11.0, 16.0);
                              final double stockFontSize =
                                  (constraints.maxWidth * 0.04).clamp(8, 12.0);

                              int piecesLow = 0;
                              int piecesHigh = 0;
                              double sellingPackPriceLow = 0;
                              double sellingPackPriceHigh = 0;

                              List<double> sellPriceValues = product.detail!
                                  .where((e) => e.stock != null)
                                  .map((e) =>
                                      double.tryParse(e.sellingPrice.toString()) ??
                                      0.0)
                                  .toList();

                              product.detail?.forEach((e) {
                                double price = double.tryParse(
                                        e.sellingPrice.toString()) ??
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
                              double largestSellPrice =
                                  sellPriceValues.isNotEmpty
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
                                } else if (stock <= lowstock) { // <-- Changed to <=
                                  lowstockItem++;
                                }
                              });

                              // product.detail?.forEach((detail) {
                              //   num stock = detail.stock ?? 0;
                              //   num lowstock = detail.lowstock ?? 0;
                              //   if (stock == 0) {
                              //     outOfStockItem++;
                              //   } else if (stock < lowstock) {
                              //     lowstockItem++;
                              //   }
                              // });

                              final colorCodeString = productFrequencyCustomer
                                      .firstWhere(
                                        (e) => e.productId == product.productId,
                                        orElse: () => ProductFrequencyData(
                                            colorCode: "#FF0000"),
                                      )
                                      .colorCode ??
                                  "#FF0000";

                              final productColor = Color(
                                int.parse(colorCodeString.replaceFirst(
                                    '#', '0xFF')),
                              );

                              return GestureDetector(
                                onTap: () {
                                  _showProductVariantDialog(
                                    product.detail ?? [],
                                    index,
                                    product,
                                    widget.products,
                                    widget.playAddToCartAnimation,
                                  );
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
                                                    placeholder:
                                                        (context, url) =>
                                                            const Padding(
                                                      padding:
                                                          EdgeInsets.all(15.0),
                                                      child: CircleAvatar(
                                                        radius: 10,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
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
                                                      if (lowstockItem > 0)
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
                                                      ' Low',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 7,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (lowstockItem > 0 && outOfStockItem > 0)
                                                  const SizedBox(width: 6),
                                                  if (outOfStockItem > 0)
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
                                                          Colors.red.shade800,
                                                    ),
                                                    child: Text(
                                                      'Nil',
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                  maxLines: 1,
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(width: 3),
                                                product.inclTax != '' &&
                                                        product.inclTax != null
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 3,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: Colors
                                                                    .blue),
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
                                                    : SizedBox.shrink()
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
                                                            ? productColor
                                                            : Colors.grey,
                                                      )
                                                    : SizedBox(),
                                                const SizedBox(width: 5),
                                                subscriptionController
                                                            .productAvailabilityStatus
                                                            .value ==
                                                        "true"
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
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
                                                                color: Colors
                                                                    .white,
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
                                            product.detail!.every((detail) =>
                                                (detail.stock) == 0)
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
          );
        })
      ],
    );
  }

  void _showProductVariantDialog(
    List<Detail> productDetail,
    int index,
    ProductModel product,
    List<ProductModel> productList,
    VoidCallback onDone,
  ) {
    List<Detail> detailsCopy = List.from(productDetail);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProductVariantDialoguePromo(
          index: index,
          product: product,
          productList: productList,
          onDone: onDone,
          detailsCopy: detailsCopy,
          productController: widget.productsController,
          onVariantsSelected: widget.onVariantsSelected,
          promo: widget.promo,
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
