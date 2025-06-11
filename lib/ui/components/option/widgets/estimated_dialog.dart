// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/nodata_dialog.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void showEstimatesDialog(
    BuildContext context,
    DashboardProvider provider,
    OrderStatus selectedOrderStatus,
    String orderType,
    bool isDraft,
    ProductsController productsController,
    CustomerAndOrderController customerOrderController,
    HomeController? homeController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (contoext, setState) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return noDataFoundWidget(orderType);
                        } else {
                          final orders = snapshot.data?.data ?? [];

                          final filteredOrders = orders.where((order) {
                            return order.orderStatus ==
                                selectedOrderStatus.type;
                          }).toList();

                          return LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double availableWidth = constraints.maxWidth;
                              double fontSize = availableWidth * 0.017;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 9;

                              return Stack(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: filteredOrders.length < 11
                                        ? null
                                        : fullScreenHeight(context) * 0.7,
                                    child: ScrollbarTheme(
                                      data: const ScrollbarThemeData(
                                        minThumbLength: 150,
                                        thickness: WidgetStatePropertyAll(5),
                                        thumbColor:
                                            WidgetStatePropertyAll(Colors.blue),
                                      ),
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        child: SingleChildScrollView(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 30.0),
                                                  child: DataTable(
                                                    dataRowHeight:
                                                        fontSize * 5.5,
                                                    headingRowHeight: 45,
                                                    columnSpacing: 10,
                                                    headingTextStyle: TextStyle(
                                                        fontSize: fontSize + 1,
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    columns: [
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            'Customer List',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            '$orderType No.',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            'Created',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            'Created By',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            'Amount',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            'Status',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Center(
                                                          child: Text(
                                                            '',
                                                          ),
                                                        ),
                                                      )),
                                                    ],
                                                    rows: filteredOrders.isEmpty
                                                        ? [
                                                            const DataRow(
                                                                cells: [
                                                                  DataCell(Text(
                                                                      'Record Not Found')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                ])
                                                          ]
                                                        : filteredOrders
                                                            .map((order) {
                                                            final customer = order
                                                                    .customer
                                                                    .isNotEmpty
                                                                ? order
                                                                    .customer[0]
                                                                : null;
                                                            return DataRow(
                                                              cells: [
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1.5,
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          radius:
                                                                              (fixedIconSize / 2) + 2,
                                                                          backgroundColor:
                                                                              const Color(0xffe6ecff),
                                                                          child: Icon(
                                                                              Icons.person,
                                                                              size: fixedIconSize,
                                                                              color: Colors.blue),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                padding),
                                                                        Flexible(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                customer != null ? customer.businessName : 'N/A',
                                                                                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                customer != null ? customer.fullName : 'N/A',
                                                                                style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.bold),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                customer != null ? customer.mobileNo : 'N/A',
                                                                                style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Text(
                                                                                customer != null ? customer.email : 'N/A',
                                                                                style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            0.9,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDetailedOrderInvoiceDialog(
                                                                          context,
                                                                          order
                                                                              .orderId,
                                                                          false,
                                                                        );
                                                                      },
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          order
                                                                              .orderId,
                                                                          style: TextStyle(
                                                                              color: primaryColor,
                                                                              fontSize: fontSize,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        // ignore: unnecessary_null_comparison
                                                                        order.orderCreatedAt !=
                                                                                null
                                                                            ? getFormattedOrderCreatAt(order.orderCreatedAt.toString())
                                                                            : 'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                        ),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        formatAmount(
                                                                            order.orderTotal),
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1.1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Color(0xffffdbb8),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(15.0)),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8.0,
                                                                              vertical: 4.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                getStatusName(order.orderStatus),
                                                                                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              if (order.orderStatus == 2 && order.deliveryDate != null) ...[
                                                                                Text(
                                                                                  NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
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
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                    SizedBox(
                                                                  width:
                                                                      flexWidth *
                                                                          0.5,
                                                                  child:
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            final cartProvider =
                                                                                Provider.of<CustomersProvider>(context, listen: false);
                                                                            customerOrderController.customerId.value =
                                                                                customer?.customerId ?? '';
                                                                            if (isDraft) {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return CartDialogue(
                                                                                    active: true,
                                                                                    cartItemCount: cartProvider.cartItemCount,
                                                                                    productsController: productsController,
                                                                                    customerOrderController: customerOrderController,
                                                                                    isDashboard: true,
                                                                                    customerId: customer?.customerId ?? '',
                                                                                    onContinueShopping: () {
                                                                                      Future.delayed(const Duration(milliseconds: 300), () {
                                                                                        _initializeCustomerData(customer, productsController, customerOrderController);
                                                                                        homeController?.sidebarXController.selectIndex(2);
                                                                                        homeController?.selectedIndex.value = 2;
                                                                                        Get.to(
                                                                                            () => OrderTaking(
                                                                                                  productsController: productsController,
                                                                                                ),
                                                                                            id: 2);
                                                                                      });
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            } else {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return InvoicePreview(
                                                                                    orderId: order.orderId,
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.visibility,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                primaryColor,
                                                                          )),
                                                                )),
                                                              ],
                                                            );
                                                          }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                            dataRowHeight: 0,
                                            headingRowHeight: 45,
                                            headingRowColor:
                                                const WidgetStatePropertyAll(
                                                    primaryColor),
                                            columnSpacing: 10,
                                            headingTextStyle: TextStyle(
                                                fontSize: fontSize + 1,
                                                color: white,
                                                fontWeight: FontWeight.w700),
                                            columns: [
                                              const DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Customer List',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    '$orderType No.',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              const DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Created',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              const DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Created By',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              const DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Amount',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              const DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Status',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: SizedBox(
                                                    width: flexWidth * 0.5),
                                              )),
                                            ],
                                            rows: [
                                              DataRow(
                                                cells: [
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1.5),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 0.9),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1.1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 0.5),
                                                  ),
                                                ],
                                              )
                                            ]),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: DataTable(
                                              dataRowHeight: 0,
                                              headingRowHeight: 30,
                                              headingRowColor:
                                                  const WidgetStatePropertyAll(
                                                      primaryColor),
                                              columnSpacing: 10,
                                              headingTextStyle: TextStyle(
                                                  fontSize: fontSize + 2,
                                                  color: white,
                                                  fontWeight: FontWeight.w700),
                                              columns: [
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      'Total',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      '',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      formatAmount(
                                                          filteredOrders.fold<
                                                                  double>(
                                                              0.0,
                                                              (sum, order) =>
                                                                  sum +
                                                                  (order.orderTotal ??
                                                                      0.0))),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                              ],
                                              rows: [
                                                DataRow(
                                                  cells: [
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 4.8),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 0.4),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth * 4),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: SizedBox(
                                      height: 45,
                                      width: 45,
                                      child: Center(
                                          child:
                                              dialogCloseButton1(context, red)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _initializeCustomerData(
    CustomerDash? customer,
    ProductsController productsController,
    CustomerAndOrderController customerAndOrderController) async {
  final customerId = customer?.customerId;
  final customerName = customer?.businessName;
  final customerImage = customer?.imageUrl;
  if (customerId!.isEmpty) {
    log('Error: Customer ID is empty in CustomerDachScreen.');
    return;
  }
  customerAndOrderController.setCustomerId(customer?.customerId ?? '');
  productsController.selectedCustomerId.value = customer?.customerId ?? '';
  productsController.updateSelectedCustomer(
    name: customerName ?? '',
    imageUrl: customerImage ?? '',
    id: customerId,
  );
  log('CustomerDachScreen - Initialized Customer ID: $customerId, Name: $customerName, Image: $customerImage');
}
