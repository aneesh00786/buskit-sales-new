import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_dialog_table.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

void showCollectionChartDialog(
  BuildContext context,
  String title,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.8;
            double maxDialogHeight = constraints.maxHeight * 0.7;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<DashboardProvider>(
                          builder: (context, provider, child) {
                            return FutureBuilder<ResponseModell>(
                              future: provider.futureResponseModel,
                              builder: (context,
                                  AsyncSnapshot<ResponseModell> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: SpinKitFadingCube(
                                      color: primaryColor,
                                      size: 20.0,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  debugPrint("Error: ${snapshot.error}");
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                } else if (!snapshot.hasData ||
                                    (snapshot.data != null &&
                                        (snapshot.data!.collection?.payment
                                                ?.completedOrders?.isEmpty ??
                                            true) &&
                                        (snapshot.data!.collection?.order
                                                ?.pendingAmount?.isEmpty ??
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

                                  // Safely calculate total amounts with fallback values
                                  final totalCompletedAmount = responseModel
                                          .collection?.payment?.completedOrders
                                          ?.fold(
                                        0.0,
                                        (sum, order) =>
                                            sum + (order.orderTotal ?? 0.0),
                                      ) ??
                                      0.0;

                                  final pendingAmountLabel =
                                      'Pending: ${formatAmount(responseModel.collection?.order?.pendingAmount?.last.amount ?? 0.0)}';

                                  final dueAmountLabel =
                                      'Due: ${formatAmount(responseModel.collection?.order?.pendingAmount?.last.dueAmount ?? 0.0)}';

                                  final overdueAmountLabel =
                                      'Overdue: ${formatAmount(responseModel.collection?.order?.pendingAmount?.last.overDue ?? 0.0)}';

                                  final completedOrdersLabel =
                                      'Completed: ${formatAmount(totalCompletedAmount)}';

                                  return Column(
                                    children: [
                                      Expanded(
                                        child: NestedPieChartj(
                                          isBig: true,
                                          completedOrdersCount:
                                              totalCompletedAmount.toInt(),
                                          pendingAmountCount: (responseModel
                                                          .collection
                                                          ?.order
                                                          ?.pendingAmount !=
                                                      null &&
                                                  responseModel
                                                      .collection!
                                                      .order!
                                                      .pendingAmount!
                                                      .isNotEmpty)
                                              ? responseModel
                                                      .collection!
                                                      .order!
                                                      .pendingAmount!
                                                      .last
                                                      .amount
                                                      ?.toInt() ??
                                                  0
                                              : 0,
                                          dueAmountCount: responseModel
                                                  .collection
                                                  ?.order
                                                  ?.pendingAmount
                                                  ?.last
                                                  .dueAmount
                                                  ?.toInt() ??
                                              0,
                                          overdueAmountCount: responseModel
                                                  .collection
                                                  ?.order
                                                  ?.pendingAmount
                                                  ?.last
                                                  .overDue
                                                  ?.toInt() ??
                                              0,
                                          collection: responseModel.collection!,
                                        ),
                                      ),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (totalCompletedAmount != 0) {
                                                showValueCollectionDialog(
                                                    context,
                                                    responseModel.collection!,
                                                    'Recieved Payment');
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color.fromARGB(
                                                  255, 90, 119, 37),
                                              completedOrdersLabel,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (responseModel
                                                      .collection
                                                      ?.order
                                                      ?.pendingAmount
                                                      ?.last
                                                      .amount !=
                                                  0) {
                                                pendingPaymentCollectionDialog(
                                                    context,
                                                    'Pending Payment',
                                                    responseModel.collection!);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color(0xffa30c13),
                                              pendingAmountLabel,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (responseModel
                                                      .collection
                                                      ?.order
                                                      ?.pendingAmount
                                                      ?.last
                                                      .dueAmount !=
                                                  0) {
                                                pendingPaymentCollectionDialog(
                                                    context,
                                                    'Due Payment',
                                                    responseModel.collection!);
                                              }
                                            },
                                            child: _buildLegendItem(
                                              const Color.fromARGB(
                                                  255, 255, 173, 181),
                                              dueAmountLabel,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (responseModel
                                                      .collection
                                                      ?.order
                                                      ?.pendingAmount
                                                      ?.last
                                                      .overDue !=
                                                  0) {
                                                pendingPaymentCollectionDialog(
                                                    context,
                                                    'Over Due Payment',
                                                    responseModel.collection!);
                                              }
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
          },
        ),
      );
    },
  );
}

Widget _buildLegendItem(Color color, String label) {
  return Row(
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
  );
}
