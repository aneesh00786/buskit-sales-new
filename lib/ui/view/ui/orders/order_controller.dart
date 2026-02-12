// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class OrderController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  RxList<OrderData> orderDataList = <OrderData>[].obs;
  OrderProcessInvoiceData orderProcessInvoiceData = OrderProcessInvoiceData();
  SpecificOrderData fetchSpecificOrderData = SpecificOrderData();
  RxInt selectedTabIndex = 0.obs;
  RxInt selectedStatusCountIndex = 11.obs;
  SearchModel searchData = SearchModel();

  RxInt offlineOrderCount = 0.obs;

  RxInt receivedCount = 0.obs;
  RxInt approvalCount = 0.obs;
  RxInt quickSaleCount = 0.obs;
  RxInt processingCount = 0.obs;
  RxInt packedCount = 0.obs;
  RxInt deliveredCount = 0.obs;
  RxInt rejectedCount = 0.obs;
  RxBool isCountLoading = true.obs;
  var currentPage = 1.obs;
  var totalPages = 0.obs;
  RxBool isOrderLoading = false.obs;

  RxBool hasOfflineOrders = false.obs;
   RxBool isButtonActionLoading = false.obs;

  final TextEditingController searchTextController = TextEditingController();
RxString searchQuery = ''.obs;
RxBool isSearching = false.obs;
RxList<OrderData> searchResults = <OrderData>[].obs;
RxBool isSearchLoading = false.obs;
Future<void> performSearch({
    required String query,
    required int status,
    int page = 1,
  }) async {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    try {
      isSearchLoading.value = true;
      isSearching.value = true;

      final response = await Dio().post(
        'https://test.thrivewoo.com/search_orders',
        data: {
          "companyId": 1,
          "status": status,
          "q": query.trim(),
          "start_date": "",
          "end_date": "",
          "limit": 100,
          "page": page,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> rawList = response.data['data'];
        searchResults.assignAll(
          rawList.map((json) => OrderData.fromJson(json)).toList(),
        );
      } else {
        searchResults.clear();
      }
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
      Get.snackbar('No Internet', 'No Internet Connection. Please check your netwrok.',colorText: Colors.white,backgroundColor: Colors.red);
    } finally {
      isSearchLoading.value = false;
    }
  }

void clearSearch() {
  searchTextController.clear();
  searchQuery.value = '';
  isSearching.value = false;
  searchResults.clear();
}

  Future<void> loadOrderCountData() async {
    isCountLoading(true);
    try {
      var notificationData =
          await Get.find<NotificationController>().loadNotificationData();
      offlineOrderCount.value = offlineOrders.length;
      if (notificationData.mainNotification != null) {
        var mainNotification = notificationData.mainNotification!;
        receivedCount.value = mainNotification.recentOrders ?? 0;
        approvalCount.value = mainNotification.waitingForApproval ?? 0;
        quickSaleCount.value = mainNotification.quickSale ?? 0;
        processingCount.value = mainNotification.processingOrders ?? 0;
        packedCount.value = mainNotification.packedAndReadyForDelivery ?? 0;
        deliveredCount.value = 0;
        rejectedCount.value = 0;
      }
    } catch (e) {
      //
    } finally {
      isCountLoading(false);
    }
  }

  Future<List<OrderData>> loadOrderData(
      {required int selectedIndex, bool hasOfflineOrders = false}) async {
    orderDataList.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderDataList.clear();
    });
    isOrderLoading.value = true;

    if (hasOfflineOrders) {
      switch (selectedIndex) {
        case 0:
          break;
        case 1:
          selectedStatusCountIndex.value = 11;
          break;
        case 2:
          selectedStatusCountIndex.value = 12;
          break;
        case 3:
          selectedStatusCountIndex.value = 14;
          break;
        case 4:
          selectedStatusCountIndex.value = 5;
          break;
        case 5:
          selectedStatusCountIndex.value = 1;
          break;
        case 6:
          selectedStatusCountIndex.value = 2;
          break;
        case 7:
          selectedStatusCountIndex.value = 13;
          break;
        default:
          selectedStatusCountIndex.value = 11;
      }
    } else {
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
    }

    try {
      var data = await ApiWorker().getRecentOrdersData(
        searchModel: searchData,
        orderStatus: selectedStatusCountIndex.value,
        page: currentPage.value,
        isLogin: false,
      );

      if (data.data == null || data.data!.isEmpty) {
        orderDataList.clear();
      } else {
        orderDataList.assignAll(data.data!);

        if (data.pagination != null && data.pagination!.totalPages != null) {
          totalPages.value = data.pagination!.totalPages!.toInt();
        } else {
          totalPages.value = 1;
        }
      }
    } catch (e) {
      isOrderLoading.value = false;
    } finally {
      isOrderLoading.value = false;
    }

    return orderDataList;
  }

  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchData.startDate = NKDateUtils.apiDayFormat(startDate);
      searchData.endDate = NKDateUtils.apiDayFormat(endDate);
    } else {
      searchData.startDate = "";
      searchData.endDate = "";
    }
    loadOrderData(selectedIndex: selectedTabIndex.value);
    refresh();
  }

  void updateTabIndex(int newIndex, {bool hasOfflineOrders = false}) {
    currentPage.value = 1;
    selectedTabIndex.value = newIndex;
    clearSearch();
    loadOrderCountData();
    loadOrderData(selectedIndex: newIndex, hasOfflineOrders: hasOfflineOrders);
  }

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

    var data = await _apiWorker.getOrderProcessInvoiceData(
      orderId: orderId,
      orderStatus: orderStatus,
    );
    if (data.data.isNotEmpty) {
      orderProcessInvoiceData = data.data.first;
    }

    isLoading(false);
    return orderProcessInvoiceData;
  }

  Future<SpecificOrderData?> loadSpecificOrderInvoiceData({
    required String orderId,
  }) async {
    isLoading(true);

    var data = await ApiWorker().fetchSpecificOrderInvoice(
      orderId,
    );

    if (data.data != null) {
      fetchSpecificOrderData = data.data ?? SpecificOrderData();
    }

    isLoading(false);
    return fetchSpecificOrderData;
  }

  Future<OrderProcessInvoiceData?> loadOrderApprovalInvoiceData({
    required String orderId,
  }) async {
    isLoading(true);

    var data = await _apiWorker.loadWaitingForApproval(
      orderId: orderId,
    );

    if (data.data.isNotEmpty) {
      orderProcessInvoiceData = data.data.first;
    }

    isLoading(false);
    return orderProcessInvoiceData;
  }

  void setTotalPages(int total) {
    totalPages.value = total;
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadOrderData(
          selectedIndex: hasOfflineOrders.value
              ? selectedTabIndex.value - 1
              : selectedTabIndex.value);
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadOrderData(
          selectedIndex: hasOfflineOrders.value
              ? selectedTabIndex.value - 1
              : selectedTabIndex.value);
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadOrderData(
          selectedIndex: hasOfflineOrders.value
              ? selectedTabIndex.value - 1
              : selectedTabIndex.value);
    }
  }

  RxList<dynamic> offlineOrders = [].obs;
  RxBool isOfflineOrderLoading = false.obs;

  Future<void> loadOfflineOrders() async {
    isOfflineOrderLoading.value = true;
    var box = await Hive.openBox('offlineOrders');
    offlineOrders.value = box.values.toList();
    offlineOrderCount.value = offlineOrders.length;
    isOfflineOrderLoading.value = false;
    offlineOrders.refresh();
    offlineOrderCount.refresh();
  }

  /// Deletes an offline order by its order_id, refreshes the list and count
  Future<void> deleteOfflineOrder(String orderId) async {
    var box = await Hive.openBox('offlineOrders');
    await box.delete(orderId);
    await loadOfflineOrders();
  }

  Future<ButtonActionData?> acceptButtonAction({
    required BuildContext context,
    required String orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      isButtonActionLoading(true);

      var data = await ApiWorker().orderAccept(
        orderId: orderId,
        updatedOrders: updatedOrders,
      );

      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order Accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      isButtonActionLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept order: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }
   Future<void> sendForCustomerApprovalButtonAction({
    required BuildContext context,
    required String orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      isButtonActionLoading(true);

      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order sent for approval successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send for approval: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<ButtonActionData?> rejectButtonAction({
    required BuildContext context,
    required String orderId,
    required String reason,
  }) async {
    try {
      isButtonActionLoading(true);

      var data = await ApiWorker().orderReject(
        orderId: orderId,
        rejectReason: reason,
      );

      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order rejected successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject order: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }
    Future<void> addToPackedAndReady({
    required BuildContext context,
    required String orderId,
    required String cartid,
  }) async {
    try {
      await ApiWorker().packedAndReadyAdd(cartId: cartid, orderId: orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Packed and Ready successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to Packed and Ready: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<ButtonActionData?> deliverButtonAction({
    required BuildContext context,
    required String orderId,
  }) async {
    try {
      isButtonActionLoading(true);

      var data = await ApiWorker().orderDeliver(
        orderId: orderId,
      );

      isButtonActionLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order delivered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return data.data!.first;
    } catch (e) {
      isButtonActionLoading(false);

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
