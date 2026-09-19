import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_collection.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';

Widget buildHeader(
    BuildContext context, ScrollController headerScrollController) {
  double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 53 : 58;
  double fontSize = ResponsiveInfo.isMobileDimension(context) ? 7 : 11;
  if (MediaQuery.of(context).orientation != Orientation.portrait) {
    headerHeight = 55;
    fontSize = 13;
  }
  return Align(
    alignment: FractionalOffset.topCenter,
    child: Container(
      width: double.infinity,
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveInfo.isMobileDimension(context) ? 2 : 4),
        child: Row(
          children: [
            SizedBox(
              width: 205,
              child: Column(
                children: [
                  Expanded(
                      child: _buildHeaderText("Customer List".tr, fontSize)),
                  const SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                    radius: const Radius.circular(10),
                    thumbColor:
                        WidgetStatePropertyAll(Colors.white.withOpacity(0.6))),
                child: Scrollbar(
                  controller: headerScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: headerScrollController,
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    child: SizedBox(
                      width: (isTabletOrPhoneLandscape(context))
                          ? fullScreenWidth(context) > 650
                              ? fullScreenWidth(context) * 1
                              : fullScreenWidth(context) > 720
                                  ? fullScreenWidth(context)
                                  : fullScreenWidth(context) * 1.2
                          : fullScreenWidth(context) * 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText(
                                        "Order No.".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child:
                                        _buildHeaderText("Date".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText(
                                        "Due Date".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 2,
                                    child:
                                        _buildHeaderText("Days".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText(
                                        "Amount".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText(
                                        "Invoice".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 4,
                                    child: _buildHeaderText(
                                        "Status".tr, fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText("", fontSize)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeaderText(String text, double fontSize) {
  return Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins_Regular',
      ),
    ),
  );
}

Widget buildOrderList(
    BuildContext context,
    PendingPaymentController orderController,
    ScrollController orderScrollController,
    ScrollController customerListScrollController,
    ScrollController orderRowsScrollController) {
  double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 53 : 58;
  return Align(
    alignment: FractionalOffset.topCenter,
    child: Container(
      padding: EdgeInsets.only(top: headerHeight),
      child: Row(
        children: [
          SizedBox(
            width: 210,
            child: ListView.builder(
              controller: customerListScrollController,
              itemCount: orderController.orderDataList.length + 1,
              itemBuilder: (context, index) {
                if (index < orderController.orderDataList.length) {
                  final customerData = orderController.orderDataList[index];
                  return _buildCustomerDetails(customerData, context, index);
                } else {
                  return Container(
                    height: 58,
                    color: const Color(0xFFF8FAFC),
                    alignment: Alignment.center,
                    child: PaginationWidget(orderController: orderController),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                trackVisibility: const WidgetStatePropertyAll(true),
                thumbVisibility: const WidgetStatePropertyAll(true),
                thumbColor: WidgetStateProperty.all(primaryColor),
                trackColor: WidgetStateProperty.all(Colors.grey[300]),
                trackBorderColor: WidgetStateProperty.all(Colors.grey[400]),
                thickness: WidgetStateProperty.all(5),
                radius: const Radius.circular(10),
              ),
              child: Scrollbar(
                controller: orderScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  controller: orderScrollController,
                  child: SizedBox(
                    width: (isTabletOrPhoneLandscape(context))
                        ? fullScreenWidth(context) > 650
                            ? fullScreenWidth(context) * 1
                            : fullScreenWidth(context) > 720
                                ? fullScreenWidth(context)
                                : fullScreenWidth(context) * 1.2
                        : fullScreenWidth(context) * 2,
                    child: ListView.builder(
                      controller: orderRowsScrollController,
                      itemCount: orderController.orderDataList.length + 1,
                      itemBuilder: (context, index) {
                        if (index < orderController.orderDataList.length) {
                          final customerData =
                              orderController.orderDataList[index];
                          return _buildOrderRow(customerData, context, index);
                        } else {
                          return _buildPageChanger(context, orderController);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildCustomerDetails(
    CustomerData customerData, BuildContext context, int index) {
  return GestureDetector(
    onTap: () => {},
    child: Container(
      decoration: BoxDecoration(
        color: index.isEven ? const Color(0xFFF8FAFC) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
        ),
      ),
      height: 80,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          ClipOval(
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Image.network(
                '${ApiConstants.baseUrl}uploads/${customerData.imageUrl}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  customerData.businessName,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins_Regular',
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customerData.fullname,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Poppins_Regular',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customerData.email,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Poppins_Regular',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOrderRow(
    CustomerData customerData, BuildContext context, int index) {
  double rowHeight = 80;

  return Container(
    decoration: BoxDecoration(
      color: index.isEven ? const Color(0xFFF8FAFC) : Colors.white,
      border: const Border(
        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
      ),
    ),
    height: rowHeight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: _buildOrderNumber(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 3, child: _buildOrderCreatedDate(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 3, child: _buildOrderDueDate(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 2, child: _buildOrderDays(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 3, child: _buildOrderPrice(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 3, child: _buildInvoiceNumber(customerData, context)),
        const SizedBox(width: 5),
        Expanded(flex: 4, child: _buildOrderStatus(customerData, context)),
        const SizedBox(width: 5),
        Expanded(
            flex: 3,
            child: _buildPaymentCollectionButton(customerData, context)),
      ],
    ),
  );
}

Widget _buildOrderNumber(CustomerData customerData, BuildContext context) {
  return Center(
      child: _buildRegularText(
    customerData.orderId,
    context,
    maxLines: 1,
  ));
}

Widget _buildOrderCreatedDate(CustomerData customerData, BuildContext context) {
  return Center(
    child: _buildRegularText(
      customerData.orderCreatAt != null &&
              customerData.orderCreatAt.toString().isNotEmpty
          ? TimeUtils.formatTimeInZone(
              DateTime.parse(customerData.orderCreatAt.toString()),
              format: 'dd-MM-yyyy',
            )
          : 'N/A',
      context,
      maxLines: 1,
    ),
  );
}

Widget _buildOrderDueDate(CustomerData customerData, BuildContext context) {
  String dueDate = 'N/A';

  if (customerData.orderCreatAt != null &&
      customerData.orderCreatAt.toString().isNotEmpty) {
    try {
      DateTime orderDate = DateTime.parse(customerData.orderCreatAt.toString());

      DateTime dueDateTime =
          orderDate.add(Duration(days: customerData.creditPeriod ?? 0));

      dueDate = TimeUtils.formatTimeInZone(
        dueDateTime,
        format: 'dd-MM-yyyy',
      );
    } catch (e) {
      debugPrint('Error parsing order dueDate: $e');
    }
  }

  return Center(
    child: _buildRegularText(
      dueDate,
      context,
      maxLines: 1,
    ),
  );
}

Widget _buildOrderDays(CustomerData customerData, BuildContext context) {
  DateTime orderCreatedDate = NKDateUtils.formatStringUTCDateTime(
    customerData.orderCreatAt.toString(),
  );
  DateTime currentDate = DateTime.now();
  int daysDifference = currentDate.difference(orderCreatedDate).inDays;
  return Center(
    child: _buildRegularText('$daysDifference', context, maxLines: 1),
  );
}

Widget _buildOrderPrice(CustomerData customerData, BuildContext context) {
  return Center(
    child: _buildRegularText(formatAmount(customerData.orderTotal), context,
        fontWeight: FontWeight.w600, maxLines: 1),
  );
}

Widget _buildRegularText(
  String label,
  BuildContext context, {
  FontWeight fontWeight = FontWeight.normal,
  TextOverflow overflow = TextOverflow.ellipsis,
  int maxLines = 1,
}) {
  return Text(
    label,
    style: TextStyle(
      color: const Color(0xFF0F172A),
      fontFamily: 'Poppins_Regular',
      fontSize: 12,
      fontWeight:
          fontWeight == FontWeight.normal ? FontWeight.w600 : fontWeight,
    ),
    maxLines: maxLines,
    overflow: overflow,
  );
}

Widget _buildOrderStatus(CustomerData customerData, BuildContext context) {
  final orderStatus = OrderHandlingClass.fromType(customerData.orderStatus);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: orderStatus.statusBgColor,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: orderStatus.statusDotColor.withOpacity(0.35)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                content: orderStatus.name.tr,
                color: orderStatus.statusTextColor,
                textAlign: TextAlign.center,
                fontSize: 10,
                overflow: TextOverflow.ellipsis,
                maxLine: 1,
                fontWeight: FontWeight.w700,
              ),
              if (customerData.orderStatus == 2 &&
                  customerData.deliveryDate != null) ...[
                Text(
                  customerData.deliveryDate != null
                      ? TimeUtils.formatTimeInZone(
                          customerData.deliveryDate!,
                          format: 'dd/MM/yyyy hh:mm a',
                        )
                      : 'N/A',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPaymentCollectionButton(
    CustomerData customerData, BuildContext context) {
  final subscriptionController = Get.find<SubscriptionController>();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. The Collect Payment Button
        InkResponse(
          onTap: () {
            if (subscriptionController.appPaymentCollection.value == "true") {
              pendingPaymentCollectionDialog(
                context,
                customerData.customerId,
                customerEmail: customerData.email,
                customerMobile: customerData.mobileno,
              );
            } else {
              showUpgradePlanDialog(context);
            }
          },
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Collect Payment'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'Poppins_Regular',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),

        if ((customerData.hasActiveLink ?? 0) != 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFF16A34A).withOpacity(0.35)),
            ),
            child: const Text(
              'Payment Link Sent',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 9,
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildInvoiceNumber(CustomerData customerData, BuildContext context) {
  return Center(
      child: InkWell(
    onTap: () {
      showInvoicePreviewOnline(
        context,
        customerData.orderId,
      );
    },
    child: Text(
      customerData.invoiceId,
      style: TextStyle(
        color: primaryColor,
        fontFamily: 'Poppins_Regular',
        fontWeight: FontWeight.w700,
        fontSize: 11.5,
        decoration: TextDecoration.underline,
        decorationColor: primaryColor.withOpacity(0.4),
      ),
      maxLines: 1,
    ),
  ));
}

Widget _buildPageChanger(
    BuildContext context, PendingPaymentController totalValuesController) {
  return Container(
    height: 58,
    decoration: const BoxDecoration(
      color: Color(0xFFF8FAFC),
      border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.6)),
    ),
    child: Padding(
      padding: EdgeInsets.only(
          top: 10, bottom: 10, right: MediaQuery.of(context).size.width * 0.39),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          if (totalValuesController.selectedTabIndex.value == 0)
            Text(
              'Total:   ${formatAmount(totalValuesController.totalAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 1)
            Text(
              'Total:   ${formatAmount(totalValuesController.nearlyDueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 2)
            Text(
              'Total:   ${formatAmount(totalValuesController.dueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 3)
            Text(
              'Total:   ${formatAmount(totalValuesController.overdueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            )
        ],
      ),
    ),
  );
}
