import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/show_product_list_dialog.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_dialog_table.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/doughnut_default_delivery.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/show_ordersstatus_value_dialog.dart';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/dashboard_customer_dailog/dashboard_customer_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/dashboard_quantity_dailog/dashboard_quantity_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/dash_frequently_table.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show-category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_collection_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_order_status_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart'
    as model;
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../components/bar_and_chart/revenue_pie_chart.dart';
import '../../provider/dash_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image/image.dart' as img;
class DashBoardMiddleWidget extends StatefulWidget {
  final DashBoardController dashBoardController;
  BuildContext context;
  DashBoardMiddleWidget({
    super.key,
    required this.dashBoardController,
    required this.context,
  });

  @override
  State<DashBoardMiddleWidget> createState() => _DashBoardMiddleWidgetState();
}

class _DashBoardMiddleWidgetState extends State<DashBoardMiddleWidget> {
  String staffProjection = '';
  String targetType = '';
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsList = await ApiWorker().fetchAllSettings(companyId);
      setState(() {
        final staffProjectionSetting = settingsList?.firstWhere(
          (setting) => setting.key == 'staffProjection',
          orElse: () =>
              AllCompanySettingsData(key: 'staffProjection', value: ''),
        );
        staffProjection = staffProjectionSetting?.value ?? '';
        final targetTypeSetting = settingsList?.firstWhere(
          (setting) => setting.key == 'targetType',
          orElse: () => AllCompanySettingsData(key: 'targetType', value: ''),
        );
        targetType = targetTypeSetting?.value ?? '';
      });
    } catch (e) {
      print("Error fetching settings: $e");
    }
  }

  TextEditingController communicationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: isMobile
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: middleTopLeftComponet()),
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: middleTopRightComponet()),
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: CommunicationsDisplayWidget()),
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: topSellingProductWidget()),
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: collectionChart(context)),
                  const SizedBox(height: 4.7),
                  SizedBox(height: 200, child: orderDeliveryChart(context)),
                ],
              ),
            )
          : Column(
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: middleTopLeftComponet()),
                      const SizedBox(
                        width: 4.7,
                      ),
                      Flexible(child: middleTopRightComponet())
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4.7,
                ),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(child: CommunicationsDisplayWidget()),
                      const SizedBox(
                        width: 4.7,
                      ),
                      Flexible(child: topSellingProductWidget())
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4.7,
                ),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(child: collectionChart(context)),
                      const SizedBox(
                        width: 4.7,
                      ),
                      Flexible(child: orderDeliveryChart(context))
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget collectionChart(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardContainerHeader('Collection'),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 2),
                  child: InkWell(
                    onTap: () {
                      showCollectionChartDialog(
                        context,
                        'Collection',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor.withOpacity(0.3)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.open_in_new,
                          size: 17,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            nkSmallSizeBox(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<ResponseModell>(
                      future: provider.futureResponseModel,
                      builder:
                          (context, AsyncSnapshot<ResponseModell> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                SizedBox(height: 10),
                                Text(
                                    "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding.",
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            (snapshot.data != null &&
                                (snapshot.data!.collection?.payment
                                        ?.completedOrders?.isEmpty ??
                                    true) &&
                                (snapshot.data!.collection?.order?.pendingAmount
                                        ?.isEmpty ??
                                    true) &&
                                snapshot.data!.collection?.payment
                                        ?.completedOrders
                                        ?.fold(
                                      0.0,
                                      (sum, order) =>
                                          sum + (order.orderTotal ?? 0),
                                    ) ==
                                    0)) {
                          return const NodataWidget();
                        } else {
                          final responseModel = snapshot.data!;
                          final totalCompletedAmount = responseModel
                              .collection!.payment!.completedOrders!
                              .fold(
                                  0.0,
                                  (sum, order) =>
                                      sum + (order.orderTotal ?? 0.0));

                          final pendingAmountLabel = responseModel
                                  .collection!.order!.pendingAmount!.isNotEmpty
                              ? 'Pending : ${formatAmount(responseModel.collection!.order!.pendingAmount!.last.amount)}'
                              : 'Pending : \$ 0.00';
                          final dueAmountLabel = responseModel
                                  .collection!.order!.pendingAmount!.isNotEmpty
                              ? 'Due : ${formatAmount(responseModel.collection!.order!.pendingAmount!.last.dueAmount)}'
                              : 'Due : \$ 0.00';

                          final overdueAmountLabel = responseModel
                                  .collection!.order!.pendingAmount!.isNotEmpty
                              ? 'Overdue : ${formatAmount(responseModel.collection!.order!.pendingAmount!.last.overDue)}'
                              : 'Overdue : \$ 0.00';

                          final completedOrdersLabel =
                              'Completed : ${formatAmount(totalCompletedAmount)}';

                          {
                            return Column(
                              children: [
                                Expanded(
                                  child: NestedPieChartj(
                                    completedOrdersCount: responseModel
                                        .collection!.payment!.completedOrders!
                                        .fold(
                                            0,
                                            (sum, order) =>
                                                sum +
                                                (order.orderTotal?.toInt() ??
                                                    0)),
                                    pendingAmountCount: (responseModel
                                                    .collection
                                                    ?.order
                                                    ?.pendingAmount !=
                                                null &&
                                            responseModel.collection!.order!
                                                .pendingAmount!.isNotEmpty)
                                        ? (responseModel.collection!.order!
                                                .pendingAmount!.last.amount
                                                ?.toInt() ??
                                            0)
                                        : 0,
                                    dueAmountCount: (responseModel
                                                .collection
                                                ?.order
                                                ?.pendingAmount
                                                ?.isNotEmpty ==
                                            true)
                                        ? responseModel.collection!.order!
                                                .pendingAmount!.last.dueAmount
                                                ?.toInt() ??
                                            0
                                        : 0,
                                    overdueAmountCount: (responseModel
                                                .collection
                                                ?.order
                                                ?.pendingAmount
                                                ?.isNotEmpty ==
                                            true)
                                        ? (responseModel.collection!.order!
                                                .pendingAmount!.last.overDue
                                                ?.toInt() ??
                                            0)
                                        : 0,
                                    collection: responseModel.collection!,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showValueCollectionDialog(
                                            context,
                                            responseModel.collection!,
                                            'Recieved Payment');
                                      },
                                      child: _buildLegendItem(
                                        const Color.fromARGB(255, 90, 119, 37),
                                        completedOrdersLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 8.3),
                                    InkWell(
                                      onTap: () {
                                        pendingPaymentCollectionDialog(
                                            context,
                                            'Pending Payment',
                                            responseModel.collection!);
                                      },
                                      child: _buildLegendItem(
                                        const Color(0xffa30c13),
                                        pendingAmountLabel,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        pendingPaymentCollectionDialog(
                                            context,
                                            'Due Payment',
                                            responseModel.collection!);
                                      },
                                      child: _buildLegendItem(
                                        const Color.fromARGB(
                                            255, 255, 173, 181),
                                        dueAmountLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 8.3),
                                    InkWell(
                                      onTap: () {
                                        pendingPaymentCollectionDialog(
                                            context,
                                            'Over Due Payment',
                                            responseModel.collection!);
                                      },
                                      child: _buildLegendItem(
                                        const Color.fromARGB(
                                            255, 255, 101, 132),
                                        overdueAmountLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
        MyRegularText(
          label: label,
          fontSize: 10.6,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
      ],
    );
  }

  Widget orderDeliveryChart(BuildContext context) {
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
              children: [
                dashboardContainerHeader('Order Status'),
                Padding(
                  padding: const EdgeInsets.only(right: 10,),
                  child: InkWell(
                    onTap: () {
                      showOrderStatusChartDialog(
                        context,
                        'Order Status',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor.withOpacity(0.3)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.open_in_new,
                          size: 17,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<ResponseModell>(
                      future: provider.futureResponseModel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                SizedBox(height: 10),
                                Text(
                                    "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding.",
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          );
                        } else if (snapshot.hasData) {
                          final categories = snapshot.data!.allCategory;
                          final categoryPerformance = snapshot.data!.delivery;

                          if (categoryPerformance == null ||
                              categoryPerformance.order!.totalOrders!.isEmpty) {
                            return const NodataWidget();
                          }

                          return Center(
                            child: DoughnutDefaultDelivery(
                              deliveryData: categoryPerformance,
                              aColor: Colors.blue.shade300,
                              bColor: const Color(0xffc38a42),
                              cColor: const Color(0xff33b4a8),
                              legend2: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  OrderStatusLegend(
                                    categoryPerformance: categoryPerformance,
                                    label:
                                        "Processing : ${formatAmount(categoryPerformance.order!.totalOrders!.last.orderProcessing)}",
                                    color: Colors.blue.shade300,
                                    onTap: () {
                                      showValueOrderDialog(context,
                                          categoryPerformance, "Processing", 5);
                                    },
                                  ),
                                  OrderStatusLegend(
                                    categoryPerformance: categoryPerformance,
                                    label: categoryPerformance.order
                                                ?.totalOrders?.isNotEmpty ==
                                            true
                                        ? "Packed & Ready for Delivery : ${formatAmount(categoryPerformance.order!.totalOrders!.last.outForDelivery)}"
                                        : "Packed & Ready for Delivery : 0",
                                    color: const Color(0xffc38a42),
                                    onTap: () {
                                      if (categoryPerformance
                                              .order?.totalOrders?.isNotEmpty ==
                                          true) {
                                        showValueOrderDialog(
                                          context,
                                          categoryPerformance,
                                          "Packed & Ready for Delivery",
                                          1,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "No data available for this status")),
                                        );
                                      }
                                    },
                                  ),
                                  OrderStatusLegend(
                                    categoryPerformance: categoryPerformance,
                                    label:
                                        "Delivered : ${formatAmount(categoryPerformance.order!.totalOrders!.last.deliverd)}",
                                    color: Color(0xff33b4a8),
                                    onTap: () {
                                      showValueOrderDialog(
                                          context,
                                          categoryPerformance,
                                          "Delivered Orders",
                                          2);
                                    },
                                  ),
                                ],
                              ),
                              legend1: SizedBox.shrink(),
                            ),
                          );
                        } else {
                          return const NodataWidget();
                        }
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget middleTopLeftComponet() {
    String displayText = '';
    if (staffProjection == "1" && targetType == "1") {
      displayText = "Category Target / Projection / Actuals";
    } else if (staffProjection == "1" && targetType == "0") {
      displayText = "Category Projection / Actuals";
    } else if (staffProjection == "0" && targetType == "1") {
      displayText = "Category Target / Actuals";
    } else {
      displayText = "Category Actuals";
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        width: double.infinity,
        isCommonBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 5, bottom: 5),
                  child: Text(
                    displayText,
                    style: cardHeadingTextStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 5, top: 2),
                      child: InkWell(
                        onTap: () {
                          showCategoryChartDialog(
                            context,
                            "Category ${targetType == '1' ? "Target / " : ''}${staffProjection == '1' ? "Projection / " : ''}Actuals",
                            staffProjection,
                            targetType,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor.withOpacity(0.3)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: const Icon(
                                Icons.open_in_new,
                                size: 17,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            nkMediumSizeBox(),
            Expanded(
              child: Padding(
                padding: nkRegularPadding(),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<model1.ResponseModell>(
                      future: provider.futureResponseModel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                Text(
                                    "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding."),
                              ],
                            ),
                          );
                        } else if (snapshot.hasData) {
                          final categories = snapshot.data!.allCategory;
                          final categoryPerformance =
                              snapshot.data!.categoryPerformance;

                          return Center(
                            child: CustomBarChart(
                              categoryPerformance: categoryPerformance!,
                              allCategory: categories!,
                              staffProjection: staffProjection,
                              targetType: targetType,
                            ),
                          );
                        } else {
                          return const NodataWidget();
                        }
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget middleTopRightComponet() {
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
              children: [
                dashboardContainerHeader('Revenue'),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      showRevenueChartDialog(context, 'Revenue');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor.withOpacity(0.3)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.open_in_new,
                          size: 17,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return FutureBuilder<ResponseModell>(
                      future: provider.futureResponseModel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitFadingCube(
                              color: primaryColor,
                              size: 20.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                Text(
                                    "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding."),
                              ],
                            ),
                          );
                        } else if (snapshot.hasData) {
                          final categoryPerformance = snapshot.data!.revenue;
                          if (categoryPerformance!.orderRevenueData!.isEmpty) {
                            return const NodataWidget();
                          }
                          final bookingRevenueLength =
                              categoryPerformance.bookingRevenueData!.isNotEmpty
                                  ? categoryPerformance.bookingRevenueData!
                                      .map((e) => e.total ?? 0.0)
                                      .reduce((a, b) => a + b)
                                  : 0.0;

                          // categoryPerformance.bookingRevenueData!.isNotEmpty
                          //     ? categoryPerformance.bookingRevenueData!.last
                          //         .totalBookingRevenue
                          // : 0.0;
                          final orderRevenueLast =
                              categoryPerformance.orderRevenueData!.isNotEmpty
                                  ? categoryPerformance
                                      .orderRevenueData!.last.totalOrderRevenue
                                  : 0.0;
                          return Center(
                            child: DoughnutDefault(
                              categoryData: categoryPerformance,
                              booking: "Booking : 3",
                              order: "Order : 3",
                              aColor: Colors.blue,
                              bColor: const Color(0xff1d3d63),
                              legend1: const SizedBox.shrink(),
                              legend2: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showValueDialog(context,
                                              categoryPerformance, 'Pre-Order');
                                        },
                                        child: _buildLegendItem(
                                          const Color(0xff1d3d63),
                                          'Pre-Order : ${formatAmount(bookingRevenueLength)}',
                                        ),
                                      ),
                                      nkSmallSizeBox(),
                                      InkWell(
                                        onTap: () {
                                          showValueDialog(context,
                                              categoryPerformance, 'Order');
                                        },
                                        child: _buildLegendItem(
                                          Colors.blue,
                                          'Order : ${formatAmount(orderRevenueLast)}',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const NodataWidget();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sendReply(DashboardProvider provider) {
    double iconSize = 20.0;
    TextEditingController communicationController = TextEditingController();

    return Row(
      children: [
        Icon(
          Icons.add,
          color: primaryColor,
          size: iconSize,
        ),
        nkSmallSizeBox(),
        SizedBox(
          width: 100,
          child: MyFormField(
            controller: communicationController,
            labelText: '',
            enableColor: primaryTextFieldColor,
            focusedColor: primaryTextFieldColor,
            disabledColor: primaryTextFieldColor,
            maxLines: 1,
          ),
        ),
        nkSmallSizeBox(),
        Icon(
          Icons.camera_alt_outlined,
          color: primaryColor,
          size: iconSize,
        ),
        nkSmallSizeBox(),
        Icon(
          Icons.person_outline,
          color: primaryColor,
          size: iconSize,
        ),
        nkSmallSizeBox(),
        GestureDetector(
          onTap: () {
            // final message = communicationController.text.trim();
            // if (provider.selectedChat != null && message.isNotEmpty) {
            //   provider.postAdminMessage(
            //       provider.selectedChat!.salesmanId, message);
            //   communicationController.clear();
            // }
            // print(message);
          },
          child: Icon(
            Icons.send,
            color: primaryColor,
            size: iconSize,
          ),
        ),
      ],
    );
  }

  Widget communicationsDisplayListWidget(Map<String, dynamic> data, int index) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(5.0),
        child: MyCommnonContainer(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: 25,
          padding:
              widget.dashBoardController.selectedCommunicationIndex.value ==
                      index
                  ? nkSmallPadding()
                  : null,
          onTap: () {
            widget.dashBoardController.selectedCommunicationIndex.value = index;

            showDialog(
              context: widget.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                            child: MyNetworkImage(
                          imageUrl: data["image"],
                          height: AppDimensions.instance!.height * 0.05,
                          width: AppDimensions.instance!.height * 0.05,
                        )),
                        Text(
                          "   " + data["name"],
                          style: const TextStyle(fontSize: 12),
                        )
                      ]),
                  content: Container(
                    width: double.maxFinite,
                    color: const Color(0xffebe8e5),
                    child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Align(
                                alignment: (index % 2 == 0)
                                    ? FractionalOffset.topRight
                                    : FractionalOffset.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xffddf7c9),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                          constraints: const BoxConstraints(
                                              minWidth: 50, maxWidth: 150),
                                          child: const Text("Hi..",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87))),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }),
                  ),
                );
              },
            );
          },
          isCommonBorder:
              widget.dashBoardController.selectedCommunicationIndex.value ==
                  index,
          child: Row(
            children: [
              ClipOval(
                  child: MyNetworkImage(
                imageUrl: data["image"],
                height: AppDimensions.instance!.height * 0.05,
                width: AppDimensions.instance!.height * 0.05,
              )),
              nkSmallSizeBox(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyRegularText(label: data["name"]),
                    MyRegularText(
                      label: data["message"],
                      fontSize: NkFontSize.smallFont(),
                      color: primaryColor,
                      align: TextAlign.start,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget topSellingProductWidget() {
    List<TopSellingProductA> topSellingProducts = [];
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        isCommonBorder: true,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 5, bottom: 5),
                  child: Text(
                    "Frequently Bought Products",
                    style: cardHeadingTextStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10,),
                  child: InkWell(
                    onTap: () {
                      if (topSellingProducts.isNotEmpty) {
                        return showProductListDialog<TopSellingProductA>(
                          context: widget.context,
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
                                    ((double.tryParse(product.tax.toString()) ??
                                            0.0) *
                                        (double.tryParse(
                                                product.quantity.toString()) ??
                                            0.0))),
                          ),
                          getBuyQuantity: (product) =>
                              int.tryParse(product.buyquantity ?? '0') ?? 0,
                          getInNo: (product) => product.inNo ?? '',
                          onQuantityTap: (context, product) =>
                              showDashTimesDialogue(
                            context,
                            product,
                            (p) => p.getTimesData ?? [],
                            (data) => data.businessName,
                            (data) => formatAmount(data.price),
                            (data) => formatAmount(product.tax),
                            (data) => data.quantity.toString(),
                            (data) => formatAmount(
                              product.inclTax == "incl_tax"
                                  ? ((double.tryParse(data.price.toString()) ??
                                          0) *
                                      (double.tryParse(
                                              data.quantity.toString()) ??
                                          0))
                                  : (((double.tryParse(data.price.toString()) ??
                                              0) *
                                          (double.tryParse(
                                                  data.quantity.toString()) ??
                                              0)) +
                                      (double.tryParse(
                                              product.tax.toString()) ??
                                          0.0)),
                            ),
                            (data) => DateFormat('dd-MM-yyyy')
                                .format(data.createdAt!),
                            true,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(widget.context).showSnackBar(
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
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.open_in_new,
                            size: 17,
                            color: primaryColor,
                          ),
                        )),
                  ),
                ),
              ],
            ),
            nkSmallSizeBox(),
            Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<model1.ResponseModell>(
                  future: provider.futureResponseModel,
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
                      topSellingProducts =
                          snapshot.data!.topSellingProducts ?? [];
                      return Expanded(
                          child: topSellingProductList(topSellingProducts));
                    } else {
                      return const Center(
                        child: MyRegularText(
                          label: "No data available",
                          color: secondaryTextColor,
                          align: TextAlign.center,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget topSellingProductListComponent(model.TopSellingProduct productData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Get.dialog(DashBoardCustomerDialog(
                  customerList: productData.customer ?? []));
            },
            child: itemComponet(
                productData.variationName
                    .toString()
                    .nkStringCapitalizeFirstCaracter,
                NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(
                    productData.createdAt.toString()))),
          ),
          itemComponet(
              (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
              price),
          InkWell(
              onTap: () {
                Get.dialog(DashBoardQuantityDialog(
                  quantityList: productData.quantityList ?? [],
                ));
              },
              child: itemComponet(
                  productData.quantity?.toString() ?? '0', quantity)),
          itemComponet(
              (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
              amount),
        ],
      ),
    );
  }

  Widget itemComponet(String title, String subTitle) {
    return nkChildWrappedSizeBox(
      width: AppDimensions.instance!.width * 0.09,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyRegularText(
            label: title,
            color: primaryColor,
          ),
          MyRegularText(
            label: subTitle,
            color: secondaryTextColor,
            fontSize: NkFontSize.smallFont(),
          )
        ],
      ),
    );
  }
}

class OrderStatusLegend extends StatelessWidget {
  const OrderStatusLegend({
    super.key,
    required this.categoryPerformance,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final model1.Delivery? categoryPerformance;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 6,
            backgroundColor: color,
          ),
          const SizedBox(width: 5),
          MyRegularText(
            label: label,
            fontSize: 11.6,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  TextEditingController _controller = TextEditingController();
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  final ScrollController _scrollController = ScrollController();
  bool isFetching = false;
  bool noMoreData = false;
  int currentPage = 1;
  File? _selectedImage;
  @override
  void initState() {
    super.initState();
    _initSocket();
    Future.microtask(() {
      Provider.of<DashboardProvider>(context, listen: false)
          .fetch_individual_chat(salesmanId, 1)
          .then((_) {});
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      if (!isFetching && !noMoreData) {
        currentPage++;
        _fetchMoreMessages();
      }
    }
  }

  void _fetchMoreMessages() async {
    if (isFetching) return;
    setState(() {
      isFetching = true;
    });
    await Provider.of<DashboardProvider>(context, listen: false)
        .fetch_individual_chat(salesmanId, currentPage);

    setState(() {
      isFetching = false;
    });
  }

  void _initSocket() {
    socket = IO.io('${ApiConstants.localHost}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.on('connect', (_) {
      log('Connected to socket server');
    });
    socket.on('disconnect', (_) {
      log('Disconnected from socket server');
    });
    socket.emit('join_room', salesmanId);

    socket.on('chat message', (msg) {
      final newMessage = Messages(
        message: msg['message'],
        image: msg['image'],
        source: msg['source'],
        salesman: msg['salesman'],
        updatedAt: msg['created_at'],
      );
      log('Date Time :${newMessage.updatedAt}');
      Provider.of<DashboardProvider>(context, listen: false)
          .addMessages([newMessage]);
      _scrollToBottom();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  String? _prepareImage() {
    if (_selectedImage == null) return null;

    final fileBytes = _selectedImage!.readAsBytesSync();
    final base64Image = base64Encode(fileBytes);
    if (fileBytes.length > 1 * 1024 * 1024) {
      debugPrint('Image is too large to send');
      return null;
    }
    return base64Image;
  }

  String cleanBase64(String base64String) {
    if (base64String.startsWith('data:image')) {
      final index = base64String.indexOf(',') + 1;
      return base64String.substring(index);
    }
    return base64String;
  }

  Uint8List? decodeBase64Image(String base64String) {
    try {
      String cleanedString = cleanBase64(base64String);
      return base64Decode(cleanedString);
    } catch (e) {
      debugPrint("Error decoding image: $e");
      return null;
    }
  }

  Uint8List compressImage(File file) {
    final originalImage = img.decodeImage(file.readAsBytesSync());
    final compressedImage = img.encodeJpg(originalImage!, quality: 70);
    return Uint8List.fromList(compressedImage);
  }

  Widget _buildMessageContent(Messages message) {
    if (message.image != null && message.image!.isNotEmpty) {
      if (message.image!.contains('chat')) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: message.source == 'salesman'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                '${ApiConstants.imageBaseUrlss}${message.image}',
                width: MediaQuery.of(context).size.width * 0.3,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.green),
                  );
                },
              ),
            ),
            SizedBox(height: 5),
            Text(
              NKDateUtils.commonFullDateTimeFormat2(
                NKDateUtils.formatStringUTCDateTime(
                    message.updatedAt.toString()),
              ),
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500),
            ),
          ],
        );
      } else {
        try {
          final base64String = message.image!.split(',').last;
          final imageBytes = base64Decode(base64String);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: message.source == 'salesman'
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(
                  imageBytes,
                  width: MediaQuery.of(context).size.width * 0.25,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    NKDateUtils.commonFullDateTimeFormat2(
                      NKDateUtils.formatStringUTCDateTime(
                          message.updatedAt.toString()),
                    ),
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500),
                  ),
                  if (message.source == 'admin') ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 11, color: Colors.black54),
                  ]
                ],
              ),
            ],
          );
        } catch (e) {
          debugPrint("Error decoding image: $e");
          return Text(
            'Failed to load image',
            style: TextStyle(color: Colors.red),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: message.source == 'salesman'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.message ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NKDateUtils.commonFullDateTimeFormat2(
                NKDateUtils.formatStringUTCDateTime(
                    message.updatedAt.toString()),
              ),
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500),
            ),
            if (message.source == 'salesman') ...[
              SizedBox(width: 4),
              Icon(Icons.done_all, size: 11, color: Colors.black54),
            ]
          ],
        ),
      ],
    );
  }

  void _sendMessage() {
    String message = _controller.text.trim();
    String? base64Image = _prepareImage();
    if (message.isEmpty && base64Image == null) return;
    socket.emit('chat message', {
      'message': message,
      'source': 'salesman',
      'salesman': salesmanId,
      'image': base64Image,
    });
    _controller.clear();
    setState(() {
      _selectedImage = null;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, chatProvider, child) {
                  List<Messages> messages =
                      chatProvider.individualChatMessages ?? [];
                  if (messages.isEmpty) {
                    return Center(child: NodataWidget());
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length + (isFetching ? 1 : 0),
                    reverse: true,
                    itemBuilder: (context, index) {
                      if (isFetching && index == messages.length) {
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              const Color.fromARGB(255, 233, 233, 233),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          foregroundColor: Colors.white,
                        );
                      }
                      final message = messages[index];
                      bool isSentBySalesman = message.source == 'salesman';
                      return Align(
                        alignment: isSentBySalesman
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(
                              message.message!.isEmpty || message.message == ''
                                  ? 5
                                  : 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSentBySalesman
                                ? const Color.fromARGB(255, 206, 241, 219)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: isSentBySalesman
                                  ? Radius.circular(10)
                                  : Radius.zero,
                              bottomRight: isSentBySalesman
                                  ? Radius.zero
                                  : Radius.circular(10),
                            ),
                          ),
                          child: _buildMessageContent(message),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 100,
                  width: 200,
                  child: Image.file(
                    _selectedImage!,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 246, 246, 246),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: const Color.fromARGB(255, 225, 225, 225))),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 204, 203, 203),
                      radius: 25,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Select Method'),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(EneftyIcons.camera_outline),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(EneftyIcons.gallery_bold),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              EneftyIcons.camera_outline,
                              color: white,
                              size: 25,
                            ),
                          )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            fillColor: white,
                            filled: true,
                            hintText: 'Type your message here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 167, 214, 225),
                      radius: 25,
                      child: InkWell(
                          onTap: () => _sendMessage(),
                          child: Icon(
                            EneftyIcons.send_3_outline,
                            size: 25,
                            color: white,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunicationsDisplayWidget extends StatefulWidget {
  @override
  _CommunicationsDisplayWidgetState createState() =>
      _CommunicationsDisplayWidgetState();
}

class _CommunicationsDisplayWidgetState
    extends State<CommunicationsDisplayWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final DashboardProvider provider = Provider.of<DashboardProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 205, 206, 208).withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: 25,
          height: 300,
          isCommonBorder: true,
          padding: EdgeInsets.zero,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 224, 224, 226)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 5, bottom: 5),
                  child: Text(
                    "Communication",
                    style: cardHeadingTextStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ChatScreen(),
            ),
            nkSmallSizeBox(),
          ])),
    );
  }
}
