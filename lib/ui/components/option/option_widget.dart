// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/estimated_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/show_orderstatus_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../generated/assets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class OptionWidget extends StatefulWidget {
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final int? orderCount;
  final int? eastimatesCount;
  final int? preOrderCount;
  final int? draftCount;
  final int? cancelledCount;
  final String? customType;
  final bool? isVisible;
  final OrderStatus? customOrderStatusType;
  final String? startDate;
  final String? endDate;
  HomeController? homeController;
  OptionWidget({
    super.key,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.orderCount,
    this.eastimatesCount,
    this.preOrderCount,
    this.draftCount,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.isVisible = false,
    this.cancelledCount,
    this.homeController,
  });

  @override
  State<OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());

  ProductsController productsController = Get.put(ProductsController());
  final subscriptionController = Get.find<SubscriptionController>();

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController1.addListener(() {
      final position = _scrollController1.position.pixels;
      if (_scrollController2.hasClients &&
          _scrollController2.position.pixels != position) {
        _scrollController2.jumpTo(position);
      }
      if (_scrollController3.hasClients &&
          _scrollController3.position.pixels != position) {
        _scrollController3.jumpTo(position);
      }
    });
    _scrollController2.addListener(() {
      final position = _scrollController2.position.pixels;
      if (_scrollController1.hasClients &&
          _scrollController1.position.pixels != position) {
        _scrollController1.jumpTo(position);
      }
      if (_scrollController3.hasClients &&
          _scrollController3.position.pixels != position) {
        _scrollController3.jumpTo(position);
      }
    });
    _scrollController3.addListener(() {
      final position = _scrollController3.position.pixels;
      if (_scrollController1.hasClients &&
          _scrollController1.position.pixels != position) {
        _scrollController1.jumpTo(position);
      }
      if (_scrollController2.hasClients &&
          _scrollController2.position.pixels != position) {
        _scrollController2.jumpTo(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<ResponseModell>(
          future: provider.futureResponseModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCube(
                  color: primaryColor,
                  size: 20.0,
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const NodataWidget();
            } else if (snapshot.hasData) {
              final chatData = snapshot.data!.orderCountList;
              return options(chatData, context, provider);
            } else {
              return const NodataWidget();
            }
          },
        );
      },
    );
  }

  Widget options(OrderCountListt? orderCountList, BuildContext context,
      DashboardProvider provider) {
    return Row(
      children: _defaultOption(context, provider, orderCountList)
          .map((e) => orderOptions(e, orderCountList, context))
          .toList(),
    );
  }

  List<OptionData> _defaultOption(BuildContext context,
          DashboardProvider provider, OrderCountListt? orderCountList) =>
      [
        OptionData(
          title: 'Orders',
          count: widget.orderCount.toString(),
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color.fromARGB(255, 229, 242, 254),
          color: const Color.fromARGB(255, 55, 74, 134),
          onTap: () {
            if (orderCountList?.totalOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.delivered);
              showOrderStatusDialog(context, provider, OrderStatus.delivered,
                  _scrollController1, _scrollController2, _scrollController3);
            }
          },
        ),
        OptionData(
            title: 'Estimates',
            count: widget.eastimatesCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardEstimates,
            svgBgColor: const Color.fromARGB(255, 226, 249, 243),
            color: const Color.fromARGB(255, 36, 108, 44),
            onTap: () {
              if (orderCountList?.estimateOrder.toString() == "0") {
                showCustomToastDisplay(
                    context, "No Record Found", red, Icons.close);
              } else {
                provider.fetchOrdersData(OrderStatus.estimates);
                showEstimatesDialog(
                    context,
                    provider,
                    OrderStatus.estimates,
                    'Estimate',
                    false,
                    productsController,
                    customerOrderController,
                    widget.homeController);
              }
            }),
        OptionData(
            title: 'Bookings',
            count: widget.preOrderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color.fromARGB(255, 230, 247, 251),
            color: const Color.fromARGB(255, 45, 104, 116),
            onTap: () {
              if (subscriptionController.bookingView.value == 'true') {
                if (orderCountList?.preorderOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {provider.fetchOrdersData(OrderStatus.preOrder);
                showEstimatesDialog(
                    context,
                    provider,
                    OrderStatus.preOrder,
                    'Booking',
                    false,
                    productsController,
                    customerOrderController,
                    widget.homeController);}
              } else {
                showUpgradePlanDialog(context);
              }
            }),
        OptionData(
            title: 'Drafts',
            count: widget.draftCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardDraft,
            svgBgColor: const Color.fromARGB(255, 255, 227, 255),
            color: const Color.fromARGB(255, 100, 43, 109),
            onTap: () {
              if (orderCountList?.draftOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {provider.fetchOrdersData(OrderStatus.draft);
              showEstimatesDialog(
                  context,
                  provider,
                  OrderStatus.draft,
                  'Draft',
                  true,
                  productsController,
                  customerOrderController,
                  widget.homeController);
              CartDatabaseManager().getDraftItems();}
            }),
        OptionData(
            title: 'Cancelled',
            count: widget.cancelledCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardCancel,
            svgBgColor: const Color.fromARGB(255, 255, 228, 228),
            color: const Color.fromARGB(255, 139, 27, 27),
            onTap: () {
              if (orderCountList?.cancelOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {provider.fetchOrdersData(OrderStatus.cancelled);
              showEstimatesDialog(
                  context,
                  provider,
                  OrderStatus.cancelled,
                  'Cancelled',
                  false,
                  productsController,
                  customerOrderController,
                  widget.homeController);}
            }),
      ];

  Widget orderOptions(OptionData optionData, OrderCountListt? orderCountList,
      BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance.height * 0.03,
      fit: BoxFit.contain,
    );

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 3, left: 3),
        child: MyCommnonContainer(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
          borderRadius: 20,
          onTap: optionData.onTap,
          margin: nkSymmetricPadding(
            vertical: 0,
            horizontal: AppDimensions.instance.width * 0.001,
          ),
          padding: nkLargePadding(),
          isCommonBorder: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: optionData.svgBgColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: svgComponent,
                  ),
                ),
                Flexible(
                  child: Wrap(
                    direction: Axis.vertical,
                    children: [
                      CustomText(
                        content: optionData.title,
                        fontSize: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? (ResponsiveInfo.isMobileDimension(context)
                                ? 4.9
                                : 13)
                            : (ResponsiveInfo.isMobileDimension(context)
                                ? 7
                                : 13),
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                      CustomText(
                        content:
                            _getCountForTitle(optionData.title, orderCountList),
                        fontSize: ResponsiveInfo.isMobileDimension(context)
                            ? 7.7
                            : 15.3,
                        fontWeight: FontWeight.w800,
                        color: optionData.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCountForTitle(String title, OrderCountListt? orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList?.totalOrder.toString() ?? "0";
      case 'estimates':
        return orderCountList?.estimateOrder.toString() ?? "0";
      case 'bookings':
        return orderCountList?.preorderOrder.toString() ?? "0";
      case 'drafts':
        return orderCountList?.draftOrder.toString() ?? "0";
      case 'cancelled':
        return orderCountList?.cancelOrder.toString() ?? "0";
      default:
        return "0";
    }
  }
}

Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceId = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceId,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ));
}
