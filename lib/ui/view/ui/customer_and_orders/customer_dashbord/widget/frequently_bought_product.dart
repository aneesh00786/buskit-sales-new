// ignore_for_file: non_constant_identifier_names

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/show_product_list_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/topselling_product_customer.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
Widget Frequently(
      BuildContext context, List<FrequantliyProductList> frequentProductLists,SubscriptionController subscriptionController) {
    frequentProductLists
        .sort((a, b) => b.count.length.compareTo(a.count.length));
    return MyCommnonContainer(
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(4, 4),
        ),
      ],
      borderRadius: 25,
      height: 320,
      isCommonBorder: true,
      margin: EdgeInsets.zero,
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
                    // print('frequently on tapped');
                    if (frequentProductLists.isNotEmpty) {
                      return showProductListDialog<FrequantliyProductList>(
                        context: context,
                        productList: frequentProductLists,
                        getQuantity: (product) =>
                            product.count.length.toDouble(),
                        getProductName: (product) => product.productName,
                        getVariationName: (product) => product.variationName,
                        getFormattedDate: (product) =>
                            DateFormat('dd-MM-yyyy').format(product.createdAt),
                        getPrice: (product) => formatAmount(product.totalPrice),
                        getBuyQuantity: (product) => product.quantity,
                        getInNo: (product) => product.inNo,
                        onQuantityTap: (context, product) =>
                            showDashTimesDialogue(
                          context,
                          product,
                          (p) => p.count,
                          (data) => data.businessName,
                          (data) => formatAmount(data.price),
                          (data) => formatAmount(data.tax),
                          (data) => data.quantity.toString(),
                          (data) => formatAmount(
                            data.inclTax == "incl_tax"
                                ? ((double.tryParse(
                                            data.totalPrice.toString()) ??
                                        0)
                                    )
                                : (((double.tryParse(
                                            data.totalPrice.toString()) ??
                                        0) +
                                    (double.tryParse(data.tax.toString()) ??
                                        0.0))),
                          ),
                          (data) =>
                              DateFormat('dd-MM-yyyy').format(data.createdAt!),
                          (data) => data.orderId.toString(),
                          false,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No data available"),
                        ),
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
          if (subscriptionController.customerFrequentlyBoughtProducts.value !=
              'true') ...[
            Expanded(
                child: Center(
              child: UpgradePlanButton(),
            ))
          ],
          if (subscriptionController.customerFrequentlyBoughtProducts.value ==
              'true') ...[
            nkSmallSizeBox(),
            Expanded(child: topSellingProductsCustomer(frequentProductLists)),
          ],
        ],
      ),
    );
  }
