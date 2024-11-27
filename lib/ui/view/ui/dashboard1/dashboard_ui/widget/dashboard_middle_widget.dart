
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
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../components/bar_and_chart/revenue_pie_chart.dart';
import '../../provider/dash_provider.dart';

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
    return MyCommnonContainer(
      height: 280,
      isCommonBorder: true,
      padding: nkRegularPadding(),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Collection',
            style: cardHeadingTextStyle,
          ),
          nkSmallSizeBox(),
          Expanded(child: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              return FutureBuilder<ResponseModell>(
                future: provider.futureResponseModel,
                builder: (context, AsyncSnapshot<ResponseModell> snapshot) {
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
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final responseModel = snapshot.data!;

                    // Calculate the total amounts
                    final totalCompletedAmount = responseModel
                        .collection!.payment!.completedOrders!
                        .fold(0.0, (sum, order) => sum + order.orderTotal);

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

                    return NestedPieChartj(
                      sabik: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 11.9,
                            width: 14.9,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 90, 119, 37),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1.0)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          MyRegularText(
                            label: completedOrdersLabel,
                            fontSize: 11.6,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 8.3),
                          Container(
                            height: 11.9,
                            width: 14.9,
                            decoration: const BoxDecoration(
                              color: Color(0xffa30c13),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1.0)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          MyRegularText(
                            label: pendingAmountLabel,
                            fontSize: 11.6,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                      sabi2: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 11.9,
                            width: 14.9,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 173, 181),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1.0)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          MyRegularText(
                            label: dueAmountLabel,
                            fontSize: 11.6,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 8.3),
                          Container(
                            height: 11.9,
                            width: 14.9,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 101, 132),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1.0)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          MyRegularText(
                            label: overdueAmountLabel,
                            fontSize: 11.6,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                      collection: responseModel.collection!,
                    );
                  }
                },
              );
            },
          )),

          //    nkMediumSizeBox()
        ],
      ),
    );
  }

  Widget orderDeliveryChart(BuildContext context) {
    return MyCommnonContainer(
      height: 280,
      width: double.infinity,
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: cardHeadingTextStyle,
          ),
          Expanded(child: Consumer<DashboardProvider>(
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
                      return const Center(child: Text('No data available'));
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
                              height: ResponsiveInfo.isMobileDimension(context)
                                  ? 11.5
                                  : 11.9,
                              width: ResponsiveInfo.isMobileDimension(context)
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
                    return const Center(child: Text('No data available'));
                  }
                },
              );
            },
          ))
        ],
      ),
    );
  }

  Widget middleTopLeftComponet() {
    return MyCommnonContainer(
      height: 280,
      width: double.infinity,
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            projectionsVsActual,
            style: cardHeadingTextStyle,
            maxLines: 1,
            softWrap: false,
          ),
          nkMediumSizeBox(),
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<ResponseModell>(
                  future: provider.futureResponseModel,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitFadingCube(
                          color: primaryColor, // Customize color if needed
                          size: 20.0,
                        ),
                      );
                    } else if (snapshot.hasError) {
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
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 50, color: Colors.grey),
                            Text('No data available'),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget middleTopRightComponet() {
    return MyCommnonContainer(
      height: 280,
      width: double.infinity,
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue',
            style: cardHeadingTextStyle,
          ),
          Expanded(
            child: Consumer<DashboardProvider>(
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
                      if (categoryPerformance == null) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 50, color: Colors.grey),
                              Text('No data available'),
                            ],
                          ),
                        );
                      }

                      final bookingRevenueLength = categoryPerformance
                              .bookingRevenueData!.isNotEmpty
                          ? categoryPerformance.bookingRevenueData!.last.total
                          : 0.0;

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
                    } else {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 50, color: Colors.grey),
                            Text('No data available'),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
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
            final message = communicationController.text.trim();
            if (provider.selectedChat != null && message.isNotEmpty) {
              provider.postAdminMessage(
                  provider.selectedChat!.salesmanId, message);
              communicationController.clear();
            }
            print(message);
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
      () => MyCommnonContainer(
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
    );
  }

  Widget topSellingProductList(List<TopSellingProductA> topSellingProducts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double fontSize = 11;

        // Sort products by quantity
        topSellingProducts
            .sort((a, b) => b.quantity!.compareTo(a.quantity.toString()));

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: availableWidth,
          child: Column(
            children: [
              Container(
                color: Colors.white, // Background color for headers
                child: Row(
                  children: [
                    Expanded(
                      child: DataTable(
                        horizontalMargin: 6,
                        headingRowHeight: 30,
                        dataRowHeight: 0,
                        dividerThickness: 0,
                        border: TableBorder.all(width: 0, color: Colors.white),
                        columns: const [
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: MyRegularText(
                                  label: "Product",
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
                                  '${product.variationId} - ${product.variationName}',
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
                                    label: "Product",
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
                                    '${product.variationId} - ${product.variationName}',
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
                                                          const EdgeInsets.all(
                                                              10),
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
                                                              color:
                                                                  Colors.white,
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
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                                              text: 'Quantity',
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
                                                          return DataRow(
                                                              cells: [
                                                                DataCell(Center(
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
                                                                DataCell(Center(
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
                                                                    child: Text(
                                                                      quantity.price !=
                                                                              null
                                                                          ? '${formatAmount(quantity.price)}'
                                                                          : 'N/A',
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
                                                                  ),
                                                                ),
                                                                DataCell(Center(
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
                                                                )), // Format this date as needed
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
    return MyCommnonContainer(
      height: 280,
      isCommonBorder: true,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //  mainAxisSize: MainAxisSize.max,
        children: [
          nkSmallSizeBox(),
          Row(
            children: [
              nkSmallSizeBox(),
              const Text(
                'Frequently Bought Products',
                style: cardHeadingTextStyle,
              ),
            ],
          ),
          nkSmallSizeBox(),
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              return FutureBuilder<ResponseModell>(
                future: provider.futureResponseModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitFadingCube(
                        color: primaryColor, // Customize color if needed
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
    );
  }

  Widget topSellingProductListComponent(TopSellingProduct productData) {
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

/*
  Widget exportWidget(String lable) {
    return MyCommnonContainer(
      padding: nkRegularPadding(
          left: AppDimensions.instance!.height * 0.018,
          right: AppDimensions.instance!.height * 0.018),
      color: const Color(0xFFEEF2F7),
      onTap: () {
        // Get.dialog(CalanderDiloag());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyRegularText(label: lable),
          nkSmallSizeBox(),
          const Flexible(child: Icon(Icons.ios_share_rounded)),
        ],
      ),
    );
  }
*/
}
// class MessageScreen extends StatelessWidget {
//   final String salesmanId;
//   final TextEditingController _messageController = TextEditingController();

//   MessageScreen({required this.salesmanId});

//   @override
//   Widget build(BuildContext context) {
//     final DashboardProvider provider = Provider.of<DashboardProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Chat with Salesman $salesmanId',
//           style: const TextStyle(color: Colors.black, fontSize: 15.5),
//         ),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<MessagesResponse>(
//               future: provider.fetch_individual_chat(salesmanId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (snapshot.hasData) {
//                   return ListView.builder(
//                     itemCount: snapshot.data!.data.length,
//                     itemBuilder: (context, index) {
//                       Messages message = snapshot.data!.data[index];
//                       // Determine color based on source
//                       Color tileColor = Colors.white;
//                       if (message.source == 'admin') {
//                         tileColor = const Color(0xffd1e7dd);
//                       } else if (message.source == 'salesman') {
//                         tileColor = const Color(0xfff1f1f1);
//                       }

//                       return Align(
//                         alignment: message.source == 'admin'
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: tileColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(message.message ?? ''),
//                         ),
//                       );
//                     },
//                   );
//                 } else {
//                   return const Center(child: Text('No data available'));
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () async {
//                     if (_messageController.text.trim().isNotEmpty) {
//                       await provider.postAdminMessage(salesmanId, _messageController.text.trim());
//                       _messageController.clear();
//                       // Re-fetch the chat data to refresh the messages
//                       await provider.fetch_individual_chat(salesmanId);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class ChatScreen extends StatelessWidget {
  final String chatId;
  final VoidCallback onBack;

  const ChatScreen({super.key, required this.chatId, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.individualChatMessages == null) {
          provider.fetch_individual_chat(chatId);
        }

        final TextEditingController _messageController =
            TextEditingController();
        final ScrollController _scrollController = ScrollController();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return provider.individualChatMessages == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: provider.individualChatMessages!.length,
                      itemBuilder: (context, index) {
                        Messages message =
                            provider.individualChatMessages![index];

                        // Determine color based on source
                        Color tileColor = Colors.white;
                        if (message.source == 'admin') {
                          tileColor = const Color(0xffd1e7dd);
                        } else if (message.source == 'salesman') {
                          tileColor = const Color(0xfff1f1f1);
                        }

                        return Align(
                          alignment: message.source == 'admin'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: message.source == 'admin'
                                  ? Colors.green[200]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.message,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          labelText: 'Type a message',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 22.5,
                        ),
                        onPressed: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            provider
                                .postAdminMessage(
                                    chatId, _messageController.text.trim())
                                .then((_) {
                              _messageController.clear();
                              provider.fetchChatData('');
                              // provider.fetchChatData(chatId);
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              }
                            });
                          }

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              );
      },
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

    return MyCommnonContainer(
      height: 280,
      isCommonBorder: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            width: double.maxFinite,
            height: 40,
            decoration: BoxDecoration(
                color: Color(0xFF62a582),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Text(
              'Communications',
              style: TextStyle(
                fontFamily: fontFamilyName,
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: white,
              ),
            ),
          ),
          // nkSmallSizeBox(),
          Expanded(
            child: Padding(
              padding: nkRegularPadding(top: 10, bottom: 0),
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<SalesmenResponse>(
                    future: provider.salesmenResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.data.isEmpty) {
                        return const Center(
                          child: Text('No chat data available'),
                        );
                      } else {
                        final chatData =
                            snapshot.data!.data.expand((list) => list).toList();

                        return ListView.builder(
                          itemCount: chatData.length,
                          itemBuilder: (context, index) {
                            final chat = chatData[index];
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: MyCommnonContainer(
                                borderRadius: 3.7,
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 0.4),
                                // color: const Color(0xffe1e4e6),
                                child: ListTile(
                                  leading: Container(
                                    width: 33,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Color(0xffe6ecff), // Background color
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 20.5,
                                      color: Color(0xff4294ff),
                                    ),
                                  ),
                                  title: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            MyRegularText(
                                              label: chat.fullname,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.6,
                                              color: secondaryTextColor,
                                            ),
                                            const Spacer(),
                                            Container(
                                              width: 9.3,
                                              height: 9.3,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 1,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            MyRegularText(
                                              label:
                                                  '${NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(chat.updatedAt.toString()))}  ${NKDateUtils.commonTimeFormat(NKDateUtils.formatStringUTCDateTime(chat.updatedAt.toString()))}',
                                              fontWeight: NkGeneralSize
                                                  .nkGeneralFontWeight(),
                                              fontSize: 9.2,
                                            ),
                                          ],
                                        ),
                                        MyRegularText(
                                          label: chat.message,
                                          fontSize: 10,
                                          color: secondaryTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    provider.selectChat(chat);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          titlePadding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          content: SizedBox(
                                            width: 300,
                                            height: 414,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                                  width: double.maxFinite,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF62a582),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(
                                                                      10))),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        chat.fullname,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              fontFamilyName,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13.0,
                                                          color: white,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      dialogCloseButton(
                                                          context, red)
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                const Divider(),
                                                Expanded(
                                                  child: ChatScreen(
                                                    chatId: chat.salesmanId,
                                                    onBack: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      provider
                                                          .clearSelectedChat();
                                                    },
                                                  ),
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
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          nkSmallSizeBox(),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    provider.pickImageCommuni();
                  },
                  icon: const Icon(
                    Icons.photo_camera,
                    size: 20,
                  )),
              Expanded(
                child: SizedBox(
                  height: 37.6,
                  child: MyFormField(
                    controller: _messageController,
                    labelText: 'Enter message',
                    enableColor: primaryTextFieldColor,
                    focusedColor: primaryTextFieldColor,
                    disabledColor: primaryTextFieldColor,
                    maxLines: 1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.send,
                  size: 20,
                ),
                onPressed: () {
                  if (_messageController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // contentPadding: EdgeInsets.zero,
                            // titlePadding: EdgeInsets.zero,
                            content: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.report_gmailerrorred,
                                    color: Color(0xffeecd6e),
                                    size: 22,
                                  ),
                                  SizedBox(
                                    width: 6.1,
                                  ),
                                  Text(
                                    'Please Enter Message to Proceed',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xffeecd6e)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          4.0), // Adjust the radius value as needed
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // Handle accept action
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Back',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        });
                  }
                  if (_messageController.text.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Salesman List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppins_Regular',
                                  ),
                                ),
                                const Spacer(),
                                dialogCloseButton(context, red),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(15),
                          titlePadding: EdgeInsets.zero,
                          content: Consumer<DashboardProvider>(
                            builder: (context, provider, child) {
                              return FutureBuilder<SalesmenResponse>(
                                future: provider.salesmenResponse,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.data.isEmpty) {
                                    return const Center(
                                      child: Text('No chat data available'),
                                    );
                                  } else {
                                    final chatData = snapshot.data!.data
                                        .expand((list) => list)
                                        .toList();

                                    // provider.selectAllChats(chatData);

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Select All button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              if (provider
                                                      .selectedChats.length ==
                                                  chatData.length) {
                                                provider.clearAllSelections();
                                              } else {
                                                provider
                                                    .selectAllChats(chatData);
                                              }
                                            },
                                            child: Text(
                                              provider.selectedChats.length ==
                                                      chatData.length
                                                  ? 'Deselect All'
                                                  : 'Select All',
                                              style: const TextStyle(
                                                  color: primaryColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: 400,
                                          height: 400,
                                          child: ListView.builder(
                                            itemCount: chatData.length,
                                            itemBuilder: (context, index) {
                                              final chat = chatData[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: MyCommnonContainer(
                                                  isCommonBorder: true,
                                                  color:
                                                      const Color(0xffffffff),
                                                  child: ListTile(
                                                    leading: Container(
                                                      width: 33,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors
                                                            .blueGrey[100],
                                                      ),
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 20.5,
                                                        color:
                                                            Color(0xff4294ff),
                                                      ),
                                                    ),
                                                    title: MyRegularText(
                                                      label: chat.fullname,
                                                      fontSize: 14,
                                                      fontWeight: NkGeneralSize
                                                          .nkBoldFontWeight(),
                                                      color: secondaryTextColor,
                                                    ),
                                                    trailing: Checkbox(
                                                      value: provider
                                                          .selectedChats
                                                          .contains(chat),
                                                      onChanged: (bool? value) {
                                                        provider
                                                            .toggleChatSelection(
                                                                chat);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                final message = _messageController.text.trim();
                                if (message.isNotEmpty &&
                                    provider.selectedChats.isNotEmpty) {
                                  for (var chat in provider.selectedChats) {
                                    provider.postAdminMessage(
                                        chat.salesmanId, message);
                                    // provider.fetchChatData(chat.salesmanId);
                                    provider.fetchChatData('');
                                  }

                                  _messageController.clear();
                                  provider.selectedChats.clear();

                                  setState(() {}); // to refresh the page

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Messages sent to selected chats')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'No chats selected or message is empty')),
                                  );
                                }

                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                              ),
                              child: const Text('Send',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
          nkSmallSizeBox(),
        ],
      ),
    );
  }
}