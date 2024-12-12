import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  // API worker for handling network requests
  final ApiWorker _apiWorker = ApiWorker();

  // Observables for storing order data and various status counts
  RxList<OrderData> orderDataList = <OrderData>[].obs;
  OrderProcessInvoiceData orderProcessInvoiceData = OrderProcessInvoiceData();
  FetchSpecificOrderData fetchSpecificOrderData = FetchSpecificOrderData();

  // Observables to manage UI state like selected tab index and status
  RxInt selectedTabIndex = 0.obs;
  RxInt selectedStatusCountIndex = 11.obs;

  // Model to store search/filter data
  SearchModel searchData = SearchModel();

  // Order status counts (Observables)
  RxInt receivedCount = 0.obs;
  RxInt approvalCount = 0.obs;
  RxInt quickSaleCount = 0.obs;
  RxInt processingCount = 0.obs;
  RxInt packedCount = 0.obs;
  RxInt deliveredCount = 0.obs;
  RxInt rejectedCount = 0.obs;

  // Loading status for order count
  RxBool isCountLoading = true.obs;

  // Function to load order count data based on status
  Future<void> loadOrderCountData() async {
    var response = await _apiWorker.getOrderCountData(
      searchModel: searchData,
    );

    if (response != null && response.data != null) {
      var orderCountDataList = response.data;

      // Update counts for each order status
      for (var countData in orderCountDataList) {
        switch (countData.status) {
          case 'latest':
            receivedCount.value = countData.count;
            break;
          case 'approval':
            approvalCount.value = countData.count;
            break;
          case 'quickSale':
            quickSaleCount.value = countData.count;
            break;
          case 'proccessing':
            processingCount.value = countData.count;
            break;
          case 'packed':
            packedCount.value = countData.count;
            break;
          case 'delivers':
            deliveredCount.value = countData.count;
            break;
          case 'rejected':
            rejectedCount.value = countData.count;
            break;
          default:
            break;
        }
      }
    }
    isCountLoading(false);
  }
  Future<List<OrderData>> loadOrderData({required int selectedIndex}) async {
    orderDataList.clear();
    switch (selectedIndex) {
      case 0:
        selectedStatusCountIndex.value = 11;
        break;
      case 1:
        selectedStatusCountIndex.value = 12;
        break;
      case 2:
        selectedStatusCountIndex.value = 14;
        break;
      case 3:
        selectedStatusCountIndex.value = 5;
        break;
      case 4:
        selectedStatusCountIndex.value = 1;
        break;
      case 5:
        selectedStatusCountIndex.value = 2;
        break;
      case 6:
        selectedStatusCountIndex.value = 13;
        break;
      default:
        selectedStatusCountIndex.value = 11;
    }

    // Fetch recent orders data based on status
    var data = await _apiWorker.getRecentOrdersData(
      searchModel: searchData,
      order_status: selectedStatusCountIndex.value,
    );
    orderDataList.assignAll(data.data!); // Assign new data
    return data.data!;
  }

  // Function to update the date range for customer visits and reload order data
  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchData.startDate = NKDateUtils.apiDayFormat(startDate);
      searchData.endDate = NKDateUtils.apiDayFormat(endDate);
    } else {
      searchData.startDate = "";
      searchData.endDate = "";
    }
    loadOrderData(selectedIndex: selectedTabIndex.value); // Reload orders
    refresh();
    print('444+${searchData.startDate}');
    print('444++${searchData.endDate}');
  }

  // Function to update the selected tab and load respective data
  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
    loadOrderCountData(); // Reload counts based on new tab
    loadOrderData(selectedIndex: newIndex); // Load corresponding order data
  }

  // Function to create a widget for displaying order status with color
  Widget orderStatusWidget(String status, Color color) {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: MyRegularText(
        label: status,
      ),
    );
  }

  RxBool isLoading = false.obs;
  Future<OrderProcessInvoiceData?> loadOrderProcessInvoiceData({
    required String orderId,
    required int orderStatus,
  }) async {
    isLoading(true);
    log("Loading Order Process Invoice Data");

    var data = await _apiWorker.getOrderProcessInvoiceData(
      orderId: orderId,
      orderStatus: orderStatus,
    );

    // Update process invoice data if response is valid
    if (data.data != null && data.data!.isNotEmpty) {
      orderProcessInvoiceData = data.data!.first;
    }

    isLoading(false); // Stop loading
    return orderProcessInvoiceData;
  }

  // Function to load specific invoice data by order ID
  Future<FetchSpecificOrderData?> loadSpecificOrderInvoiceData({
    required String orderId,
  }) async {
    isLoading(true); // Start loading
    log("Loading Specific Order Invoice Data");

    var data = await _apiWorker.fetchSpecificOrder(
      orderId: orderId,
    );

    if (data.data != null) {
      fetchSpecificOrderData = data.data!;
    }

    isLoading(false); // Stop loading
    return fetchSpecificOrderData;
  }

  // Function to load approval invoice data for an order
  Future<OrderProcessInvoiceData?> loadOrderApprovalInvoiceData({
    required String orderId,
  }) async {
    isLoading(true); // Start loading
    log("Loading Waiting for Approval Invoice Data");

    var data = await _apiWorker.loadWaitingForApproval(
      orderId: orderId,
    );

    if (data.data.isNotEmpty) {
      orderProcessInvoiceData = data.data.first;
    }

    isLoading(false); // Stop loading
    return orderProcessInvoiceData;
  }

  // Loading indicator for button actions
  RxBool isButtonActionLoading = false.obs;

  // Function to handle reject button action
  Future<ButtonActionData?> rejectButtonAction({
    required BuildContext context,
    required String orderId,
    required String reason,
  }) async {
    try {
      isButtonActionLoading(true); // Start loading
      log("Reject Button Action");

      var data = await _apiWorker.orderReject(
        orderId: orderId,
        rejectReason: reason,
      );

      log("${data.message}");
      isButtonActionLoading(false); // Stop loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order rejected successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      isButtonActionLoading(false); // Stop loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject order: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  Future<ButtonActionData?> acceptButtonAction({
    required BuildContext context,
    required String orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      isButtonActionLoading(true);
      log("Accept Button Action");

      var data = await _apiWorker.orderAccept(
        orderId: orderId,
        updatedOrders: updatedOrders,
      );

      log("${data.message}");
      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order Accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      isButtonActionLoading(false);
      log('Failed to accept order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept order: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  // Function to send order for customer approval
  Future<void> sendForCustomerApprovalButtonAction({
    required BuildContext context,
    required String orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      isButtonActionLoading(true);
      log("Send for customer approval Button Action");

      var response = await _apiWorker.sendMail(orderId: orderId, updatedOrders: updatedOrders);

      log("${response.statusMessage}");
      isButtonActionLoading(false);

      // Show success SnackBar if the mail was sent successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order sent for approval successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      isButtonActionLoading(false); // Stop loading

      log('Failed to send for approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send for approval: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to add order to "Packed and Ready" status
  Future<void> addToPackedAndReady({
    required BuildContext context,
    required String orderId,
    required String cartid,
  }) async {
    log("Add to Packed and ready button action");

    try {
      await _apiWorker.packedAndReadyAdd(cartId: cartid, orderId: orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Packed and Ready successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to Packed and Ready: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to handle the deliver button action
  Future<ButtonActionData?> deliverButtonAction({
    required BuildContext context,
    required String orderId,
  }) async {
    try {
      isButtonActionLoading(true); // Start loading
      log("Deliver Button Action");

      var data = await _apiWorker.orderDeliver(
        orderId: orderId,
      );

      log("${data.message}");
      isButtonActionLoading(false); // Stop loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order delivered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      log("$e");
      isButtonActionLoading(false); // Stop loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to deliver order: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }
}
