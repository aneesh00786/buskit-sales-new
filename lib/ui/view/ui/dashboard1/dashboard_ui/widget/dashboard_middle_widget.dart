import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';

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
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart'
    as model;
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart'
    as model1;
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../components/bar_and_chart/revenue_pie_chart.dart';
import '../../provider/dash_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image/image.dart' as img;

// ignore: must_be_immutable
class DashBoardMiddleWidget extends StatelessWidget {
  final DashBoardController dashBoardController;
  BuildContext context;

  DashBoardMiddleWidget(
      {super.key, required this.dashBoardController, required this.context});
  TextEditingController communicationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600; // Adjust the breakpoint as needed

    return SizedBox(
      height: MediaQuery.of(context).size.height, // For larger screens
      width: MediaQuery.of(context).size.width, // For larger screens
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
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        isCommonBorder: true,
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              child: Text(
                "Collection",
                style: cardHeadingTextStyle,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            nkSmallSizeBox(),
            Expanded(
                child: Padding(
              padding: nkRegularPadding(),
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<model1.ResponseModell>(
                    future: provider.futureResponseModel,
                    builder: (context,
                        AsyncSnapshot<model1.ResponseModell> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const NodataWidget();
                      } else {
                        final responseModel = snapshot.data!;
                        final totalCompletedAmount = responseModel
                                .collection?.payment?.completedOrders
                                ?.fold(0.0,
                                    (sum, order) => sum + order.orderTotal) ??
                            0.0;

                        final pendingAmountCount = responseModel.collection
                                    ?.order?.pendingAmount?.isNotEmpty ==
                                true
                            ? responseModel.collection!.order!.pendingAmount!
                                .last.amount as int
                            : 0;
                        final pendingAmountLabel = pendingAmountCount > 0
                            ? 'Pending : ${formatAmount(pendingAmountCount)}'
                            : 'Pending : \$ 0.00';

                        final dueAmountCount = responseModel.collection?.order
                                    ?.pendingAmount?.isNotEmpty ==
                                true
                            ? responseModel.collection!.order!.pendingAmount!
                                .last.dueAmount as int
                            : 0;
                        final dueAmountLabel = dueAmountCount > 0
                            ? 'Due : ${formatAmount(dueAmountCount)}'
                            : 'Due : \$ 0.00';

                        final overdueAmountCount = responseModel.collection
                                    ?.order?.pendingAmount?.isNotEmpty ==
                                true
                            ? responseModel.collection!.order!.pendingAmount!
                                .last.overDue as int
                            : 0;
                        final overdueAmountLabel = overdueAmountCount > 0
                            ? 'Overdue : ${formatAmount(overdueAmountCount)}'
                            : 'Overdue : \$ 0.00';

                        final completedOrdersLabel = totalCompletedAmount > 0
                            ? 'Completed : ${formatAmount(totalCompletedAmount)}'
                            : 'Completed : \$ 0.00';

                        if (totalCompletedAmount <= 0 &&
                            pendingAmountCount <= 0 &&
                            dueAmountCount <= 0 &&
                            overdueAmountCount <= 0) {
                          return const NodataWidget();
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: NestedPieChartj(
                                  completedOrdersCount:
                                      totalCompletedAmount.toInt(),
                                  pendingAmountCount: pendingAmountCount,
                                  dueAmountCount: dueAmountCount,
                                  overdueAmountCount: overdueAmountCount,
                                  collection: responseModel.collection ??
                                      model1.Collection(),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Legend for the chart
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem(
                                    const Color.fromARGB(255, 90, 119, 37),
                                    completedOrdersLabel,
                                  ),
                                  const SizedBox(width: 8.3),
                                  _buildLegendItem(
                                    const Color(0xffa30c13),
                                    pendingAmountLabel,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem(
                                    const Color.fromARGB(255, 255, 173, 181),
                                    dueAmountLabel,
                                  ),
                                  const SizedBox(width: 8.3),
                                  _buildLegendItem(
                                    const Color.fromARGB(255, 255, 101, 132),
                                    overdueAmountLabel,
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
            )),

            //    nkMediumSizeBox()
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          height: 11.9,
          width: 14.9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(1.0)),
          ),
        ),
        const SizedBox(width: 2),
        MyRegularText(
          label: label,
          fontSize: 11.6,
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
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              child: Text(
                "Order Status",
                style: cardHeadingTextStyle,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            Expanded(
                child: Padding(
              padding: nkRegularPadding(),
              child: Consumer<DashboardProvider>(
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
                            aColor: const Color(0xff142b33),
                            bColor: const Color(0xff4455dd),
                            sabik: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height:
                                      ResponsiveInfo.isMobileDimension(context)
                                          ? 11.5
                                          : 11.9,
                                  width:
                                      ResponsiveInfo.isMobileDimension(context)
                                          ? 14.9
                                          : 14.9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffc38a42),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      "Out for delivery : ${formatAmount(categoryPerformance.order!.totalOrders!.last.outForDelivery)}",
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 8.3),
                                Container(
                                  height: 11.9,
                                  width: 14.9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff33b4a8),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      "Delivered : ${formatAmount(categoryPerformance.order!.totalOrders!.last.delivered)}",
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ],
                            ),
                            sabik1: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 11.9,
                                  width: 14.9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff142b33),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      "Processing : ${formatAmount(categoryPerformance.order!.totalOrders!.last.orderProcessing)}",
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 8.3),
                                Container(
                                  height: 11.9,
                                  width: 14.9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff4455dd),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      "Packed : ${formatAmount(categoryPerformance.order!.totalOrders!.last.packedForDelivery)}",
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ],
                            ),
                            cColor: const Color(0xffcc8f3d),
                            dColor: const Color(0xff33b4a8),
                          ),
                        );
                      } else {
                        return const NodataWidget();
                      }
                    },
                  );
                },
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget middleTopLeftComponet() {
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
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              child: Text(
                projectionsVsActual,
                style: cardHeadingTextStyle,
                maxLines: 1,
                softWrap: false,
              ),
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
                          final errorMessage = snapshot.error.toString();
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
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              child: Text(
                "Revenue",
                style: cardHeadingTextStyle,
                maxLines: 1,
                softWrap: false,
              ),
            ),
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
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 50, color: Colors.red),
                                Text(
                                  "Our servers are currently down for maintenance. We’re working to resolve the issue as quickly as possible. Please check back soon, and thank you for your understanding.",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data?.revenue == null) {
                          return const NodataWidget();
                        }

                        final categoryPerformance = snapshot.data!.revenue;

                        // Check if booking or order revenue data is empty
                        final bookingRevenueLength = categoryPerformance
                                    ?.bookingRevenueData?.isNotEmpty ??
                                false
                            ? categoryPerformance
                                ?.bookingRevenueData?.last.total
                            : 0.0;

                        final orderRevenueLast =
                            categoryPerformance?.orderRevenueData?.isNotEmpty ??
                                    false
                                ? categoryPerformance
                                    ?.orderRevenueData?.last.totalOrderRevenue
                                : 0.0;
                        if (bookingRevenueLength == 0.0 &&
                            orderRevenueLast == 0.0) {
                          return const NodataWidget();
                        }

                        return Center(
                          child: DoughnutDefault(
                            categoryData: categoryPerformance!,
                            booking: "Booking : 3",
                            order: "Order : 3",
                            aColor: Colors.blue,
                            bColor: const Color(0xff1d3d63),
                            sabik: const SizedBox.shrink(),
                            sabik1: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 11.9,
                                  width: 14.9,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff1d3d63),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      'Booking : ${formatAmount(bookingRevenueLength)}',
                                  color: secondaryTextColor,
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(
                                  width: 8.3,
                                ),
                                Container(
                                  height: 11.9,
                                  width: 14.9,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1.0)),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyRegularText(
                                  label:
                                      'Order : ${formatAmount(orderRevenueLast)}',
                                  color: secondaryTextColor,
                                  fontSize: 11.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        );
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
          padding: dashBoardController.selectedCommunicationIndex.value == index
              ? nkSmallPadding()
              : null,
          onTap: () {
            dashBoardController.selectedCommunicationIndex.value = index;

            showDialog(
              context: context,
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
                          // ignore: prefer_interpolation_to_compose_strings
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
              dashBoardController.selectedCommunicationIndex.value == index,
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

  Widget topSellingProductList(
      List<model1.TopSellingProductA> topSellingProducts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double fontSize = 11;
        topSellingProducts
            .sort((a, b) => b.quantity!.compareTo(a.quantity.toString()));
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: availableWidth,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: DataTable(
                        horizontalMargin: 6,
                        headingRowHeight: 30,
                        dataRowHeight: 0,
                        dividerThickness: 0,
                        headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => const Color.fromARGB(255, 205, 206, 208)
                              .withOpacity(0.2),
                        ),
                        border: TableBorder.all(
                            width: 0,
                            color: const Color.fromARGB(255, 238, 235, 235)),
                        columns: const [
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Product",
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                  align: TextAlign.center,
                                  fontSize: 11.3,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Last Purchase",
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                  maxlines: 2,
                                  align: TextAlign.center,
                                  fontSize: 11.3,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Times",
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                  align: TextAlign.center,
                                  fontSize: 11.3,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Price",
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                  align: TextAlign.center,
                                  fontSize: 11.3,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Qty",
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                  align: TextAlign.center,
                                  fontSize: 11.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: topSellingProducts.map((product) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  '${product.productName} - ${product.variationName}',
                                  style: TextStyle(fontSize: fontSize),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MyRegularText(
                                    label: DateFormat('dd-MM-yyyy')
                                        .format(product.createdAt!),
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: InkWell(
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: MyRegularText(
                                          label: product.quantityList!.length
                                              .toString(),
                                          color: buttonTextColor,
                                          align: TextAlign.center,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MyRegularText(
                                    label: formatAmount(product.price),
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                    maxlines: 1,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MyRegularText(
                                    label: "${product.quantity}",
                                    color: secondaryTextColor,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              if (topSellingProducts.isEmpty)
                Expanded(child: Center(child: NodataWidget()))
              else
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            horizontalMargin: 6,
                            headingRowHeight: 0,
                            dataRowHeight: 35,
                            dividerThickness: 0,
                            border:
                                TableBorder.all(width: 0, color: Colors.white),
                            columns: const [
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: MyRegularText(
                                      label: "Produc",
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                      align: TextAlign.center,
                                      fontSize: 11.3,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: MyRegularText(
                                      label: "Last Purchase",
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                      maxlines: 2,
                                      align: TextAlign.center,
                                      fontSize: 11.3,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: MyRegularText(
                                      label: "Times",
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                      align: TextAlign.center,
                                      fontSize: 11.3,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: MyRegularText(
                                      label: "Price",
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                      align: TextAlign.center,
                                      fontSize: 11.3,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: MyRegularText(
                                      label: "Qty",
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                      align: TextAlign.center,
                                      fontSize: 11.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: topSellingProducts.map((product) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Text(
                                      '${product.productName} - ${product.variationName}',
                                      style: TextStyle(fontSize: fontSize),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: MyRegularText(
                                        label: DateFormat('dd-MM-yyyy')
                                            .format(product.createdAt!),
                                        color: secondaryTextColor,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                titlePadding: EdgeInsets.zero,
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 45,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: primaryColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              product
                                                                  .variationName
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Poppins_Regular',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            dialogCloseButton(
                                                                context, red),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: DataTable(
                                                          dataRowHeight: 30,
                                                          headingRowHeight: 35,
                                                          columnSpacing: 30,
                                                          // horizontalMargin: 0,
                                                          columns: const [
                                                            DataColumn(
                                                              label:
                                                                  DialogTableHeaderText(
                                                                text: 'Price',
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label:
                                                                  DialogTableHeaderText(
                                                                text:
                                                                    'Quantity',
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label:
                                                                  DialogTableHeaderText(
                                                                text: 'Amount',
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label:
                                                                  DialogTableHeaderText(
                                                                text:
                                                                    'Purchased At',
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                          rows: product
                                                              .quantityList!
                                                              .map((quantity) {
                                                            log('PRICE ${quantity.price}');
                                                            return DataRow(
                                                                cells: [
                                                                  DataCell(
                                                                      Center(
                                                                    child: Text(
                                                                      // '1',
                                                                      formatAmount(
                                                                          quantity
                                                                              .price),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        color:
                                                                            secondaryTextColor,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                  DataCell(
                                                                      Center(
                                                                    child: Text(
                                                                      quantity
                                                                          .quantity
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        color:
                                                                            secondaryTextColor,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                  DataCell(
                                                                    Center(
                                                                      child:
                                                                          Text(
                                                                        quantity.price !=
                                                                                null
                                                                            ? '${formatAmount(quantity.price)}'
                                                                            : 'N/A',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              secondaryTextColor,
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  DataCell(
                                                                      Center(
                                                                    child: Text(
                                                                      DateFormat(
                                                                              'dd-MM-yyyy')
                                                                          .format(
                                                                              quantity.createdAt!)
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        color:
                                                                            secondaryTextColor,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                ]);
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: MyRegularText(
                                              label: product
                                                  .quantityList!.length
                                                  .toString(),
                                              color: buttonTextColor,
                                              align: TextAlign.center,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: MyRegularText(
                                        label: formatAmount(product.price),
                                        color: secondaryTextColor,
                                        fontSize: fontSize,
                                        maxlines: 1,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: MyRegularText(
                                        label: "${product.quantity}",
                                        color: secondaryTextColor,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget topSellingProductWidget() {
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
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              child: Text(
                "Frequently Bought Products",
                style: cardHeadingTextStyle,
                maxLines: 1,
                softWrap: false,
              ),
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
                      final topSellingProducts =
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
      );
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            '${ApiConstants.imageBaseUrlss}${message.image}',
            width: MediaQuery.of(context).size.width * 0.25,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'Failed to load image',
                style: TextStyle(color: Colors.green),
              );
            },
          ),
        );
      } else {
        try {
          final base64String = message.image!.split(',').last;
          final imageBytes = base64Decode(base64String);
          return ClipRRect(
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
    return Text(
      message.message ?? '',
      style: TextStyle(fontSize: 16),
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
                              message.message.isEmpty || message.message == ''
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
