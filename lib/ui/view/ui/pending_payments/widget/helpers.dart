import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
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
      color: primaryColor,
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveInfo.isMobileDimension(context) ? 2 : 4),
        child: Row(
          children: [
            SizedBox(
              width: 205,
              child: Column(
                children: [
                  Expanded(child: _buildHeaderText("Customer List", fontSize)),
                  const SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
            Expanded(
              child: ScrollbarTheme(
                data: const ScrollbarThemeData(
                    radius: Radius.circular(10),
                    thumbColor: WidgetStatePropertyAll(Colors.cyanAccent)),
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
                                        "Order No.", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child: _buildHeaderText("Date", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child:
                                        _buildHeaderText("Due Date", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 2,
                                    child: _buildHeaderText("Days", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child:
                                        _buildHeaderText("Amount", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 3,
                                    child:
                                        _buildHeaderText("Invoice", fontSize)),
                                const SizedBox(width: 5),
                                Expanded(
                                    flex: 4,
                                    child:
                                        _buildHeaderText("Status", fontSize)),
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
    ScrollController orderScrollController) {
  double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 53 : 58;
  return Align(
    alignment: FractionalOffset.topCenter,
    child: Container(
      padding: EdgeInsets.only(top: headerHeight),
      child: Row(
        children: [
          SizedBox(
            width: 210,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: orderController.orderDataList.length + 1,
                itemBuilder: (context, index) {
                  if (index < orderController.orderDataList.length) {
                    final customerData = orderController.orderDataList[index];
                    return _buildCustomerDetails(customerData, context, index);
                  } else {
                    return Container(
                      height: 58,
                      color: Colors.grey[200],
                    );
                  }
                },
              ),
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
      color: index.isEven ? Colors.grey[50] : Colors.white,
      height: 80,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          ClipOval(
            child: Container(
              height: 24,
              width: 24,
              color: Colors.grey[200],
              child: Image.network(
                '${ApiConstants.baseUrl}uploads/${customerData.imageUrl}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 30,
                    ),
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
                      color: Colors.black,
                      fontFamily: 'Poppins_Regular',
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customerData.fullname,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins_Regular',
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customerData.email,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins_Regular',
                    fontSize: 10,
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
    color: index.isEven ? Colors.grey[50] : Colors.white,
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
      NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(
        customerData.orderCreatAt.toString(),
      )),
      context,
      maxLines: 1,
    ),
  );
}

Widget _buildOrderDueDate(CustomerData customerData, BuildContext context) {
  int? creditPeriod = customerData.creditPeriod;
  String? orderCreatAt = customerData.orderCreatAt.toString();
  String? dueDate;

  DateTime orderDate = DateTime.parse(orderCreatAt);

  DateTime dueDateTime = orderDate.add(Duration(days: creditPeriod));

  dueDate = NKDateUtils.commonDayFormat2(dueDateTime);

  return Center(
    child: _buildRegularText(
      dueDate.toString(),
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
      color: Colors.black,
      fontFamily: 'Poppins_Regular',
      fontSize: 10,
      fontWeight: fontWeight,
    ),
    maxLines: maxLines,
    overflow: overflow,
  );
}

Widget _buildOrderStatus(CustomerData customerData, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xffffdbb8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                content:
                    OrderHandlingClass.fromType(customerData.orderStatus).name,
                textAlign: TextAlign.center,
                fontSize: 10,
                overflow: TextOverflow.ellipsis,
                maxLine: 1,
                fontWeight: FontWeight.w600,
              ),
              if (customerData.orderStatus == 2 &&
                  customerData.deliveryDate != null) ...[
                Text(
                  NKDateUtils.commonFullDateTimeFormat(
                      NKDateUtils.formatStringUTCDateTime(
                          customerData.deliveryDate!.toIso8601String())),
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
    child: InkResponse(
      onTap: () {
        if (subscriptionController.appPaymentCollection.value == "true") {
          pendingPaymentCollectionDialog(context, customerData.customerId);
        } else {
          showUpgradePlanDialog(context);
        }
      },
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xff5bc0de),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              'Collect Payment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
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
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      maxLines: 1,
    ),
  ));
}

Widget _buildPageChanger(
    BuildContext context, PendingPaymentController totalValuesController) {
  return Container(
    height: 58,
    color: Colors.grey[200],
    child: Padding(
      padding: EdgeInsets.only(
          top: 10, bottom: 10, right: MediaQuery.of(context).size.width * 0.39),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (totalValuesController.orderDataList.length > 10)
            PaginationWidget(),
          const Spacer(),
          if (totalValuesController.selectedTabIndex.value == 0)
            Text(
              'Total:   ${formatAmount(totalValuesController.totalAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 1)
            Text(
              'Total:   ${formatAmount(totalValuesController.nearlyDueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 2)
            Text(
              'Total:   ${formatAmount(totalValuesController.dueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (totalValuesController.selectedTabIndex.value == 3)
            Text(
              'Total:   ${formatAmount(totalValuesController.overdueAmount.value)}  ',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
        ],
      ),
    ),
  );
}
