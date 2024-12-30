import 'dart:developer';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/customer_order_status_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class OptionWidgetCustomerDash extends StatelessWidget {
  final String customerId;
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final String? customType;
  final bool? isVisible;
  final OrderStatus? customOrderStatusType;
  final String? startDate;
  final String? endDate;

  const OptionWidgetCustomerDash({
    super.key,
    required this.customerId,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.countFuture == null) {
            provider.fetchCustomerDashboardCountData(customerId,);
          }
        });

        return FutureBuilder<ApiResponsees>(
          future: provider.countFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCube(
                  color: primaryColor,
                  size: 20.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              final chatData = snapshot.data!.data;
              return options(chatData, context, provider);
            } else {
              return const NodataWidget();
            }
          },
        );
      },
    );
  }

  Widget options(OrderDataas orderCountList, BuildContext context,
      CustomersProvider provider) {
    return Row(
      children: _defaultOption(context, provider, orderCountList)
          .map((e) => orderOptions(e, orderCountList, context))
          .toList(),
    );
  }

  List<OptionData> _defaultOption(BuildContext context,
          CustomersProvider provider, OrderDataas orderCountList) =>
      [
        OptionData(
          title: 'Orders',
          count: orderCountList.totalOrder.toString(),
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color.fromARGB(255, 229, 242, 254),
          color: Color.fromARGB(255, 55, 74, 134),
          onTap: () {
            _showOrderStatusDialog(context, provider, OrderStatus.delivered);
            provider.fetchOrdersForCustomDash(
                OrderStatus.delivered, customerId,);
          },
        ),
        OptionData(
          title: 'Estimates',
          count: orderCountList.estimateOrder.toString(),
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color.fromARGB(255, 226, 249, 243),
          color: Color.fromARGB(255, 36, 108, 44),
          onTap: () {
            _showOrderStatusDialog(context, provider, OrderStatus.estimates);
            provider.fetchOrdersForCustomDash(
                OrderStatus.estimates, customerId,);
          },
        ),
        OptionData(
          title: 'Pre-Orders',
          count: orderCountList.preorderOrder.toString(),
          svg: Assets.iconsIcDashboardPreOrder,
          svgBgColor: const Color.fromARGB(255, 230, 247, 251),
          color: Color.fromARGB(255, 45, 104, 116),
          onTap: () {
            _showOrderStatusDialog(context, provider, OrderStatus.preOrder);

            provider.fetchOrdersForCustomDash(
                OrderStatus.preOrder, customerId,);
          },
        ),
        OptionData(
          title: 'Draft',
          count: orderCountList.draftOrder.toString(),
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color.fromARGB(255, 255, 227, 255),
          color: Color.fromARGB(255, 100, 43, 109),
          onTap: () {
            _showOrderStatusDialog(context, provider, OrderStatus.draft);

            provider.fetchOrdersForCustomDash(OrderStatus.draft, customerId,);
          },
        ),
        OptionData(
          title: 'Cancelled',
          count: orderCountList.cancelOrder.toString(),
          svg: Assets.iconsIcDashboardCancel,
          svgBgColor: const Color.fromARGB(255, 255, 228, 228),
          color: Color.fromARGB(255, 139, 27, 27),
          onTap: () {
            _showOrderStatusDialog(context, provider, OrderStatus.cancelled);

            provider.fetchOrdersForCustomDash(
                OrderStatus.cancelled, customerId, );
          },
        ),
      ];

  Widget orderOptions(
      OptionData optionData, OrderDataas orderCountList, BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance!.height * 0.03,
      fit: BoxFit.contain,
    );

    return Flexible(
      child: MyCommnonContainer(
        color: white,
        onTap: optionData.onTap,
        margin: nkSymmetricPadding(
          vertical: 0,
          horizontal: AppDimensions.instance!.width * 0.001,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: 20,
        padding: nkLargePadding(),
        isCommonBorder: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      //maxLines: optionData.title.length,
                    ),
                    CustomText(
                      content:
                          _getCountForTitle(optionData.title, orderCountList),
                      fontSize: ResponsiveInfo.isMobileDimension(context)
                          ? 7.7
                          : 15.3,
                      fontWeight: FontWeight.w600,
                      color: optionData.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountForTitle(String title, OrderDataas orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList.totalOrder.toString() ?? "0";
      case 'estimates':
        return orderCountList.estimateOrder.toString() ?? "0";
      case 'pre-orders':
        return orderCountList.preorderOrder.toString() ?? "0";
      case 'draft':
        return orderCountList.draftOrder.toString() ?? "0";
      case 'cancelled':
        return orderCountList.cancelOrder.toString() ?? "0";
      default:
        return "0";
    }
  }

  String getOrderStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.preOrder:
        return 'Pre Order';
      case OrderStatus.outOfDelivery:
        return 'Out For Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.estimates:
        return 'Estimates';

      default:
        throw Exception('Unsupported order status: $status');
    }
  }

  String getOrderStatusName(int orderStatus) {
    switch (orderStatus) {
      case 0:
        return 'Pre Order';
      case 1:
        return 'Out For Delivery';
      case 2:
        return 'Delivered';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Draft';
      case 5:
        return 'Processing';
      case 6:
        return 'Pending';
      case 7:
        return 'Estimates';
      case 8:
        return 'Accept By Admin';
      case 9:
        return 'Reject By Admin';
      case 10:
        return 'Packed For Delivery';
      default:
        return '';
    }
  }

  void _showOrderStatusDialog(BuildContext context, CustomersProvider provider,
      OrderStatus _selectedOrderStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return _buildTableLayout(context);
                        } else {
                          final orders = snapshot.data?.data ?? [];
                          final dynamic filteredOrders;
                          filteredOrders = orders.toList();
                          return buildOrdersTable(
                            filteredOrders: filteredOrders,
                            context: context,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}


Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceIds = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceIds,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ));
}

Widget _buildTableLayout(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.2,
    child: Column(
      children: [
        _buildTableHeader(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Center(
          child: NodataWidget(),
        )
      ],
    ),
  );
}

Widget _buildTableHeader() {
  return Container(
    color: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 10),
        Expanded(flex: 2, child: _buildHeaderText('Customer List', 13)),
        Expanded(child: _buildHeaderText('Order Number', 13)),
        Expanded(child: _buildHeaderText('Order Created', 13)),
        Expanded(child: _buildHeaderText('Order Price', 13)),
        Expanded(child: _buildHeaderText('Invoice', 13)),
        Expanded(child: _buildHeaderText('Payment Status', 13)),
        Expanded(child: _buildHeaderText('Status', 13)),
        SizedBox(width: 10),
      ],
    ),
  );
}

Widget _buildHeaderText(String text, double fontSize) {
  return Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins_Regular',
      ),
    ),
  );
}

class OptionData {
  String title;
  String count;
  String svg;
  Color svgBgColor;
  Color? color;
  VoidCallback? onTap;

  OptionData({
    required this.title,
    required this.count,
    required this.svg,
    required this.svgBgColor,
    this.onTap,
    this.color,
  });
}
class YourWidget extends StatelessWidget {
  final OrderStatus selectedOrderStatus;
  final void Function(OrderStatus?)? onChanged; // Adjusted callback type

  const YourWidget({
    Key? key,
    required this.selectedOrderStatus,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<OrderStatus>(
      value: selectedOrderStatus,
      onChanged: onChanged,
      items: OrderStatus.values.map((status) {
        return DropdownMenuItem<OrderStatus>(
          value: status,
          child: Text(status.name),
        );
      }).toList(),
    );
  }
}
