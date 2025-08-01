import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/connectivity/connectivity_cheker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../csord_model/customers_orders_model.dart';

class CustomersProvider with ChangeNotifier {
  final ApiService _apiService;
  final Logger _logger;
  List<YearList> get yearList => _yearList;
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  CustomersProvider({
    required ApiService apiService,
    required Logger logger,
  })  : _apiService = apiService,
        _logger = logger {
    fetchCustomerData();
  }
  String _errorMessage = '';
  bool _isLoading = false;
  Future<CustomerResponseModelxx>? _customersFuture;
  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  String _selectedStartDate = '';
  String _selectedEndDate = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  File? get imageFile => _imageFile;
  int _currentPage = 1;
  int _totalPages = 1;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Future<CustomerResponseModelxx>? get customersFuture => _customersFuture;
  FilterDateEnum get selectedFilter => _selectedFilter;

  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
  String get searchCustomerName => _searchCustomerName;

  final TextEditingController searchController = TextEditingController();
  var _searchCustomerName = '';
  String get selectedCustomerName => _searchCustomerName;

  Future<ApiResponseModel>? _customersDashFuture;

  Future<ApiResponseModel>? get customersDashFuture => _customersDashFuture;

  Future<CustomerTotalSaleResponse>? _customerTotalSaleResponseFuture;

  Future<CustomerRevenueResponse>? _customerRevenueResponseFuture;

  Future<CustomerTotalSaleResponse>? get customerTotalSaleResponseFuture =>
      _customerTotalSaleResponseFuture;

  Future<CustomerRevenueResponse>? get customerRevenueResponseFuture =>
      _customerRevenueResponseFuture;

  Future<ApiResponsees>? _countFuture;

  Future<ApiResponsees>? get countFuture => _countFuture;
  int? get selectedYear => _selectedYear;
  final List<RecentOrder> _selectedOrders = [];
  List<RecentOrder> get selectedOrders => _selectedOrders;
  // ignore: unused_field
  List<CustomerModelxx> get customers => _customers;
  List<CustomerModelxx> _customers = [];
  List<CustomerModelxx> _filteredCustomers = [];
  List<OrderTotalxx> _orderTotalList = [];
  List<YearsListOfAll> _yearsListOfAllList = [];

  List<OrderTotalxx> get orderTotalList => _orderTotalList;
  List<YearsListOfAll> get yearsListOfAllList => _yearsListOfAllList;

  List<CustomerModelxx> get filteredCustomers => _filteredCustomers;

  /// Gets the current page of customers for display
  List<CustomerModelxx> get currentPageCustomers => getCurrentPageCustomers();
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Future<ProductResponse>? _productResponse;
  Future<ProductResponse>? get productResponse => _productResponse;
  int cartItemCount = 0;
  List<BarChartGroupData> barGroups = [];
  Future<OrderResponse>? _orderResponse;
  Future<OrderResponse>? get orderResponse => _orderResponse;
  Future<CustomerResponse>? _customerResponse;
  Future<CustomerResponse>? get customerResponse => _customerResponse;
  void setCurrentMonthDates() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateFormat = DateFormat('yyyy-MM-dd');
    _selectedStartDate = dateFormat.format(firstDayOfMonth);
    _selectedEndDate = dateFormat.format(lastDayOfMonth);
  }

  void createBarGroups({
    required List<CategoryPerformance> categoryPerformance,
    required List<ValueTargetDatum> valuePerformance,
    required String targetType,
    required String staffProjection,
  }) {
    log('This function has called');
    barGroups = targetType == '0'
        ? valuePerformance.asMap().entries.map((entry) {
            int index = entry.key;
            ValueTargetDatum perf = entry.value;
            num target = perf.actualTarget ?? 0.0;
            num projection = perf.actualProjection ?? 0.0;
            num actual = perf.actualSales ?? 0.0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: target.toDouble(),
                  color: const Color(0xff3b6491),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                if (staffProjection == "1")
                  BarChartRodData(
                    toY: projection.toDouble(),
                    color: const Color(0xff15396a),
                    width: 8,
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                BarChartRodData(
                  toY: actual.toDouble(),
                  color: const Color(0xff7a8f3d),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ],
            );
          }).toList()
        : categoryPerformance.asMap().entries.map((entry) {
            int index = entry.key;
            CategoryPerformance perf = entry.value;
            num target = perf.actualTarget ?? 0.0;
            num projection = perf.actualProjection ?? 0.0;
            num actual = num.parse(perf.actualSales.toString());

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: target.toDouble(),
                  color: const Color(0xff3b6491),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                if (staffProjection == "1")
                  BarChartRodData(
                    toY: projection.toDouble(),
                    color: const Color(0xff15396a),
                    width: 8,
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                BarChartRodData(
                  toY: actual.toDouble(),
                  color: const Color(0xff7a8f3d),
                  width: 8,
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ],
            );
          }).toList();
  }

  Future<int> getCartItemCounts(String customerId) async {
    try {
      log("Customer Id inside getCartItemCounts: $customerId");
      final cartItems = await CartDatabaseManager().getCartItems(customerId);
      log("Cart items inside count : ${cartItems.map((e) => e.toJson()).toList()}");
      final count = cartItems.length;
      cartItemCount = count;
      notifyListeners();
      log('Cart count calculated for customer $customerId: $cartItemCount');
      updateCartCount(customerId);
      return cartItemCount;
    } catch (e) {
      log('Error calculating cart item counts for customer $customerId: $e');
      return 0;
    }
  }

  Future<void> updateCartCount(String customerId) async {
    try {
      log("Customer Id inside updateCartCount: $customerId");
      final cartItems = await CartDatabaseManager().getCartItems(customerId);
      cartItemCount = cartItems.length;
      log('The cart item Count $cartItemCount');
      notifyListeners();
      log('Cart count updated for customer $customerId: $cartItemCount');
    } catch (e) {
      log('Error updating cart count for customer $customerId: $e');
    }
  }

  Future<void> fetchChartCategoryPerformance(
      dynamic customerId, dynamic catId, dynamic selectedYearCategory) async {
    //comeback
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    final firstDayOfYear = DateTime(now.year, 1, 1);
    final lastDayOfYear = DateTime(now.year, 12, 31);

    try {
      _productResponse = _apiService.fetchCustomerDashboardCartData(
        customerId: customerId,
        catId: catId,
        selectedYearCategory: selectedYearCategory,
        startDate: dateFormat.format(firstDayOfYear),
        endDate: dateFormat.format(lastDayOfYear),
      );
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  set currentPage(int newPage) {
    if (newPage != _currentPage) {
      _currentPage = newPage;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) async {
    log("updateSearchQuery query : $query");
    _searchCustomerName = query;
    _currentPage = 1;
    _errorMessage = ''; // Clear previous error messages

    try {
      if (query.isEmpty) {
        _filteredCustomers.clear();
        // When clearing search, reload cached data if offline
        bool isOnline = await ConnectivityService().isOnline();
        if (!isOnline) {
          await loadCachedDataForCurrentPage();
        } else {
          await fetchCustomerData();
        }
      } else {
        _filteredCustomers.clear();
        notifyListeners();

        // Check if offline and perform local search
        bool isOnline = await ConnectivityService().isOnline();
        if (!isOnline) {
          await performOfflineSearch(query);
        } else {
          await fetchCustomerData();
        }
      }
    } catch (e) {
      log("Error fetching customer data: $e");
    } finally {
      notifyListeners();
    }
  }

  /// Performs offline search by searching through all cached customer data
  Future<void> performOfflineSearch(String searchQuery) async {
    log('[performOfflineSearch] Starting offline search for: $searchQuery');

    try {
      _isLoading = true;
      notifyListeners();

      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      final customerBox = Hive.box('customerBox');
      final List<CustomerModelxx> allCachedCustomers = [];

      // Search through all cached pages
      int page = 1;
      bool hasMoreData = true;

      while (hasMoreData) {
        final cacheKey = '${companyId}_customer_list_$page';
        final cachedData = customerBox.get(cacheKey);

        if (cachedData != null) {
          try {
            final safeMap =
                jsonDecode(jsonEncode(cachedData)) as Map<String, dynamic>;
            final response = CustomerResponseModelxx.fromJson(safeMap);
            allCachedCustomers.addAll(response.data);
            log('[performOfflineSearch] Loaded ${response.data.length} customers from page $page');

            // Check if there are more pages
            if (page >= response.pagination.totalPages) {
              hasMoreData = false;
            } else {
              page++;
            }
          } catch (e) {
            log('[performOfflineSearch] Error parsing cached data for page $page: $e');
            hasMoreData = false;
          }
        } else {
          log('[performOfflineSearch] No cached data for page $page, stopping search');
          hasMoreData = false;
        }
      }

      // Perform local search on all cached customers
      final List<CustomerModelxx> searchResults =
          allCachedCustomers.where((customer) {
        final query = searchQuery.toLowerCase();
        return customer.businessName.toLowerCase().startsWith(query);
      }).toList();

      log('[performOfflineSearch] Found ${searchResults.length} matching customers out of ${allCachedCustomers.length} total cached customers');

      if (searchResults.isNotEmpty) {
        // Store all search results and calculate pagination
        _customers = searchResults;
        _filteredCustomers = searchResults;

        // Calculate total pages based on search results (assuming 10 items per page)
        const int itemsPerPage = 10;
        _totalPages = (searchResults.length / itemsPerPage).ceil();
        _currentPage = 1; // Reset to first page for search results

        // Set order totals and year list from the first cached page if available
        if (allCachedCustomers.isNotEmpty) {
          final firstCacheKey = '${companyId}_customer_list_1';
          final firstCachedData = customerBox.get(firstCacheKey);
          if (firstCachedData != null) {
            try {
              final safeMap = jsonDecode(jsonEncode(firstCachedData))
                  as Map<String, dynamic>;
              final response = CustomerResponseModelxx.fromJson(safeMap);
              setOrderTotal(response.orderTotal);
              setYearList(response.yearsListOfAll);
            } catch (e) {
              log('[performOfflineSearch] Error loading order totals and year list: $e');
            }
          }
        }

        _errorMessage = '';
      } else {
        _filteredCustomers = [];
        _errorMessage =
            'No customers found matching "$searchQuery" in offline data.';
      }
    } catch (e) {
      log('[performOfflineSearch] Error during offline search: $e');
      _errorMessage = 'Error performing offline search: $e';
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads cached data for the current page when offline
  Future<void> loadCachedDataForCurrentPage() async {
    log('[loadCachedDataForCurrentPage] Loading cached data for page $_currentPage');

    try {
      _isLoading = true;
      notifyListeners();

      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      final customerBox = Hive.box('customerBox');
      final cacheKey = '${companyId}_customer_list_$_currentPage';

      final cachedData = customerBox.get(cacheKey);
      if (cachedData != null) {
        try {
          final safeMap =
              jsonDecode(jsonEncode(cachedData)) as Map<String, dynamic>;
          final response = CustomerResponseModelxx.fromJson(safeMap);

          log('[loadCachedDataForCurrentPage] Loaded ${response.data.length} customers from page $_currentPage');
          setCustomers(response.data, response.pagination.totalPages);
          setOrderTotal(response.orderTotal);
          setYearList(response.yearsListOfAll);
          _errorMessage = '';
        } catch (e) {
          log('[loadCachedDataForCurrentPage] Error parsing cached data: $e');
          _filteredCustomers = [];
          _errorMessage = 'Corrupted offline data for this page.';
        }
      } else {
        log('[loadCachedDataForCurrentPage] No cached data for page $_currentPage');
        _filteredCustomers = [];
        _errorMessage = 'No offline data for this page.';
      }
    } catch (e) {
      log('[loadCachedDataForCurrentPage] Error loading cached data: $e');
      _errorMessage = 'Error loading offline data: $e';
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCustomers(List<CustomerModelxx> customers, int totalPages) {
    _customers = customers;
    _filteredCustomers = customers;
    _totalPages = totalPages;
    notifyListeners();
  }

  /// Gets the current page of customers for display (handles pagination for search results)
  List<CustomerModelxx> getCurrentPageCustomers() {
    if (_searchCustomerName.isNotEmpty) {
      // For search results, implement pagination
      const int itemsPerPage = 10;
      final startIndex = (_currentPage - 1) * itemsPerPage;
      final endIndex = startIndex + itemsPerPage;

      log('[getCurrentPageCustomers] Search mode: $_searchCustomerName, Page: $_currentPage, Total customers: ${_customers.length}, Start: $startIndex, End: $endIndex');

      if (startIndex < _customers.length) {
        final result = _customers.sublist(startIndex,
            endIndex > _customers.length ? _customers.length : endIndex);
        log('[getCurrentPageCustomers] Returning ${result.length} customers for current page');
        return result;
      } else {
        log('[getCurrentPageCustomers] No customers for current page');
        return [];
      }
    } else {
      // For normal browsing, return all filtered customers
      log('[getCurrentPageCustomers] Normal mode: returning ${_filteredCustomers.length} customers');
      return _filteredCustomers;
    }
  }

  void setOrderTotal(List<OrderTotalxx> orderTotals) {
    _orderTotalList = orderTotals;
    notifyListeners();
  }

  void setYearList(List<YearsListOfAll> yearsListOfAll) {
    _yearsListOfAllList = yearsListOfAll;
  }

  Future<void> fetchCustomerDashboardCountData(
    String customerId,
  ) async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final lastDayOfYear = DateTime(now.year, 12, 31);
    try {
      _countFuture = _apiService.fetchOrderCount(
        customerId,
        dateFormat.format(firstDayOfYear),
        dateFormat.format(lastDayOfYear),
      );
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> pickImage(gallery) async {
    final pickedFile = await _picker.pickImage(source: gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> addLead({
    required CustomerDashMo admin,
    required String salsmanId,
  }) async {
    try {
      await _apiService
          .addLead(
              model: admin,
              adminProfilePicture: imageFile!,
              salesmanId: salsmanId)
          .then((value) => fetchCustomerData());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
  }

  Future<void> addCustomer({
    required Map<String, dynamic> admin,
    required String salsmanId,
  }) async {
    try {
      await _apiService
          .addCustomer(
              model: admin,
              adminProfilePicture: imageFile!,
              salesmanId: salsmanId)
          .then((value) => fetchCustomerData());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    } finally {
      _imageFile = null;
    }
  }

  Future<void> fetchCustomersDataDash(String customerId) async {
    try {
      _customerResponse = _apiService.fetchOneCustomer(customerId);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchOrdersForCustomDash(OrderStatus s, String custId) async {
    log("[fetchOrdersForCustomDash]");
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, 1, 1);
      final endDate = DateTime(now.year, 12 + 1, 0);

      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      dynamic orderType;

      switch (s) {
        case OrderStatus.delivered:
          orderType = '';
        case OrderStatus.estimates:
          orderType = 7;
        case OrderStatus.preOrder:
          orderType = 0;
        case OrderStatus.draft:
          orderType = 4;
        case OrderStatus.cancelled:
          orderType = 3;
        default:
          orderType = '';
      }
      _orderResponse = Future.delayed(const Duration(milliseconds: 300), () {
        final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
        return _apiService.fetchCustomerDashOrders(
            cusId: custId,
            salesmanId: salesmanId,
            orderType: orderType,
            startDate: formattedStartDate,
            endDate: formattedEndDate,
            orderStatus: s);
      });
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  List<YearList> _yearList = [];
  int? _selectedYear;
  Future<void> fetchCustomerDashboardDataSalseData(String customerId) async {
    final now = DateTime.now();
    int currentYear = now.year;
    try {
      _customerTotalSaleResponseFuture =
          _apiService.fetchCustomerTotalSale(customerId, currentYear);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchCustomerDashboardRevenueData(String customerId) async {
    final now = DateTime.now();
    final startDate1 = DateTime(now.year, 1, 1);
    final endDate1 = DateTime(now.year, 12, 31);

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate1);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate1);
    int currentYear = now.year;

    try {
      _customerRevenueResponseFuture = _apiService.fetchCustomerRevenueData(
          customerId, currentYear, formattedStartDate, formattedEndDate);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchCustomerDashboardData(String customerId) async {
    final now = DateTime.now();
    final startDate1 = DateTime(now.year, 1, 1);
    final endDate1 = DateTime(now.year, 12, 31);

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate1);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate1);
    int currentYear = now.year;

    log('Start Date End Date $formattedStartDate, $formattedEndDate');

    try {
      _customersDashFuture = _apiService
          .fetchCustomerDashboardDataa(
              customerId, currentYear, formattedStartDate, formattedEndDate)
          .then((response) {
        _yearList = response.data.yearList;
        notifyListeners();
        return response;
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching customer dashboard data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void toggleOrderSelection(RecentOrder order) {
    if (_selectedOrders.contains(order)) {
      _selectedOrders.remove(order);
    } else {
      _selectedOrders.add(order);
    }
    notifyListeners();
  }

  bool isOrderSelected(RecentOrder order) {
    return _selectedOrders.contains(order);
  }

  Future<void> fetchCustomerData({int page = 1}) async {
    log("Filter type : " +
        (_selectedFilter == FilterDateEnum.range
            ? [_selectedFilter.name, _selectedStartDate, _selectedEndDate]
                .toString()
            : _selectedFilter.name));

    _errorMessage = '';
    NotificationController notificationController =
        Get.find<NotificationController>();

    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final customerBox = Hive.box('customerBox');
    final cacheKey = '${companyId}_customer_list_$page';
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      log('[fetchCustomerData] Offline mode. Looking for cacheKey: $cacheKey');

      // If there's an active search query, perform offline search
      if (_searchCustomerName.isNotEmpty) {
        log('[fetchCustomerData] Offline search mode with query: $_searchCustomerName');
        await performOfflineSearch(_searchCustomerName);
        return;
      }

      final cachedData = customerBox.get(cacheKey);
      if (cachedData != null) {
        try {
          // This safely converts the Hive-stored map into a Map<String, dynamic>
          final safeMap =
              jsonDecode(jsonEncode(cachedData)) as Map<String, dynamic>;

          final response = CustomerResponseModelxx.fromJson(safeMap);
          log('[fetchCustomerData] Loaded [${response.data.length}] customers from cacheKey: $cacheKey');
          setCustomers(response.data, response.pagination.totalPages);
          setOrderTotal(response.orderTotal);
          setYearList(response.yearsListOfAll);
          _isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          log('[fetchCustomerData] Error parsing cached data for page $page: $e');
          _filteredCustomers = [];
          _errorMessage = 'Corrupted offline data for this page.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      } else {
        log('[fetchCustomerData] No cached data for page $page');
        _filteredCustomers = [];
        _errorMessage = 'No offline data for this page.';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    if (_selectedFilter == FilterDateEnum.thisMonth ||
        _selectedFilter == FilterDateEnum.today ||
        _selectedFilter == FilterDateEnum.thisWeek ||
        _selectedFilter == FilterDateEnum.thisYear ||
        _selectedFilter == FilterDateEnum.range) {
      try {
        _isLoading = true;
        log("fetchCustomer query : $_searchCustomerName");
        final dynamic valueFromDw = _selectedFilter == FilterDateEnum.range
            ? [_selectedFilter.name, _selectedStartDate, _selectedEndDate]
            : _selectedFilter.name;

        log('Final valueFromDw sent to API: $valueFromDw');

        _customersFuture = _apiService.fetchCustomer(
          salesmanId: '',
          customerName: _searchCustomerName,
          startDate: "",
          endDate: "",
          limit: 10,
          page: page,
          valueFromDw: valueFromDw,
        );
        log('Selecetd Filters : $_selectedFilter');
        _customersFuture!.then((value) {
          setCustomers(value.data, value.pagination.totalPages);
          setOrderTotal(value.orderTotal);
          setYearList(value.yearsListOfAll);
          log('year list : ${value.yearsListOfAll.first.orderYears ?? ''}');
          // notificationController.loadNotificationData();
          _isLoading = false;
          notifyListeners();
        }).catchError((error) {
          _isLoading = false;
          _errorMessage = 'Failed to fetch customer data 3: $error';
          notifyListeners();
        });
      } catch (e, stackTrace) {
        _isLoading = false;
        _logger.e('Error fetching customers', error: e, stackTrace: stackTrace);
        rethrow;
      }
    } else {
      await fetchCustomerData();
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate.isNotEmpty
              ? DateTime.parse(_selectedStartDate)
              : DateTime.now())
          : (_selectedEndDate.isNotEmpty
              ? DateTime.parse(_selectedEndDate)
              : DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = pickedDate.toIso8601String().substring(0, 10);

      if (isStartDate) {
        _selectedStartDate = formattedDate;
      } else {
        _selectedEndDate = formattedDate;
      }
      if (_selectedFilter == FilterDateEnum.range &&
          _selectedStartDate.isNotEmpty &&
          _selectedEndDate.isNotEmpty) {}

      notifyListeners();
    }
  }

  void onFilterChanged(FilterDateEnum? selectedFilter) {
    NotificationController notificationController =
        Get.find<NotificationController>();
    if (selectedFilter != null) {
      _selectedFilter = selectedFilter;
      _errorMessage = ''; // Clear previous error messages
      if (_selectedFilter != FilterDateEnum.range) {
        _selectedStartDate = '';
        _selectedEndDate = '';
      } else {
        if (_selectedStartDate.isEmpty) {
          _selectedStartDate =
              DateTime.now().toIso8601String().substring(0, 10);
        }
        if (_selectedEndDate.isEmpty) {
          _selectedEndDate = DateTime.now().toIso8601String().substring(0, 10);
        }
      }

      final now = DateTime.now();

      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          _selectedStartDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          _selectedEndDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          _selectedStartDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          _selectedEndDate = _selectedStartDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _selectedStartDate = startOfWeek.toIso8601String().substring(0, 10);
          _selectedEndDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          _selectedStartDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          _selectedEndDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          break;
      }

      if (selectedFilter != FilterDateEnum.range) {
        fetchCustomerData();
        notificationController.loadNotificationData(
            _selectedStartDate, _selectedEndDate);
      }
      notifyListeners();
    }
  }

  void goToNextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;

      // Check if we're offline and have an active search
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline && _searchCustomerName.isNotEmpty) {
        // For offline search, all results are already loaded, just update the UI
        notifyListeners();
      } else {
        fetchCustomerData(page: _currentPage);
      }
    }
  }

  void goToPreviousPage() async {
    if (_currentPage > 1) {
      _currentPage--;

      // Check if we're offline and have an active search
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline && _searchCustomerName.isNotEmpty) {
        // For offline search, all results are already loaded, just update the UI
        notifyListeners();
      } else {
        fetchCustomerData(page: _currentPage);
      }
    }
  }

  void refreshCurrentPage() async {
    _errorMessage = ''; // Clear error message on refresh

    // Check if we're offline and have an active search
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline && _searchCustomerName.isNotEmpty) {
      // For offline search, just update the UI since all results are already loaded
      log('[refreshCurrentPage] Offline search mode - just updating UI');
      notifyListeners();
    } else {
      fetchCustomerData(page: _currentPage);
    }
  }

  /// Handles pagination for offline search results
  void goToNextPageOffline() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      // For offline search, we don't need to fetch new data since all results are already loaded
      notifyListeners();
    }
  }

  void goToPreviousPageOffline() {
    if (_currentPage > 1) {
      _currentPage--;
      // For offline search, we don't need to fetch new data since all results are already loaded
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Clears the search query and resets to normal browsing mode
  void clearSearch() async {
    _searchCustomerName = '';
    _currentPage = 1;
    _errorMessage = '';

    // Clear search controller if it exists
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }

    // Reload data based on connectivity
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      await loadCachedDataForCurrentPage();
    } else {
      await fetchCustomerData();
    }
  }

  /// Handles pagination clicks for both online and offline modes
  void handlePaginationClick(int page) async {
    log('[handlePaginationClick] Page: $page, Current page: $_currentPage, Search: $_searchCustomerName');

    if (page == _currentPage) return; // No change needed

    _currentPage = page;
    log('[handlePaginationClick] Updated current page to: $_currentPage');

    // Check if we're offline and have an active search
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline && _searchCustomerName.isNotEmpty) {
      // For offline search, just update the UI since all results are already loaded
      log('[handlePaginationClick] Offline search mode - just updating UI');
      log('[handlePaginationClick] Total customers: ${_customers.length}, Total pages: $_totalPages');
      logCurrentState();
      notifyListeners();
    } else {
      // For normal browsing or online search, fetch data for the new page
      log('[handlePaginationClick] Online mode - fetching data for page: $page');
      fetchCustomerData(page: page);
    }
  }

  // Future<void> addEvent(
  //     String customerId, int eventStatus, List<String> daysList) async {
  //   final success =
  //       await _apiService.addEvent(customerId, eventStatus, daysList);
  //   if (success) {
  //   } else {}
  //   notifyListeners();
  // }

  Future<AddEvent> addEvent(
    String customerId,
    int eventStatus,
    List<String> daysList,
    String period,
    BuildContext context,
  ) async {
    final response = await _apiService.addEvent(
        customerId, eventStatus, daysList, period, context);
    // notifyListeners(); // Keep this if needed
    return response;
  }

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  /// Debug method to log current state
  void logCurrentState() {
    log('[logCurrentState] Current page: $_currentPage, Total pages: $_totalPages');
    log('[logCurrentState] Search query: "$_searchCustomerName"');
    log('[logCurrentState] Total customers: ${_customers.length}, Filtered customers: ${_filteredCustomers.length}');
    log('[logCurrentState] Current page customers: ${getCurrentPageCustomers().length}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
