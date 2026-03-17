import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/show_product_list_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/dash_frequently_table.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



Widget topSellingProductWidget(
    {required BuildContext context,
    required SubscriptionController subscriptionController}){
    List<TopSellingProductA> topSellingProducts = [];
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        width: double.infinity,
        isCommonBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dashboardContainerHeader("Frequently Ordered Products"),
                Padding(
                  padding: EdgeInsets.only(
                      right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
                  child: InkWell(
                    onTap: () {
                      if (subscriptionController
                              .frequentlyBroughtProduct1.value ==
                          'true') {
                        if (topSellingProducts.isNotEmpty) {
                          return showProductListDialog<TopSellingProductA>(
                            context: context,
                            productList: topSellingProducts,
                            getQuantity: (product) =>
                                product.quantity?.toDouble() ?? 0.0,
                            getProductName: (product) =>
                                product.productName ?? '',
                            getVariationName: (product) =>
                                product.variationName ?? '',
                            getFormattedDate: (product) =>
                                DateFormat('dd-MM-yyyy')
                                    .format(product.createdAt!.toLocal()),
                            getPrice: (product) => formatAmount(
                              product.inclTax == "incl_tax"
                                  ? (double.tryParse(product
                                          .topSellingProductATotalPrice
                                          .toString()) ??
                                      0.0)
                                  : ((double.tryParse(product
                                              .topSellingProductATotalPrice
                                              .toString()) ??
                                          0.0) +
                                      (product.getTimesData?.fold<double>(
                                            0.0,
                                            (sum, item) =>
                                                sum + (item.tax ?? 0.0),
                                          ) ??
                                          0.0)),
                            ),
                            getBuyQuantity: (product) =>
                                // int.tryParse(product.buyquantity ?? '0') ?? 0,
                                product.getTimesData?.fold(
                                    0, (sum, item) => sum! + item.quantity!) ??
                                0,
                            getInNo: (product) => product.inNo ?? '',
                            onQuantityTap: (context, product) =>
                                showDashTimesDialogue(
                              context,
                              product,
                              (p) => p.getTimesData ?? [],
                              (data) => data.businessName,
                              (data) => formatAmount(data.price),
                              (data) => formatAmount(data.tax),
                              (data) => data.quantity.toString(),
                              (data) => formatAmount(
                                product.inclTax == "incl_tax"
                                    ? ((double.tryParse(
                                            data.totalPrice.toString()) ??
                                        0))
                                    : (((double.tryParse(data.totalPrice
                                                    .toString()) ??
                                                0) *
                                            (double.tryParse(
                                                    data.quantity.toString()) ??
                                                0)) +
                                        (double.tryParse(data.tax.toString()) ??
                                            0.0)),
                              ),
                              (data) => DateFormat('dd-MM-yyyy')
                                  .format(data.createdAt!),
                              (data) => data.orderId.toString(),
                              true,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No data available"),
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const UpgradePlanScreen(),
                        );
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor.withOpacity(0.3)),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.open_in_new,
                            size: 17,
                            color: primaryColor,
                          ),
                        )),
                  ),
                ),
              ],
            ),
            if (subscriptionController.frequentlyBroughtProduct1.value !=
                'true') ...[
              const Expanded(
                child: Center(
                  child: UpgradePlanButton(),
                ),
              )
            ],
            if (subscriptionController.frequentlyBroughtProduct1.value ==
                'true') ...[
              nkSmallSizeBox(),
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<ResponseModell>(
                    future: provider.futureResponseModel,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Expanded(
                          child: Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                Text("No Data Available")
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        topSellingProducts =
                            snapshot.data?.topSellingProducts ?? [];
                        return Expanded(
                            child: topSellingProductList(topSellingProducts));
                      } else {
                        return SizedBox();
                      }
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }


// Widget topSellingProductWidget(
//     {required BuildContext context,
//     required SubscriptionController subscriptionController}) {
//   List<TopSellingProductA> topSellingProducts = [];
//   return Padding(
//     padding: const EdgeInsets.all(2.0),
//     child: MyCommnonContainer(
//       boxShadow: [
//         BoxShadow(
//           color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
//           blurRadius: 5,
//           offset: const Offset(4, 4),
//         ),
//       ],
//       borderRadius: 25,
//       height: 300,
//       width: double.infinity,
//       isCommonBorder: true,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               dashboardContainerHeader("Frequently Bought Products"),
//               Padding(
//                 padding: EdgeInsets.only(
//                     right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
//                 child: InkWell(
//                   onTap: () {
//                     if (topSellingProducts.isNotEmpty) {
//                       return showProductListDialog<TopSellingProductA>(
//                         context: context,
//                         productList: topSellingProducts,
//                         getQuantity: (product) =>
//                             product.quantity?.toDouble() ?? 0.0,
//                         getProductName: (product) => product.productName ?? '',
//                         getVariationName: (product) =>
//                             product.variationName ?? '',
//                         getFormattedDate: (product) => DateFormat('dd-MM-yyyy')
//                             .format(product.createdAt!.toLocal()),
//                         getPrice: (product) => formatAmount(
//                           product.inclTax == "incl_tax"
//                               ? (double.tryParse(
//                                       product.totalAmount.toString()) ??
//                                   0.0)
//                               : ((double.tryParse(
//                                       product.totalAmount.toString()) ??
//                                   0.0)),
//                         ),
//                         getBuyQuantity: (product) =>
//                             int.tryParse(product.buyquantity ?? '0') ?? 0,
//                         getInNo: (product) => product.inNo ?? '',
//                         onQuantityTap: (context, product) =>
//                             showDashTimesDialogue(
//                           context,
//                           product,
//                           (p) => p.getTimesData ?? [],
//                           (data) => data.businessName,
//                           (data) => formatAmount(data.price),
//                           (data) => formatAmount(data.tax),
//                           (data) => data.quantity.toString(),
//                           (data) => formatAmount(
//                               ((double.tryParse(data.totalAmount.toString()) ??
//                                   0))),
//                           (data) =>
//                               DateFormat('dd-MM-yyyy').format(data.createdAt!),
//                           (data) => data.orderId.toString(),
//                           true,
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("No data available"),
//                         ),
//                       );
//                     }
//                   },
//                   child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: primaryColor.withOpacity(0.3)),
//                       child: const Padding(
//                         padding: EdgeInsets.all(5.0),
//                         child: Icon(
//                           Icons.open_in_new,
//                           size: 17,
//                           color: primaryColor,
//                         ),
//                       )),
//                 ),
//               ),
//             ],
//           ),
//           nkSmallSizeBox(),
//           if (subscriptionController.frequentlyBroughtProduct1.value !=
//               'true') ...[
//             Expanded(
//               child: Center(
//                 child: UpgradePlanButton(),
//               ),
//             )
//           ],
//           if (subscriptionController.frequentlyBroughtProduct1.value == 'true')
//             Consumer<DashboardProvider>(
//               builder: (context, provider, child) {
//                 return FutureBuilder<ResponseModell>(
//                   future: provider.futureResponseModel,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Expanded(
//                         child: Center(
//                           child: SpinKitFadingCube(
//                             color: primaryColor,
//                             size: 20.0,
//                           ),
//                         ),
//                       );
//                     } else if (snapshot.hasError) {
//                       return const Expanded(
//                         child: Center(
//                           child: NodataWidget(),
//                         ),
//                       );
//                     } else if (snapshot.hasData) {
//                       topSellingProducts =
//                           snapshot.data!.topSellingProducts ?? [];
//                       return Expanded(
//                         child: topSellingProductList(topSellingProducts),
//                       );
//                     } else {
//                       return Expanded(
//                         child: FutureBuilder(
//                           future: Future.delayed(const Duration(seconds: 3)),
//                           builder: (context, delaySnapshot) {
//                             if (delaySnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                 child: SpinKitFadingCube(
//                                   color: primaryColor,
//                                   size: 20.0,
//                                 ),
//                               );
//                             } else {
//                               return const Center(
//                                 child: NodataWidget(),
//                               );
//                             }
//                           },
//                         ),
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//         ],
//       ),
//     ),
//   );
// }
